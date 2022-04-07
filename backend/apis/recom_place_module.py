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

    query = f"select link_len as len,distance,strt_node_,ST_LineLocatePoint(ab.geom, 'SRID={settings.SRID};POINT({lng} {lat})'::geometry) as split,end_node_i\
            from (select ST_LineMerge(geom) as geom,link_len,distance,strt_node_,end_node_i\
            from(SELECT link_len,geom,strt_node_,end_node_i,ST_DISTANCE(ST_Transform(geom,2097),ST_Transform(ST_GeomFromText('SRID={settings.SRID};POINT({lng} {lat})', {settings.SRID}), 2097)) AS distance\
            FROM link2\
            ORDER BY distance\
            LIMIT 1) as a) as ab"
    with connection.cursor() as cursor:
        cursor.execute(query)
        row = cursor.fetchall()
    len = float(row[0][0])
    strt_node = int(row[0][2])
    seg = float(row[0][3])
    dist = float(row[0][1])
    end_node = float(row[0][4])
    # 점에서 가장가까운 링크까지의 거리와 링크분할점에서 출발노드까지의 거리 보정상수
    # 사소한 오차 발견하여 임시적으로 시작노드까지의 거리 오차보정부분 삭제
    S_start = -dist
    S_end = -dist
    return strt_node, S_start, end_node, S_end


def get_convexhull(node, S):
    """
    Travel Time 기준으로 convexhull을 찾는 함수
    """
    # 링크까지거리 보정
    query_extract_convexhull = f"(select 20::INTEGER as minute, ST_AsText(st_convexhull(st_union(geom))) as geom\
                                    from\
                                    (SELECT (SELECT geom FROM node2 b where b.node_id=a.node::bigint) as geom\
                                    FROM pgr_drivingDistance('\
                                        SELECT link_id::int4 AS id,\
                                        strt_node_::int4 AS source,\
                                        end_node_i::int4 AS target,\
                                        link_len::float8 AS cost,\
                                        link_len::float8 AS reverse_cost\
                                        FROM link2',\
                                    {node},\
                                    {1000+S}) a) c) \
                                    UNION\
                                    (select 15::INTEGER as gid, ST_AsText(st_convexhull(st_union(geom))) as geom\
                                    from\
                                    (SELECT (SELECT geom FROM node2 b where b.node_id=a.node::bigint) as geom\
                                    FROM pgr_drivingDistance('\
                                        SELECT link_id::int4 AS id,\
                                        strt_node_::int4 AS source,\
                                        end_node_i::int4 AS target,\
                                        link_len::float8 AS cost,\
                                        link_len::float8 AS reverse_cost\
                                        FROM link2',\
                                    {node},\
                                    {667+S}) a) c)\
                                    UNION\
                                    (select 10::INTEGER as gid, ST_AsText(st_convexhull(st_union(geom))) as geom\
                                    from\
                                    (SELECT (SELECT geom FROM node2 b where b.node_id=a.node::bigint) as geom\
                                    FROM pgr_drivingDistance('\
                                        SELECT link_id::int4 AS id,\
                                        strt_node_::int4 AS source,\
                                        end_node_i::int4 AS target,\
                                        link_len::float8 AS cost,\
                                        link_len::float8 AS reverse_cost\
                                        FROM link2',\
                                    {node},\
                                    {333+S}) a) c)\
                                    UNION\
                                    (select 5::INTEGER as gid, ST_AsText(st_convexhull(st_union(geom))) as geom\
                                    from\
                                    (SELECT (SELECT geom FROM node2 b where b.node_id=a.node::bigint) as geom\
                                    FROM pgr_drivingDistance('\
                                        SELECT link_id::int4 AS id,\
                                        strt_node_::int4 AS source,\
                                        end_node_i::int4 AS target,\
                                        link_len::float8 AS cost,\
                                        link_len::float8 AS reverse_cost\
                                        FROM link2',\
                                    {node},\
                                    {140+S}) a) c)"
    with connection.cursor() as cursor:
        cursor.execute(query_extract_convexhull)
        row = cursor.fetchall()

    geometry_temp = []
    minute_temp = []
    for i in range(4):
        geometry_temp.append(row[i][1])
        minute_temp.append(row[i][0])
    geometry_temp2 = gpd.GeoSeries.from_wkt(geometry_temp)
    data = {
        'minute': minute_temp,
        'geometry': geometry_temp2
    }
    convex_gdf = gpd.GeoDataFrame(
        data, geometry='geometry').set_crs(epsg=settings.SRID, inplace=True)
    return convex_gdf


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


