import 'package:flutter/material.dart';

/// Create Schedule Screen을 위한 상수, 함수들

/// 각 스케쥴 블록의 1시간 높이
const double itemHeight = 85;

/// 타임라인을 몇시간으로 설정할 것인지 (24시간)
const int hours = 24;

/// 순서 조정시 생기는 DragTarget 높이
const double reorderDragTargetHeight = itemHeight / 5;

/// 최소한의 스케줄 블록 사이즈를 Duration으로 결정
const Duration minimumScheduleBoxDuration = Duration(minutes: 30);

/// 타임라인의 너비 (Rough)
const double roughTimeLineWidth = 120;

/// 타임라인의 너비 (Detail)
const double detailTimeLineWidth = 100;

const double scheduleBoxHandleWidth = 22;

/// BorderRadius 기본값
BorderRadius defaultBoxRadius = BorderRadius.circular(20);

/// 버튼용 BorderRadius
BorderRadius buttonBoxRadius = BorderRadius.circular(10);

/// 잔잔한 그림자
const List<BoxShadow> defaultBoxShadow = [
  BoxShadow(color: Color.fromARGB(29, 0, 0, 0), blurRadius: 30)
];

/// 타임라인에서 높이를 받으면 Duration으로 반환해주는 함수
Duration heightToDuration(double height) {
  final double heightSecondConst = 86400 / (itemHeight * hours.toDouble());
  return Duration(seconds: (height * heightSecondConst).round());
}

/// 타임라인에서 Duration을 받으면 높이로 반환해주는 함수
double durationToHeight(Duration duration) {
  final double secondHeightConst = (itemHeight * hours.toDouble()) / 86400;
  return duration.inSeconds.toDouble() * secondHeightConst;
}

/// 타임라인에서 DateTime을 받으면 높이로 반환해주는 함수
double dateTimeToHeight(DateTime datetime) {
  return durationToHeight(Duration(
      hours: datetime.hour,
      minutes: datetime.minute,
      seconds: datetime.second));
}

/// Duration을 받으면 HH:MM:SS 형식으로 반환해주는 함수
String printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}
