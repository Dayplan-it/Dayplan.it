import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/class/route_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

///
/// ## 각 스케줄을 일컫는 객체
/// `Schedule`이 모여서 schedules가 됨.
///
/// 참고로 TimeOfDay는 제약사항이 많아
/// 본 앱에서는 TimeOfDay 대신 Duration을 TimeOfDay처럼 사용함

/// Place에 해당하는 클래스
class Place {
  Place(
      {required this.nameKor,
      required this.placeType,
      required this.color,
      required this.duration,
      this.isFixed = false,
      this.startsAt,
      this.endsAt,
      this.place,
      this.placeName,
      this.placeId});

  final String nameKor;
  final String placeType;
  final Color color;
  Duration duration;
  bool isFixed;
  DateTime? startsAt;
  DateTime? endsAt;
  LatLng? place;
  String? placeName;
  String? placeId;

  Place copy() => Place(
      nameKor: nameKor,
      placeType: placeType,
      color: color,
      duration: duration,
      startsAt: startsAt,
      endsAt: endsAt,
      isFixed: isFixed,
      place: place,
      placeName: placeName,
      placeId: placeId);

  double toHeight() {
    return durationToHeight(duration);
  }

  void changeAndSetStartsAt(DateTime startsAt) {
    this.startsAt = startsAt;
    endsAt = startsAt.add(duration);
  }

  void changeAndSetEndsAt(DateTime endsAt) {
    this.endsAt = endsAt;
    startsAt = endsAt.subtract(duration);
  }

  void changeDurationAndStartsAt(DateTime startsAt) {
    this.startsAt = startsAt;
    duration = endsAt!.difference(startsAt);
  }

  void changeDurationAndEndsAt(DateTime endsAt) {
    this.endsAt = endsAt;
    duration = endsAt.difference(startsAt!);
  }

  void setPlace(LatLng place, String placeName, String placeId) {
    this.place = place;
    this.placeName = placeName;
    this.placeId = placeId;
  }

  String getInstruction() {
    return "${printDateTime(startsAt!)} 부터 ${printDateTime(endsAt!)}까지 ${printDuration(duration)}동안";
  }

  Map toJson() => {
        "type": "PL",
        "detail": {
          "starts_at": printDateTime(startsAt!),
          "ends_at": printDateTime(endsAt!),
          "duration": printDuration(duration),
          "place_name": placeName,
          "place_type": placeType,
          "point": {"latitude": place!.latitude, "longitude": place!.longitude},
          "place_id": placeId
        }
      };
}

/// 실제 완성되는 스케줄이 담기는 클래스
/// scheduleCreated = [ Schedule, Route, Schedule, ... ]
class ScheduleCreated {
  ScheduleCreated._initWithSchedules({required List<dynamic> scheduleList})
      : list = [
          for (int i = 0; i < scheduleList.length; i++) ...[
            scheduleList[i].copy(),
            if (i != scheduleList.length - 1) 'temp'
          ]
        ];

  static Future<ScheduleCreated> create(
      {required List<dynamic> scheduleList,
      required DateTime scheduleDate}) async {
    ScheduleCreated tempScheduleCreated =
        ScheduleCreated._initWithSchedules(scheduleList: scheduleList);

    for (int i = 0; i < tempScheduleCreated.list.length; i++) {
      if (i % 2 == 1) {
        Map<String, dynamic> foundRoute;
        Place scheduleBefore = tempScheduleCreated.list[i - 1];
        Place scheduleAfter = tempScheduleCreated.list[i + 1];
        bool shouldUseDepartTime = scheduleBefore.isFixed;
        int time = (shouldUseDepartTime
            ? (scheduleBefore.endsAt!.millisecondsSinceEpoch / 1000).round()
            : (scheduleAfter.startsAt!.millisecondsSinceEpoch / 1000).round());

        try {
          final response = await Dio().get(
              '$commonUrl/api/getroute?lat_ori=${scheduleBefore.place!.latitude}&lng_ori=${scheduleBefore.place!.longitude}&lat_dest=${scheduleAfter.place!.latitude}&lng_dest=${scheduleAfter.place!.longitude}&should_use_depart_time=${shouldUseDepartTime ? "true" : "false"}&time=$time');
          if (response.statusCode == 200) {
            foundRoute = response.data;
          } else {
            throw Exception('서버에 문제가 발생했습니다');
          }
        } catch (error) {
          rethrow;
        }

        RouteOrder createdRoute = RouteOrder.fromJson(json: foundRoute);
        scheduleBefore.changeDurationAndEndsAt(createdRoute.startsAt);
        scheduleAfter.changeDurationAndStartsAt(createdRoute.endsAt);

        tempScheduleCreated.list[i - 1] = scheduleBefore;
        tempScheduleCreated.list[i] = createdRoute;
        tempScheduleCreated.list[i + 1] = scheduleAfter;
      }
    }

    tempScheduleCreated.date = scheduleDate;
    return tempScheduleCreated;
  }

  /// [Place] , [RouteOrder]
  late List<dynamic> list;

  late DateTime date;

  String title = "";

  String memo = "";

  int userId = 10; // 추후 변경해야 함

  Map toJson() => {
        "user_id": userId,
        "date": (date.millisecondsSinceEpoch / 1000).round(),
        "schedule_title": title,
        "memo": memo,
        "order": [for (var order in list) order.toJson()]
      };
}
