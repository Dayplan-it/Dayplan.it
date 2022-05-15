import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

/// Route의 공통되는 Interface
abstract class RouteStep {
  /// 거리 (km)
  final double distance;

  /// 소요시간 (sec)
  final Duration duration;

  /// 출발(역) 좌표
  final LatLng departStopLatLng;

  /// 도착(역) 좌표
  final LatLng arrivalStopLatLng;

  /// 폴리곤 라인
  final String polyline;

  /// 설명
  final String instruction;

  /// 선의 두께
  final int lineWidth = 5;

  /// [Polyline] Getter
  Polyline getPolyline();

  RouteStep(this.distance, this.duration, this.departStopLatLng,
      this.arrivalStopLatLng, this.polyline, this.instruction);

  RouteStep.fromJson(Map<String, dynamic> json)
      : distance = double.parse(
            (json['distance']!['value'] / 1000).toStringAsFixed(3)),
        duration = Duration(seconds: json['duration']!['value']),
        departStopLatLng = LatLng(
            json['start_location']!['lat'], json['start_location']!['lng']),
        arrivalStopLatLng =
            LatLng(json['end_location']!['lat'], json['end_location']!['lng']),
        polyline = json['polyline']!['points'],
        instruction = json['html_instructions']!;

  RouteStep.fromGetScheduleApiJson(
      Map<String, dynamic> json, LatLng privLatLng, LatLng nextLatLng)
      : distance = json["distance"],
        duration = stringToDuration(json["duration"]),
        departStopLatLng = privLatLng,
        arrivalStopLatLng = nextLatLng,
        polyline = json['polyline'],
        instruction = (json['instruction'] as String).replaceFirst("대한민국 ", "");

  Map toJson();
}

/// 대중교통 Step
class TransitStep extends RouteStep {
  /// 출발시간
  final DateTime departTime;

  /// 도착시간
  final DateTime arrivalTime;

  /// 출발역 이름
  final String departStopName;

  /// 도착역 이름
  final String arrivalStopName;

  /// 라인 컬러
  final Color color;

  /// 정착 정거장 수
  final int numStops;

  /// 대중교통 종류 (BUS / SUB)
  final String transitType;

  /// 대중교통 이름
  final String transitName;

  /// 대중교통 이름 (노선이름)
  final String transitShortName;

  @override
  Polyline getPolyline() {
    return Polyline(
        polylineId: PolylineId(polyline),
        width: lineWidth,
        color: color,
        points: decodePolyline(polyline)
            .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
            .toList());
  }

  TransitStep.fromJson({required Map<String, dynamic> json})
      : departStopName = json['transit_details']!['departure_stop']['name'],
        arrivalStopName = json['transit_details']!['arrival_stop']['name'],
        color = Color(int.parse(json['transit_details']!['line']['color']
            .replaceFirst('#', '0xFF'))),
        numStops = json['transit_details']!['num_stops'],
        transitShortName = json['transit_details']!['line']['short_name'],
        transitName = json['transit_details']!['line']['name'],
        transitType =
            (json['transit_details']!['line']['vehicle']['type'] == "BUS"
                ? "BUS"
                : "SUB"),
        departTime = DateTime.fromMillisecondsSinceEpoch(
            json['transit_details']!['departure_time']['value'] * 1000),
        arrivalTime = DateTime.fromMillisecondsSinceEpoch(
            json['transit_details']!['arrival_time']['value'] * 1000),
        super.fromJson(json);

  TransitStep.fromGetScheduleApiJson(
      {required Map<String, dynamic> json,
      required LatLng privLatLng,
      required LatLng nextLatLng,
      required DateTime scheduleDate})
      : departStopName = json['transit_detail']['departure_stop_name'],
        arrivalStopName = json['transit_detail']['arrival_stop_name'],
        color = Color(int.parse(
            json['transit_detail']["transit_color"].replaceFirst('#', '0xFF'))),
        numStops = json['transit_detail']['num_stops'],
        transitShortName = json['transit_detail']['transit_short_name'],
        transitName = json['transit_detail']['transit_name'],
        transitType = json['transit_detail']['transit_type'],
        departTime = stringToDateTime(
            datetimeStr: json['transit_detail']['departure_time'],
            date: scheduleDate),
        arrivalTime = stringToDateTime(
            datetimeStr: json['transit_detail']['arrival_time'],
            date: scheduleDate),
        super.fromGetScheduleApiJson(json, privLatLng, nextLatLng);

