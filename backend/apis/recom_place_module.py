import json
import requests
import pandas as pd
import geopandas as gpd
from django.db import connection
from django.conf import settings
from urllib import parse


MAX_PHOTO_WIDTH = 600


def extract_closest_node(lng, lat):
    """
    가장 가까운 노드를 찾는 함수
    가장 가까운 노드의 번호를 리턴
    """
    query = f"SELECT streets.strt_node_, end_node_i,\
            streets.geom <-> 'SRID={settings.SRID};POINT({lng} {lat})'::geometry AS Distance\
            FROM link2 streets\
            ORDER BY Distance\
            LIMIT 1"
    with connection.cursor() as cursor:
        cursor.execute(query)
        row = cursor.fetchall()
    strt_node = int(row[0][0])
    dist = float(row[0][2])
    end_node = int(row[0][1])
    # 점에서 가장가까운 링크까지의 거리와 링크분할점에서 출발노드까지의 거리 보정상수
    # 사소한 오차 발견하여 임시적으로 시작노드까지의 거리 오차보정부분 삭제
    S_start = -dist
    S_end = -dist
    return strt_node, S_start, end_node, S_end


def dijkstra_distance(ori_lng, ori_lat, des_lng, des_lat):
    '''
    입력 : 출발도착좌표
    출력 : 둘 사이 다익스트라최단거리, 최단경로(Linestring)
    '''
    start_node, S_start, temp1, temp2 = extract_closest_node(ori_lng, ori_lat)
    temp3, temp4, end_node, S_end = extract_closest_node(des_lng, des_lat)
    query = f"select sum(cost)::float8 as cost, ST_AsEncodedPolyline(ST_LineMerge(ST_Union(geom))) as geom\
            from(SELECT cost,(SELECT geom FROM link2 b where b.link_id=a.edge::bigint) as geom\
            FROM pgr_dijkstra(\
            'SELECT link_id::int4 AS id,\
            strt_node_::int4 AS source,\
            end_node_i::int4 AS target,\
            link_len::float8 AS cost,\
            link_len::float8 AS reverse_cost\
            FROM link2',\
            {int(start_node)}, {int(end_node)},\
            FALSE) as a) as t"
    with connection.cursor() as cursor:
        cursor.execute(query)
        row = cursor.fetchone()
    distance = row[0]
    geom = row[1]
    # 거리보정
    corrected_distance = distance-S_start-S_end
    return corrected_distance, geom


def get_nearby_place(startNode, lng, lat, type, distance=1800):
    nearbystr = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'\
        + f'?location={str(lat)},{str(lng)}'\
        + '&type='+type\
        + '&radius='+str(distance)\
        + '&language=ko'\
        + '&key='+settings.GOOGLE_API_KEY
    # main branch settings에 GOOGLE_API_KEY가 있음

    response = requests.get(nearbystr)
    data = json.loads(response.text)

    # 맛집목록 리스트
    results = data['results']
    new_list = []

    # 좌표 목록!
    points = []
    # 사전형으로 변환
    for result in results:
        dic = {}
        dic['name'] = result['name']
        dic['lng'] = str(result['geometry']['location']['lng'])
        dic['lat'] = str(result['geometry']['location']['lat'])
        points.append(
            [str(result['geometry']['location']['lng']), str(result['geometry']['location']['lat'])])
        dic['place_id'] = result['place_id']
        dic['rating'] = result['rating'] if 'rating' in result else '-'
        dic['user_ratings_total'] = result['user_ratings_total'] if 'user_ratings_total' in result else '-'
        new_list.append(dic)

    # 이부분에서 걸리는 시간 받아서 데이터프레임 저장
    node_list = getMinuteList(points)
    cost = calMinute(node_list, startNode)

    for i in range(len(node_list)):
        for j in range(len(cost)):
            if node_list[i] == cost[j][0]:
                if cost[j][1]*0.015 <= 5:
                    new_list[i]['minute'] = 5
                elif cost[j][1]*0.015 > 5 and cost[j][1]*0.015 <= 10:
                    new_list[i]['minute'] = 10
                elif cost[j][1]*0.015 > 10 and cost[j][1]*0.015 <= 15:
                    new_list[i]['minute'] = 15
                elif cost[j][1]*0.015 > 15 and cost[j][1]*0.015 <= 20:
                    new_list[i]['minute'] = 20
                elif cost[j][1]*0.015 > 20:
                    new_list[i]['minute'] = 25
    # Geodataframe 변환
    df = pd.DataFrame(new_list, columns=[
                      'name', 'lng', 'lat', 'place_id', 'rating', 'user_ratings_total', 'minute'])

    return df


def getMinuteList(pointList):

    end_node_list = []
    for point in pointList:
        start_node, S_start, end_node, S_end = extract_closest_node(
            point[0], point[1])
        end_node_list.append(end_node)
    return end_node_list


