import 'package:flutter/material.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place.dart';

///Create Schedule Screen을 위한 `Store`
///클래스간 getter setter 이동보다는 Store 사용을 지향하도록 함

class CreateScheduleStore extends ChangeNotifier {
  /// 생성되는 스케줄의 날짜, `create_schedule_screen.dart`에서 init
  late DateTime scheduleDate;

  // /// 러프한 일정이 저장되는 List
  // /// 저장이 잘 되면 아래와 같은 구조가 됩니다.
  // /// ```dart
  // /// [
  // ///   class PlaceRough(
  // ///     String nameKor,
  // ///     String nameEng,
  // ///     Color color,
  // ///     DateTime startsAt,
  // ///     DateTime endsAt,
  // ///     Duration duration,
  // ///   ),
  // /// ]
  // /// ```
  // List<PlaceRough> roughSchedule = [];

  // /// 타임라인에서 스캐쥴 블록 앞에 넣을 빈 공간의 높이
  // /// 기본적으로 8시에 해당하는 `itemHeight * 8`로 초기화됨
  // double scheduleStartHeight = itemHeight * 8;

  // /// 러프 스케줄이 아무것도 없을 때 새로 추가할 스케줄 앞 빈공간 높이
  // /// 스크롤 높이에 따라 달라짐
  // double scheduleAddHeight = itemHeight * 8;

  // /// 타임라인에서 블록 이동중임을 확인하기 위한 변수
  // bool isDragging = false;

  // /// 블록 이동시 현재 이동중인 블록의 `index`를 저장하기 위한 변수
  // int currentlyDragging = 0;

  // /// 타임라인에서 블록 사이즈 변경중임을 확인하기 위한 변수
  // bool isBlockResizing = false;
  // onBlockResizing() {
  //   isBlockResizing = true;
  //   notifyListeners();
  // }

  // onEndBlockResizing() {
  //   isBlockResizing = false;
  //   notifyListeners();
  // }

  // /// 타임라인 Auto Scroll
  // bool isAutoScrollAble = false;
  // onAutoScrollOn() {
  //   isAutoScrollAble = true;
  //   notifyListeners();
  // }

  // onAutoScrollOff() {
  //   isAutoScrollAble = false;
  //   notifyListeners();
  // }

  // /// 커스텀 블록 생성중 여부를 확인하기 위한 변수
  // bool isCustomBlockBeingMade = false;

  // /// 디테일 스케줄 생성중인지 여부를 확인하기 위한 변수
  // bool isDetailBeingMade = false;
  // toggleIsDetailBeingMade() {
  //   isDetailBeingMade = !isDetailBeingMade;
  //   notifyListeners();
  // }

  // /// 처음 스케쥴을 추가할 때 사용하는 함수
  // /// 기본적으로 1시간으로 들어가도록 돼있으나 남은 시간적 여유에 따라 줄어들기도 함
  // /// (최솟값은 `minimumScheduleBoxDuration`을 따름)
  // /// 스케줄의 맨 밑으로 추가되는것이 default이며,
  // /// 경우에 따라 스케줄 앞으로 붙기도 하고
  // /// 전체 스케줄의 길이가 (하루 - minimumScheduleBoxDuration)이 넘는다면 추가가 안되도록 함
  // addRoughSchedule(PlaceRough _place) {
  //   PlaceRough place = _place.copy();
  //   if (roughSchedule.isNotEmpty) {
  //     final Duration scheduleDuration = roughSchedule[roughSchedule.length - 1]
  //         .endsAt
  //         .difference(roughSchedule[0].startsAt);
  //     final Duration maximumScheduleDuration =
  //         const Duration(days: 1) - minimumScheduleBoxDuration;

  //     if (scheduleDuration < maximumScheduleDuration) {
  //       final Duration beforeScheduleStarts =
  //           roughSchedule[0].startsAt.difference(scheduleDate);
  //       final Duration afterScheduleEnds = scheduleDate
  //           .add(const Duration(days: 1))
  //           .difference(roughSchedule[roughSchedule.length - 1].endsAt);

  //       if (afterScheduleEnds > minimumScheduleBoxDuration) {
  //         place.startsAt = roughSchedule[roughSchedule.length - 1].endsAt;

  //         place.duration = (afterScheduleEnds > const Duration(hours: 1)
  //             ? const Duration(hours: 1)
  //             : minimumScheduleBoxDuration);

