from rest_framework.views import APIView
from rest_framework.response import Response
from django.http import JsonResponse
from rest_framework.status import HTTP_400_BAD_REQUEST, HTTP_200_OK
from .recom_place_module import *

# Define Param Names
PARAM_PLACE_TYPE = 'place_type'
PARAM_PLACE_LNG = 'lng'
PARAM_PLACE_LAT = 'lat'
PARAM_PLACE_ID = 'place_id'
class PlaceRecommand(APIView):
    
    def get(self, request):
        # 예시데이터
        #lng = 126.99446459234908
        #lat = 37.534638765751424
        lng =request.query_params[PARAM_PLACE_LNG]
        lat =request.query_params[PARAM_PLACE_LAT]
        place_type = request.query_params[PARAM_PLACE_TYPE]
        # 기준위치와 가장 가까운 노드를 결정한다.
        closest_node = extract_closest_node(lng, lat)
        # nearby로 장소를 가져온다.(타입입력가능)
        places_gdf = get_nearby_place(lng, lat, place_type)
        # 노드를 기준으로 20분,15분거리, 10분거리, 5분거리 컨벡스홀을 반환한다.
        convex_gdf = get_convexhull(closest_node)
        # 데이터프레임에 distnace정보 삽입
        for minutes in [20, 15, 10, 5]:
            for i in range(len(places_gdf)):
                if places_gdf['geometry'].iloc[i].within(convex_gdf.loc[convex_gdf['minute'] == minutes, 'geometry'].iloc[0]):
                    places_gdf['minute'].iloc[i] = minutes
        place_wkt = places_gdf.to_wkt()
        data = place_wkt.to_dict()
        return Response({'data': data}, status=HTTP_200_OK)



class PlaceDetail(APIView):
    def get(self, request):
        # 예시데이터
        #lng = 126.99446459234908
        #lat = 37.534638765751424
        place_id = request.query_params[PARAM_PLACE_ID]
        print(place_id)
        detail = place_detail(place_id)
        return Response({'data': detail}, status=HTTP_200_OK)