  @override
  Map toJson() {
    String colorStr = '#${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
    return {
      "travel_mode": "TR",
      "duration": printDuration(duration),
      "distance": distance,
      "instruction": instruction,
      "polyline": polyline,
      "transit_detail": {
        "transit_type": transitType,
        "transit_name": transitName,
        "transit_short_name": transitShortName,
        "departure_stop_name": departStopName,
        "departure_time": printDateTime(departTime),
        "arrival_stop_name": arrivalStopName,
        "arrival_time": printDateTime(arrivalTime),
        "num_stops": numStops,
        "transit_color": colorStr
      }
    };
  }
}

/// Walking Step
class WalkingStep extends RouteStep {
  @override
  Polyline getPolyline() {
    return Polyline(
        polylineId: PolylineId(polyline),
        width: lineWidth,
        color: subTextColor,
        points: decodePolyline(polyline)
            .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
            .toList());
  }

  WalkingStep.fromJson({required Map<String, dynamic> json})
      : super.fromJson(json);

  WalkingStep.fromGetScheduleApiJson(
      {required Map<String, dynamic> json,
      required LatLng privLatLng,
      required LatLng nextLatLng})
      : super.fromGetScheduleApiJson(json, privLatLng, nextLatLng);

  @override
  Map toJson() => {
        "travel_mode": "WK",
        "duration": printDuration(duration),
        "distance": distance,
        "instruction": instruction,
        "polyline": polyline
      };
}

/// 전체 Route가 담기는 클래스
class RouteOrder {
  /// 거리 (km)
  double distance;

  /// 소요시간 (sec)
  Duration duration;

  /// 출발 좌표
  LatLng departLatLng;

  /// 도착 좌표
  LatLng arrivalLatLng;

  /// 출발시간
  DateTime startsAt;

  /// 도착시간
  DateTime endsAt;

  /// 폴리곤 라인
  String polyline;

  /// [WalkingStep], [TransitStep]이 들어갈 리스트
  late List<RouteStep> steps;

  /// [Polyline] Getter
  Polyline getPolyline(Color color, int lineWidth) {
    return Polyline(
        polylineId: PolylineId(polyline),
        width: lineWidth,
        color: color,
        points: decodePolyline(polyline)
            .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
            .toList());
  }

  /// 구글 API용임에 유의
  RouteOrder.fromJson({required Map<String, dynamic> json})
      : distance = double.parse(
            (json['distance']!['value'] / 1000).toStringAsFixed(3)),
        duration = Duration(seconds: json['duration']!['value']),
        departLatLng = LatLng(
            json['start_location']!['lat'], json['start_location']!['lng']),
        arrivalLatLng =
            LatLng(json['end_location']!['lat'], json['end_location']!['lng']),
        startsAt = DateTime.fromMillisecondsSinceEpoch(
            json['departure_time']['value'] * 1000),
        endsAt = DateTime.fromMillisecondsSinceEpoch(
            json['arrival_time']['value'] * 1000),
        polyline = json['overview_polyline']!['points'],
        steps = [
          for (Map<String, dynamic> step in json["steps"])
            if (step["travel_mode"] == "WALKING") ...[
              WalkingStep.fromJson(json: step),
            ] else
              TransitStep.fromJson(json: step),
        ];

