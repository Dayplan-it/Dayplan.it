## Find Schedule API

본 API 사용에 사용할 데이터는
`python manage.py get_sample_schedule` 커멘드를 이용해 뽑으면 손쉬운 테스트가 가능합니다.

### request **(GET)**

```
https://(Base URL)/schedules/find?**parameters**
```

#### Required parameters

- `user_id`
  찾으려는 User의 id, Integer 형식
- `date`
  스케쥴의 날짜, Timestamp 형식

#### Request URL 예시

```
http://127.0.0.1:8000/schedules/find?user_id=25&date=1651244400
```

### response

```json
{
    "created": 스케쥴 생성시각                     bigint,
    "updated": 스케쥴 수정시각                     bigint,
    "schedule_title": 스케쥴 제목                  char(50),
    "memo": 스케쥴 관련 내용                       text,
    "order":
        [
            {
                "order_serial": 스케쥴 순서                 integer,
                "type": 스케쥴 타입 (장소:"PL")             char(2),
                "detail": {
                    "starts_at": 스케쥴 시작시간              bigint,
                    "ends_at": 스케쥴 종료시간                bigint,
                    "duration": 스케쥴 소요시간(초단위)         bigint,
                    "place_name": 장소 이름                 char(50),
                    "place_type": 장소 종류                 char(50),
                    "point": {
                        "latitude": 장소의 위도                 float,
                        "longitude": 장소의 경도                float
                    },
                    "place_id": 장소 id (GoogleAPI용)       char(50)
                }
            },
            {
                "order_serial": 스케쥴 순서                 integer,
                "type": 스케쥴 타입 (경로:"RO")             char(2),
                "detail": {
                    "starts_at": 이동 시작시간              bigint,
                    "ends_at": 이동 종료시간                bigint,
                    "duration": 이동 소요시간(초단위)         bigint,
                    "distance": 이동 거리(KM단위)           float,
                    "polyline": 이동 경로(polyline형식)    text,
                    "step":
                        [
                            {
                                "travel_mode": 이동 수단(도보:"WK") char(2),
                                "duration": Step 소요시간(초단위)   bigint,
                                "distance": Step 이동 거리(KM단위)       float,
                                "instruction": Step 이동 안내(구글제공)  text,
                                "polyline": Step 이동 경로(polyline형식)    text,
                                // walking_detail은 삭제됨
                                // "walking_detail":
                                //     [
                                //         {
                                //             "duration": WalkingDetail 소요시간(초단위)   bigint,
                                //             "distance": WalkingDetail 이동 거리(KM단위)       float,
                                //             "polyline": Step 이동 경로(polyline형식)    text,
                                //         },
                                //         ...
                                //     ]
                            },
                            {
                                "travel_mode": 이동 수단(대중교통:"TR") char(2),
                                "duration": Step 소요시간(초단위)   bigint,
                                "distance": Step 이동 거리(KM단위)       float,
                                "instruction": Step 이동 안내(구글제공)  text,
                                "polyline": Step 이동 경로(polyline형식)    text,
                                "transit_detail": // transit_detail은 walking_detail과는 다르게 단일 객체
                                    {
                                        "transit_type": 대중교통 종류(버스:"BUS", 지하철:"SUB") char(3),
                                        "transit_name": 대중교통 호선 이름  char(10),
                                        "departure_stop_name": 출발역 이름  char(50),
                                        "departure_time": 출발시간          bigint,
                                        "arrival_stop_name": 도착역 이름  char(50),
                                        "arrival_time": 도착시간          bigint,
                                        "num_stops": 정류장 수               int,
                                        "transit_color": 호선 컬러          char
                                    }
                            },
                            ...
                        ]
                }
            },
            ...
        ]
}
```

#### Response 예시

[예시 Json 보기 (HTML File이므로 브라우저에서 열어보세요)](../../../examples/Find%20Schedule%20Api%20%E2%80%93%20Django%20REST%20framework.html)

## Create Schedule API

### request **(POST)**

```
https://(Base URL)/schedules/create
```

