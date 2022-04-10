from django.contrib.gis.geos import Point, LineString
from django.conf import settings
from routes.api.serializers import RouteSerializer, StepSerializer, TransitDetailSerializer, PlaceSerializer
from routes.api.serializers_post import PlaceSerializer as POST_PlaceSerializer, RouteSerializer as POST_RouteSerializer, StepSerializer as POST_StepSerializer, TransitDetailSerializer as POST_TransitDetailSerializer
from core.functions.polyline4postgis import PolylineDecoderForPostGIS
from schedules import models as schedule_models


KEY_ID = 'id'
KEY_POINT = 'point'
KEY_LATITUDE = 'latitude'
KEY_LONGITUDE = 'longitude'
KEY_POLYLINE = 'poly_line'
KEY_START_LOC = 'start_loc'
KEY_END_LOC = 'end_loc'
KEY_START_NAME = 'start_name'
KEY_END_NAME = 'end_name'
KEY_SCHEDULE_ORDER = 'schedule_order'
KEY_START_PLACE = 'start_place'
KEY_END_PLACE = 'end_place'
KEY_PLACE_NAME = 'place_name'
KEY_PLACE_GEOM = 'place_geom'
KEY_SERIAL = 'serial'
KEY_ROUTE = 'route'
KEY_DEPARTURE_STOP_LOC = 'departure_stop_loc'
KEY_ARRIVAL_STOP_LOC = 'arrival_stop_loc'
KEY_TRANSIT_STEP = 'transit_step'


def findPlace(order):
    return PlaceSerializer(order.place.get()).data


def findRoute(order):
    return RouteSerializer(order.route.get()).data


def findSteps(order):
    route = order.route.get()
    step_list = []

    for iter_step in route.steps.all().iterator():
        step = StepSerializer(iter_step).data

        # if step["travel_mode"] == "WK":
        #     step["walking_detail"] = []
        #     for walking_detail in iter_step.walking_details.iterator():
        #         step["walking_detail"].append(
        #             WalkingDetailSerializer(walking_detail).data)
        if step["travel_mode"] == "TR":
            step["transit_detail"] = TransitDetailSerializer(
                iter_step.transit_detail.get()).data

        # elif step["travel_mode"] == "DR":
        # 추후 필요하다면 운전 경로 관련 기능을 추가

        step_list.append(step)

    return step_list


def createPlace(order_id, place_detail):
    place_detail[KEY_PLACE_GEOM] = Point(
        x=place_detail[KEY_POINT][KEY_LONGITUDE], y=place_detail[KEY_POINT][KEY_LATITUDE], srid=settings.SRID)

    place_detail[KEY_SCHEDULE_ORDER] = order_id

    place_serialized = POST_PlaceSerializer(data=place_detail)
    if place_serialized.is_valid():
        place_serialized.save()
        return place_serialized.data


def createRoute(order_id, route_detail, start_place, end_place):
    route_detail[KEY_POLYLINE] = LineString(PolylineDecoderForPostGIS(
        route_detail.pop('polyline')).get(), srid=settings.SRID)

    route_detail[KEY_START_LOC] = start_place[KEY_PLACE_GEOM]
    route_detail[KEY_END_LOC] = end_place[KEY_PLACE_GEOM]

    route_detail[KEY_START_NAME] = start_place[KEY_PLACE_NAME]
    route_detail[KEY_END_NAME] = end_place[KEY_PLACE_NAME]

    route_detail[KEY_START_PLACE] = start_place[KEY_ID]
    route_detail[KEY_END_PLACE] = end_place[KEY_ID]

    route_detail[KEY_SCHEDULE_ORDER] = order_id

    route_serialized = POST_RouteSerializer(data=route_detail)

    if route_serialized.is_valid():
        route_serialized.save()
        return route_serialized.data


def createStep(route_id, serial, step):
    line = PolylineDecoderForPostGIS(
        step.pop('polyline')).get()

    step[KEY_POLYLINE] = LineString(line, srid=settings.SRID)
    step[KEY_START_LOC] = Point(x=line[0][1], y=line[0][0], srid=settings.SRID)
    step[KEY_END_LOC] = Point(x=line[len(line)-1][1],
                              y=line[len(line)-1][0], srid=settings.SRID)

    step[KEY_SERIAL] = serial

    step[KEY_ROUTE] = route_id

    step_serialized = POST_StepSerializer(data=step)
    if step_serialized.is_valid():
        step_serialized.save()
        return step_serialized.data


def createTransitDetail(step_id, transit_detail, depart_loc, arrive_loc):
    transit_detail[KEY_DEPARTURE_STOP_LOC] = depart_loc
    transit_detail[KEY_ARRIVAL_STOP_LOC] = arrive_loc

    transit_detail[KEY_TRANSIT_STEP] = step_id

    transit_detail_serialized = POST_TransitDetailSerializer(
        data=transit_detail)
    if transit_detail_serialized.is_valid():
        transit_detail_serialized.save()
        return transit_detail_serialized.data