  //         place.endsAt = place.startsAt.add(place.duration);
  //         roughSchedule.add(place);
  //         notifyListeners();
  //       } else if (beforeScheduleStarts > minimumScheduleBoxDuration) {
  //         place.endsAt = roughSchedule[0].startsAt;
  //         place.duration = (beforeScheduleStarts > const Duration(hours: 1)
  //             ? const Duration(hours: 1)
  //             : minimumScheduleBoxDuration);
  //         place.startsAt = place.endsAt.subtract(place.duration);
  //         roughSchedule.insert(0, place);

  //         setScheduleStartHeight(
  //             durationToHeight(place.startsAt.difference(scheduleDate)));
  //         notifyListeners();
  //       }
  //     }
  //   } else {
  //     place.startsAt = scheduleDate.add(heightToDuration(scheduleAddHeight));
  //     scheduleStartHeight = scheduleAddHeight;

  //     place.duration = const Duration(hours: 1);
  //     place.endsAt = place.startsAt.add(place.duration);
  //     roughSchedule.add(place);
  //     notifyListeners();
  //   }
  // }

  // /// 러프 스케쥴을 삭제하는 함수
  // removeRoughSchedule(int index) {
  //   // 뒤에 스케쥴이 있는 경우 뒷 스케쥴의 시작 시간을 변경해줘야 함
  //   if (index <= roughSchedule.length - 2) {
  //     roughSchedule[index + 1].startsAt = roughSchedule[index].startsAt;
  //     roughSchedule[index + 1].endsAt = roughSchedule[index + 1]
  //         .startsAt
  //         .add(roughSchedule[index + 1].duration);
  //   }
  //   roughSchedule.removeAt(index);
  //   notifyListeners();
  // }

  // clearSchedule() {
  //   roughSchedule = [];
  //   scheduleStartHeight = itemHeight * 8;
  //   scheduleAddHeight = itemHeight * 8;
  //   notifyListeners();
  // }

  // onDragEnd() {
  //   isDragging = false;
  //   notifyListeners();
  // }

  // onDragStart(int _currentlyDragging) {
  //   isDragging = true;
  //   currentlyDragging = _currentlyDragging;
  //   notifyListeners();
  // }

  // /// scheduleBox.dart의 RoughScheduleBoxUpDown 위젯을 위한 함수로,
  // /// 위, 아래 화살표를 드래그 할 시 스케쥴 내용 또한 바꾸는 내용
  // /// 경우의 수가 많아 복잡하며, 버그 발생 확률 높으므로 주의를 요함
  // changeDurationOfScheduleForUpDownBtn(int index, double delta, bool isUp) {
  //   Duration timeDelta = heightToDuration(delta.abs());
  //   if ((isUp && delta > 0) || (!isUp && delta < 0)) {
  //     if (roughSchedule[index].duration - timeDelta <
  //         minimumScheduleBoxDuration) {
  //       roughSchedule[index].duration = minimumScheduleBoxDuration;
  //     } else {
  //       roughSchedule[index].duration -= timeDelta;
  //     }
  //   } else if (isUp && index == 0) {
  //     if (roughSchedule[0]
  //             .startsAt
  //             .subtract(timeDelta)
  //             .difference(scheduleDate)
  //             .inMilliseconds <
  //         0) {
  //       roughSchedule[index].duration +=
  //           roughSchedule[index].startsAt.difference(scheduleDate);
  //     } else {
  //       roughSchedule[index].duration += timeDelta;
  //     }
  //   } else if (!isUp && index == roughSchedule.length - 1) {
  //     if (roughSchedule[index]
  //             .endsAt
  //             .add(timeDelta)
  //             .difference(scheduleDate.add(const Duration(days: 1)))
  //             .inMilliseconds >
  //         0) {
  //       roughSchedule[index].duration ==
  //           scheduleDate
  //               .add(const Duration(days: 1))
  //               .difference(roughSchedule[index].startsAt);
  //     } else {
  //       roughSchedule[index].duration += timeDelta;
  //     }
  //   } else {
  //     if (roughSchedule.length > 1) {
  //       if (isUp && index != 0) {
  //         if (roughSchedule[index - 1].duration - timeDelta <
  //             minimumScheduleBoxDuration) {
  //           roughSchedule[index].duration += roughSchedule[index - 1]
  //               .endsAt
  //               .difference(roughSchedule[index - 1]
  //                   .startsAt
  //                   .add(minimumScheduleBoxDuration));
  //         } else {
  //           roughSchedule[index].duration += timeDelta;
  //         }
  //       } else if (!isUp && index != roughSchedule.length - 1) {
  //         if (roughSchedule[index + 1].duration - timeDelta <
  //             minimumScheduleBoxDuration) {
  //           roughSchedule[index].duration += roughSchedule[index + 1]
  //               .endsAt
  //               .subtract(minimumScheduleBoxDuration)
  //               .difference(roughSchedule[index + 1].startsAt);
  //         } else {
  //           roughSchedule[index].duration += timeDelta;
  //         }
  //       } else {
  //         roughSchedule[index].duration += timeDelta;
  //       }
  //     } else {
  //       roughSchedule[index].duration += timeDelta;
  //     }
  //   }

