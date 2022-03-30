import requests
import json

# =========================================
#       두 위치 사이의 경로 정보
# =========================================
# INPUT :ori_lng - 출발지 경도
#       ori_lat - 출발지 위도
#       des_lng - 도착지 경도
#       des_lat - 도착지 위도
#       mode    - 대중교통(transit), 자동차(driving), 도보(walking)
#       depart_time - 출발시간

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
# ===========================================


def pointroute(ori_lng, ori_lat, des_lng, des_lat, mode='transit', depart_time='now'):
    URL = 'https://maps.googleapis.com/maps/api/directions/json?'\
        'origin='+str(ori_lat)+','+str(ori_lng) + '&'\
        'destination='+str(des_lat)+','+str(des_lng)+'&'\
        'mode='+mode+'&'\
        'departure_time='+depart_time+'&key=AIzaSyAh5evFBv_28Sa0-d45pyrVpTvXaxfuSlI'
    response = requests.get(URL)
    data = json.loads(response.text)
    return data['routes'][0]['legs'][0]
