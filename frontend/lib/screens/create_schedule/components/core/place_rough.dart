import 'package:flutter/material.dart';

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
///# 클래스 함수
///## 아이템의 높이를 가져옵니다.
///```dart
///getItemHeight()
/// ```
///

class PlaceRough {
  PlaceRough({
    required this.nameKor,
    required this.nameEng,
    required this.color,
    required this.startsAt,
    required this.endsAt,
    required this.duration,
  });

  final String nameKor;
  final String nameEng;
  final Color color;
  DateTime startsAt;
  DateTime endsAt;
  Duration duration;

  getItemHeight() {
    return;
  }
}
