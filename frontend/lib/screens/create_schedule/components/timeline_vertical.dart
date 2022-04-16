import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/create_schedule_screen.dart';
import 'package:dayplan_it/screens/create_schedule/components/dragNdropAbles.dart';

const double itemHeight = 85;
const int hours = 24;

const double timeLineWidth = 120;

class TimeLine extends StatefulWidget {
  const TimeLine({Key? key}) : super(key: key);

  @override
  State<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  final double timeLineFullHeight = itemHeight * hours;
  final double initScrollOffset = itemHeight * 8 - 20;
  final ScrollController _scrollController = ScrollController(
      initialScrollOffset: (itemHeight * 8 - 20), keepScrollOffset: false);

  double scheduleStartHeight = itemHeight * 8;

  double currentTimeLineOffset = itemHeight * 8 - 20;

  Widget _buildRoughScheduleBoxColumn() {
    List<Map> roughSchedule =
        context.watch<CreateScheduleStore>().roughSchedule;

    if (roughSchedule.isEmpty) {
      scheduleStartHeight = currentTimeLineOffset + 20;
      return const SizedBox();
    } else {
      return Column(
        children: [
          SizedBox(
            height: scheduleStartHeight,
          ),
          Column(
            children: [
              for (int i = 0; i < roughSchedule.length; i++)
                _buildRoughScheduleBoxes(roughSchedule[i], i)
            ],
          ),
        ],
      );
    }
  }

  Widget _buildRoughScheduleBoxes(
      Map roughScheduleBox, int roughScheduleIndex) {
    Place place = roughScheduleBox["detail"]["place"];
    return ScheduleBox(place: place, roughScheduleIndex: roughScheduleIndex);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        currentTimeLineOffset = _scrollController.offset;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Stack(children: [
            Row(
              children: [
                SizedBox(
                    width: 37,
                    child: Column(
                      children: [
                        for (int i = 0; i < hours + 1; i++)
                          SizedBox(
                            height:
                                i != 0 && i != 24 ? itemHeight : itemHeight / 2,
                            child: i != 0 && i != 24
                                ? Align(
                                    alignment: Alignment.centerRight,
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
                SizedBox(
                  width: timeLineWidth,
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        for (int i = 0; i < hours; i++)
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: itemHeight,
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
                )
              ],
            ),
            Positioned.fill(
              child: Row(
                children: [
                  const SizedBox(width: 37, child: SizedBox()),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                      width: timeLineWidth,
                      child: _buildRoughScheduleBoxColumn()),
                ],
              ),
            )
          ]),
        );
      },
    );
  }
}

class ScheduleBox extends StatelessWidget {
  ScheduleBox({Key? key, required this.place, required this.roughScheduleIndex})
      : super(key: key);

  final Place place;
  final int roughScheduleIndex;

  Widget _onLongPress(double boxHeight) {
    return Container(
      decoration: BoxDecoration(
          color: place.color.withAlpha(150),
          borderRadius: BorderRadius.circular(20)),
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

  Widget _childWhenDragging(double boxHeight) {
    return Container(
      decoration: BoxDecoration(
          color: place.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color.fromARGB(255, 38, 0, 255), width: 5)),
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

  @override
  Widget build(BuildContext context) {
    List<String> durationArr = context
        .watch<CreateScheduleStore>()
        .roughSchedule[roughScheduleIndex]["detail"]["duration"]
        .split(":");
    double boxHeight = (double.parse(durationArr[0]) +
            double.parse(durationArr[1]) / 60 +
            double.parse(durationArr[2]) / 3600) *
        itemHeight;

    return LongPressDraggable(
      feedback: _onLongPress(boxHeight),
      delay: Duration(milliseconds: 100),
      onDragEnd: (DraggableDetails details) {
        // print('onDragEnd');
        // print('wasAccepted: ${details.wasAccepted}');
        // print('velocity: ${details.velocity}');
        // print('offset: ${details.offset}');
        context.read<CreateScheduleStore>().onDragEnd(details.offset);
      },
      data: roughScheduleIndex,
      onDragStarted: context.read<CreateScheduleStore>().onDragStart,
      onDragUpdate: (DragUpdateDetails details) => context
          .read<CreateScheduleStore>()
          .onDragUpdate(details.globalPosition),
      child: Container(
        decoration: BoxDecoration(
            color: place.color, borderRadius: BorderRadius.circular(20)),
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
                  place.nameKor,
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
