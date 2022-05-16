import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/class/route_class.dart';
import 'package:dayplan_it/screens/create_schedule/exceptions/exceptions.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

/// PlaceOrder에 해당하는 클래스
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

  String nameKor;
  String placeType;
  Color color;
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

  void setEmptyPlace(Place newPlace) {
    if (placeType == "empty") {
      nameKor = newPlace.nameKor;
      placeType = newPlace.placeType;
      color = newPlace.color;
      duration = newPlace.duration;
      isFixed = newPlace.isFixed;
      startsAt = newPlace.startsAt;
      endsAt = newPlace.endsAt;
      place = newPlace.place;
      placeName = newPlace.placeName;
      placeId = newPlace.placeId;
    } else {
      throw 'This is not a Empty Place Order';
    }
  }

  Map<String, String> getInstruction() {
    return {
      "startsAt": printDateTimeHourAndMinuteOnly(startsAt!),
      "endsAt": printDateTimeHourAndMinuteOnly(endsAt!),
      "duration": printDurationKor(duration)
    };
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

        var prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('apiToken');

        Dio dio = Dio();
        dio.options.headers['Authorization'] = token.toString();

        try {
          final response = await dio.get(
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

        if (scheduleBefore.duration.inSeconds < 0) {
          throw TravelTimeException(scheduleIndex: i - 1);
        } else if (scheduleAfter.duration.inSeconds < 0) {
          throw TravelTimeException(scheduleIndex: i + 1);
        }

        tempScheduleCreated.list[i - 1] = scheduleBefore;
        tempScheduleCreated.list[i] = createdRoute;
        tempScheduleCreated.list[i + 1] = scheduleAfter;
      }
    }

    tempScheduleCreated.date = scheduleDate;
    return tempScheduleCreated;
  }

  static Future<ScheduleCreated> getSchedule({required int date}) async {
    Dio dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('apiToken')!;
    dio.options.headers['Authorization'] = token.toString();

    String url = '$commonUrl/schedules/find?date=$date';

    try {
      Response response = await dio.get(url);
      Map<String, dynamic> json = response.data;
      ScheduleCreated fetchedSchedule = ScheduleCreated();
      fetchedSchedule.date = dashStringToDate(json['date']);
      fetchedSchedule.title = json['schedule_title'];
      fetchedSchedule.memo = json['memo'];

      /// `fetchedSchedule.list`에 넣어야 하는 리스트
      List<dynamic> scheduleOrders = [];

      for (int i = 0; i < (json['order'] as List).length; i++) {
        if (json['order'][i]["type"] == "PL") {
          scheduleOrders.add(Place(
              nameKor: placeTypeNameKorByPlaceType(
                  json['order'][i]["detail"]["place_type"]),
              placeType: json['order'][i]["detail"]["place_type"],
              color: placeColorByPlaceType(
                  json['order'][i]["detail"]["place_type"]),
              duration:
                  stringToDuration(json['order'][i]["detail"]["duration"]),
              startsAt: stringToDateTime(
                  datetimeStr: json['order'][i]["detail"]["starts_at"],
                  date: dashStringToDate(json['date'])),
              endsAt: stringToDateTime(
                  datetimeStr: json['order'][i]["detail"]["ends_at"],
                  date: dashStringToDate(json['date'])),
              place: LatLng(json['order'][i]["detail"]["point"]["latitude"],
                  json['order'][i]["detail"]["point"]["longitude"]),
              placeName: json['order'][i]["detail"]["place_name"],
              placeId: json['order'][i]["detail"]["place_id"]));
        } else {
          scheduleOrders.add(RouteOrder.fromGetScheduleApiJson(
              json: json['order'][i],
              scheduleDate: dashStringToDate(json['date']),
              privPlace: (scheduleOrders[i - 1] as Place).place!,
              nextPlace: LatLng(
                  json['order'][i + 1]["detail"]["point"]["latitude"],
                  json['order'][i + 1]["detail"]["point"]["longitude"])));
        }
      }

      fetchedSchedule.list = scheduleOrders;

      return fetchedSchedule;
    } on DioError catch (e) {
      if (e.response!.statusCode == 404) {
        throw NoScheduleFound();
      }
    }
    throw NoScheduleFound();
  }

  ScheduleCreated();

  /// [Place] , [RouteOrder]
  late List<dynamic> list;

  late DateTime date;

  String title = "";

  String memo = "";

  // ScheduleCreated._fromGetScheduleApiJson({required Map<String, dynamic> json})
  //     : title = json['schedule_title'],
  //       memo = json['memo'],
  //       date = dashStringToDate(json['date']),
  //       list = [
  //         for (int i = 0; i < (json['order'] as List).length; i++) ...[
  //           if (json['order'][i]["type"] == "PL") ...[
  //             Place(
  //                 nameKor: placeTypeNameKorByPlaceType(
  //                     json['order'][i]["detail"]["place_type"]),
  //                 placeType: json['order'][i]["detail"]["place_type"],
  //                 color: placeColorByPlaceType(
  //                     json['order'][i]["detail"]["place_type"]),
  //                 duration:
  //                     stringToDuration(json['order'][i]["detail"]["duration"]),
  //                 startsAt: stringToDateTime(
  //                     datetimeStr: json['order'][i]["detail"]["starts_at"],
  //                     date: dashStringToDate(json['date'])),
  //                 endsAt: stringToDateTime(
  //                     datetimeStr: json['order'][i]["detail"]["ends_at"],
  //                     date: dashStringToDate(json['date'])),
  //                 place: LatLng(json['order'][i]["detail"]["point"]["latitude"],
  //                     json['order'][i]["detail"]["point"]["longitude"]),
  //                 placeName: json['order'][i]["detail"]["place_name"],
  //                 placeId: json['order'][i]["detail"]["place_id"])
  //           ] else ...[
  //             RouteOrder.fromGetScheduleApiJson(
  //                 json: json['order'][i],
  //                 scheduleDate: dashStringToDate(json['date']))
  //           ]
  //         ]
  //       ];

  Map toJson() => {
        "date": (date.millisecondsSinceEpoch / 1000).round(),
        "schedule_title": title,
        "memo": memo,
        "order": [for (var order in list) order.toJson()]
      };
}
