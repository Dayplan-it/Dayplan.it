import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/create_schedule_screen.dart';
import 'package:dayplan_it/screens/create_schedule/components/timeline_vertical.dart';

class ScheduleBox extends StatefulWidget {
  ScheduleBox({
    Key? key,
    required this.place,
    required this.roughScheduleIndex,
    required this.scheduleStartHeight,
    required this.setScheduleStartHeight,
  }) : super(key: key);

  final Place place;
  final int roughScheduleIndex;
  final double scheduleStartHeight;
  final Function setScheduleStartHeight;

  @override
  State<ScheduleBox> createState() => _ScheduleBoxState();
}

class _ScheduleBoxState extends State<ScheduleBox> {
  Widget _onLongPress(double boxHeight) {
    return Container(
      decoration: BoxDecoration(
          color: widget.place.color.withAlpha(150),
          borderRadius: BorderRadius.circular(20)),
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

  Widget _childWhenDragging(double boxHeight) {
    return Container(
      decoration: BoxDecoration(
          color: widget.place.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color.fromARGB(255, 38, 0, 255), width: 5)),
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
    List<String> durationArr = context
        .watch<CreateScheduleStore>()
        .roughSchedule[widget.roughScheduleIndex]["detail"]["duration"]
        .split(":");
    double boxHeight = (double.parse(durationArr[0]) +
            double.parse(durationArr[1]) / 60 +
            double.parse(durationArr[2]) / 3600) *
        itemHeight;

    return Container(
        decoration: BoxDecoration(
            color: widget.place.color, borderRadius: BorderRadius.circular(20)),
        height: boxHeight,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Column(
            children: [
              Expanded(
                flex: 1,
                child: ScheduleBoxUpDown(
                  isUp: true,
                  roughScheduleIndex: widget.roughScheduleIndex,
                  scheduleStartHeight: widget.scheduleStartHeight,
                  setScheduleStartHeight: widget.setScheduleStartHeight,
                ),
              ),
              const Expanded(flex: 4, child: SizedBox()),
              Expanded(
                flex: 1,
                child: ScheduleBoxUpDown(
                  isUp: false,
                  roughScheduleIndex: widget.roughScheduleIndex,
                  scheduleStartHeight: widget.scheduleStartHeight,
                  setScheduleStartHeight: widget.setScheduleStartHeight,
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  flex: context.read<CreateScheduleStore>().isDragging ? 0 : 1,
                  child: const SizedBox(),
                ),
                Expanded(
                  flex: 4,
                  child: LongPressDraggable(
                    feedback: _onLongPress(boxHeight),
                    delay: const Duration(milliseconds: 100),
                    data: widget.roughScheduleIndex,
                    onDragEnd: (DraggableDetails details) {
                      context
                          .read<CreateScheduleStore>()
                          .onDragEnd(details.offset);
                    },
                    onDragStarted: () {
                      context
                          .read<CreateScheduleStore>()
                          .onDragStart(widget.roughScheduleIndex);
                    },
                    onDragUpdate: (DragUpdateDetails details) => context
                        .read<CreateScheduleStore>()
                        .draggingBoxOffset = details.globalPosition,
                    onDraggableCanceled: (velocity, offset) {
                      context.read<CreateScheduleStore>().onDragEnd(offset);
                    },
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
                    childWhenDragging: _childWhenDragging(boxHeight),
                  ),
                ),
                Expanded(
                    flex:
                        context.read<CreateScheduleStore>().isDragging ? 0 : 1,
                    child: const SizedBox())
              ],
            ),
          )
        ]));
  }
}

