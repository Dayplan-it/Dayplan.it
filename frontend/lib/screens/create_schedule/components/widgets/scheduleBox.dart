import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/schedule_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class ScheduleBox extends StatelessWidget {
  const ScheduleBox({
    Key? key,
    required this.schedule,
    required this.index,
    required this.itemWidth,
  }) : super(key: key);

  final Schedule schedule;
  final int index;
  final double itemWidth;

  @override
  Widget build(BuildContext context) {
    bool isEmpty = (schedule.placeType == "empty");
    return Container(
        decoration: BoxDecoration(
            color: schedule.color,
            borderRadius: defaultBoxRadius,
            boxShadow: defaultBoxShadow),
        height: schedule.toHeight(),
        width: itemWidth,
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Center(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Column(
                  children: [
                    if (!isEmpty)
                      Text(
                        schedule.nameKor,
                        style: mainFont(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: itemHeight / 5,
                            letterSpacing: 1),
                      ),
                    schedule.toHeight() > itemHeight / 4
                        ? Text(
                            ((schedule.duration.inMinutes >= 60)
                                    ? schedule.duration.inHours.toString() +
                                        "시간 "
                                    : "") +
                                ((schedule.duration.inMinutes % 60) != 0
                                    ? (schedule.duration.inMinutes % 60)
                                            .toString() +
                                        "분"
                                    : ""),
                            style: mainFont(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: itemHeight / 7,
                                letterSpacing: 1),
                          )
                        : const SizedBox()
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                if (index != 0)
                  ScheduleBoxUpDownHandle(
                    isUp: true,
                    index: index,
                  ),
                Expanded(
                  child: LongPressDraggable(
                    feedback: OnScheduleBoxLongPress(
                      width: itemWidth,
                      schedule: schedule,
                      isFeedback: true,
                    ),
                    delay: const Duration(milliseconds: 100),
                    data: index,
                    onDragEnd: (DraggableDetails details) => context
                        .read<CreateScheduleStore>()
                        .onScheduleBoxDragEnd(),
                    onDragStarted: () => context
                        .read<CreateScheduleStore>()
                        .onScheduleBoxDragStart(index),
                    onDraggableCanceled: (velocity, offset) => context
                        .read<CreateScheduleStore>()
                        .onScheduleBoxDragEnd(),
                    child: Container(
                      color: const Color.fromRGBO(0, 0, 0, 0),
                    ),
                  ),
                ),
                ScheduleBoxUpDownHandle(
                  isUp: false,
                  index: index,
                ),
              ],
            ),
          ),
        ]));
  }
}

class OnScheduleBoxLongPress extends StatelessWidget {
  const OnScheduleBoxLongPress({
    Key? key,
    required this.schedule,
    required this.width,
    this.isFeedback = false,
  }) : super(key: key);

  final Schedule schedule;
  final double width;
  final bool isFeedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: schedule.color.withAlpha((isFeedback ? 150 : 255)),
          borderRadius: defaultBoxRadius,
          border: Border.all(color: Colors.blue, width: 3)),
      height: schedule.toHeight(),
      width: width,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(
              children: [
                Text(
                  schedule.nameKor,
                  style: mainFont(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: itemHeight / 5,
                      letterSpacing: 1),
                ),
                schedule.toHeight() > itemHeight / 4
                    ? Text(
                        ((schedule.duration.inMinutes >= 60)
                                ? schedule.duration.inHours.toString() + "시간 "
                                : "") +
                            ((schedule.duration.inMinutes % 60) != 0
                                ? (schedule.duration.inMinutes % 60)
                                        .toString() +
                                    "분"
                                : ""),
                        style: mainFont(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: itemHeight / 7,
                            letterSpacing: 1),
                      )
                    : const SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScheduleBoxUpDownHandle extends StatelessWidget {
  const ScheduleBoxUpDownHandle({
    Key? key,
    required this.isUp,
    required this.index,
  }) : super(key: key);
  final bool isUp;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      axis: Axis.vertical,
      feedback: const SizedBox(),
      data: isUp,
      child: Container(
        height: upDownHandleHeight,
        width: double.maxFinite,
        color: const Color.fromARGB(0, 255, 255, 255),
      ),
      childWhenDragging: Container(
        height: upDownHandleHeight,
        width: double.maxFinite,
        color: const Color.fromARGB(71, 255, 255, 255),
      ),
      onDragUpdate: (detail) {
        context.read<CreateScheduleStore>().toggleIsScheduleBoxDragging();
        context
            .read<CreateScheduleStore>()
            .changeDurationOfScheduleForUpDownBtn(index, detail.delta.dy, isUp);
      },
      onDragEnd: (detail) {
        context.read<CreateScheduleStore>().toggleIsScheduleBoxDragging();
      },
      onDragCompleted: () {
        context.read<CreateScheduleStore>().toggleIsScheduleBoxDragging();
      },
    );
  }
}

class ScheduleBoxDragTarget extends StatefulWidget {
  const ScheduleBoxDragTarget({Key? key, required this.targetId})
      : super(key: key);
  final int targetId;

  @override
  State<ScheduleBoxDragTarget> createState() => _ScheduleBoxDragTargetState();
}

class _ScheduleBoxDragTargetState extends State<ScheduleBoxDragTarget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return isHovered
            ? Container(
                height: reorderDragTargetHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: defaultBoxRadius,
                  color: const Color.fromARGB(232, 129, 197, 253),
                ),
              )
            : Container(
                height: reorderDragTargetHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: defaultBoxRadius,
                  color: const Color.fromARGB(148, 33, 149, 243),
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
      onAcceptWithDetails: (DragTargetDetails details) {
        context
            .read<CreateScheduleStore>()
            .onChangeScheduleOrder(details.data, (widget.targetId / 2).floor());
        context.read<CreateScheduleStore>().onScheduleBoxDragEnd();
      },
    );
  }
}
