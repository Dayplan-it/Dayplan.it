import 'package:dayplan_it/screens/create_schedule/components/noSelectedSchedule.dart';
import 'package:dayplan_it/screens/create_schedule/components/timeline_vertical.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/screens/create_schedule/components/dragNdropAbles.dart';

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
  _scheduleTypeSelected(
      String selectedPlaceTypeKor, String selectedPlaceTypeEng, Place place) {
    context
        .read<CreateScheduleStore>()
        .addSchedule(selectedPlaceTypeKor, selectedPlaceTypeEng, place);
  }

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
          Expanded(flex: 47, child: VerticalTimeLine()),
          Expanded(
              flex: 53,
              child: Column(
                children: [
                  Expanded(
                      flex: 50,
                      child: RecommendedSchedulesGrid(
                          scheduleTypeSelected: _scheduleTypeSelected,
                          addCustomBlockBtnClicked: _addCustomBlockBtnClicked)),
                  Expanded(
                      flex: 50,
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

class CreateScheduleStore extends ChangeNotifier {
  late DateTime scheduleDate;

  bool isRoughScheduleMade = false;
  List selectedSchedulesKor = [];
  List selectedSchedulesEng = [];
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
        }
      },
      ...
    ]

    참고로 Dart에서의 TimeOfDay는 초단위는 세지 않음
  */

  addSchedule(
      String selectedPlaceTypeKor, String selectedPlaceTypeEng, Place place) {
    selectedSchedulesKor.add(selectedPlaceTypeKor);
    selectedSchedulesEng.add(selectedPlaceTypeEng);
    selectedSchedulesPlaces.add(place);
    isRoughScheduleMade = true;

    String starts_at = "", ends_at = "", duration = "01:00:00";

    if (roughSchedule.length != 0) {
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
        "place_type": selectedPlaceTypeEng
      }
    });

    notifyListeners();
  }
}

// Vertical Timeline

const double ITEM_HEIGHT = 72;
const int HOURS = 24;

class VerticalTimeLine extends StatefulWidget {
  const VerticalTimeLine({Key? key}) : super(key: key);

  @override
  State<VerticalTimeLine> createState() => _VerticalTimeLineState();
}

class _VerticalTimeLineState extends State<VerticalTimeLine> {
  final double initScrollOffset = ITEM_HEIGHT * 8 - 20;
  late final ScrollController _scrollController = ScrollController(
      initialScrollOffset: initScrollOffset, keepScrollOffset: false);

  Widget _buildRoughScheduleBoxColumn() {
    List<Place> places =
        context.watch<CreateScheduleStore>().selectedSchedulesPlaces;
    List<Map> roughSchedule =
        context.watch<CreateScheduleStore>().roughSchedule;

    return Column(
      children: roughSchedule.map(_buildRoughScheduleBoxes).toList(),
    );
  }

  Widget _buildRoughScheduleBoxes(Map roughScheduleBox) {
    return Container(
      height: 10,
      child: Text(roughScheduleBox["detail"]["place_type"]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Stack(children: [
        Row(
          children: [
            Expanded(
                flex: 20,
                child: Column(
                  children: [
                    for (int i = 0; i < HOURS + 1; i++)
                      SizedBox(
                        height:
                            i != 0 && i != 24 ? ITEM_HEIGHT : ITEM_HEIGHT / 2,
                        child: i != 0 && i != 24
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  (i.toString() + (i < 12 ? ' AM' : ' PM')),
                                  style: mainFont(
                                      color: subTextColor, fontSize: 12),
                                ))
                            : null,
                      )
                  ],
                )),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              flex: 70,
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    for (int i = 0; i < HOURS; i++)
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: ITEM_HEIGHT,
                            color: skyBlue,
                          ),
                          const Divider(
                            height: 0,
                            indent: 10,
                            endIndent: 10,
                            thickness: 1,
                            color: Colors.white,
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
            const Expanded(
              flex: 5,
              child: SizedBox(),
            ),
          ],
        ),
        Positioned.fill(
          child: Row(
            children: [
              const Expanded(flex: 20, child: SizedBox()),
              const SizedBox(
                width: 5,
              ),
              Expanded(flex: 70, child: _buildRoughScheduleBoxColumn()),
              const Expanded(flex: 5, child: SizedBox()),
            ],
          ),
        )
      ]),
    );
  }
}
