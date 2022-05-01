import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

///
/// ## 각 스케줄을 일컫는 객체
/// `Schedule`이 모여서 schedules가 됨.
///
/// 참고로 TimeOfDay는 제약사항이 많아
/// 본 앱에서는 TimeOfDay 대신 Duration을 TimeOfDay처럼 사용함

class Schedule {
  Schedule(
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

  Schedule copy() => Schedule(
      nameKor: nameKor,
      placeType: placeType,
      color: color,
      duration: duration,
      startsAt: startsAt,
      endsAt: endsAt,
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

  void setPlace(LatLng place, String placeName, String placeId) {
    this.place = place;
    this.placeName = placeName;
    this.placeId = placeId;
  }
}