```json
// Body에 json을 아래 형식으로 넣어주면 됨
{
  "user_id": 10,
  "date": 1677405349,
  "schedule_title": "테스트 스케쥴",
  "memo": "Create Schedule이 제대로 작동하는지 확인용",
  "order": [
    {
      "type": "PL",
      "detail": {
        "starts_at": "10:18:10",
        "ends_at": "12:18:10",
        "duration": "02:00:00",
        "place_name": "(주)탐네커피",
        "place_type": "cafe",
        "point": {
          "latitude": 37.5228803,
          "longitude": 126.9931461
        },
        "place_id": "ChIJZdlnlS2ifDURkbzVn87QoOA"
      }
    },
    {
      "type": "RO",
      "detail": {
        "starts_at": "12:18:10",
        "ends_at": "12:45:03",
        "duration": "00:26:53",
        "distance": 1.543,
        "polyline": "ejbfW_u_dFrRbNfQHvLrArIJfAEhQqDo@iL"
      },
      "step": [
        {
          "travel_mode": "WK",
          "duration": "00:06:27",
          "distance": 0.386,
          "instruction": "서빙고역교차로까지 도보",
          "polyline": "ejbfW_u_dFrRdN"
        },
        {
          "travel_mode": "TR",
          "duration": "00:02:26",
          "distance": 0.918,
          "instruction": "버스 한국은행.신세계행",
          "polyline": "qvafWye_dF?AtCBpLDbANrJbArIJfAEfQqD@?@@",
          "transit_detail": {
            "transit_type": "BUS",
            "transit_name": "서울 간선버스",
            "departure_stop_name": "서빙고역교차로",
            "departure_time": "12:38:37",
            "arrival_stop_name": "국립중앙박물관용산가족공원",
            "arrival_time": "12:41:03",
            "num_stops": 1,
            "transit_color": "#374ff2"
          }
        },
        {
          "travel_mode": "WK",
          "duration": "00:04:00",
          "distance": 0.239,
          "instruction": "대한민국 서울특별시 용산구 용산동6가 168-6까지 도보",
          "polyline": "iw_fWgh_dFq@kL"
        }
      ]
    },
    {
      "type": "PL",
      "detail": {
        "starts_at": "12:45:03",
        "ends_at": "14:45:03",
        "duration": "02:00:00",
        "place_name": "거울못 식당",
        "place_type": "restaurant",
        "point": {
          "latitude": 37.5229846,
          "longitude": 126.9801372
        },
        "place_id": "ChIJFa09ASSifDURl-u59-W3kvM"
      }
    },
    {
      "type": "RO",
      "detail": {
        "starts_at": "14:45:03",
        "ends_at": "15:18:10",
        "duration": "00:33:07",
        "distance": 4.719,
        "polyline": "{x_fWsu_dFpJp[_Ex@uEn@yCVcCJa@IgOGQLcB?a@?QJCl@E~@Iz@]NmLg@{BIuC]u@I{@UyAa@iAa@gDmBuCqBqCsBIi@?QVk@BSTYnDIzBOBQDOfCOrBBpCAtDA`BFnEVRd@@VYTw@FkM]qAUeD?s@NmDNaDJaDA}BMk@QGS@UjAyMj@wCZ_AvD{GnA_CRy@Z_Dz@sOJk@Ho@f@gAB?uBrG"
      },
      "step": [
        {
          "travel_mode": "WK",
          "duration": "00:08:56",
          "distance": 0.535,
          "instruction": "이촌동점보아파트까지 도보",
          "polyline": "{x_fWsu_dFpJr["
        },
        {
          "travel_mode": "TR",
          "duration": "00:11:12",
          "distance": 4.023,
          "instruction": "버스 용산구청행",
          "polyline": "im_fW_y~cF?AA?}Dx@iAPkC\\iAJoAJC?_CJa@IgOGQLcB?a@?QJCj@?@CXAd@Iz@]Nk@CaKc@{BIuC]u@I{@UyAa@iAa@gDmBuCqBqCsBIi@?QVk@BSTY^?nCIzBOBQ@CBKrBMRApAB`@?nBA`@?tDA`BFlCL`AHRd@@VYTw@FiL[a@AC?mAUcA?aB?s@NmDNaDJaDAaAC{@IWGSIGS@UjAyMj@wCZ_AvD{GXi@t@uARy@Z_Dz@sOJk@Ho@f@gAB?",
          "transit_detail": {
            "transit_type": "BUS",
            "transit_name": "서울 간선버스",
            "departure_stop_name": "이촌동점보아파트",
            "departure_time": "15:03:59",
            "arrival_stop_name": "용산구청.크라운호텔",
            "arrival_time": "15:15:11",
            "num_stops": 5,
            "transit_color": "#374ff2"
          }
        },
        {
          "travel_mode": "WK",
          "duration": "00:02:42",
          "distance": 0.161,
          "instruction": "대한민국 서울특별시 용산구 이태원1동 장문로 12까지 도보",
          "polyline": "a~afWscadFuBrG"
        }
      ]
    },
    {
      "type": "PL",
      "detail": {
        "starts_at": "15:18:10",
        "ends_at": "17:18:10",
        "duration": "02:00:00",
        "place_name": "스타벅스 동빙고점",
        "place_type": "cafe",
        "point": {
          "latitude": 37.52896399999999,
          "longitude": 126.991805
        },
        "place_id": "ChIJbZsk_jOifDURMpqal2_w3XQ"
      }
    }
  ]
}
```

### response

제대로 생성되었을 경우 생성된 데이터의 id를 아래처럼 반환합니다.

```json
{
  "created_schedule_id": 79,
  "created_order_id": [299, 301, 303],
  "created_place_id": [425, 426, 427],
  "created_route_id": [292, 293],
  "created_step_id": [847, 848, 849, 850, 851, 852],
  "created_transit_detail_id": [285, 286]
}
```

## Delete Schedule API

### requset **(DELETE)**

```
http://127.0.0.1:8000/schedules/delete
```

Body에 `user_id`와 `date`(Timestamp)를 넣어주면 됩니다.

### response

제대로 삭제되었을 경우 (아래는 [Create Schedule API 예시](#create-schedule-api)에서 생성한 스케쥴을 지우는 경우)

```json
{
  "message": "wilsonrachel의 2023-02-26 스케쥴 '테스트 스케쥴' 삭제"
}
```