  static RouteOrder fromGetScheduleApiJson(
      {required Map<String, dynamic> json,
      required DateTime scheduleDate,
      required LatLng privPlace,
      required LatLng nextPlace}) {
    RouteOrder resultRouteOrder = RouteOrder._fromGetScheduleApiJson(
        json: json,
        scheduleDate: scheduleDate,
        privPlace: privPlace,
        nextPlace: nextPlace);

    for (int i = 0; i < (json["step"] as List).length; i++) {
      List<LatLng> polylineLatLngList =
          decodePolyline(json["step"][i]["polyline"])
              .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
              .toList();
      LatLng privLatLng =
          i == 0 ? privPlace : resultRouteOrder.steps[i - 1].arrivalStopLatLng;
      LatLng nextLatLng = i == (json["step"] as List).length - 1
          ? nextPlace
          : (polylineLatLngList[0] == privLatLng
              ? polylineLatLngList[polylineLatLngList.length - 1]
              : polylineLatLngList[0]);

      if (json["step"][i]["travel_mode"] == "WK") {
        resultRouteOrder.steps.add(WalkingStep.fromGetScheduleApiJson(
            json: json["step"][i],
            privLatLng: privLatLng,
            nextLatLng: nextLatLng));
      } else {
        resultRouteOrder.steps.add(TransitStep.fromGetScheduleApiJson(
            json: json["step"][i],
            privLatLng: privLatLng,
            nextLatLng: nextLatLng,
            scheduleDate: scheduleDate));
      }
    }

    return resultRouteOrder;
  }

  /// Get Schedule API용
  /// LatLng은 필요 없으므로 더미로 채움
  /// 참고로 폴리라인으로는 어디가 시작이고 끝인지 알수가 없었음
  /// 추후 Backend API를 바꿀 필요가 있음
  RouteOrder._fromGetScheduleApiJson(
      {required Map<String, dynamic> json,
      required DateTime scheduleDate,
      required LatLng privPlace,
      required LatLng nextPlace})
      : distance = json["detail"]["distance"],
        duration = stringToDuration(json["detail"]["duration"]),
        departLatLng = privPlace,
        arrivalLatLng = nextPlace,
        startsAt = stringToDateTime(
            datetimeStr: json["detail"]["starts_at"], date: scheduleDate),
        endsAt = stringToDateTime(
            datetimeStr: json["detail"]["ends_at"], date: scheduleDate),
        polyline = json["detail"]["polyline"],
        steps = [];

  Map toJson() => {
        "type": "RO",
        "detail": {
          "starts_at": printDateTime(startsAt),
          "ends_at": printDateTime(endsAt),
          "duration": printDuration(duration),
          "distance": distance,
          "polyline": polyline,
        },
        "step": [for (RouteStep step in steps) step.toJson()]
      };

  double toHeight() {
    return durationToHeight(duration);
  }

  bool isTransitRoute() {
    for (RouteStep step in steps) {
      if (step.runtimeType == TransitStep) {
        return true;
      }
    }

    return false;
  }

  /// WALKING / BUS / SUB / BOTH
  String getType() {
    if (isTransitRoute()) {
      bool _isBus = false;
      bool _isSub = false;
      bool _isBoth = false;

      for (var step in steps) {
        if (step.runtimeType == TransitStep) {
          if ((step as TransitStep).transitType == 'BUS') {
            _isBus = true;
          } else if ((step).transitType == 'SUB') {
            _isSub = true;
          }
        }

        if (_isBus && _isSub) {
          _isBoth = true;
          break;
        }
      }
      return (_isBoth ? 'BOTH' : (_isBus ? 'BUS' : 'SUB'));
    }

    return 'WALKING';
  }

  Map<String, String> getInstruction() {
    String _instruction;
    switch (getType()) {
      case "WALKING":
        _instruction = "도보로 이동";
        break;
      case "BOTH":
        _instruction = "대중교통으로 이동";
        break;
      case "BUS":
        _instruction = "버스로 이동";
        break;
      case "SUB":
        _instruction = "지하철로 이동";
        break;
      default:
        _instruction = "";
    }
    return {
      "instruction": _instruction,
      "duration": printDurationKor(duration)
    };
  }
}