def get_nearby_place(lng, lat, type, distance=1800):
    # 구글 place_type 참고하여 만듬
    # place_type = [
    #     (0, 'bowling_alley', '볼링장'),
    #     (1, 'cafe', '카페'),
    #     (2, 'car_repair', '자동차수리'),
    #     (3, 'car_wash', '세차장'),
    #     (4, 'church', '교회'),
    #     (5, 'department_store', '백화점'),
    #     (6, 'drugstore', '약국1'),
    #     (7, 'gym', '헬스장'),
    #     (8, 'hospital', '병원'),
    #     (9, 'laundry', '세탁소'),
    #     (10, 'pharmacy', '약국2'),
    #     (11, 'police', '경찰'),
    #     (12, 'post_office', '우체국'),
    #     (13, 'restaurant', '식당'),
    #     (14, 'convenience_store', '편의점'),
    #     (15, 'supermarket', '마트')
    # ]

    nearbystr = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'\
        + f'?location={str(lat)},{str(lng)}'\
        + '&type='+type\
        + '&radius='+str(distance)\
        + '&key='+settings.GOOGLE_API_KEY
    # main branch settings에 GOOGLE_API_KEY가 있음

    response = requests.get(nearbystr)
    data = json.loads(response.text)

    # 맛집목록 리스트
    results = data['results']
    new_list = []

    # 사전형으로 변환
    for result in results:
        dic = {}
        dic['name'] = result['name']
        dic['lng'] = str(result['geometry']['location']['lng'])
        dic['lat'] = str(result['geometry']['location']['lat'])
        dic['place_id'] = result['place_id']
        dic['rating'] = result['rating'] if 'rating' in result else '-'
        dic['user_ratings_total'] = result['user_ratings_total'] if 'user_ratings_total' in result else '-'
        new_list.append(dic)

    # Geodataframe 변환
    df = pd.DataFrame(new_list, columns=[
                      'name', 'lng', 'lat', 'place_id', 'rating', 'user_ratings_total', 'minute'])
    gdf = gpd.GeoDataFrame(
        df[['name', 'lng', 'lat', 'place_id',
            'rating', 'user_ratings_total', 'minute']],
        geometry=gpd.points_from_xy(df.lng, df.lat))
    gdf.set_crs(epsg=settings.SRID, inplace=True)

    return gdf


def place_detail(place_id):
    detail_str = 'https://maps.googleapis.com/maps/api/place/details/json'\
        + '?place_id='+str(place_id)\
        + '&fields=formatted_address,name,geometry,review,photo,rating,user_ratings_total,international_phone_number'\
        + '&key='+settings.GOOGLE_API_KEY
    response = requests.get(detail_str)
    data = json.loads(response.text)
    results = data['result']
    #EPSG : 900913
    lng = results['geometry']['location']['lng']
    lat = results['geometry']['location']['lat']
    name = results['name']
    rating = results['rating']
    user_ratings_total = results['user_ratings_total']
    photo = []
    for i in results['photos'][:2]:
        photo_str = 'https://maps.googleapis.com/maps/api/place/photo'\
            + f'?maxwidth={MAX_PHOTO_WIDTH}'\
            + '&photo_reference='+i['photo_reference']\
            + '&key='+settings.GOOGLE_API_KEY
        photo.append(photo_str)

    reviews = []
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

