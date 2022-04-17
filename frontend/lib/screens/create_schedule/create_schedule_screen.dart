import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/RecommendedSchedulesGrid.dart';
import 'package:dayplan_it/screens/create_schedule/components/bottom_right_space.dart';
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
                          : const RecommendedSchedulesGrid()),
                  Expanded(
                      flex: (context
                              .watch<CreateScheduleStore>()
                              .roughSchedule
                              .isEmpty
                          ? (context
                                  .watch<CreateScheduleStore>()
                                  .isCustomBlockBeingMade
                              ? 180
                              : 40)
                          : (context
                                  .watch<CreateScheduleStore>()
                                  .isCustomBlockBeingMade
                              ? 180
                              : 0)),
                      child: _buildBottomRight(context)),
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
                              borderRadius: defaultBoxRadius)),
                      child: Text(
                        "일정 결정",
                        style: mainFont(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ))
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildBottomRight(BuildContext context) {
    if (context.watch<CreateScheduleStore>().roughSchedule.isEmpty &&
        !context.watch<CreateScheduleStore>().isCustomBlockBeingMade) {
      return const NoScheduleText();
    } else if (context.watch<CreateScheduleStore>().isCustomBlockBeingMade) {
      return const CreateCustomBlock();
    } else {
      return const SizedBox();
    }
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
                    borderRadius: defaultBoxRadius, color: pointColor),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              )
            : Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: defaultBoxRadius,
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
        context.read<CreateScheduleStore>().removeRoughSchedule(scheduleIndex);
        context.read<CreateScheduleStore>().onDragEnd();
      },
    );
  }
}