  //   if (isUp) {
  //     roughSchedule[index].startsAt =
  //         roughSchedule[index].endsAt.subtract(roughSchedule[index].duration);
  //     if (index == 0) {
  //       scheduleStartHeight = dateTimeToHeight(roughSchedule[0].startsAt);
  //     } else if (roughSchedule.length > 1) {
  //       roughSchedule[index - 1].endsAt = roughSchedule[index].startsAt;
  //       roughSchedule[index - 1].duration = roughSchedule[index - 1]
  //           .endsAt
  //           .difference(roughSchedule[index - 1].startsAt);
  //     }
  //   } else {
  //     roughSchedule[index].endsAt =
  //         roughSchedule[index].startsAt.add(roughSchedule[index].duration);
  //     if (index != roughSchedule.length - 1) {
  //       roughSchedule[index + 1].startsAt = roughSchedule[index].endsAt;
  //       roughSchedule[index + 1].duration = roughSchedule[index + 1]
  //           .endsAt
  //           .difference(roughSchedule[index + 1].startsAt);
  //     }
  //   }
  //   notifyListeners();
  // }

  // onChangeScheduleOrder(int oldIndex, int newIndex) {
  //   DateTime scheduleStartTime = roughSchedule[0].startsAt;

  //   if (newIndex > oldIndex) {
  //     newIndex = newIndex - 1;
  //   }

  //   final PlaceRough temp = roughSchedule.removeAt(oldIndex);
  //   roughSchedule.insert(newIndex, temp);

  //   // 순서를 바꾸기는 했는데, PlaceRough 내의 시간은 바뀌지 않음
  //   // 따라서 이를 계산하는 과정이 필요함.
  //   // 나머지는 전부 바뀌지만 duration만큼은 유지되므로, 이를 이용해 처음부터
  //   // 싹 계산하는 방법 이용

  //   for (int i = 0; i < roughSchedule.length; i++) {
  //     if (i == 0) {
  //       roughSchedule[0].startsAt = scheduleStartTime;
  //     } else {
  //       roughSchedule[i].startsAt = roughSchedule[i - 1].endsAt;
  //     }
  //     roughSchedule[i].endsAt =
  //         roughSchedule[i].startsAt.add(roughSchedule[i].duration);
  //   }
  //   notifyListeners();
  // }

  // setScheduleStartHeight(double newHeight) {
  //   scheduleStartHeight = newHeight;
  //   notifyListeners();
  // }

  // /// 커스텀 블록 생성 시작
  // onStartMakingCustomBlock() {
  //   isCustomBlockBeingMade = true;
  //   notifyListeners();
  // }

  // /// 커스텀 블록 생성 끝
  // onEndMakingCustomBlock() {
  //   isCustomBlockBeingMade = false;
  //   notifyListeners();
  // }

  // ///
  // /// 이하는 디테일 스케줄 결정 스크린에 사용
  // ///

  // /// 현재 디테일 결정중인 스케줄 확인에 사용
  // /// gotoNextDetail, backtoPrivDetail로 index 조절
  // int indexOfCurrentlyDecidingDetail = 0;
  // gotoNextDetail() {
  //   if (indexOfCurrentlyDecidingDetail != roughSchedule.length - 1) {
  //     indexOfCurrentlyDecidingDetail++;
  //     notifyListeners();
  //   }
  // }

  // backtoPrivDetail() {
  //   if (indexOfCurrentlyDecidingDetail != 0) {
  //     indexOfCurrentlyDecidingDetail--;
  //     notifyListeners();
  //   }
  // }

  ///
  /// 이하는 러프 스케줄 결정 (Duration만 결정하는 타입, 45-2번쨰 브랜치 참고) 관련
  ///

  /// 스케줄 DurationLine ScrollHeight
  double durationLineHeight = 0;

  /// Duration만 존재하는 PlaceDurationOnly class 객체로 이루어진
  /// 스케줄 List
  List<PlaceDurationOnly> durationSchedule = [];

