import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place.dart';

class DurationOnlyScheduleBox extends StatelessWidget {
  const DurationOnlyScheduleBox({
    Key? key,
    required this.placeDurationOnly,
    required this.index,
    required this.itemWidth,
  }) : super(key: key);

  final PlaceDurationOnly placeDurationOnly;
  final int index;
  final double itemWidth;

  @override
  Widget build(BuildContext context) {
    bool isEmpty = (placeDurationOnly.placeType == "empty");
    return Container(
        decoration: BoxDecoration(
            color: placeDurationOnly.color,
            borderRadius: defaultBoxRadius,
            boxShadow: defaultBoxShadow),
        height: placeDurationOnly.toHeight(),
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
                        placeDurationOnly.nameKor,
                        style: mainFont(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: itemHeight / 5,
                            letterSpacing: 1),
                      ),
                    placeDurationOnly.toHeight() > itemHeight / 4
                        ? Text(
                            ((placeDurationOnly.duration.inMinutes >= 60)
                                    ? placeDurationOnly.duration.inHours
                                            .toString() +
                                        "시간 "
                                    : "") +
                                ((placeDurationOnly.duration.inMinutes % 60) !=
                                        0
                                    ? (placeDurationOnly.duration.inMinutes %
                                                60)
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
                ScheduleBoxUpDownHandle(
                  isUp: true,
                  index: index,
                ),
                Expanded(
                  child: LongPressDraggable(
                    feedback: OnDurationOnlyScheduleBoxLongPress(
                      width: itemWidth,
                      placeDurationOnly: placeDurationOnly,
                      isFeedback: true,
                    ),
                    delay: const Duration(milliseconds: 100),
                    data: index,
                    onDragEnd: (DraggableDetails details) => context
                        .read<CreateScheduleStore>()
                        .onDurationScheduleDragEnd(),
                    onDragStarted: () => context
                        .read<CreateScheduleStore>()
                        .onDurationScheduleDragStart(index),
                    onDraggableCanceled: (velocity, offset) => context
                        .read<CreateScheduleStore>()
                        .onDurationScheduleDragEnd,
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

class OnDurationOnlyScheduleBoxLongPress extends StatelessWidget {
  const OnDurationOnlyScheduleBoxLongPress({
    Key? key,
    required this.placeDurationOnly,
    required this.width,
    this.isFeedback = false,
  }) : super(key: key);

  final PlaceDurationOnly placeDurationOnly;
  final double width;
  final bool isFeedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: placeDurationOnly.color.withAlpha((isFeedback ? 150 : 255)),
          borderRadius: defaultBoxRadius,
          border: Border.all(color: Colors.blue, width: 3)),
      height: placeDurationOnly.toHeight(),
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
                  placeDurationOnly.nameKor,
                  style: mainFont(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: itemHeight / 5,
                      letterSpacing: 1),
                ),
                placeDurationOnly.toHeight() > itemHeight / 4
                    ? Text(
                        ((placeDurationOnly.duration.inMinutes >= 60)
                                ? placeDurationOnly.duration.inHours
                                        .toString() +
                                    "시간 "
                                : "") +
                            ((placeDurationOnly.duration.inMinutes % 60) != 0
                                ? (placeDurationOnly.duration.inMinutes % 60)
                                        .toString() +
                                    "분"
                                : ""),
                        style: mainFont(
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 255, 255, 255),
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
        context.read<CreateScheduleStore>().onBlockResizing();
        context
            .read<CreateScheduleStore>()
            .changeDurationOfScheduleForUpDownBtn(index, detail.delta.dy, isUp);
      },
      onDragEnd: (detail) {
        context.read<CreateScheduleStore>().onEndBlockResizing();
      },
      onDragCompleted: () {
        context.read<CreateScheduleStore>().onEndBlockResizing();
      },
    );
  }
}

class DurationOnlyScheduleBoxDragTarget extends StatefulWidget {
  const DurationOnlyScheduleBoxDragTarget({Key? key, required this.targetId})
      : super(key: key);
  final int targetId;

  @override
  State<DurationOnlyScheduleBoxDragTarget> createState() =>
      _DurationOnlyScheduleBoxDragTargetState();
}

class _DurationOnlyScheduleBoxDragTargetState
    extends State<DurationOnlyScheduleBoxDragTarget> {
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
        context.read<CreateScheduleStore>().onDurationScheduleDragEnd();
      },
    );
  }
}
