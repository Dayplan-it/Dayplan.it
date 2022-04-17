import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/create_schedule_screen.dart';
import 'package:dayplan_it/screens/create_schedule/components/scheduleBox.dart';

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
  _setScheduleStartHeight(double _scheduleStartHeight) {
    setState(() {
      scheduleStartHeight = _scheduleStartHeight;
    });
  }

  double currentTimeLineOffset = itemHeight * 8 - 20;

  Widget _buildRoughScheduleBoxes(
      Map roughScheduleBox, int roughScheduleIndex) {
    Place place = roughScheduleBox["detail"]["place"];
    return ScheduleBox(
      place: place,
      roughScheduleIndex: roughScheduleIndex,
      scheduleStartHeight: scheduleStartHeight,
      setScheduleStartHeight: _setScheduleStartHeight,
    );
  }

  Widget _buildRoughScheduleBoxColumn() {
    List<Map> roughSchedule =
        context.watch<CreateScheduleStore>().roughSchedule;

    if (roughSchedule.isEmpty) {
      scheduleStartHeight = currentTimeLineOffset + 20;
      return const SizedBox();
    } else {
      return Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: scheduleStartHeight,
              ),
              for (int i = 0; i < roughSchedule.length; i++)
                _buildRoughScheduleBoxes(roughSchedule[i], i)
            ],
          ),
          Positioned.fill(
              child: context.watch<CreateScheduleStore>().isDragging
                  ? Stack(children: [
                      Column(
                        children: [
                          SizedBox(
                            height: scheduleStartHeight,
                          ),
                          for (int i = 0; i < roughSchedule.length; i++)
                            if (context
                                    .read<CreateScheduleStore>()
                                    .currentlyDragging ==
                                i)
                              ScheduleBoxWhenDraggingDummy(
                                  roughSchedule: roughSchedule,
                                  roughScheduleIndex: i,
                                  selected: true)
                            else
                              ScheduleBoxWhenDragging(
                                  roughSchedule: roughSchedule,
                                  roughScheduleIndex: i)
                        ],
                      ),
                      Positioned.fill(
                          child: Column(
                        children: [
                          SizedBox(
                            height: scheduleStartHeight - itemHeight / 10,
                          ),
                          for (int i = 0; i < roughSchedule.length * 2 + 1; i++)
                            if (i % 2 == 0)
                              ScheduleBoxDragTarget(targetId: i)
                            else
                              ScheduleBoxWhenDraggingDummy(
                                  roughSchedule: roughSchedule,
                                  roughScheduleIndex: (i / 2).floor())
                        ],
                      ))
                    ])
                  : const SizedBox())
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // print(_scrollController.position.pixels);

      setState(() {
        currentTimeLineOffset = _scrollController.position.pixels;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Stack(children: [
        const TimelineBackground(),
        Positioned.fill(
          child: Row(
            children: [
              const SizedBox(width: 37, child: SizedBox()),
              const SizedBox(
                width: 5,
              ),
              SizedBox(
                width: timeLineWidth,
                child: _buildRoughScheduleBoxColumn(),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class TimelineBackground extends StatelessWidget {
  const TimelineBackground({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 37,
            child: Column(
              children: [
                for (int i = 0; i < hours + 1; i++)
                  SizedBox(
                    height: i != 0 && i != 24 ? itemHeight : itemHeight / 2,
                    child: i != 0 && i != 24
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              (i.toString() + (i < 12 ? ' AM' : ' PM')),
                              style:
                                  mainFont(color: subTextColor, fontSize: 12),
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
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
    );
  }
}
