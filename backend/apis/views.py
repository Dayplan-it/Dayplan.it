from unittest import result
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.status import HTTP_200_OK, HTTP_400_BAD_REQUEST
from .recom_place_module import *
from users.utils import LoginConfirm

# Define Param Names
PARAM_PLACE_TYPE = 'place_type'
PARAM_PLACE_LNG = 'lng'
PARAM_PLACE_LAT = 'lat'
PARAM_PLACE_ID = 'place_id'
PARAM_ROUTE_LNG_ORI = 'lng_ori'
PARAM_ROUTE_LAT_ORI = 'lat_ori'
PARAM_ROUTE_LNG_DEST = 'lng_dest'
PARAM_ROUTE_LAT_DEST = 'lat_dest'
PARAM_ROUTE_TYPE = 'route_type'
PARAM_QUERY_FOR_AUTOCOMPLETE = 'input'
PARAM_IS_RANKBY_DISTANCE = 'is_rankby_distance'
PARAM_SHOULD_GET_IMG = 'should_get_img'
PARAM_SHOULD_USE_DEPART_TIME = 'should_use_depart_time'
PARAM_TIME = 'time'


class PlaceRecommend(APIView):

    """
    lng, lat값과 place_type을 받아
    각 장소별로 convex_hull값을 부여하는 API
    """
    @LoginConfirm
    def get(self, request):
        # 예시데이터
        #lng = 126.99446459234908
        #lat = 37.534638765751424

        lng = request.query_params[PARAM_PLACE_LNG]
        lat = request.query_params[PARAM_PLACE_LAT]
        place_type = request.query_params[PARAM_PLACE_TYPE]
        # 기준위치와 가장 가까운 노드를 결정한다.
        start_node, S_start, end_node, S_end = extract_closest_node(lng, lat)
        # nearby+dijkstra로 걸리는 시간 계산
        places_gdf = get_nearby_place(start_node, lng, lat, place_type)
        places_gdf = places_gdf.fillna(5)
        places_ordered = [row.to_dict()
                          for index, row in places_gdf.iterrows()]

        return Response(places_ordered, status=HTTP_200_OK)


class PlaceDetail(APIView):

    """
    place_id를 받아 장소의 자세한 정보를 주는 API
    """

    @LoginConfirm
    def get(self, request):
        # 예시데이터
        # ChIJKbC0o06ifDURYATbX7adyKg
        place_id = request.query_params[PARAM_PLACE_ID]

        if PARAM_SHOULD_GET_IMG in request.query_params:
            shouldGetImg = request.query_params[PARAM_SHOULD_GET_IMG]
        else:
            shouldGetImg = False

        return Response(place_detail(place_id, shouldGetImg=shouldGetImg), status=HTTP_200_OK)


class MakeRoute(APIView):

    """
    두 지점간의 경로를 생성한다. walking으로 검색 후 결과 없으면 transit으로 변경하여 검색
    """

    # OUTPUT: (dict)
    #       x['arrival_time']     -도착시간
    #       x['departure_time']   -출발시간
    #       x['distance']         -총거리
    #       x['duration']         -소요시간
    #       x['end_address']      -도착장소주소
    #       x['start_address']    -출발장소주소
    #       x['end_location']     -도착장소좌표
    #       x['start_location']   -출발장소위치
    #
    #       x['steps']            -상세경로

    @LoginConfirm
    def get(self, request):
        # 두 지점의 위치정보와 이동타입을 를 쿼리로 입력
        lng_ori = request.query_params[PARAM_ROUTE_LNG_ORI]
        lat_ori = request.query_params[PARAM_ROUTE_LAT_ORI]
        lng_dest = request.query_params[PARAM_ROUTE_LNG_DEST]
        lat_dest = request.query_params[PARAM_ROUTE_LAT_DEST]

        should_use_depart_time = True
        if PARAM_SHOULD_USE_DEPART_TIME in request.query_params:
            should_use_depart_time = request.query_params[PARAM_SHOULD_USE_DEPART_TIME] == "true"

        time = None

        if PARAM_TIME in request.query_params:
            time = request.query_params[PARAM_TIME]
        else:
            time = "now"

        # 쿼리에서 이동타입을 입력해줘도되고 안해줘도 가능
        if PARAM_ROUTE_TYPE in request.query_params:
            route_type = request.query_params[PARAM_ROUTE_TYPE]
            result = pointroute(lng_ori, lat_ori, lng_dest,
                                lat_dest, mode=route_type, should_use_depart_time=should_use_depart_time, time=time)
        else:
            result = pointroute(lng_ori, lat_ori, lng_dest,
                                lat_dest, should_use_depart_time=should_use_depart_time, time=time)
        # route type은 필수아님! 상황에 맞게 검색해주긴함

        return Response(result, status=HTTP_200_OK)


class PlaceAutocomplete(APIView):

    """
    검색어의 자동완성을 위한 API
    """

    @LoginConfirm
    def get(self, request):
        inputStr = request.query_params[PARAM_QUERY_FOR_AUTOCOMPLETE]
        lat = request.query_params[PARAM_PLACE_LAT]
        lng = request.query_params[PARAM_PLACE_LNG]

        isRankByDistance = False
        if PARAM_IS_RANKBY_DISTANCE in request.query_params:
            isRankByDistance = request.query_params[PARAM_IS_RANKBY_DISTANCE] == "true"

        return Response(place_autocomplete(inputStr, lat, lng, isRankByDistance), status=HTTP_200_OK)


class FindAddressByLatLng(APIView):

    """
    좌표를 이용해 주소를 얻는 API
    """

    @LoginConfirm
    def get(self, request):
        lat = request.query_params[PARAM_PLACE_LAT]
        lng = request.query_params[PARAM_PLACE_LNG]

        return Response({"address": find_address_by_latlng(lat, lng)}, status=HTTP_200_OK)
