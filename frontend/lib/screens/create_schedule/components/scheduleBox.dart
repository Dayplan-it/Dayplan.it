import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place_rough.dart';

const double upDownBtnHeight = 14;

class ScheduleBoxRough extends StatefulWidget {
  ScheduleBoxRough({
    Key? key,
    required this.place,
    required this.index,
  }) : super(key: key);

  final PlaceRough place;
  final int index;

  @override
  State<ScheduleBoxRough> createState() => _ScheduleBoxRoughState();
}

class _ScheduleBoxRoughState extends State<ScheduleBoxRough> {
  Widget _onLongPress(double boxHeight) {
    return Container(
      decoration: BoxDecoration(
          color: widget.place.color.withAlpha(150),
          borderRadius: defaultBoxRadius),
      height: boxHeight,
      width: timeLineWidth,
      alignment: Alignment.center,
      child: Text(
        widget.place.nameKor,
        style: mainFont(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: itemHeight / 5,
            letterSpacing: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double boxHeight = durationToHeight(widget.place.duration);

    return Container(
        decoration: BoxDecoration(
            color: widget.place.color, borderRadius: defaultBoxRadius),
        height: boxHeight,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Column(
            children: [
              RoughScheduleBoxUpDown(
                isUp: true,
                index: widget.index,
              ),
              const Expanded(child: SizedBox()),
              RoughScheduleBoxUpDown(
                isUp: false,
                index: widget.index,
              ),
            ],
          ),
          Positioned.fill(
            child: Column(
              children: [
                if (context.read<CreateScheduleStore>().isDragging)
                  const SizedBox(
                    height: upDownBtnHeight,
                  ),
                Expanded(
                  child: LongPressDraggable(
                    feedback: _onLongPress(boxHeight),
                    delay: const Duration(milliseconds: 100),
                    data: widget.index,
                    onDragEnd: (DraggableDetails details) =>
                        context.read<CreateScheduleStore>().onDragEnd(),
                    onDragStarted: () => context
                        .read<CreateScheduleStore>()
                        .onDragStart(widget.index),
                    onDraggableCanceled: (velocity, offset) =>
                        context.read<CreateScheduleStore>().onDragEnd(),
                    child: Center(
                      child: Text(
                        widget.place.nameKor,
                        style: mainFont(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: itemHeight / 5,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                ),
                if (context.read<CreateScheduleStore>().isDragging)
                  const SizedBox(
                    height: upDownBtnHeight,
                  ),
              ],
            ),
          )
        ]));
  }
}

class RoughScheduleBoxUpDown extends StatelessWidget {
  const RoughScheduleBoxUpDown({
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
      feedback: SizedBox(),
      child: Container(
        height: upDownBtnHeight,
        width: double.maxFinite,
        // alignment: Alignment.center,
        color: Color.fromARGB(0, 255, 255, 255),
        // child: Icon(
        //   isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        //   size: upDownBtnHeight - 2,
        // ),
      ),
      childWhenDragging: Container(
        height: upDownBtnHeight,
        width: double.maxFinite,
        // alignment: Alignment.center,
        color: const Color.fromARGB(71, 255, 255, 255),
        // child: Icon(
        //   isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        //   size: upDownBtnHeight - 2,
        // ),
      ),
      onDragUpdate: (detail) {
        context
            .read<CreateScheduleStore>()
            .changeDurationOfScheduleForUpDownBtn(index, detail.delta.dy, isUp);
      },
    );
  }
}

class ScheduleBoxWhenDragging extends StatelessWidget {
  const ScheduleBoxWhenDragging(
      {Key? key,
      required this.placeRough,
      required this.index,
      this.dragging = false})
      : super(key: key);

  final PlaceRough placeRough;
  final int index;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: placeRough.color,
          borderRadius: defaultBoxRadius,
          border: dragging
              ? Border.all(
                  color: const Color.fromARGB(255, 38, 0, 255), width: 5)
              : null),
      height: durationToHeight(placeRough.duration),
      width: timeLineWidth,
      alignment: Alignment.center,
      child: Text(
        placeRough.nameKor,
        style: mainFont(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: itemHeight / 5,
            letterSpacing: 1),
      ),
    );
  }
}

class ScheduleBoxWhenDraggingDummy extends StatelessWidget {
  const ScheduleBoxWhenDraggingDummy(
      {Key? key,
      required this.placeRough,
      required this.index,
      this.selected = false,
      this.selectedNeighbor = false})
      : super(key: key);
  final PlaceRough placeRough;
  final int index;
  final bool selected;
  final bool selectedNeighbor;

  @override
  Widget build(BuildContext context) {
    double boxHeight = durationToHeight(placeRough.duration);

    if ((index == 0 ||
            index ==
                context.read<CreateScheduleStore>().roughSchedule.length - 1) &&
        context.read<CreateScheduleStore>().roughSchedule.length != 1) {
      boxHeight -= itemHeight / 20;
    } else if (context.read<CreateScheduleStore>().roughSchedule.length != 1 ||
        selectedNeighbor) {
      boxHeight -= itemHeight / 10;
    }

    return SizedBox(
      height: boxHeight,
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
                height: itemHeight / 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 129, 197, 253),
                ),
              )
            : Container(
                height: itemHeight / 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue,
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
        context.read<CreateScheduleStore>().onDragEnd();
      },
    );
  }
}
