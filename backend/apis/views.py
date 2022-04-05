from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.status import HTTP_200_OK
from .recom_place_module import *

# Define Param Names
PARAM_PLACE_TYPE = 'place_type'
PARAM_PLACE_LNG = 'lng'
PARAM_PLACE_LAT = 'lat'
PARAM_PLACE_ID = 'place_id'


class PlaceRecommend(APIView):

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
            for i in range(len(places_gdf)):
                if places_gdf['geometry'].iloc[i].within(convex_gdf.loc[convex_gdf['minute'] == minutes, 'geometry'].iloc[0]):
                    places_gdf['minute'].iloc[i] = minutes
        places_gdf = places_gdf.fillna(25).to_wkt()

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
