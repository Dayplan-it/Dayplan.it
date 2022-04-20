import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/scheduleBox.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place_rough.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

/// 타임라인 위젯
/// 전체적으로 다음과 같은 순서로 진행됨
/// 1. 타임라인을 그림
/// 2. 타임라인 위에 올려질 스케줄 블록을 Stack
///   2-1. isDragging에 따라 모양이 바뀜
class TimeLine extends StatefulWidget {
  const TimeLine({Key? key, required this.timeLineWidth}) : super(key: key);
  final double timeLineWidth;

  @override
  State<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    if (context.read<CreateScheduleStore>().roughSchedule.isEmpty) {
      _scrollController = ScrollController(
          initialScrollOffset: (itemHeight * 8 - 20), keepScrollOffset: false);
      _scrollController.addListener(() {
        context.read<CreateScheduleStore>().scheduleAddHeight =
            _scrollController.position.pixels + 20;
      });
    } else {
      _scrollController = ScrollController(
          initialScrollOffset:
              (context.read<CreateScheduleStore>().scheduleAddHeight - 20),
          keepScrollOffset: false);
      _scrollController.addListener(() {
        context.read<CreateScheduleStore>().scheduleAddHeight =
            _scrollController.position.pixels + 20;
      });
    }
  }

  Widget _buildRoughScheduleBoxTimeLine() {
    List<PlaceRough> roughSchedule =
        context.watch<CreateScheduleStore>().roughSchedule;

    if (roughSchedule.isEmpty) {
      return const SizedBox();
    } else {
      return Row(
        children: [
          //const SizedBox(width: 42),
          SizedBox(
              width: widget.timeLineWidth + 42,
              child: Align(
                alignment: Alignment.centerRight,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: context
                              .watch<CreateScheduleStore>()
                              .scheduleStartHeight,
                        ),
                        for (int i = 0; i < roughSchedule.length; i++)
                          context.read<CreateScheduleStore>().isDetailBeingMade
                              ? Row(
                                  children: [
                                    const SizedBox(
                                      width: 42,
                                    ),
                                    ScheduleBoxWhenDragging(
                                      placeRough: roughSchedule[i],
                                      index: i,
                                      itemWidth: widget.timeLineWidth,
                                      dragging: (context
                                                  .read<CreateScheduleStore>()
                                                  .indexOfCurrentlyDecidingDetail ==
                                              i)
                                          ? true
                                          : false,
                                    ),
                                  ],
                                )
                              : Stack(children: [
                                  SizedBox(
                                    height: durationToHeight(
                                        roughSchedule[i].duration),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            width: 42 - scheduleBoxHandleWidth,
                                          ),
                                          ScheduleBoxHandle(
                                              timeLineWidth:
                                                  widget.timeLineWidth,
                                              index: i),
                                        ]),
                                  ),
                                  Positioned.fill(
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 42,
                                        ),
                                        ScheduleBoxRough(
                                            place: roughSchedule[i],
                                            index: i,
                                            itemWidth: widget.timeLineWidth,
                                            scrollController:
                                                _scrollController),
                                      ],
                                    ),
                                  ),
                                ]),
                      ],
                    ),
                    Positioned.fill(
                        child: context.watch<CreateScheduleStore>().isDragging
                            ? _buildDragComponents(roughSchedule)
                            : const SizedBox())
                  ],
                ),
              )),
        ],
      );
    }
  }

  Row _buildDragComponents(List<PlaceRough> roughSchedule) {
    return Row(
      children: [
        const SizedBox(
          width: 42,
        ),
        Stack(children: [
          Column(
            children: [
              SizedBox(
                height:
                    context.watch<CreateScheduleStore>().scheduleStartHeight,
              ),
              for (int i = 0; i < roughSchedule.length; i++)
                if (context.read<CreateScheduleStore>().currentlyDragging == i)
                  ScheduleBoxWhenDragging(
                      placeRough: roughSchedule[i],
                      index: i,
                      itemWidth: widget.timeLineWidth,
                      dragging: true)
                else
                  ScheduleBoxWhenDragging(
                    placeRough: roughSchedule[i],
                    index: i,
                    itemWidth: widget.timeLineWidth,
                  )
            ],
          ),
          Positioned.fill(
              child: Column(
            children: [
              SizedBox(
                height:
                    context.read<CreateScheduleStore>().scheduleStartHeight != 0
                        ? context
                                .read<CreateScheduleStore>()
                                .scheduleStartHeight -
                            reorderDragTargetHeight / 2
                        : 0,
              ),
              for (int i = 0; i < roughSchedule.length * 2 + 1; i++)
                if (i % 2 == 0)
                  ScheduleBoxDragTarget(targetId: i)
                else
                  ScheduleBoxWhenDraggingDummy(
                      placeRough: roughSchedule[(i / 2).floor()],
                      index: (i / 2).floor())
            ],
          ))
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Stack(children: [
            TimelineBackground(timeLineWidth: widget.timeLineWidth),
            Positioned.fill(
              child: _buildRoughScheduleBoxTimeLine(),
            )
          ]),
        ),
        Positioned.fill(
            child: Column(
          children: [
            if (context.watch<CreateScheduleStore>().isBlockResizing)
              TimeLineAutoDragTarget(
                  scrollController: _scrollController, isUp: true),
            const Expanded(child: SizedBox()),
            if (context.watch<CreateScheduleStore>().isBlockResizing)
              TimeLineAutoDragTarget(
                  scrollController: _scrollController, isUp: false),
          ],
        ))
      ],
    );
  }
}

class TimeLineAutoDragTarget extends StatefulWidget {
  const TimeLineAutoDragTarget(
      {Key? key, required this.scrollController, required this.isUp})
      : super(key: key);
  final ScrollController scrollController;
  final bool isUp;

  @override
  State<TimeLineAutoDragTarget> createState() => _TimeLineAutoDragTargetState();
}

class _TimeLineAutoDragTargetState extends State<TimeLineAutoDragTarget> {
  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return context.read<CreateScheduleStore>().isAutoScrollAble
            ? Container(
                height: itemHeight / 2,
                width: double.infinity,
                color: const Color.fromARGB(169, 93, 96, 251),
              )
            : Container(
                height: itemHeight / 2,
                width: double.infinity,
                color: const Color.fromARGB(0, 0, 0, 0),
              );
      },
      onMove: (_) {},
      onWillAccept: (bool? data) {
        context.read<CreateScheduleStore>().onAutoScrollOn();
        return true;
      },
      onLeave: (data) {
        context.read<CreateScheduleStore>().onAutoScrollOff();
      },
    );
  }
}

class TimelineBackground extends StatelessWidget {
  const TimelineBackground({Key? key, required this.timeLineWidth})
      : super(
          key: key,
        );
  final double timeLineWidth;

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
                    height: i != 0 && i != hours ? itemHeight : itemHeight / 2,
                    child: i != 0 && i != hours
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
