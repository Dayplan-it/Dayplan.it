import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/buttons.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/notification_text.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/create_duration_schedule_right_side.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/durationLine_vertical.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/screens/set_primary_schedule_screen.dart';

class CreateDurationScheduleScreen extends StatefulWidget {
  const CreateDurationScheduleScreen({Key? key, required this.date})
      : super(key: key);
  final DateTime date;

  @override
  State<CreateDurationScheduleScreen> createState() =>
      _CreateDurationScheduleScreenState();
}

class _CreateDurationScheduleScreenState
    extends State<CreateDurationScheduleScreen> {
  @override
  void initState() {
    context.read<CreateScheduleStore>().isDetailBeingMade = false;
    context.read<CreateScheduleStore>().scheduleDate = widget.date;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<CreateScheduleStore>().onPopCreateDurationScheduleScreen();
        return true;
      },
      child: Scaffold(
          appBar: DayplanitAppBar(
            title: "일정별 소요시간 정하기",
            subtitle:
                "${widget.date.month.toString()}월 ${widget.date.day.toString()}일",
            isHomePage: false,
          ),
          body: CreateDurationScheduleScreenBody(
            date: widget.date,
          )),
    );
  }
}

class CreateDurationScheduleScreenBody extends StatelessWidget {
  const CreateDurationScheduleScreenBody({Key? key, required this.date})
      : super(key: key);
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
        child: Row(children: const [
          Expanded(
              flex: 47,
              child: DurationLine(
                durationLineWidth: roughTimeLineWidth,
              )),
          Expanded(flex: 53, child: CreateDurationScheduleScreenRightSide())
        ]));
  }
}

class CreateDurationScheduleScreenRightSide extends StatelessWidget {
  const CreateDurationScheduleScreenRightSide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _onNextBtnPressed() {
      context.read<CreateScheduleStore>().currentScreenIndex = 1;
      return Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const SetPrimaryScheduleScreen()));
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  const Expanded(flex: 2, child: RecommendedSchedulesGrid()),
                  if (context
                      .watch<CreateScheduleStore>()
                      .isCustomBlockBeingMade)
                    const Expanded(flex: 6, child: CreateCustomBlock())
                  else if (context
                      .watch<CreateScheduleStore>()
                      .durationSchedule
                      .isEmpty)
                    const Expanded(flex: 1, child: NoScheduleText()),
                ],
              ),
              if (context
                  .watch<CreateScheduleStore>()
                  .isDurationOnlyScheduleDragging)
                const Positioned.fill(child: DeleteDurationOnlyScheduleArea()),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        const NotificationText(
          title: "스케줄의 소요시간을 조절하거나 순서를 바꿔보세요",
          isInstruction: true,
        ),
        if (context.watch<CreateScheduleStore>().durationSchedule.isEmpty)
          const NotificationText(
            title: "스케줄이 없습니다",
            isRed: true,
          ),
        SquareButton(
            title: "다음 단계",
            activate: context
                .watch<CreateScheduleStore>()
                .durationSchedule
                .isNotEmpty,
            onPressed: _onNextBtnPressed),
      ],
    );
  }
}

class DeleteDurationOnlyScheduleArea extends StatefulWidget {
  const DeleteDurationOnlyScheduleArea({Key? key}) : super(key: key);

  @override
  State<DeleteDurationOnlyScheduleArea> createState() =>
      _DeleteDurationOnlyScheduleAreaState();
}

class _DeleteDurationOnlyScheduleAreaState
    extends State<DeleteDurationOnlyScheduleArea> {
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
      onAccept: (int durationOnlyScheduleIndex) {
        context
            .read<CreateScheduleStore>()
            .removeDurationOnlySchedule(durationOnlyScheduleIndex);
        context.read<CreateScheduleStore>().onDurationScheduleDragEnd();
      },
    );
  }
}
