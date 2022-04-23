import 'package:flutter/material.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place.dart';

///Create Schedule Screen을 위한 `Store`
///클래스간 getter setter 이동보다는 Store 사용을 지향하도록 함

class CreateScheduleStore extends ChangeNotifier {
  /// 현재 스크린의 인덱스를 확인하는 변수
  /// 0 : create_duration_screen
  /// 1 : set_primary_schedule_screen
  /// Navigation에서 유용하게 사용됨
  int currentScreenIndex = 0;

  /// 생성되는 스케줄의 날짜, `create_schedule_screen.dart`에서 init
  late DateTime scheduleDate;

  /// 중요한 변수들을 초기화함
  void onPopCreateDurationScheduleScreen() {
    currentScreenIndex = 0;
    if (isDetailBeingMade) {
      toggleIsDetailBeingMade();
    }
    clearDurationSchedule();
    onEndBlockResizing();
    onEndDecidePrimarySchedule();
    onEndMakingCustomBlock();
  }

  void onPopSetPrimaryScheduleScreen() {
    currentScreenIndex = 0;
  }

  // AppBar에서 사용할 onPop 함수
  void onPopCreateScheduleScreens() {
    switch (currentScreenIndex) {
      case 0:
        onPopCreateDurationScheduleScreen();
        break;
      case 1:
        onPopSetPrimaryScheduleScreen();
    }
  }

  ///
  /// 이하는 CreateDurationScheduleScreen 관련
  ///

  /// 스케줄 DurationLine ScrollHeight
  double durationLineHeight = 0;

  /// Duration만 존재하는 PlaceDurationOnly class 객체로 이루어진
  /// 스케줄 List
  List<PlaceDurationOnly> durationSchedule = [];

  /// durationSchedule은 하나의 스케줄이 isPrimary = true(고정일정)여야 일정 결정이 가능함
  /// 이를 체크하는 함수
  /// isPrimary가 하나인지 여부는 검사하지 않음에 유의 (두개 이상일 경우는 디텍트 안함)
  bool checkIfDurationScheduleAbleToMakeDetail() {
    for (PlaceDurationOnly place in durationSchedule) {
      if (place.isPrimary) {
        return true;
      }
    }
    return false;
  }

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
    isDecidingPrimarySchedule = false; // PrimarySchedule 생성중이라면 해당 과정 종료
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

  /// durationSchedule에서 스케줄을 삭제하는 함수
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

  /// 스케줄 순서 조정시에 사용되는 함수
  /// isPrimary도 고려해서 옮길 수 있는지 여부까지 판단함 (옮길 수 없으면 return)
  void onChangeScheduleOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    // else {
    //   // isPrimary를 고려해서 옮길 수 있는지 여부를 판단해야 함

    //   int primaryScheduleIndex = 999;
    //   Duration beforePrimaryStartsAt = Duration.zero;
    //   Duration sum = Duration.zero;
    //   for (int i = oldIndex; i >= 0; i--) {
    //     if (durationSchedule[i].isPrimary) {
    //       beforePrimaryStartsAt =
    //           durationSchedule[i].startsAt!.difference(scheduleDate);
    //       primaryScheduleIndex = i;
    //     } else if (primaryScheduleIndex != 999) {
    //       sum += durationSchedule[i].duration;
    //     }
    //   }

    //   if (primaryScheduleIndex != 999) {
    //     if (sum + durationSchedule[oldIndex].duration > beforePrimaryStartsAt) {
    //       return;
    //     }
    //   }
    // }

    final PlaceDurationOnly temp = durationSchedule.removeAt(oldIndex);
    durationSchedule.insert(newIndex, temp);
    notifyListeners();
  }

  /// primary 스케줄 결정중 여부 확인
  bool isDecidingPrimarySchedule = false;

  /// 현재 결정중인 primary schedule의 인덱스
  late int currentlyDecidingPrimarySchedule;

  /// primary 스케줄 결정 시작시 호출
  void onDecidePrimarySchedule(int _currentlyDecidingPrimarySchedule) {
    isDecidingPrimarySchedule = true;
    currentlyDecidingPrimarySchedule = _currentlyDecidingPrimarySchedule;
    onEndMakingCustomBlock(); // 커스텀 블록 생성중일시 블록 생성 중지
    notifyListeners();
  }

  /// primary 스케줄 결정 끝날시 호출
  void onEndDecidePrimarySchedule() {
    isDecidingPrimarySchedule = false;
    notifyListeners();
  }

  /// primary 스케줄 시간 결정시, 해당 스케줄의 시작 시간과 전후 스케줄을 고려해
  /// 해당 시작 시간을 수용할 수 있는지 여부를 판단하는 데에 사용하는 함수
  bool checkIfPrimaryScheduleDecideAble(DateTime _primaryScheduleStartsAt) {
    Duration beforePrimaryStartsAt =
        _primaryScheduleStartsAt.difference(scheduleDate);
    Duration afterPrimaryStartsAt = scheduleDate
        .add(const Duration(days: 1))
        .difference(_primaryScheduleStartsAt);
    Duration sum = Duration.zero;

    if (currentlyDecidingPrimarySchedule != 0) {
      for (int i = currentlyDecidingPrimarySchedule - 1; i >= 0; i--) {
        sum += durationSchedule[i].duration;
      }

      if (beforePrimaryStartsAt < sum) {
        return false;
      }

      sum = Duration.zero;
    }

    for (int i = currentlyDecidingPrimarySchedule;
        i < durationSchedule.length;
        i++) {
      sum += durationSchedule[i].duration;
    }
    if (afterPrimaryStartsAt < sum) {
      return false;
    }
    return true;
  }

  /// primary Schedule 시작시간
  late DateTime primaryScheduleStartsAt;

  /// primary 스케줄 시간 결정시 호출
  void setPrimarySchedule(DateTime _primaryScheduleStartsAt) {
    for (PlaceDurationOnly place in durationSchedule) {
      place.isPrimary = false;
      // 먼저 기존 primary 스케줄 초기화
    }

    durationSchedule[currentlyDecidingPrimarySchedule].isPrimary = true;
    durationSchedule[currentlyDecidingPrimarySchedule].startsAt =
        _primaryScheduleStartsAt;

    primaryScheduleStartsAt = _primaryScheduleStartsAt;

    onEndDecidePrimarySchedule();
    notifyListeners();
  }

  /// primary 스케줄 설정 해제시 호출 (핀버튼 클릭시)
  void undoPrimarySchedule(int primaryScheduleIndex) {
    durationSchedule[primaryScheduleIndex].isPrimary = false;
    notifyListeners();
  }
}
