import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/screens/create_schedule/components/class/schedule_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/modified_custom_info_window.dart';

/// Create Schedule Screen을 위한 `Store`
/// 클래스간 getter setter 이동보다는 Store 사용을 지향하도록 함

class CreateScheduleStore with ChangeNotifier {
  /// 스케줄 날짜
  late DateTime scheduleDate;

  /// 스케줄 리스트
  List<Place> scheduleList = [];
  void clearScheduleList() {
    scheduleList = [];
    notifyListeners();
  }

  Duration getScheduleDuration() {
    Duration sum = Duration.zero;
    for (Place schedule in scheduleList) {
      sum += schedule.duration;
    }
    sum += scheduleListStartsAt.difference(scheduleDate);
    return sum;
  }

  /// 고정 / 유동 토글용 함수
  void toggleScheduleFixedOrNot(int scheduleIndex) {
    scheduleList[scheduleIndex].isFixed = !scheduleList[scheduleIndex].isFixed;
    notifyListeners();
  }

  /// 전체 스케줄의 시작시간을 저장하는 변수
  late DateTime scheduleListStartsAt;

  /// 스케줄을 추가할 때 호출하는 함수
  void addSchedule(Place schedule) {
    schedule.duration = const Duration(hours: 1);
    scheduleList.add(schedule.copy());
    calSchedulesStartsAndEndsAt();
    notifyListeners();
  }

  /// 스케줄을 삭제할 때 호출하는 함수
  void removeSchedule(int scheduleIndex) {
    if (_isFixedExistsDownside(scheduleIndex)) {
      Duration removedDuration = scheduleList[scheduleIndex].duration;
      if (scheduleIndex == 0) {
        scheduleListStartsAt = scheduleListStartsAt.add(removedDuration);
      } else {
        scheduleList[scheduleIndex - 1].duration += removedDuration;
      }
    }

    scheduleList.removeAt(scheduleIndex);
    calSchedulesStartsAndEndsAt();

    // 스케줄 시작시간을 조정중에 삭제할 경우
    // 경우에 따라 indexOfcurrentlyDecidingStartsAtSchedule, indexOfPlaceDecidingSchedule을 바꿔줘야 함
    if (isDecidingScheduleStartsAt) {
      if (indexOfcurrentlyDecidingStartsAtSchedule != 0) {
        indexOfcurrentlyDecidingStartsAtSchedule--;
      }
    }
    if (indexOfPlaceDecidingSchedule != 0) {
      indexOfPlaceDecidingSchedule--;
    }
    notifyListeners();
  }

  /// 스케줄 시작시간 조정 여부 확인용 변수
  bool isDecidingScheduleStartsAt = false;

  void onDecidingScheduleStartsAtStart() {
    isDecidingScheduleStartsAt = true;
    resetDatePicker();
    tabController.animateTo(0);
    notifyListeners();
  }

  void onDecidingScheduleStartsAtEnd() {
    isDecidingScheduleStartsAt = false;
    notifyListeners();
  }

  /// 현재 시작시간을 변경중인 스케줄의 인덱스
  late int indexOfcurrentlyDecidingStartsAtSchedule;
  late Place currentlyDecidingStartsAtSchedule;

  late DateTime currentlySelectedTime;

  void setCurrentlySelectedTime(DateTime _currentlySelectedTime) {
    currentlySelectedTime = _currentlySelectedTime;
    notifyListeners();
  }

  void setIndexOfcurrentlyDecidingStartsAtSchedule(int index) {
    indexOfcurrentlyDecidingStartsAtSchedule = index;
    setCurrentlyDecidingStartsAtSchedule();
    setCurrentlySelectedTime(currentlyDecidingStartsAtSchedule.startsAt!);
    notifyListeners();
  }

  /// 시작시간 전 회색영역 탭 여부 확인용 변수
  bool isBeforeStartTap = false;

  void onBeforeStartTap() {
    isBeforeStartTap = true;
    setCurrentlyDecidingStartsAtSchedule();
    setCurrentlySelectedTime(currentlyDecidingStartsAtSchedule.startsAt!);
    notifyListeners();
  }

