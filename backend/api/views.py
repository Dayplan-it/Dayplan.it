from django.http import JsonResponse
from api import calmodule
from rest_framework.response import Response
from rest_framework.views import APIView
import json
from . import calmodule
import geopandas as gpd
import requests

# 장소유형을 리스트로 만들기
# 구글 place_type 참고하여 만듬
place_type = [
    (0, 'bowling_alley', '볼링장'),
    (1, 'cafe', '카페'),
    (2, 'car_repair', '자동차수리'),
    (3, 'car_wash', '세차장'),
    (4, 'church', '교회'),
    (5, 'department_store', '백화점'),
    (6, 'drugstore', '약국1'),
    (7, 'gym', '헬스장'),
    (8, 'hospital', '병원'),
    (9, 'laundry', '세탁소'),
    (10, 'pharmacy', '약국2'),
    (11, 'police', '경찰'),
    (12, 'post_office', '우체국'),
    (13, 'restaurant', '식당'),
    (14, 'convenience_store', '편의점'),
    (15, 'supermarket', '마트')
]


'''
=================
input
1. 추천 기준 위치    -   
2. 장소타입
3. 
'''


class recommandplaceAPI(APIView):
    def post(self, request):

        # (전 일정의 위치) + (현재일정 type)을 기준으로 2km nearbyAPI
        # ==================================================
        nearbystr = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'\
            + '?location=' + str(위도)+','+str(경도)\
            + '&radius='+str(2000)\
            + '&type='+place_type[13][1]\
            + '&key=YOUR_API_KEY'
        response = requests.get(nearbystr)
        data = json.loads(response.text)
        #맛집목록 리스트
        result = data['result']
        # 보행로 데이터를 이용한 걷는 거리와 시간 분류
        # ==================================================
        # 서울 도로구간데이터 불러오기
        link_data = gpd.read_file(
            'api/shp/Z_KAIS_TL_SPRD_MANAGE_11000.shp', encoding='utf-8')

        # 사용자 취향을 반영
        # ===================================================

        # response전에 dictionary형태로 변환하고 JsonResponse
        # ==================================================
        M = dict(zip(range(1, len(all_result) + 1), all_result))
        return JsonResponse(M, status=200)
