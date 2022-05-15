import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/scheduleBox.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class TimeLine extends StatefulWidget {
  const TimeLine({
    Key? key,
  }) : super(key: key);

  @override
  State<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  final GlobalKey _timeLineBoxAreaKey = GlobalKey();

  _getAndSetTimeLineBoxAreaWidth() {
    context.read<CreateScheduleStore>().setTimeLineBoxAreaWidth(
        _timeLineBoxAreaKey.currentContext!.size!.width);
  }

  @override
  void initState() {
    context.read<CreateScheduleStore>().timeLineScrollController =
        ScrollController(
            initialScrollOffset: durationToHeight(const Duration(hours: 9)));
    context
        .read<CreateScheduleStore>()
        .timeLineScrollController
        .addListener(() {
      context.read<CreateScheduleStore>().timeLineScrollHeight = context
          .read<CreateScheduleStore>()
          .timeLineScrollController
          .position
          .pixels;
    });
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => _getAndSetTimeLineBoxAreaWidth());
  }

  Widget _buildScheduleStartsAt() {
    return Row(
      children: [
        const SizedBox(
          width: 40,
        ),
        Expanded(
          child: Column(
            children: [
              const SizedBox(
                height: reorderDragTargetHeight / 2,
              ),
              GestureDetector(
                onTap: () {
                  context.read<CreateScheduleStore>().onBeforeStartTap();
                  context
                      .read<CreateScheduleStore>()
                      .onDecidingScheduleStartsAtStart();
                },
                child: Container(
                  height: (context
                              .watch<CreateScheduleStore>()
                              .isCreateRouteTabOn &&
                          context
                              .watch<CreateScheduleStore>()
                              .isScheduleCreated)
                      ? dateTimeToHeight(context
                          .watch<CreateScheduleStore>()
                          .scheduleCreated
                          .list[0]
                          .startsAt!)
                      : dateTimeToHeight(context
                          .watch<CreateScheduleStore>()
                          .scheduleListStartsAt),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(157, 69, 69, 69),
                    borderRadius: defaultBoxRadius,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleBoxTimeLine() {
    List<dynamic> scheduleList =
        context.watch<CreateScheduleStore>().scheduleList;

    if (scheduleList.isEmpty) {
      return const SizedBox.shrink();
    } else {
      // if (context.watch<CreateScheduleStore>().isCreateRouteTabOn &&
      //     context.watch<CreateScheduleStore>().isScheduleCreated) {
      //   if (!context.watch<CreateScheduleStore>().isFindingRoute &&
      //       context.watch<CreateScheduleStore>().isRouteCreateAble()) {
      //     List<dynamic> scheduleCreatedList =
      //         context.read<CreateScheduleStore>().scheduleCreated.list;
      //     return Column(children: [
      //       SizedBox(
      //         height: reorderDragTargetHeight / 2 +
      //             dateTimeToHeight(scheduleCreatedList[0].startsAt!),
      //       ),
      //       for (int i = 0; i < scheduleCreatedList.length; i++)
      //         if (scheduleCreatedList[i].runtimeType == Place) ...[
      //           ScheduleBoxForCreatedSchedule(
      //             place: scheduleCreatedList[i],
      //           ),
      //         ] else ...[
      //           RouteBox(
      //             route: scheduleCreatedList[i],
      //           )
      //         ],
      //     ]);
      //   } else {
      //     return const SizedBox.shrink();
      //   }
      // }
      return Column(children: [
        SizedBox(
          height: reorderDragTargetHeight / 2 +
              dateTimeToHeight(
                  context.watch<CreateScheduleStore>().scheduleListStartsAt),
        ),
        Stack(
          children: [
            Column(
              children: [
                for (int i = 0; i < scheduleList.length; i++)
                  ScheduleBox(
                    place: scheduleList[i],
                    index: i,
                  ),
              ],
            ),
            if (context.watch<CreateScheduleStore>().tabController.index == 1)
              Positioned.fill(
                child: Column(children: [
                  for (int i = 0; i < scheduleList.length; i++)
                    if (i ==
                        context
                            .watch<CreateScheduleStore>()
                            .indexOfPlaceDecidingSchedule)
                      ScheduleBox(
                        place: scheduleList[i],
                        index: i,
                        isLongPress: true,
                      )
                    else
                      SizedBox(
                        height: scheduleList[i].toHeight(),
                      ),
                ]),
              ),
            if (context.watch<CreateScheduleStore>().isScheduleBoxDragging)
              Positioned.fill(
                child: Column(children: [
                  for (int i = 0; i < scheduleList.length; i++)
                    if (i ==
                        context
                            .watch<CreateScheduleStore>()
                            .indexOfDraggingScheduleBox)
                      ScheduleBox(
                        place: scheduleList[i],
                        index: i,
                        isLongPress: true,
                      )
                    else
                      SizedBox(
                        height: scheduleList[i].toHeight(),
                      ),
                ]),
              ),
          ],
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        controller:
            context.read<CreateScheduleStore>().timeLineScrollController,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Stack(children: [
          const TimelineBackground(),
          Positioned.fill(child: _buildScheduleStartsAt()),
          Positioned.fill(
              child: Row(
            children: [
              const SizedBox(
                width: 42,
              ),
              Expanded(
                key: _timeLineBoxAreaKey,
                child: Stack(children: [
                  _buildScheduleBoxTimeLine(),
                  if (context
                      .watch<CreateScheduleStore>()
                      .isScheduleBoxDragging)
                    const Positioned.fill(
                        child: TimeLineReorderDragTargetCol()),
                ]),
              )
            ],
          ))
        ]));
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
            width: 35,
            child: Column(
              children: [
                const SizedBox(
                  height: reorderDragTargetHeight / 2,
                ),
                for (int i = 0; i < hours + 1; i++)
                  SizedBox(
                    height: i != 0 && i != hours ? itemHeight : itemHeight / 2,
                    child: i != 0 && i != hours
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              (i.toString() + (i < 12 ? 'AM' : 'PM')),
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
        Expanded(
          child: Column(
            children: [
              const SizedBox(
                height: reorderDragTargetHeight / 2,
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                width: double.infinity,
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
            ],
          ),
        )
      ],
    );
  }
}

class TimeLineReorderDragTargetCol extends StatelessWidget {
  const TimeLineReorderDragTargetCol({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: dateTimeToHeight(
              context.watch<CreateScheduleStore>().scheduleListStartsAt),
        ),
        for (int i = 0;
            i < context.read<CreateScheduleStore>().scheduleList.length * 2 + 1;
            i++)
          if (i % 2 == 0) ScheduleBoxDragTarget(targetId: i)
      ],
    );
  }
}