  void onBeforeStartTapEnd() {
    isBeforeStartTap = false;
    notifyListeners();
  }

  void setCurrentlyDecidingScheduleStartsAtBeforeStart() {
    currentlyDecidingStartsAtSchedule = Place(
        nameKor: "전체 일정 시작시간",
        placeType: "dummy",
        color: const Color.fromARGB(157, 69, 69, 69),
        duration: Duration.zero,
        startsAt: scheduleListStartsAt);
    notifyListeners();
  }

  void setCurrentlyDecidingStartsAtSchedule() {
    if (isBeforeStartTap) {
      setCurrentlyDecidingScheduleStartsAtBeforeStart();
    } else {
      currentlyDecidingStartsAtSchedule =
          scheduleList[indexOfcurrentlyDecidingStartsAtSchedule];
    }
    // createTimePickerSpinner();
    notifyListeners();
  }

  /// TimePickerSpinner를 리셋하기 위해
  /// 스피너에 글로벌 키를 주고, 블록이 바뀔때마다
  /// 리셋을 호출해 리셋함
  late GlobalKey datePickerKey;
  void resetDatePicker() {
    datePickerKey = GlobalKey();
    notifyListeners();
  }

  /// 스케줄 시작시간을 사용자에게 입력받을 때
  /// 해당 시간이 적용이 가능한지 여부를 확인하는 함수 (bool)
  bool checkIfScheduleListStartsAtSettable(DateTime startsAt) {
    bool _checkAfterStartsAt(DateTime startsAt) {
      Duration sum = Duration.zero;
      for (int i = indexOfcurrentlyDecidingStartsAtSchedule;
          i < scheduleList.length;
          i++) {
        sum += scheduleList[i].duration;
      }

      if (sum >
          scheduleDate.add(const Duration(days: 1)).difference(startsAt)) {
        return false;
      } else {
        return true;
      }
    }

    bool _checkBeforeStartsAt(DateTime startsAt) {
      Duration sum = Duration.zero;
      for (int i = indexOfcurrentlyDecidingStartsAtSchedule - 1; i >= 0; i--) {
        sum += scheduleList[i].duration;
      }

      if (sum > startsAt.difference(scheduleDate)) {
        return false;
      } else {
        return true;
      }
    }

    if (scheduleList.isNotEmpty) {
      if (indexOfcurrentlyDecidingStartsAtSchedule == 0) {
        return _checkAfterStartsAt(startsAt);
      }

      if (_checkBeforeStartsAt(startsAt)) {
        return _checkAfterStartsAt(startsAt);
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  /// 시작시간 바꿨을 때
  /// 스케줄의 시작시간으로 자동 스크롤
  void scrollToScheduleListStartsAt() {
    timeLineScrollController.animateTo(
        dateTimeToHeight(scheduleListStartsAt) - 10,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutExpo);
    notifyListeners();
  }

  /// 스케줄 시작시간이 바뀔 때 호출
  /// 인덱스를 지정해서 전체 스케줄 시작시간을 계산할수도 있음
  void setScheduleListStartsAt(DateTime startsAt) {
    if (scheduleList.isNotEmpty) {
      DateTime _startsAt = startsAt;
      for (int i = indexOfcurrentlyDecidingStartsAtSchedule; i > 0; i--) {
        scheduleList[i - 1].changeAndSetEndsAt(_startsAt);
        _startsAt = scheduleList[i - 1].startsAt!;
      }
      _startsAt = startsAt;
      for (int i = indexOfcurrentlyDecidingStartsAtSchedule;
          i < scheduleList.length;
          i++) {
        scheduleList[i].changeAndSetStartsAt(_startsAt);
        _startsAt = scheduleList[i].endsAt!;
      }

      scheduleListStartsAt = getScheduleListStartsAt();
    } else {
      scheduleListStartsAt = startsAt;
    }
    notifyListeners();
  }

  /// 스케줄의 시작시간을 얻어오는 함수
  DateTime getScheduleListStartsAt() {
    return scheduleList[0].startsAt!;
  }

  /// 새로운 블록이 추가 / 삭제될 때, 블록 순서가 바뀔때 등에 호출하는 함수로
  /// 블록별 시간을 계산해 넣어줌
  void calSchedulesStartsAndEndsAt() {
    DateTime tempStartsAt = scheduleListStartsAt;
    if (scheduleList.isNotEmpty) {
      for (int i = 0; i < scheduleList.length; i++) {
        scheduleList[i].changeAndSetStartsAt(tempStartsAt);
        tempStartsAt = scheduleList[i].endsAt!;
      }
    }
    notifyListeners();
  }

  /// 블록 순서 바꿀 때 호출하는 함수
  void onChangeScheduleOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final Place temp = scheduleList.removeAt(oldIndex);
    scheduleList.insert(newIndex, temp);
    calSchedulesStartsAndEndsAt();
    notifyListeners();
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
    tabController.animateTo(0);
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

  bool _isFixedExistsDownside(int _index) {
    for (int i = _index + 1; i < scheduleList.length; i++) {
      if (scheduleList[i].isFixed) {
        return true;
      }
    }
    return false;
  }

  bool _isFixedExistsUpside(int _index) {
    for (int i = _index - 1; i >= 0; i--) {
      if (scheduleList[i].isFixed) {
        return true;
      }
    }
    return false;
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

    if (tabController.index != 0) {
      tabController.animateTo(0);
    }

    // 1번 타입

    if (delta > 0) {
      // 아래로 당기는 경우
      Duration scheduleDuration = getScheduleDuration();
      if (isUp == true) {
        // 윗쪽 핸들 아래로 당김
        if (index == 0) {
          indexOfcurrentlyDecidingStartsAtSchedule = 0;
          if (scheduleList[0].duration - timeDelta >
              minimumScheduleBoxDuration) {
            scheduleList[0].duration -= timeDelta;
            setScheduleListStartsAt(scheduleList[0].startsAt!.add(timeDelta));
          } else {
            scheduleList[0].duration = minimumScheduleBoxDuration;
            setScheduleListStartsAt(
                scheduleList[0].endsAt!.subtract(minimumScheduleBoxDuration));
          }
        } else if (!scheduleList[index - 1].isFixed) {
          if (_isFixedExistsDownside(index)) {
            if (scheduleList[index].duration - timeDelta >=
                minimumScheduleBoxDuration) {
              scheduleList[index - 1].duration += timeDelta;
              scheduleList[index].duration -= timeDelta;
            } else {
              scheduleList[index - 1].duration +=
                  scheduleList[index].duration - minimumScheduleBoxDuration;
              scheduleList[index].duration = minimumScheduleBoxDuration;
            }
          } else {
            if (scheduleDuration + timeDelta <= const Duration(days: 1)) {
              scheduleList[index - 1].duration += timeDelta;
            } else {
              scheduleList[index - 1].duration +=
                  (const Duration(days: 1) - scheduleDuration);
            }
          }
        } else {
          // 아무것도 안함
        }
      } else {
        // 아랫쪽 핸들 아래로 당김
        if (index == scheduleList.length - 1) {
          if (scheduleDuration + timeDelta < const Duration(days: 1)) {
            scheduleList[index].duration += timeDelta;
          } else {
            scheduleList[index].duration +=
                (const Duration(days: 1) - scheduleDuration);
          }
        } else if (!scheduleList[index + 1].isFixed) {
          if (_isFixedExistsDownside(index)) {
            if (scheduleList[index + 1].duration - timeDelta >=
                minimumScheduleBoxDuration) {
              scheduleList[index].duration += timeDelta;
              scheduleList[index + 1].duration -= timeDelta;
            } else {
              scheduleList[index].duration +=
                  scheduleList[index + 1].duration - minimumScheduleBoxDuration;
              scheduleList[index + 1].duration = minimumScheduleBoxDuration;
            }
          } else {
            if (scheduleDuration + timeDelta < const Duration(days: 1)) {
              scheduleList[index].duration += timeDelta;
            } else {
              scheduleList[index].duration +=
                  (const Duration(days: 1) - scheduleDuration);
            }
          }
        } else {}
      }
    } else {
      // delta가 음수로, duration이 감소하는 케이스이므로
      // 감소 전에 minimumScheduleBoxDuration과 비교해 최소높이가 되는지 여부를 확인하는 과정이 추가됨
      // 위로 당기는 경우
      if (isUp == true) {
        // 위쪽 핸들을 위로 당김
        if (index == 0) {
          indexOfcurrentlyDecidingStartsAtSchedule = 0;
          if (scheduleList[0]
              .startsAt!
              .subtract(timeDelta)
              .isAfter(scheduleDate)) {
            scheduleList[0].duration += timeDelta;
            setScheduleListStartsAt(
                scheduleList[0].startsAt!.subtract(timeDelta));
          } else {
            scheduleList[0].duration =
                scheduleList[0].endsAt!.difference(scheduleDate);
            setScheduleListStartsAt(scheduleDate);
          }
        } else if (!scheduleList[index - 1].isFixed) {
          if (_isFixedExistsUpside(index) || _isFixedExistsDownside(index)) {
            if (scheduleList[index - 1].duration - timeDelta >=
                minimumScheduleBoxDuration) {
              scheduleList[index - 1].duration -= timeDelta;
              scheduleList[index].duration += timeDelta;
            } else {
              scheduleList[index].duration +=
                  scheduleList[index - 1].duration - minimumScheduleBoxDuration;
              scheduleList[index - 1].duration = minimumScheduleBoxDuration;
            }
          } else {
            if (scheduleList[index - 1].duration - timeDelta >=
                minimumScheduleBoxDuration) {
              scheduleList[index - 1].duration -= timeDelta;
            } else {
              scheduleList[index - 1].duration = minimumScheduleBoxDuration;
            }
          }
        } else {
          // 아무것도 안함
        }
      } else {
        // 아래쪽 핸들을 위로 당김
        if (index == scheduleList.length - 1) {
          if (scheduleList[index].duration - timeDelta >=
              minimumScheduleBoxDuration) {
            scheduleList[index].duration -= timeDelta;
          } else {
            scheduleList[index].duration = minimumScheduleBoxDuration;
          }
        } else if (!scheduleList[index + 1].isFixed) {
          if (_isFixedExistsDownside(index)) {
            if (scheduleList[index].duration - timeDelta >=
                minimumScheduleBoxDuration) {
              scheduleList[index].duration -= timeDelta;
              scheduleList[index + 1].duration += timeDelta;
            } else {
              scheduleList[index + 1].duration +=
                  scheduleList[index].duration - minimumScheduleBoxDuration;
              scheduleList[index].duration = minimumScheduleBoxDuration;
            }
          } else {
            if (scheduleList[index].duration - timeDelta >=
                minimumScheduleBoxDuration) {
              scheduleList[index].duration -= timeDelta;
            } else {
              scheduleList[index].duration = minimumScheduleBoxDuration;
            }
          }
        } else {}
      }
    }

    /// 1-1번 타입
    // if (delta > 0) {
    //   // 아래로 당기는 경우
    //   Duration scheduleDuration = getScheduleDuration();
    //   if (isUp == true) {
    //     // 윗쪽 핸들 아래로 당김
    //     if (index == 0) {
    //       indexOfcurrentlyDecidingStartsAtSchedule = 0;
    //       if (scheduleList[0].duration - timeDelta >
    //           minimumScheduleBoxDuration) {
    //         scheduleList[0].duration -= timeDelta;
    //         setScheduleListStartsAt(scheduleList[0].startsAt!.add(timeDelta));
    //       } else {
    //         scheduleList[0].duration = minimumScheduleBoxDuration;
    //         setScheduleListStartsAt(
    //             scheduleList[0].endsAt!.subtract(minimumScheduleBoxDuration));
    //       }
    //     } else if (!scheduleList[index - 1].isFixed) {
    //       if (scheduleDuration + timeDelta < const Duration(days: 1)) {
    //         scheduleList[index - 1].duration += timeDelta;
    //       } else {
    //         scheduleList[index - 1].duration +=
    //             (const Duration(days: 1) - scheduleDuration);
    //       }
    //     } else {
    //       // 아무것도 안함
    //     }
    //   } else {
    //     // 아랫쪽 핸들 아래로 당김
    //     if (scheduleDuration + timeDelta < const Duration(days: 1)) {
    //       scheduleList[index].duration += timeDelta;
    //     } else {
    //       scheduleList[index].duration +=
    //           (const Duration(days: 1) - scheduleDuration);
    //     }
    //   }
    // } else {
    //   // delta가 음수로, duration이 감소하는 케이스이므로
    //   // 감소 전에 minimumScheduleBoxDuration과 비교해 최소높이가 되는지 여부를 확인하는 과정이 추가됨
    //   // 위로 당기는 경우
    //   if (isUp == true) {
    //     // 위쪽 핸들을 위로 당김
    //     if (index == 0) {
    //       indexOfcurrentlyDecidingStartsAtSchedule = 0;
    //       if (scheduleList[0]
    //           .startsAt!
    //           .subtract(timeDelta)
    //           .isAfter(scheduleDate)) {
    //         scheduleList[0].duration += timeDelta;
    //         setScheduleListStartsAt(
    //             scheduleList[0].startsAt!.subtract(timeDelta));
    //       } else {
    //         scheduleList[0].duration =
    //             scheduleList[0].endsAt!.difference(scheduleDate);
    //         setScheduleListStartsAt(scheduleDate);
    //       }
    //     } else if (!scheduleList[index - 1].isFixed) {
    //       if (scheduleList[index - 1].duration - timeDelta >
    //           minimumScheduleBoxDuration) {
    //         scheduleList[index - 1].duration -= timeDelta;
    //       } else {
    //         scheduleList[index - 1].duration = minimumScheduleBoxDuration;
    //       }
    //     } else {
    //       // 아무것도 안함
    //     }
    //   } else {
    //     // 아래쪽 핸들을 위로 당김
    //     if (scheduleList[index].duration - timeDelta >
    //         minimumScheduleBoxDuration) {
    //       scheduleList[index].duration -= timeDelta;
    //     } else {
    //       scheduleList[index].duration = minimumScheduleBoxDuration;
    //     }
    //   }
    // }

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
    calSchedulesStartsAndEndsAt();
    notifyListeners();
  }

  /// 타임라인 스크롤 높이를 저장하는 변수
  late double timeLineScrollHeight;

  /// 타임라인 너비 조정용
  /// Flex값이므로 %라고 생각하면 됨
  int timelineWidthFlex = 47;
  void setTimeLineWidthFlex(int flex) {
    timelineWidthFlex = flex;
    notifyListeners();
  }

  void setTimeLineWidthFlexByTabIndex(int tabIndex) {
    setTimeLineWidthFlex([47, 30, 30][tabIndex]);
  }

  /// 타임라인의 박스가 들어가는 곳 너비를 넣는 변수
  /// TimeLine 위젯에서 계산해서 넣고
  /// OnScheduleBoxLongPress(isFeedback:true)에서 사용함
  /// 타임라인 너비 조정용이 아님!!
  late double timeLineBoxAreaWidth;
  void setTimeLineBoxAreaWidth(double width) {
    timeLineBoxAreaWidth = width;
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

  /// 중요한 변수들을 초기화함
  /// 스케줄 생성 스크린 pop시 호출
  void onPopCreateScheduleScreen() {
    clearScheduleList();
    setCurrentlyDecidingScheduleStartsAtBeforeStart();
    onEndMakingCustomBlock();
    onScheduleBoxDragEnd();
    setTimeLineWidthFlexByTabIndex(0);
    setIndexOfPlaceDecidingSchedule(0);
    onPlaceRecommendedEnd();
    onDecidingScheduleStartsAtEnd();
    onLookingPlaceDetailEnd();
    onCreateRouteTabEnd();
    clearScheduleCreated();
    isBeforeStartTap = false;
  }

  ///
  /// 이하 장소 선택 탭을 위한 Store
  ///

  /// 현재 장소를 선택중인 스케줄의 인덱스
  int indexOfPlaceDecidingSchedule = 0;
  void setIndexOfPlaceDecidingSchedule(int index) {
    indexOfPlaceDecidingSchedule = index;
    notifyListeners();
  }

  /// ## 현재 상황에서 추천에 필요한 좌표를 반환하는 함수
  /// ~~~json
  /// { "type": PlaceType(String), "latlng": LatLng}
  /// ~~~
  /// 추천에 사용할 좌표가 전혀 없다면 사용자의 현 위치를 반환함(`"type":"userPosition"`)
  ///
  /// `indexOfPlaceDecidingSchedule`이 사용됨을 참고
  Future<Map<String, dynamic>> getLatLngForPlaceRecommend() async {
    if (indexOfPlaceDecidingSchedule != 0) {
      for (int i = indexOfPlaceDecidingSchedule - 1; i >= 0; i--) {
        if (scheduleList[i].place != null) {
          return {
            "type": scheduleList[i].placeType,
            "latlng": scheduleList[i].place!
          };
        }
      }
    }
    for (int i = indexOfPlaceDecidingSchedule + 1;
        i < scheduleList.length;
        i++) {
      if (scheduleList[i].place != null) {
        return {
          "type": scheduleList[i].placeType,
          "latlng": scheduleList[i].place!
        };
      }
    }

    return {
      "type": scheduleList[indexOfPlaceDecidingSchedule].placeType,
      "latlng": await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high)
    };
  }

  /// '다른 장소를 중심으로 추천받기'가 가능한지 여부를 체크하는 함수
  dynamic checkAndGetIndexForPlaceRecommend() {
    if (indexOfPlaceDecidingSchedule != 0) {
      for (int i = indexOfPlaceDecidingSchedule - 1; i >= 0; i--) {
        if (scheduleList[i].place != null) {
          return i;
        }
      }
    }
    for (int i = indexOfPlaceDecidingSchedule + 1;
        i < scheduleList.length;
        i++) {
      if (scheduleList[i].place != null) {
        return i;
      }
    }

    return false;
  }

  /// 현재 선택된 장소의 플레이스 id
  String selectedPlaceId = "";
  late String selectedPlaceName;
  late LatLng selectedPlace;
  void setSelectedPlace(String placeId, String placeName, LatLng place) {
    selectedPlaceId = placeId;
    selectedPlaceName = placeName;
    selectedPlace = place;
    notifyListeners();
  }

  /// 장소 결정시
  void setPlaceForSchedule() {
    scheduleList[indexOfPlaceDecidingSchedule].place = selectedPlace;
    scheduleList[indexOfPlaceDecidingSchedule].placeName = selectedPlaceName;
    scheduleList[indexOfPlaceDecidingSchedule].placeId = selectedPlaceId;
    onLookingPlaceDetailEnd();
    onPlaceRecommendedEnd();
    notifyListeners();
  }

  /// 장소 검색 후 선택해서 디테일 화면을 볼때
  /// 토글용 변수
  bool isLookingPlaceDetail = false;
  void toggleIsLookingPlaceDetail() {
    isLookingPlaceDetail = !isLookingPlaceDetail;
    notifyListeners();
  }

  void onLookingPlaceDetailEnd() {
    isLookingPlaceDetail = false;
    notifyListeners();
  }

  void onLookingPlaceDetailStart() {
    isLookingPlaceDetail = true;
    notifyListeners();
  }

  void setSchedulePlace(
      int scheduleIndex, LatLng place, String placeName, String placeId) {
    scheduleList[scheduleIndex].setPlace(place, placeName, placeId);
    notifyListeners();
  }

  /// 장소 추천시 사용하는 flag
  bool isPlaceRecommended = false;

  void onPlaceRecommendedEnd() {
    isPlaceRecommended = false;
    notifyListeners();
  }

  /// 장소 추천 기준점
  late LatLng placeRecommendPoint;
  void setPlaceRecommendPoint(LatLng point) {
    placeRecommendPoint = point;
    notifyListeners();
  }

  /// convex hull index
  // int convexHullIndex = 0;
  // void setConvexHullIndex(int _convexHullIndex) {
  //   convexHullIndex = _convexHullIndex;
  //   notifyListeners();
  // }

  /// 추천된 장소 리스트
  Map<MarkerId, Marker> markersStored = <MarkerId, Marker>{};

  Map<MarkerId, Marker> onPlaceRecommened(
      ModifiedCustomInfoWindowController customInfoWindowController,
      List<List<MarkerId>> convex,
      Map<MarkerId, Marker> markers) {
    isPlaceRecommended = true;

    markersStored = markers;

    notifyListeners();

    int convexHullIndex = 0;
    for (int i = 0; i < convex.length; i++) {
      if (convex[i].isNotEmpty) {
        convexHullIndex = i;
        break;
      }
    }
    setConvexType(convexHullIndex);
    return setConvexHullVisibility(
        customInfoWindowController, convex, convexHullIndex);
  }

  /// 컨벡스홀 컨트롤 인덱스 변수
  int convexType = 0;
  void setConvexType(int convexHullIndex) {
    convexType = convexHullIndex;
    notifyListeners();
  }

  Map<MarkerId, Marker> setConvexHullVisibility(
      ModifiedCustomInfoWindowController customInfoWindowController,
      List<List<MarkerId>> convex,
      int convexHullIndex) {
    Map<MarkerId, Marker> markersReturn = {};
    customInfoWindowController.hideAllInfoWindow!();
    for (int index = 0; index <= convexHullIndex; index++) {
      for (MarkerId markerId in convex[index]) {
        markersReturn[markerId] = markersStored[markerId]!;
        customInfoWindowController.showInfoWindow!(markerId);
      }
    }
    customInfoWindowController.googleMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(placeRecommendPoint,
            [16.0, 15.5, 15.0, 14.5, 14.0][convexHullIndex]));
    customInfoWindowController.updateInfoWindow!();
    return markersReturn;
  }

  ///
  /// 이하 경로 생성 탭을 위한 Store
  ///

  bool isCreateRouteTabOn = false;
  onCreateRouteTabStart() {
    isCreateRouteTabOn = true;
    notifyListeners();
  }

  onCreateRouteTabEnd() {
    isCreateRouteTabOn = false;
    notifyListeners();
  }

  /// 모든 스케줄의 장소가 결정됐는지 체크
  bool isRouteCreateAble() {
    if (scheduleList.isEmpty) {
      return false;
    } else {
      for (Place place in scheduleList) {
        if (place.place == null) {
          return false;
        }
      }

      return true;
    }
  }

  late ScheduleCreated scheduleCreated;
  bool isScheduleCreated = false;
  void setSchduleCreated(ScheduleCreated scheduleCreated) {
    this.scheduleCreated = scheduleCreated;
    isScheduleCreated = true;
    // scheduleList = scheduleCreated.list;
    // indexOfPlaceDecidingSchedule = 0;
    notifyListeners();
  }

  void clearScheduleCreated() {
    isScheduleCreated = false;
    scheduleCreated.list = [];
    notifyListeners();
  }

  ///
  /// 이하 각종 컨트롤러
  ///

  /// 탭 컨트롤
  late TabController tabController;

  /// 타임라인 스크롤 컨트롤
  late ScrollController timeLineScrollController;

  /// custom info window 컨트롤
  ModifiedCustomInfoWindowController? customInfoWindowController = null;

  // late AnimationController animationController;
  // late Animation animation;

  // animateTimeLine() {
  //   if (tabController.index == 0) {
  //     animationController.forward();
  //   } else {
  //     animationController.reverse();
  //   }
  //   notifyListeners();
  // }
}
