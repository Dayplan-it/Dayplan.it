from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.status import HTTP_200_OK
from .recom_place_module import *

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


class PlaceRecommand(APIView):

    """
    lng, lat값과 place_type을 받아
    convex_hull을 5분, 10분, 15분, 20분 단위로 생성,
    각 장소별로 convex_hull값을 부여하는 API
    """

    def get(self, request):
        # 예시데이터
        #lng = 126.99446459234908
        #lat = 37.534638765751424
        lng = request.query_params[PARAM_PLACE_LNG]
        lat = request.query_params[PARAM_PLACE_LAT]
        place_type = request.query_params[PARAM_PLACE_TYPE]
        # 기준위치와 가장 가까운 노드를 결정한다.
        closest_node, S = extract_closest_node(lng, lat)
        # nearby로 장소를 가져온다.(타입입력가능)
        places_gdf = get_nearby_place(lng, lat, place_type)
        # 노드를 기준으로 20분,15분거리, 10분거리, 5분거리 컨벡스홀을 반환한다.
        convex_gdf = get_convexhull(closest_node, S)
        # 데이터프레임에 distnace정보 삽입

        for minutes in [20, 15, 10, 5]:
            for index, row in places_gdf.iterrows():
                if row['geometry'].within(convex_gdf.loc[convex_gdf['minute'] == minutes, 'geometry'].iloc[0]):
                    row['minute'] = minutes
        places_gdf = places_gdf.fillna(25).to_wkt()
        print(places_gdf.keys())

        # Dataframe을 바로 JSON으로 렌더링하면 dict로 바뀌는 과정에서 key별로 생성이 돼버림
        # 따라서, row별로 dict들의 array로 바꿔주는 과정이 필요

        places_ordered = [row.to_dict()
                          for index, row in places_gdf.iterrows()]

        return Response(places_ordered, status=HTTP_200_OK)


class PlaceDetail(APIView):

    """
    place_id를 받아 장소의 자세한 정보를 주는 API
    """

    def get(self, request):
        # 예시데이터
        # ChIJKbC0o06ifDURYATbX7adyKg
        place_id = request.query_params[PARAM_PLACE_ID]

        return Response(place_detail(place_id), status=HTTP_200_OK)


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

    def get(self, request):
        # 두 지점의 위치정보와 이동타입을 를 쿼리로 입력
        lng_ori = request.query_params[PARAM_ROUTE_LNG_ORI]
        lat_ori = request.query_params[PARAM_ROUTE_LAT_ORI]
        lng_dest = request.query_params[PARAM_ROUTE_LNG_DEST]
        lat_dest = request.query_params[PARAM_ROUTE_LAT_DEST]

        # 쿼리에서 이동타입을 입력해줘도되고 안해줘도 가능
        if request.query_params in ['route_type']:
            route_type = request.query_params[PARAM_ROUTE_TYPE]
            result = pointroute(lng_ori, lat_ori, lng_dest,
                                lat_dest, mode=route_type)
        else:
            result = pointroute(lng_ori, lat_ori, lng_dest,
                                lat_dest)
        # route type은 필수아님! 상황에 맞게 검색해주긴함

        return Response(result, status=HTTP_200_OK)