  /// 디테일 스케줄 생성중인지 여부를 확인하기 위한 변수
  bool isDetailBeingMade = false;
  void toggleIsDetailBeingMade() {
    isDetailBeingMade = !isDetailBeingMade;
    notifyListeners();
  }

  /// 커스텀 블록 생성중 여부를 확인하기 위한 변수
  bool isCustomBlockBeingMade = false;

  /// 커스텀 블록 생성 시작
  void onStartMakingCustomBlock() {
    isCustomBlockBeingMade = true;
    notifyListeners();
  }

  /// 커스텀 블록 생성 끝
  void onEndMakingCustomBlock() {
    isCustomBlockBeingMade = false;
    notifyListeners();
  }

  /// Navigation.pop에 이용하는 durationSchedule 초기화 함수
  void clearDurationSchedule() {
    durationSchedule = [];
    isCustomBlockBeingMade = false;
    isDurationOnlyScheduleDragging = false;
    notifyListeners();
  }

  void removeDurationOnlySchedule(int durationOnlyScheduleIndex) {
    durationSchedule.removeAt(durationOnlyScheduleIndex);
    notifyListeners();
  }

  /// durationSchedule 전체 Duration을 계산하는 함수
  Duration durationOfDurationSchedule() {
    Duration sumOfScheduleDuration = const Duration(seconds: 0);

    for (PlaceDurationOnly schedule in durationSchedule) {
      sumOfScheduleDuration += schedule.duration;
    }

    return sumOfScheduleDuration;
  }

  /// durationSchedule에 PlaceDurationOnly 추가하는 함수
  /// 추가되는 스케줄의 처음 들어가는 시간을 조절하려면 여기에서 하면 됨
  void addScheduleDurationOnly(PlaceDurationOnly _placeDurationOnly) {
    PlaceDurationOnly placeDurationOnly = _placeDurationOnly.copy();
    placeDurationOnly.duration = const Duration(hours: 1);

    Duration sumOfScheduleDuration = durationOfDurationSchedule();

    if (sumOfScheduleDuration + placeDurationOnly.duration <=
        const Duration(days: 1)) {
      durationSchedule.add(placeDurationOnly);
      notifyListeners();
    }
  }

  /// 현재 옮기는중인 PlaceDurationOnly의 index를 저장하는 변수
  int indexOfcurrentlyDraggingPlaceDurationOnly = 999;

  bool isDurationOnlyScheduleDragging = false;

  void onDurationScheduleDragEnd() {
    isDurationOnlyScheduleDragging = false;
    notifyListeners();
  }

  void onDurationScheduleDragStart(
      int _currentlyDraggingPlaceDurationOnlyIndex) {
    isDurationOnlyScheduleDragging = true;
    indexOfcurrentlyDraggingPlaceDurationOnly =
        _currentlyDraggingPlaceDurationOnlyIndex;
    notifyListeners();
  }

  /// 타임라인에서 블록 사이즈 변경중임을 확인하기 위한 변수
  bool isBlockResizing = false;
  void onBlockResizing() {
    isBlockResizing = true;
    notifyListeners();
  }

  void onEndBlockResizing() {
    isBlockResizing = false;
    notifyListeners();
  }

