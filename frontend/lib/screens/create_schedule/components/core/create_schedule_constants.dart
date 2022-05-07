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

/// 스케줄박스 위아래 핸들
const double upDownHandleHeight = 14;

/// BorderRadius 기본값
BorderRadius defaultBoxRadius = BorderRadius.circular(20);

/// 버튼용 BorderRadius
BorderRadius buttonBoxRadius = BorderRadius.circular(10);

/// 잔잔한 그림자
const List<BoxShadow> defaultBoxShadow = [
  BoxShadow(color: Color.fromARGB(29, 0, 0, 0), blurRadius: 30)
];

/// 각 탭을 바꿀 때 Resize Animation의 Duration
const tabResizeAnimationDuration = Duration(milliseconds: 700);

///
/// 시간 계산 관련 함수들은 종종 사용되는데,
/// 원래는 초단위로 계산하게끔 했지만
/// 분단위로 계산하게끔 변경함
/// 초단위로 하는게 박스 조절시 더 부드러운 움직임을 보이나,
/// 정확하게 시간을 지정하기가 어려워서 변경함
///
/// 코드는 둘 다 살려둠
///

/// 타임라인에서 높이를 받으면 Duration으로 반환해주는 함수
// Duration heightToDuration(double height) {
//   final double heightSecondConst = 86400 / (itemHeight * hours.toDouble());
//   return Duration(seconds: (height * heightSecondConst).round());
// }
Duration heightToDuration(double height) {
  final double heightMinuteConst = 1440 / (itemHeight * hours.toDouble());
  return Duration(minutes: (height * heightMinuteConst).round());
}

/// 타임라인에서 Duration을 받으면 높이로 반환해주는 함수
// double durationToHeight(Duration duration) {
//   final double secondHeightConst = (itemHeight * hours.toDouble()) / 86400;
//   return duration.inSeconds.toDouble() * secondHeightConst;
// }
double durationToHeight(Duration duration) {
  final double minuteHeightConst = (itemHeight * hours.toDouble()) / 1440;
  return duration.inMinutes.toDouble() * minuteHeightConst;
}

/// 타임라인에서 DateTime을 받으면 높이로 반환해주는 함수
// double dateTimeToHeight(DateTime datetime) {
//   return durationToHeight(Duration(
//       hours: datetime.hour,
//       minutes: datetime.minute,
//       seconds: datetime.second));
// }
double dateTimeToHeight(DateTime datetime) {
  return durationToHeight(Duration(
    hours: datetime.hour,
    minutes: datetime.minute,
  ));
}

/// Duration을 받으면 HH:MM:SS 형식으로 반환해주는 함수
String printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

/// DateTime을 받으면 HH:MM:SS 형식으로 반환해주는 함수
String printDateTime(DateTime time) {
  return printDuration(
      Duration(hours: time.hour, minutes: time.minute, seconds: time.second));
}
