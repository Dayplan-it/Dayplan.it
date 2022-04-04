import json
import requests
import pandas as pd
import geopandas as gpd
from django.db import connection
from django.conf import settings


def extract_closest_node(lng, lat):
    """
    가장 가까운 노드를 찾는 함수
    가장 가까운 노드의 번호를 리턴
    """

    query_extract_node = f"select strt_node_\
                    from(\
                    SELECT \
                        strt_node_,\
                        ST_DISTANCE(\
                            geom,\
                            'SRID={4326};POINT({lng} {lat})'::geometry\
                        ) AS distance\
                    FROM \
                        link2\
                    ORDER BY\
                        distance\
                    LIMIT 1\
                    ) as a"
    with connection.cursor() as cursor:
        cursor.execute(query_extract_node)
        row = cursor.fetchone()
    result = row[0]
    return int(result)


def get_convexhull(node):
    """
    Travel Time 기준으로 convexhull을 찾는 함수
    """

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
                                    1000) a) c) \
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
                                    667) a) c)\
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
                                    333) a) c)\
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
                                    132) a) c)"
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
    convex_gdf = gpd.GeoDataFrame(data, geometry='geometry')
    convex_gdf.set_crs(epsg=4326, inplace=True)
    return convex_gdf


def get_nearby_place(lng, lat, type, distance=3000):
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
    # main branch settings에 SRID가 있음
    return gdf

def place_detail(place_id):

    
    nearbystr = 'https://maps.googleapis.com/maps/api/place/details/json'\
        + f'?location={str(lat)},{str(lng)}'\
        + '&type='+type\
        + '&radius='+str(distance)\
        + '&key='+settings.GOOGLE_API_KEY