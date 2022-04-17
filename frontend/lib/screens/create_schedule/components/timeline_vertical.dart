import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/components/scheduleBox.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place_rough.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

/// 타임라인 위젯
/// 전체적으로 다음과 같은 순서로 진행됨
/// 1. 타임라인을 그림
/// 2. 타임라인 위에 올려질 스케줄 블록을 Stack
///   2-1. isDragging에 따라 모양이 바뀜
class TimeLine extends StatefulWidget {
  const TimeLine({Key? key}) : super(key: key);

  @override
  State<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  // 처음에는 8시 - 20만큼에서 타임라인바 시작
  final ScrollController _scrollController = ScrollController(
      initialScrollOffset: (itemHeight * 8 - 20), keepScrollOffset: false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      context.read<CreateScheduleStore>().scheduleAddHeight =
          _scrollController.position.pixels + 20;
    });
  }

  Widget _buildRoughScheduleBoxColumn() {
    List<PlaceRough> roughSchedule =
        context.watch<CreateScheduleStore>().roughSchedule;

    if (roughSchedule.isEmpty) {
      return const SizedBox();
    } else {
      return Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height:
                    context.watch<CreateScheduleStore>().scheduleStartHeight,
              ),
              for (int i = 0; i < roughSchedule.length; i++)
                ScheduleBoxRough(
                  place: roughSchedule[i],
                  index: i,
                )
            ],
          ),
          Positioned.fill(
              child: context.watch<CreateScheduleStore>().isDragging
                  ? Stack(children: [
                      Column(
                        children: [
                          SizedBox(
                            height: context
                                .watch<CreateScheduleStore>()
                                .scheduleStartHeight,
                          ),
                          for (int i = 0; i < roughSchedule.length; i++)
                            if (context
                                    .read<CreateScheduleStore>()
                                    .currentlyDragging ==
                                i)
                              ScheduleBoxWhenDragging(
                                  placeRough: roughSchedule[i],
                                  index: i,
                                  dragging: true)
                            else
                              ScheduleBoxWhenDragging(
                                  placeRough: roughSchedule[i], index: i)
                        ],
                      ),
                      Positioned.fill(
                          child: Column(
                        children: [
                          SizedBox(
                            height: context
                                    .watch<CreateScheduleStore>()
                                    .scheduleStartHeight -
                                itemHeight / 10,
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
                    ])
                  : const SizedBox())
        ],
      );
    }
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
