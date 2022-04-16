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
  late Function setScheduleStartHeight;

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

    return LongPressDraggable(
      feedback: _onLongPress(boxHeight),
      delay: const Duration(milliseconds: 100),
      data: widget.roughScheduleIndex,
      onDragEnd: (DraggableDetails details) {
        // print('onDragEnd');
        // print('wasAccepted: ${details.wasAccepted}');
        // print('velocity: ${details.velocity}');
        // print('offset: ${details.offset}');
        context.read<CreateScheduleStore>().onDragEnd(details.offset);
        widget.setScheduleStartHeight(
            context.read<CreateScheduleStore>().scheduleStartHeight);
      },
      onDragStarted: () {
        context.read<CreateScheduleStore>().onDragStart();
        context.read<CreateScheduleStore>().scheduleStartHeight =
            widget.scheduleStartHeight;
      },
      onDragUpdate: (DragUpdateDetails details) => context
          .read<CreateScheduleStore>()
          .draggingBoxOffset = details.globalPosition,
      onDraggableCanceled: (velocity, offset) {
        context.read<CreateScheduleStore>().onDragEnd(offset);
      },
      child: Container(
        decoration: BoxDecoration(
            color: widget.place.color, borderRadius: BorderRadius.circular(20)),
        height: boxHeight,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const Expanded(
              flex: 1,
              child: ScheduleBoxUpDown(
                isUp: true,
              ),
            ),
            Expanded(
              flex: 4,
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
            const Expanded(
              flex: 1,
              child: ScheduleBoxUpDown(
                isUp: false,
              ),
            ),
          ],
        ),
      ),
      childWhenDragging: _childWhenDragging(boxHeight),
    );
  }
}

class ScheduleBoxUpDown extends StatelessWidget {
  const ScheduleBoxUpDown({Key? key, required this.isUp}) : super(key: key);
  final bool isUp;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        primary: const Color.fromARGB(71, 255, 255, 255),
        fixedSize: const Size(double.maxFinite, itemHeight / 6),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
      ),
      child: Icon(
        isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        size: itemHeight / 5,
      ),
      onPressed: () {},
      clipBehavior: Clip.hardEdge,
    );
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
      {Key? key, required this.roughSchedule, required this.roughScheduleIndex})
      : super(key: key);
  final List<Map> roughSchedule;
  final int roughScheduleIndex;

  @override
  Widget build(BuildContext context) {
    List<String> durationArr =
        roughSchedule[roughScheduleIndex]["detail"]["duration"].split(":");
    double boxHeight = (double.parse(durationArr[0]) +
            double.parse(durationArr[1]) / 60 +
            double.parse(durationArr[2]) / 3600) *
        itemHeight;

    if ((roughScheduleIndex == 0 ||
            roughScheduleIndex == roughSchedule.length - 1) &&
        roughSchedule.length != 1) {
      boxHeight -= itemHeight / 20;
    } else if (roughSchedule.length != 1) {
      boxHeight -= itemHeight / 10;
    }

    return SizedBox(
      height: boxHeight,
    );
  }
}

class ScheduleBoxDragTarget extends StatefulWidget {
  const ScheduleBoxDragTarget({Key? key}) : super(key: key);

  @override
  State<ScheduleBoxDragTarget> createState() => _ScheduleBoxDragTargetState();
}

class _ScheduleBoxDragTargetState extends State<ScheduleBoxDragTarget> {
  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: itemHeight / 10,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.blue,
          ),
        );
      },
      onWillAccept: (data) {
        return true;
      },
    );
  }
}
