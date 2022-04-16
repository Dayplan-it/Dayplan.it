import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/screens/create_schedule/components/dragNdropAbles.dart';
import 'package:dayplan_it/screens/create_schedule/components/noSelectedSchedule.dart';
import 'package:dayplan_it/screens/create_schedule/components/timeline_vertical.dart';

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
                      flex: context
                              .watch<CreateScheduleStore>()
                              .isRoughScheduleMade
                          ? 100
                          : 60,
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
                              .isRoughScheduleMade
                          ? 0
                          : 40,
                      child: context
                              .watch<CreateScheduleStore>()
                              .isRoughScheduleMade
                          ? Container()
                          : const NoScheduleText()),
                  ElevatedButton(
                      onPressed: context
                              .watch<CreateScheduleStore>()
                              .isRoughScheduleMade
                          ? () {}
                          : null,
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
                    color: Color.fromARGB(255, 39, 39, 39)),
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

  late double scheduleStartHeight;
  setScheduleStartHeight(double height) {
    scheduleStartHeight = height;
    notifyListeners();
  }

  bool isRoughScheduleMade = false;
  bool isDragging = false;
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
    isRoughScheduleMade = true;

    String starts_at = "", ends_at = "", duration = "01:00:00";

    if (roughSchedule.isNotEmpty) {
      starts_at = roughSchedule[roughSchedule.length - 1]["detail"]["ends_at"];
      List<String> tempArr = roughSchedule[roughSchedule.length - 1]["detail"]
              ["ends_at"]
          .split(":");

      var ends_at_DateTime = scheduleDate.add(Duration(
          hours: int.parse(tempArr[0]) + 1,
          minutes: int.parse(tempArr[1]),
          seconds: int.parse(tempArr[2])));

      ends_at =
          "${ends_at_DateTime.hour.toString().padLeft(2, '0')}:${ends_at_DateTime.minute.toString().padLeft(2, '0')}:${ends_at_DateTime.second.toString().padLeft(2, '0')}";
    } else {
      starts_at = "08:00:00";
      ends_at = "09:00:00";
    }

    roughSchedule.add({
      "type": "PL",
      "detail": {
        "starts_at": starts_at,
        "ends_at": ends_at,
        "duration": duration,
        "place_type": place.nameEng,
        "place": place
      }
    });
    notifyListeners();
  }

  removeSchedule(int oldIndex) {
    roughSchedule.removeAt(oldIndex);
    notifyListeners();
  }

  insertScheduleToNewOrder(int newIndex, Map schedule) {
    roughSchedule.insert(newIndex, schedule);
    notifyListeners();
  }

  onDragStart() {
    isDragging = true;
    notifyListeners();
  }

  onDragEnd(Offset droppedBoxOffset) {
    isDragging = false;
    droppedBoxOffset = droppedBoxOffset;
    print(droppedBoxOffset);
    notifyListeners();
  }

  onDragUpdate(Offset draggingBoxOffset) {
    draggingBoxOffset = draggingBoxOffset;
    notifyListeners();
  }
}
