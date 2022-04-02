from django.shortcuts import render, get_object_or_404, redirect, get_list_or_404
from rest_framework.views import APIView
from django.http import HttpResponse, JsonResponse
from .recom_place_module import *
import pandas as pd
import geopandas as gpd


class PlaceRecommand(APIView):
    def post(self, request):
        #예시데이터 
        #lng = 126.99446459234908
        #lat = 37.534638765751424
        data = json.loads(request.body)
        lng = data['lng']
        lat = data['lat']
        #기준위치와 가장 가까운 노드를 결정한다.
        closest_node = extract_closest_node(lng,lat)
        #nearby로 장소를 가져온다.(타입입력가능)
        places_gdf = get_nearby_place(lng,lat,'restaurant')
        #노드를 기준으로 20분,15분거리, 10분거리, 5분거리 컨벡스홀을 반환한다.
        convex_gdf = get_convexhull(closest_node)
        #데이터프레임에 distnace정보 삽입
        for m in [20,15,10,5]:
            for i in range(len(places_gdf)):
                if places_gdf['geometry'].iloc[i].within(convex_gdf.loc[convex_gdf['minute']==m,'geometry'].iloc[0]):
                    places_gdf['minute'].iloc[i]=m
        place_wkt = places_gdf.to_wkt()
        data = place_wkt.to_dict()
        return JsonResponse({'data': data}, json_dumps_params={'ensure_ascii': False}, status=200)
        