class ScheduleBoxUpDown extends StatelessWidget {
  const ScheduleBoxUpDown({
    Key? key,
    required this.isUp,
    required this.roughScheduleIndex,
    required this.scheduleStartHeight,
    required this.setScheduleStartHeight,
  }) : super(key: key);
  final bool isUp;
  final int roughScheduleIndex;
  final double scheduleStartHeight;
  final Function setScheduleStartHeight;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      axis: Axis.vertical,
      feedback: SizedBox(),
      child: Container(
        height: itemHeight / 6,
        width: double.maxFinite,
        alignment: Alignment.center,
        color: const Color.fromARGB(71, 255, 255, 255),
        child: Icon(
          isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          size: itemHeight / 5,
        ),
      ),
      onDragUpdate: (detail) {
        String _printDuration(Duration duration) {
          String twoDigits(int n) => n.toString().padLeft(2, "0");
          String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
          String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
          return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
        }

        if (isUp) {
          bool isChangeStart = true;
          List<String> durationArr = context
              .read<CreateScheduleStore>()
              .roughSchedule[roughScheduleIndex]["detail"]["duration"]
              .split(":");
          // double hourHeight = itemHeight * hours / 24;
          // double minuteHeight = itemHeight * hours / 1440;
          double secoundHeight = itemHeight * hours / 86400;
          double movedSecounds = detail.delta.dy.abs() / secoundHeight;
          if (detail.delta.dy > 0) {
            movedSecounds = -movedSecounds;
          }
          Duration duration = Duration(
              seconds: (double.parse(durationArr[0]) * 3600 +
                      double.parse(durationArr[1]) * 60 +
                      double.parse(durationArr[2]) +
                      movedSecounds.floor())
                  .round());

          List<String> startsAtArr = context
              .read<CreateScheduleStore>()
              .roughSchedule[roughScheduleIndex]["detail"]["starts_at"]
              .split(":");
          Duration startsAtDelta = Duration(
              seconds: (double.parse(startsAtArr[0]) * 3600 +
                      double.parse(startsAtArr[1]) * 60 +
                      double.parse(startsAtArr[2]) -
                      movedSecounds.floor())
                  .round());

          if (roughScheduleIndex == 0) {
            context.read<CreateScheduleStore>().setScheduleStartHeight(
                (startsAtDelta.inSeconds / 3600) * itemHeight);
            setScheduleStartHeight(
                (startsAtDelta.inSeconds / 3600) * itemHeight);
          }

          context.read<CreateScheduleStore>().changeDurationOfSchedule(
              roughScheduleIndex,
              _printDuration(duration),
              _printDuration(startsAtDelta),
              isChangeStart);
        }
      },
    );
    //   style: ElevatedButton.styleFrom(
    //     padding: const EdgeInsets.all(0),
    //     primary: const Color.fromARGB(71, 255, 255, 255),
    //     fixedSize: const Size(double.maxFinite, itemHeight / 6),
    //     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    //     elevation: 0,
    //   ),
    //   child: Icon(
    //     isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
    //     size: itemHeight / 5,
    //   ),
    //   onPressed: () {},
    //   onLongPress: () {
    //     if (isUp) {
    //       context.read<CreateScheduleStore>().roughSchedule[roughScheduleIndex]
    //           ["detail"]["duration"];
    //     }
    //   },
    // );
  }
}

class ScheduleBoxWhenDragging extends StatelessWidget {
  const ScheduleBoxWhenDragging(
      {Key? key, required this.roughSchedule, required this.roughScheduleIndex})
      : super(key: key);
  final List<Map> roughSchedule;
  final int roughScheduleIndex;

  @override
  Widget build(BuildContext context) {
    Place place = roughSchedule[roughScheduleIndex]["detail"]["place"];
    List<String> durationArr =
        roughSchedule[roughScheduleIndex]["detail"]["duration"].split(":");
    double boxHeight = (double.parse(durationArr[0]) +
            double.parse(durationArr[1]) / 60 +
            double.parse(durationArr[2]) / 3600) *
        itemHeight;

    return Container(
      decoration: BoxDecoration(
        color: place.color,
        borderRadius: BorderRadius.circular(20),
      ),
      height: boxHeight,
      width: timeLineWidth,
      alignment: Alignment.center,
      child: Text(
        place.nameKor,
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
      required this.roughSchedule,
      required this.roughScheduleIndex,
      this.selected = false,
      this.selectedNeighbor = false})
      : super(key: key);
  final List<Map> roughSchedule;
  final int roughScheduleIndex;
  final bool selected;
  final bool selectedNeighbor;

  @override
  Widget build(BuildContext context) {
    List<String> durationArr =
        roughSchedule[roughScheduleIndex]["detail"]["duration"].split(":");
    double boxHeight = (double.parse(durationArr[0]) +
            double.parse(durationArr[1]) / 60 +
            double.parse(durationArr[2]) / 3600) *
        itemHeight;

    if (!selected) {
      if ((roughScheduleIndex == 0 ||
              roughScheduleIndex == roughSchedule.length - 1) &&
          roughSchedule.length != 1) {
        boxHeight -= itemHeight / 20;
      } else if (roughSchedule.length != 1 || selectedNeighbor) {
        boxHeight -= itemHeight / 10;
      }
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
      },
    );
  }
}
