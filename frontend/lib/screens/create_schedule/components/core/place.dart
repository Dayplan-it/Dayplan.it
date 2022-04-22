import 'package:flutter/material.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

///
/// 장소를 직접 선택하기 전에
/// 러프한 일정 저장을 위해 사용되는 클래스
///
///# 생성되는 클래스 변수
/// ```dart
///final String nameKor;
///final String nameEng;
///final Color color;
///DateTime startsAt;
///DateTime endsAt;
///Duration duration;
///```
///

// class PlaceRough {
//   PlaceRough({
//     required this.nameKor,
//     required this.nameEng,
//     required this.color,
//     required this.startsAt,
//     required this.endsAt,
//     required this.duration,
//   });

//   final String nameKor;
//   final String nameEng;
//   final Color color;
//   DateTime startsAt;
//   DateTime endsAt;
//   Duration duration;

//   PlaceRough copy() => PlaceRough(
//       nameKor: nameKor,
//       nameEng: nameEng,
//       color: color,
//       startsAt: startsAt,
//       endsAt: endsAt,
//       duration: duration);
// }

///
/// duration과 장소 이름만 가지는 객체
/// isPrimary로 고정일정 / 변동일정을 구분
///

class PlaceDurationOnly {
  PlaceDurationOnly(
      {required this.nameKor,
      required this.placeType,
      required this.color,
      required this.duration,
      this.isPrimary = false,
      this.startsAt});

  final String nameKor;
  final String placeType;
  final Color color;
  Duration duration;
  bool isPrimary;
  DateTime? startsAt;

  PlaceDurationOnly copy() => PlaceDurationOnly(
      nameKor: nameKor,
      placeType: placeType,
      color: color,
      duration: duration,
      isPrimary: isPrimary,
      startsAt: startsAt);

  double toHeight() {
    final double secondHeightConst = (itemHeight * hours.toDouble()) / 86400;
    return duration.inSeconds.toDouble() * secondHeightConst;
  }
}