  /// 위, 아래 화살표를 드래그 할 시 스케쥴 duration 또한 바꾸는 내용
  /// 경우의 수가 많아 복잡하며, 버그 발생 확률 높으므로 주의를 요함
  /// 두가지 타입의 코드가 있음
  /// 1. 조절이 다음 블록에 영향을 주지 않는 타입
  /// 2. 조절이 다음 블록에도 영향을 주는 타입
  /// 지금은 1번 타입으로 해놨지만 언제든지 주석처리된 코드를 주석해제하면 2번타입으로 변경 가능
  void changeDurationOfScheduleForUpDownBtn(
      int index, double delta, bool isUp) {
    Duration timeDelta = heightToDuration(delta.abs());

    // 1번 타입

    if (delta > 0) {
      // 아래로 당기는 경우
      if (isUp == true) {
        // 윗쪽 핸들 아래로 당김
        durationSchedule[index - 1].duration += timeDelta;
      } else {
        // 아랫쪽 핸들 아래로 당김
        durationSchedule[index].duration += timeDelta;
      }
    } else {
      // delta가 음수로, duration이 감소하는 케이스이므로
      // 감소 전에 minimumScheduleBoxDuration과 비교해 최소높이가 되는지 여부를 확인하는 과정이 추가됨
      // 위로 당기는 경우
      if (isUp == true) {
        // 위쪽 핸들을 위로 당김
        if (durationSchedule[index - 1].duration - timeDelta >
            minimumScheduleBoxDuration) {
          durationSchedule[index - 1].duration -= timeDelta;
        } else {
          durationSchedule[index - 1].duration = minimumScheduleBoxDuration;
        }
      } else {
        // 아래쪽 핸들을 위로 당김
        if (durationSchedule[index].duration - timeDelta >
            minimumScheduleBoxDuration) {
          durationSchedule[index].duration -= timeDelta;
        } else {
          durationSchedule[index].duration = minimumScheduleBoxDuration;
        }
      }
    }

    /// 2번 타입

    /// 1. delta 부호 판단
    /// 2. 1개만 있는 경우
    /// 3. isUp 판단
    /// 4. index 판단
    /// 5. 최소 시간단위 여부 판단

    // int lastIndex = durationSchedule.length - 1;
    // if (delta > 0) {
    //   // 아래로 당기는 경우
    //   if (lastIndex == 0) {
    //     durationSchedule[0].duration += timeDelta;
    //   } else if (isUp == true) {
    //     // 윗쪽 핸들 아래로 당김
    //     // 이 경우 항상 앞 스케줄이 존재함
    //     if (durationSchedule[index].duration - timeDelta >
    //         minimumScheduleBoxDuration) {
    //       durationSchedule[index].duration -= timeDelta;
    //       durationSchedule[index - 1].duration += timeDelta;
    //     } else {
    //       durationSchedule[index - 1].duration +=
    //           durationSchedule[index].duration - minimumScheduleBoxDuration;
    //       durationSchedule[index].duration = minimumScheduleBoxDuration;
    //     }
    //   } else {
    //     // 아랫쪽 핸들 아래로 당김
    //     if (index == lastIndex) {
    //       durationSchedule[index].duration += timeDelta;
    //     } else {
    //       if (durationSchedule[index + 1].duration - timeDelta >
    //           minimumScheduleBoxDuration) {
    //         durationSchedule[index].duration += timeDelta;
    //         durationSchedule[index + 1].duration -= timeDelta;
    //       } else {
    //         durationSchedule[index].duration +=
    //             durationSchedule[index + 1].duration -
    //                 minimumScheduleBoxDuration;
    //         durationSchedule[index + 1].duration = minimumScheduleBoxDuration;
    //       }
    //     }
    //   }
    // } else {
    //   // 위로 당기는 경우
    //   if (lastIndex == 0) {
    //     if (durationSchedule[0].duration - timeDelta <
    //         minimumScheduleBoxDuration) {
    //       durationSchedule[0].duration = minimumScheduleBoxDuration;
    //     } else {
    //       durationSchedule[0].duration -= timeDelta;
    //     }
    //   } else {
    //     if (isUp == true) {
    //       // 위쪽 핸들을 위로 당김
    //       // 이 경우 항상 앞 스케줄이 존재함
    //       if (durationSchedule[index - 1].duration - timeDelta >
    //           minimumScheduleBoxDuration) {
    //         durationSchedule[index - 1].duration -= timeDelta;
    //         durationSchedule[index].duration += timeDelta;
    //       } else {
    //         durationSchedule[index - 1].duration = minimumScheduleBoxDuration;
    //         durationSchedule[index].duration +=
    //             durationSchedule[index - 1].duration -
    //                 minimumScheduleBoxDuration;
    //       }
    //     } else {
    //       // 아래쪽 핸들을 위로 당김
    //       if (index == lastIndex) {
    //         durationSchedule[index].duration -= timeDelta;
    //       } else {
    //         if (durationSchedule[index].duration - timeDelta >
    //             minimumScheduleBoxDuration) {
    //           durationSchedule[index + 1].duration += timeDelta;
    //           durationSchedule[index].duration -= timeDelta;
    //         } else {
    //           durationSchedule[index + 1].duration +=
    //               durationSchedule[index].duration - minimumScheduleBoxDuration;
    //           durationSchedule[index].duration = minimumScheduleBoxDuration;
    //         }
    //       }
    //     }
    //   }
    // }
    notifyListeners();
  }

  void onChangeScheduleOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex = newIndex - 1;
    }

    final PlaceDurationOnly temp = durationSchedule.removeAt(oldIndex);
    durationSchedule.insert(newIndex, temp);
    notifyListeners();
  }
}