def calMinute(nodeList, startNode):
    query = f"SELECT end_vid,max(agg_cost) FROM pgr_bddijkstra('\
                    SELECT link_id::int4 AS id,\
                    strt_node_::int4 AS source,\
                    end_node_i::int4 AS target,\
                    link_len::float8 AS cost,\
                    link_len::float8 AS reverse_cost\
                    FROM link2',\
                {startNode}, \
                ARRAY{nodeList},\
                FALSE) as a Join link2 as b on  a.edge=b.link_id\
                GROUP BY end_vid"

    with connection.cursor() as cursor:
        cursor.execute(query)
        row = cursor.fetchall()

    return row


def place_detail(place_id, shouldGetImg):
    detail_str = 'https://maps.googleapis.com/maps/api/place/details/json'\
        + '?place_id='+str(place_id)\
        + '&fields=formatted_address,name,geometry,review,photo,rating,user_ratings_total,international_phone_number&language=ko'\
        + '&key='+settings.GOOGLE_API_KEY
    response = requests.get(detail_str)
    data = json.loads(response.text)
    results = data['result']
    # EPSG : 900913
    lng = results['geometry']['location']['lng']
    lat = results['geometry']['location']['lat']
    name = results['name']
    if ('rating' in results.keys()):
        rating = results['rating']
        user_ratings_total = results['user_ratings_total']
    else:
        rating = []
        user_ratings_total = 0
    photo = []
    if (shouldGetImg):
        for i in results['photos'][:2]:
            photo_str = 'https://maps.googleapis.com/maps/api/place/photo'\
                + f'?maxwidth={MAX_PHOTO_WIDTH}'\
                + '&photo_reference='+i['photo_reference']\
                + '&key='+settings.GOOGLE_API_KEY
            photo.append(photo_str)

    reviews = []
    if ('reviews' in results.keys()):
        for i in results['reviews']:
            temp = {}
            temp['rating'] = i['rating']
            temp['text'] = i['text']
            temp['relative_time_description'] = i['relative_time_description']
            reviews.append(temp)

    # insta
    insta_str = f'https://www.instagram.com/explore/tags/{parse.quote(name)}/'

    # naver
    naver_str = f'https://search.naver.com/search.naver?where=nexearch&sm=top_hty&fbm=0&ie=utf8&query={parse.quote(name)}'

    detail_all = {}
    detail_all['lng'] = lng
    detail_all['lat'] = lat
    detail_all['name'] = name
    detail_all['rating'] = rating
    detail_all['user_ratings_total'] = user_ratings_total
    detail_all['photo'] = photo
    detail_all['reviews'] = reviews
    detail_all['insta_url'] = insta_str
    detail_all['naver_url'] = naver_str
    return detail_all

# 구글 api오류 수정
# from : 126.973031 37.523107
# to : 126.974964 37.521181
# API 만을 이용하는 함수


def pointroute(ori_lng, ori_lat, des_lng, des_lat, mode='default', depart_time='now'):
    '''
    최단경로 2500미터 이하 = 다익스트라 도보검색
    최단경로 2500미터 이상 = 대중교통 검색
    이동수단, 이동시간 입력가능 
    '''

    # 이동수단, 이동시간 수동조정시
    if mode != 'default':
        URL = 'https://maps.googleapis.com/maps/api/directions/json?'\
            'origin='+str(ori_lat)+','+str(ori_lng) + '&'\
            'destination='+str(des_lat)+','+str(des_lng)+'&'\
            'mode='+mode+'&'\
            'departure_time='+depart_time+'&key='+settings.GOOGLE_API_KEY
        response = requests.get(URL)
        data = json.loads(response.text)['routes'][0]['legs'][0]
        data["route_type"] = mode
        return data

    route = dijkstra_distance(ori_lng, ori_lat, des_lng, des_lat)
    distance = route[0]
    geom_wtk = route[1]
    # 최단거리가 2500미터 이하일 때 도보검색
    if distance <= 2500:
        return {"duration": {"text": f"{distance*0.015} mins"}, "distance": {"text": f"{distance/1000} km"}, "start_location": {"lat": ori_lat, "lng": ori_lng}, "end_location": {"lat": des_lat, "lng": des_lng}, "polyline": {"points": geom_wtk}, "route_type": "walking"}
    # 최단거리가 2500이상시 대중교통 검색
    else:

        URL = 'https://maps.googleapis.com/maps/api/directions/json?'\
            'origin='+str(ori_lat)+','+str(ori_lng) + '&'\
            'destination='+str(des_lat)+','+str(des_lng)+'&'\
            'mode='+'transit'+'&'\
            'departure_time='+depart_time+'&key='+settings.GOOGLE_API_KEY
        response = requests.get(URL)
        data = json.loads(response.text)['routes'][0]['legs'][0]
        data["route_type"] = 'transit'
        return data


def place_autocomplete(inputStr, lat, lng, isRankByDistance):
    '''
    장소 검색시 사용되는 구글의 AutoComplete API
    '''

    url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'\
        + f'input={inputStr}'\
        + f'&origin={lat} {lng}'\
        + f'&language=ko{"&rankby=distance" if isRankByDistance else ""}'\
        + f'&key={settings.GOOGLE_API_KEY}'
    response = requests.get(url)
    data = json.loads(response.text)

    return data
