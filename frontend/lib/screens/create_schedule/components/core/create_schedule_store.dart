import 'package:flutter/material.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/schedule_class.dart';

///Create Schedule Screen을 위한 `Store`
///클래스간 getter setter 이동보다는 Store 사용을 지향하도록 함

class CreateScheduleStore extends ChangeNotifier {
  /// 스케줄 날짜
  late DateTime scheduleDate;

  /// 스케줄 리스트
  List<Schedule> scheduleList = [];
  void clearScheduleList() {
    scheduleList = [];
    notifyListeners();
  }

  Duration getScheduleDuration() {
    Duration sum = Duration.zero;
    for (Schedule schedule in scheduleList) {
      sum += schedule.duration;
    }
    return sum;
  }

  /// 전체 스케줄의 시작시간을 저장하는 변수
  late DateTime scheduleListStartsAt;

  /// 스케줄을 추가할 때 호출하는 함수
  void addSchedule(Schedule schedule) {
    schedule.duration = const Duration(hours: 1);
    scheduleList.add(schedule.copy());
    calSchedulesStartsAndEndsAt();
    notifyListeners();
  }

  /// 스케줄을 삭제할 때 호출하는 함수
  void removeSchedule(int scheduleIndex) {
    scheduleList.removeAt(scheduleIndex);
    calSchedulesStartsAndEndsAt();
    notifyListeners();
  }

  /// 스케줄 시작시간 조정 여부 확인용 변수
  bool isDecidingScheduleStartsAt = false;

  /// 스케줄 시작시간 조정 시작 / 종료시 호출
  void toggleIsDecidingScheduleStartsAt() {
    isDecidingScheduleStartsAt = !isDecidingScheduleStartsAt;
    notifyListeners();
  }

  /// 스케줄 시작시간을 사용자에게 입력받을 때
  /// 해당 시간이 적용이 가능한지 여부를 확인하는 함수 (bool)
  bool checkIfScheduleListStartsAtSettable(
      DateTime startsAt, int scheduleIndex) {
    if (scheduleList.isNotEmpty) {
      Duration sum = Duration.zero;
      for (int i = scheduleIndex; i > 0; i--) {
        sum += scheduleList[i].duration;
      }
      if (sum > startsAt.difference(scheduleDate)) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  /// 스케줄 시작시간이 바뀔 때 호출
  /// 인덱스를 지정해서 전체 스케줄 시작시간을 계산할수도 있음
  void setScheduleListStartsAt(DateTime startsAt, int? scheduleIndex) {
    if (scheduleList.isNotEmpty) {
      if (scheduleIndex == null) {
        for (Schedule schedule in scheduleList) {
          schedule.changeAndSetStartsAt(startsAt);
          startsAt = schedule.endsAt!;
        }
      } else {
        DateTime _startsAt = startsAt;
        for (int i = scheduleIndex; i > 0; i--) {
          scheduleList[i - 1].changeAndSetEndsAt(_startsAt);
          _startsAt = scheduleList[i - 1].startsAt!;
        }
        _startsAt = startsAt;
        for (int i = scheduleIndex; i < scheduleList.length; i++) {
          scheduleList[i].changeAndSetStartsAt(_startsAt);
          _startsAt = scheduleList[i - 1].endsAt!;
        }
      }
    }
    notifyListeners();
  }

  /// 새로운 블록이 추가 / 삭제될 때, 블록 순서가 바뀔때 등에 호출하는 함수로
  /// 블록별 시간을 계산해 넣어줌
  void calSchedulesStartsAndEndsAt() {
    DateTime tempStartsAt = scheduleListStartsAt;
    if (scheduleList.isNotEmpty) {
      for (Schedule schedule in scheduleList) {
        schedule.changeAndSetStartsAt(tempStartsAt);
        tempStartsAt = schedule.endsAt!;
      }
    }
    notifyListeners();
  }

  /// 블록 순서 바꿀 때 호출하는 함수
  void onChangeScheduleOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final Schedule temp = scheduleList.removeAt(oldIndex);
    scheduleList.insert(newIndex, temp);
    calSchedulesStartsAndEndsAt();
    notifyListeners();
  }

  /// 스케줄의 시작시간을 얻어오는 함수
  /// 쓸지 안쓸지 모름 컴쿰
  DateTime getScheduleListStartsAt() {
    return scheduleList[0].startsAt!;
  }

  /// 스케줄 삭제 / 순서 바꾸기 위한
  /// 드래그가 진행중인지 여부를 확인하는 변수
  bool isScheduleBoxDragging = false;

  /// 현재 드래그중인 스케줄의 인덱스
  late int indexOfDraggingScheduleBox;

  /// 스케줄 드래그 시작시 호출
  void onScheduleBoxDragStart(int scheduleIndex) {
    isScheduleBoxDragging = true;
    indexOfDraggingScheduleBox = scheduleIndex;
    notifyListeners();
  }

  /// 스케줄 드래그 종료시 호출
  void onScheduleBoxDragEnd() {
    isScheduleBoxDragging = false;
    notifyListeners();
  }

  /// 스케줄 리사이징중인지 여부를 확인하는 변수
  bool isScheduleBoxResizing = false;

  /// 스케줄 리사이징 시작 및 종료시 호출
  void toggleIsScheduleBoxDragging() {
    isScheduleBoxResizing = !isScheduleBoxResizing;
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
      Duration scheduleDuration = getScheduleDuration();
      if (isUp == true) {
        // 윗쪽 핸들 아래로 당김
        if (scheduleDuration + timeDelta < const Duration(days: 1)) {
          scheduleList[index - 1].duration += timeDelta;
        } else {
          scheduleList[index - 1].duration +=
              (const Duration(days: 1) - scheduleDuration);
        }
      } else {
        // 아랫쪽 핸들 아래로 당김
        if (scheduleDuration + timeDelta < const Duration(days: 1)) {
          scheduleList[index].duration += timeDelta;
        } else {
          scheduleList[index].duration +=
              (const Duration(days: 1) - scheduleDuration);
        }
      }
    } else {
      // delta가 음수로, duration이 감소하는 케이스이므로
      // 감소 전에 minimumScheduleBoxDuration과 비교해 최소높이가 되는지 여부를 확인하는 과정이 추가됨
      // 위로 당기는 경우
      if (isUp == true) {
        // 위쪽 핸들을 위로 당김
        if (scheduleList[index - 1].duration - timeDelta >
            minimumScheduleBoxDuration) {
          scheduleList[index - 1].duration -= timeDelta;
        } else {
          scheduleList[index - 1].duration = minimumScheduleBoxDuration;
        }
      } else {
        // 아래쪽 핸들을 위로 당김
        if (scheduleList[index].duration - timeDelta >
            minimumScheduleBoxDuration) {
          scheduleList[index].duration -= timeDelta;
        } else {
          scheduleList[index].duration = minimumScheduleBoxDuration;
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

  /// 타임라인 스크롤 높이를 저장하는 변수
  /// 쓸지 안쓸지 모름 컴쿰
  late double timeLineScrollHeight;

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

  /// 중요한 변수들을 초기화함
  /// 스케줄 생성 스크린 pop시 호출
  void onPopCreateScheduleScreen() {
    clearScheduleList();
    onEndMakingCustomBlock();
    onScheduleBoxDragEnd();
  }
}
