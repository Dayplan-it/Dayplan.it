import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place_rough.dart';

const double upDownBtnHeight = 14;

class ScheduleBoxRough extends StatefulWidget {
  const ScheduleBoxRough(
      {Key? key,
      required this.place,
      required this.index,
      required this.itemWidth,
      this.scrollController})
      : super(key: key);

  final PlaceRough place;
  final int index;
  final double itemWidth;
  final ScrollController? scrollController;

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
      width: widget.itemWidth,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: FittedBox(
            fit: BoxFit.fitWidth,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    double boxHeight = durationToHeight(widget.place.duration);

    return Container(
        decoration: BoxDecoration(
            color: widget.place.color, borderRadius: defaultBoxRadius),
        height: boxHeight,
        width: widget.itemWidth,
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Center(
              child: FittedBox(
                fit: BoxFit.fitWidth,
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
          context.read<CreateScheduleStore>().isDetailBeingMade
              ? const SizedBox()
              : Positioned.fill(
                  child: Column(
                    children: [
                      widget.index == 0
                          ? RoughScheduleBoxUpDown(
                              isUp: true,
                              index: widget.index,
                              scrollController: widget.scrollController)
                          : RoughScheduleBoxUpDown(
                              isUp: true,
                              index: widget.index,
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
                          child: Container(
                            color: const Color.fromRGBO(0, 0, 0, 0),
                          ),
                        ),
                      ),
                      widget.index ==
                              context
                                      .read<CreateScheduleStore>()
                                      .roughSchedule
                                      .length -
                                  1
                          ? RoughScheduleBoxUpDown(
                              isUp: false,
                              index: widget.index,
                              scrollController: widget.scrollController)
                          : RoughScheduleBoxUpDown(
                              isUp: false,
                              index: widget.index,
                            ),
                    ],
                  ),
                )
        ]));
  }
}

class RoughScheduleBoxUpDown extends StatelessWidget {
  const RoughScheduleBoxUpDown(
      {Key? key,
      required this.isUp,
      required this.index,
      this.scrollController})
      : super(key: key);
  final bool isUp;
  final int index;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      axis: Axis.vertical,
      feedback: const SizedBox(),
      data: isUp,
      child: Container(
        height: upDownBtnHeight,
        width: double.maxFinite,
        // alignment: Alignment.center,
        color: const Color.fromARGB(0, 255, 255, 255),
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
        context.read<CreateScheduleStore>().onBlockResizing();
        context
            .read<CreateScheduleStore>()
            .changeDurationOfScheduleForUpDownBtn(index, detail.delta.dy, isUp);

        // if (context.read<CreateScheduleStore>().isAutoScrollAble && isUp) {
        //   scrollController!.jumpTo(
        //     scrollController!.position.pixels + detail.delta.dy * 2,
        //   );
        // } else if (context.read<CreateScheduleStore>().isAutoScrollAble &&
        //     !isUp) {
        //   scrollController!.jumpTo(
        //     scrollController!.position.pixels + detail.delta.dy * 2,
        //   );
        // }
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

class ScheduleBoxWhenDragging extends StatelessWidget {
  const ScheduleBoxWhenDragging(
      {Key? key,
      required this.placeRough,
      required this.index,
      required this.itemWidth,
      this.dragging = false})
      : super(key: key);

  final PlaceRough placeRough;
  final int index;
  final double itemWidth;
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
      width: itemWidth,
      alignment: Alignment.center,
      child: Padding(
        padding:
            dragging ? const EdgeInsets.all(3.0) : const EdgeInsets.all(8.0),
        child: Center(
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              placeRough.nameKor,
              style: mainFont(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: itemHeight / 5,
                  letterSpacing: 1),
            ),
          ),
        ),
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
    double boxHeight =
        durationToHeight(placeRough.duration) - reorderDragTargetHeight;

    // if ((index == 0 ||
    //         index ==
    //             context.read<CreateScheduleStore>().roughSchedule.length - 1) &&
    //     context.read<CreateScheduleStore>().roughSchedule.length != 1) {
    //   boxHeight -= reorderDragTargetHeight / 2;
    // } else if (context.read<CreateScheduleStore>().roughSchedule.length != 1 ||
    //     selectedNeighbor) {
    //   boxHeight -= reorderDragTargetHeight;
    // }

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

  _calHeight() {
    int scheduleLen = context.read<CreateScheduleStore>().roughSchedule.length;

    if (((context.read<CreateScheduleStore>().scheduleStartHeight == 0) &&
            (widget.targetId == 0)) ||
        ((context
                    .read<CreateScheduleStore>()
                    .roughSchedule[scheduleLen - 1]
                    .endsAt
                    .difference(context
                        .read<CreateScheduleStore>()
                        .scheduleDate
                        .add(const Duration(days: 1)))
                    .inSeconds <
                2) &&
            (widget.targetId == scheduleLen * 2))) {
      return reorderDragTargetHeight / 2;
    } else {
      return reorderDragTargetHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    double _height = _calHeight();

    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return isHovered
            ? Container(
                height: _height,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: defaultBoxRadius,
                  color: const Color.fromARGB(232, 129, 197, 253),
                ),
              )
            : Container(
                height: _height,
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
        context.read<CreateScheduleStore>().onDragEnd();
      },
    );
  }
}

class ScheduleBoxHandle extends StatelessWidget {
  const ScheduleBoxHandle(
      {Key? key, required this.timeLineWidth, required this.index})
      : super(key: key);

  final double timeLineWidth;
  final int index;

  Widget _feedback(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        _buildHandle(),
        Positioned(
          child: Row(
            children: [
              const SizedBox(width: scheduleBoxHandleWidth),
              ScheduleBoxWhenDragging(
                  placeRough:
                      context.read<CreateScheduleStore>().roughSchedule[index],
                  index: index,
                  itemWidth: timeLineWidth,
                  dragging: true)
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: _feedback(context),
      onDragStarted: () =>
          context.read<CreateScheduleStore>().onDragStart(index),
      onDragEnd: (detail) => context.read<CreateScheduleStore>().onDragEnd(),
      onDragCompleted: () => context.read<CreateScheduleStore>().onDragEnd(),
      onDragUpdate: (detail) => print(detail.globalPosition),
      axis: Axis.vertical,
      child: _buildHandle(),
    );
  }

  Container _buildHandle() {
    return Container(
      height: 40,
      width: scheduleBoxHandleWidth + timeLineWidth / 2,
      decoration: BoxDecoration(
          color: const Color.fromARGB(162, 169, 169, 169),
          borderRadius: BorderRadius.circular(10),
          boxShadow: defaultBoxShadow),
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: scheduleBoxHandleWidth,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(
                Icons.arrow_drop_up,
                color: Color.fromARGB(157, 64, 64, 64),
                size: 20,
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Color.fromARGB(157, 64, 64, 64),
                size: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
