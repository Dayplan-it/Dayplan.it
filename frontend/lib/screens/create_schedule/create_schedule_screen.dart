import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/screens/create_schedule/components/RecommendedSchedulesGrid.dart';
import 'package:dayplan_it/screens/create_schedule/components/noSelectedSchedule.dart';
import 'package:dayplan_it/screens/create_schedule/components/timeline_vertical.dart';

class Place {
  Place(
      {required this.nameKor,
      required this.nameEng,
      required this.color,
      required this.iconData});

  final String nameKor;
  final String nameEng;
  final Color color;
  final IconData iconData;
}

class CreateScheduleScreen extends StatelessWidget {
  const CreateScheduleScreen({Key? key, required this.date}) : super(key: key);
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DayplanitAppBar(
          title: "일정 생성하기",
          subtitle: "${date.month.toString()}월 ${date.day.toString()}일",
          isHomePage: false,
        ),
        body: ChangeNotifierProvider<CreateScheduleStore>(
            create: (context) => CreateScheduleStore(),
            child: RoughSceduleCreatorBody(
              date: date,
            )));
  }
}

class RoughSceduleCreatorBody extends StatefulWidget {
  const RoughSceduleCreatorBody({Key? key, required this.date})
      : super(key: key);
  final DateTime date;

  @override
  State<RoughSceduleCreatorBody> createState() =>
      _RoughSceduleCreatorBodyState();
}

class _RoughSceduleCreatorBodyState extends State<RoughSceduleCreatorBody> {
  _addCustomBlockBtnClicked() {}

  @override
  void initState() {
    super.initState();
    context.read<CreateScheduleStore>().scheduleDate = widget.date;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
      child: Row(
        children: [
          const Expanded(flex: 47, child: TimeLine()),
          Expanded(
              flex: 53,
              child: Column(
                children: [
                  Expanded(
                      flex: 60,
                      child: context.watch<CreateScheduleStore>().isDragging
                          ? const DeleteScheduleArea()
                          : RecommendedSchedulesGrid(
                              scheduleTypeSelected: context
                                  .read<CreateScheduleStore>()
                                  .addSchedule,
                              addCustomBlockBtnClicked:
                                  _addCustomBlockBtnClicked)),
                  Expanded(
                      flex: context
                              .watch<CreateScheduleStore>()
                              .roughSchedule
                              .isEmpty
                          ? 40
                          : 0,
                      child: context
                              .watch<CreateScheduleStore>()
                              .roughSchedule
                              .isEmpty
                          ? const NoScheduleText()
                          : const SizedBox()),
                  ElevatedButton(
                      onPressed: context
                              .watch<CreateScheduleStore>()
                              .roughSchedule
                              .isEmpty
                          ? null
                          : () {},
                      style: ElevatedButton.styleFrom(
                          primary: primaryColor,
                          minimumSize: const Size(double.maxFinite, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: Text(
                        "일정 결정",
                        style: mainFont(),
                      ))
                ],
              ))
        ],
      ),
    );
  }
}

class DeleteScheduleArea extends StatefulWidget {
  const DeleteScheduleArea({
    Key? key,
  }) : super(key: key);

  @override
  State<DeleteScheduleArea> createState() => _DeleteScheduleAreaState();
}

class _DeleteScheduleAreaState extends State<DeleteScheduleArea> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return isHovered
            ? Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: pointColor),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              )
            : Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 39, 39, 39)),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              );
      },
      onWillAccept: (data) {
        setState(() {
          isHovered = true;
        });
        return true;
      },
      onLeave: (data) {
        setState(() {
          isHovered = false;
        });
      },
      onAccept: (int scheduleIndex) {
        // if (context.read<CreateScheduleStore>().roughSchedule.length == 2 &&
        //     scheduleIndex == 0) {
        //   List<String> durationArr = context
        //       .read<CreateScheduleStore>()
        //       .roughSchedule[1]["detail"]["duration"]
        //       .split(":");
        //   double boxHeight = (double.parse(durationArr[0]) +
        //           double.parse(durationArr[1]) / 60 +
        //           double.parse(durationArr[2]) / 3600) *
        //       itemHeight;
        //   context.read<CreateScheduleStore>().setScheduleStartHeight(
        //       context.read<CreateScheduleStore>().scheduleStartHeight +
        //           boxHeight);
        // }

        context
            .read<CreateScheduleStore>()
            .roughSchedule
            .removeAt(scheduleIndex);
      },
    );
  }
}

class CreateScheduleStore extends ChangeNotifier {
  late DateTime scheduleDate;

  double scheduleStartHeight = itemHeight * 8;
  bool isDragging = false;

  int currentlyDragging = 0;

  Offset droppedBoxOffset = const Offset(0, 0);
  Offset draggingBoxOffset = const Offset(0, 0);
  List<Place> selectedSchedulesPlaces = [];
  List<Map> roughSchedule = [];
  /* 
    roughSchedule 구조
    이후 Create API에서 Order 중 Place를 맡게 됨. (아직은 Route나 place_name, poit, place_id가 없음)
    [
      {
        type: "PL"
        detail: {
          starts_at: "HH:MM:SS",
          ends_at: "HH:MM:SS",
          duration: "HH:MM:SS",
          place_type: "cafe"
          place: Widget<Place>
        }
      },
      ...
    ]
  */

  addSchedule(Place place) {
    String startsAt = "", endsAt = "", duration = "01:00:00";

    if (roughSchedule.isNotEmpty) {
      startsAt = roughSchedule[roughSchedule.length - 1]["detail"]["ends_at"];
      List<String> tempArr = roughSchedule[roughSchedule.length - 1]["detail"]
              ["ends_at"]
          .split(":");

      var endsAtDateTime = scheduleDate.add(Duration(
          hours: int.parse(tempArr[0]) + 1,
          minutes: int.parse(tempArr[1]),
          seconds: int.parse(tempArr[2])));

      endsAt =
          "${endsAtDateTime.hour.toString().padLeft(2, '0')}:${endsAtDateTime.minute.toString().padLeft(2, '0')}:${endsAtDateTime.second.toString().padLeft(2, '0')}";
    } else {
      startsAt = "08:00:00";
      endsAt = "09:00:00";
    }

    roughSchedule.add({
      "type": "PL",
      "detail": {
        "starts_at": startsAt,
        "ends_at": endsAt,
        "duration": duration,
        "place_type": place.nameEng,
        "place": place
      }
    });
    notifyListeners();
  }

  onDragEnd(Offset _droppedBoxOffset) {
    isDragging = false;
    droppedBoxOffset = _droppedBoxOffset;
    notifyListeners();
  }

  onDragStart(int _currentlyDragging) {
    isDragging = true;
    currentlyDragging = _currentlyDragging;
    notifyListeners();
  }

  onChangeScheduleOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex = newIndex - 1;
    }
    final Map temp = roughSchedule.removeAt(oldIndex);
    roughSchedule.insert(newIndex, temp);

    roughSchedule[oldIndex];
    print(roughSchedule[newIndex]);

    notifyListeners();
  }

  setScheduleStartHeight(double newHeight) {
    scheduleStartHeight = newHeight;
    notifyListeners();
  }

  changeDurationOfSchedule(int scheduleIndex, String newDuration,
      String newTime, bool isChangeStart) {
    roughSchedule[scheduleIndex]["detail"]["duration"] = newDuration;

    if (isChangeStart) {
      roughSchedule[scheduleIndex]["detail"]["starts_at"] = newTime;
    }
    notifyListeners();
  }
}
