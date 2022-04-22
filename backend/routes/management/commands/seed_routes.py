import random
import json
import datetime
from time import sleep, mktime
import requests
from pathlib import Path
from django.core.management.base import BaseCommand
from django.contrib.gis.geos import Point, LineString
from django.conf import settings
from core.functions.polyline4postgis import PolylineDecoderForPostGIS
# PostGIS를 위한 polyline decoder
from routes import models as route_models
from schedules import models as schedule_models


NAME = "Routes"


class Command(BaseCommand):

    help = f'Create {NAME} for all schedules'

    def handle(self, *args, **options):
        all_schedules = schedule_models.Schedule.objects.all()

        with open(Path(Path(__file__).parent.parent, 'data/FAKE_DATA/data_seoul.json')) as f:
            dummy_places = json.load(f)

            for schedule in all_schedules.iterator():
                orders_selected_by_schedule = schedule_models.Order.objects.filter(
                    schedule_id=schedule.id).order_by("serial")

                # 무작위로 Place 고르기
                selected_dummy_places = []
                order_for_dummy_places = []
                order_for_dummy_routes = []

                for order in orders_selected_by_schedule.iterator():
                    if order.is_place:
                        while True:
                            random_place = random.choice(dummy_places)
                            if random_place not in selected_dummy_places:
                                selected_dummy_places.append(random_place)
                                break
                        order_for_dummy_places.append(order)
                        # 아직 다음 일정 시작시간은
                        # Route의 duration을 모르므로 Place 릴레이션에는 저장할 수 없음
                    else:
                        order_for_dummy_routes.append(order)

                # 위에서 고른 selected_dummy_places 기준으로 경로 검색 후
                # Route, Step, WalkingDetail, TransitDetail 저장
                previous_ends_at = datetime.time()
                created_Route = ""
                for i in range(0, len(selected_dummy_places)):
                    duration = datetime.timedelta(
                        hours=random.randint(1, 2))  # 1~2시간
                    if i == 0:
                        starts_at = datetime.time(random.randint(9, 10), random.randint(0, 59), random.randint(0, 59), 0, tzinfo=datetime.timezone(
                            datetime.timedelta(hours=9)))  # 9시 ~ 10시 59분 사이 시작
                    else:
                        starts_at = datetime.time(previous_ends_at.hour, previous_ends_at.minute, previous_ends_at.second, previous_ends_at.microsecond, tzinfo=datetime.timezone(
                            datetime.timedelta(hours=9)))  # 이전 경로의 도착시간 (previous_ends_at)

                    ends_at = (datetime.datetime.combine(
                        schedule.date, starts_at) + duration).time()

                    # Place 생성
                    try:
                        created_Place = route_models.Place.objects.create(
                            schedule_order=order_for_dummy_places[i],
                            starts_at=starts_at,
                            ends_at=ends_at,
                            duration=duration,
                            place_name=selected_dummy_places[i]["name"],
                            place_id=selected_dummy_places[i]["place_id"],
                            place_type=selected_dummy_places[i]["place_type"],
                            place_geom=Point(
                                x=selected_dummy_places[i]["lng"], y=selected_dummy_places[i]["lat"], srid=settings.SRID)
                        )
                    except:
                        return self.stdout.write(self.style.ERROR('ERROR : 이미 생성된 스케쥴이 있습니다.'))

                    if i > 0:
                        created_Route.end_place = created_Place
                        created_Route.save()

                    if i != len(selected_dummy_places)-1:
                        """
                        1. Route 생성
                        2. Route를 참조하는 Step(여러개일것임) 생성
                        3. Step을 참조하는 sub-Step들 (WalkingDetail, TransitDetail 등) 생성
                        """

                        origin = selected_dummy_places[i]["place_id"]
                        destination = selected_dummy_places[i+1]["place_id"]
                        departure_time = int(round(datetime.datetime.combine(
                            schedule.date, ends_at).timestamp()))  # Schedule의 날짜와 이전 일정의 끝나는 시간을 합쳐 DateTime
                        directions_url = f"https://maps.googleapis.com/maps/api/directions/json?origin=place_id:{origin}&destination=place_id:{destination}&mode=transit&departure_time={departure_time}&language=ko&key={settings.GOOGLE_API_KEY}"
                        response = requests.get(url=directions_url)

                        sleep(0.5)  # API 호출은 1초에 두번

                        if json.loads(response.text)["status"] == "ZERO_RESULTS":
                            directions_url = f"https://maps.googleapis.com/maps/api/directions/json?origin=place_id:{origin}&destination=place_id:{destination}&mode=walking&departure_time={departure_time}&language=ko&key={settings.GOOGLE_API_KEY}"
                            response = requests.get(url=directions_url)
                            sleep(0.5)

                        if json.loads(response.text)["status"] == "ZERO_RESULTS":
                            self.stdout.write(self.style.ERROR(
                                f'ERROR : {order_for_dummy_routes[i].schedule.user.id}번 유저의 {mktime(order_for_dummy_routes[i].schedule.date.timetuple())} 스케줄 {order_for_dummy_routes[i].serial}번째 Order인 Route는 Google Directions API로는 경로를 찾을 수 없음'))
                            continue

                        routes_legs = json.loads(response.text)[
                            "routes"][0]["legs"][0]

                        overview_polyline = json.loads(
                            response.text)["routes"][0]["overview_polyline"]["points"]

                        previous_ends_at = datetime.datetime.fromtimestamp(
                            routes_legs["arrival_time"]["value"]).time()  # 다음 Place 일정 생성을 위해 저장, 현재 생성중인 Route에도 ends_at으로 들어감
                        duration = datetime.timedelta(
                            seconds=routes_legs["duration"]["value"])

                        # 1. Route 생성

                        created_Route = route_models.Route.objects.create(
                            schedule_order=order_for_dummy_routes[i],
                            starts_at=ends_at,
                            ends_at=datetime.datetime.fromtimestamp(
                                routes_legs["arrival_time"]["value"]).time(),

                            # start_addr=routes_legs["start_address"],
                            start_name=selected_dummy_places[i]['name'],
                            start_place=created_Place,
                            # end_addr=routes_legs["end_address"],
                            end_name=selected_dummy_places[i+1]['name'],
                            end_place=created_Place,  # 임시로 이렇게 집어넣고, 다음 Place 생성시에 Update로 정정

                            duration=duration,
                            distance=float(
                                routes_legs["distance"]["value"] / 1000),
                            start_loc=Point(
                                x=selected_dummy_places[i]["lng"], y=selected_dummy_places[i]["lat"], srid=settings.SRID),
                            end_loc=Point(
                                x=selected_dummy_places[i+1]["lng"], y=selected_dummy_places[i+1]["lat"], srid=settings.SRID),
                            poly_line=LineString(
                                PolylineDecoderForPostGIS(overview_polyline).get(), srid=settings.SRID)
                        )

                        # 2. Step 생성

                        for j in range(0, len(routes_legs["steps"])):
                            travel_mode = 'WK' if routes_legs["steps"][j]["travel_mode"] == 'WALKING' else (
                                'TR' if routes_legs["steps"][j]["travel_mode"] == 'TRANSIT' else 'DR')
                            current_step = routes_legs["steps"][j]
                            created_step = route_models.Step.objects.create(
                                duration=datetime.timedelta(
                                    seconds=current_step["duration"]["value"]),
                                distance=float(
                                    current_step["distance"]["value"] / 1000),
                                start_loc=Point(
                                    x=current_step["start_location"]["lng"], y=current_step["start_location"]["lat"], srid=settings.SRID),
                                end_loc=Point(
                                    x=current_step["end_location"]["lng"], y=current_step["end_location"]["lat"], srid=settings.SRID),
                                poly_line=LineString(
                                    PolylineDecoderForPostGIS(current_step["polyline"]["points"]).get(), srid=settings.SRID),
                                serial=j,
                                route=created_Route,
                                instruction=current_step["html_instructions"],
                                travel_mode=travel_mode
                            )

                            # sub-Step 생성
                            """
                                WalkingDetail은 삭제됨
                            """
                            # if travel_mode == 'WK':  # create WalkingDetail as sub-Step Relation
                            #     for k in range(0, len(routes_legs["steps"][j]["steps"])):
                            #         current_substep = routes_legs["steps"][j]["steps"][k]

                            #         try:
                            #             route_models.WalkingDetail.objects.create(
                            #                 duration=datetime.timedelta(
                            #                     seconds=current_substep["duration"]["value"]),
                            #                 distance=float(
                            #                     current_substep["distance"]["value"] / 1000),
                            #                 start_loc=Point(
                            #                     x=current_substep["start_location"]["lng"], y=current_substep["start_location"]["lat"], srid=settings.SRID),
                            #                 end_loc=Point(
                            #                     x=current_substep["end_location"]["lng"], y=current_substep["end_location"]["lat"], srid=settings.SRID),
                            #                 poly_line=LineString(
                            #                     polyline.decode(current_substep["polyline"]["points"])),
                            #                 serial=k,
                            #                 walking_step=created_step
                            #             )
                            #         except ValueError:
                            #             route_models.WalkingDetail.objects.create(
                            #                 duration=datetime.timedelta(
                            #                     seconds=current_substep["duration"]["value"]),
                            #                 distance=float(
                            #                     current_substep["distance"]["value"] / 1000),
                            #                 start_loc=Point(
                            #                     x=current_substep["start_location"]["lng"], y=current_substep["start_location"]["lat"], srid=settings.SRID),
                            #                 end_loc=Point(
                            #                     x=current_substep["end_location"]["lng"], y=current_substep["end_location"]["lat"], srid=settings.SRID),
                            #                 poly_line=Point(
                            #                     polyline.decode(current_substep["polyline"]["points"])[0]),
                            #                 serial=k,
                            #                 walking_step=created_step
                            #             )

                            if travel_mode == 'TR':
                                current_substep = routes_legs["steps"][j]["transit_details"]
                                route_models.TransitDetail.objects.create(
                                    transit_step=created_step,
                                    transit_type='SUB' if current_substep["line"][
                                        "vehicle"]["type"] == 'SUBWAY' else 'BUS',
                                    transit_name=current_substep["line"]["name"],
                                    transit_short_name=current_substep["line"]["short_name"],

                                    departure_stop_name=current_substep["departure_stop"]["name"],
                                    departure_stop_loc=Point(
                                        x=current_substep["departure_stop"]["location"]["lng"], y=current_substep["departure_stop"]["location"]["lat"], srid=settings.SRID),
                                    departure_time=datetime.datetime.fromtimestamp(
                                        current_substep["departure_time"]["value"]).time(),

                                    arrival_stop_name=current_substep["arrival_stop"]["name"],
                                    arrival_stop_loc=Point(
                                        x=current_substep["arrival_stop"]["location"]["lng"], y=current_substep["arrival_stop"]["location"]["lat"], srid=settings.SRID),
                                    arrival_time=datetime.datetime.fromtimestamp(
                                        current_substep["arrival_time"]["value"]).time(),

                                    num_stops=current_substep["num_stops"],
                                    transit_color=current_substep["line"]["color"]
                                )

        self.stdout.write(self.style.SUCCESS(f"{NAME} created!"))


"""
순서

1. 스캐쥴을 가져옴
2. 스케쥴의 오더를 가져옴
3. 오더 수 따라 장소 무작위 추출 및 순서 주기
4. 상세 일정
    1. 첫번쨰 장소의 시작시간 및 duration 설정 Place
    2. 둘째장소로의 경로검색 및 저장 Route, Step, WalkingDetail, TransitDetail
    3. 둘째장소의 duration 설정
    ...
"""
