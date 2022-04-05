## Find Schedule API

### request

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
