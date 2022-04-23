import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/scheduleBox.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class DurationLine extends StatefulWidget {
  const DurationLine({Key? key, required this.durationLineWidth})
      : super(key: key);
  final double durationLineWidth;

  @override
  State<DurationLine> createState() => _DurationLineState();
}

class _DurationLineState extends State<DurationLine> {
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      context.read<CreateScheduleStore>().durationLineHeight =
          _scrollController.position.pixels;
    });
  }

  Widget _buildDurationScheduleBoxTimeLine() {
    List<PlaceDurationOnly> durationSchedule =
        context.watch<CreateScheduleStore>().durationSchedule;

    if (durationSchedule.isEmpty) {
      return const SizedBox();
    } else {
      return Column(
        children: [
          const SizedBox(
            height: reorderDragTargetHeight / 2,
          ),
          Stack(children: [
            Column(
              children: [
                for (int i = 0; i < durationSchedule.length; i++)
                  if (context
                          .watch<CreateScheduleStore>()
                          .isDecidingPrimarySchedule &&
                      context
                              .watch<CreateScheduleStore>()
                              .currentlyDecidingPrimarySchedule ==
                          i)
                    OnDurationOnlyScheduleBoxLongPress(
                      placeDurationOnly: durationSchedule[i],
                      width: widget.durationLineWidth,
                    )
                  else
                    DurationOnlyScheduleBox(
                      placeDurationOnly: durationSchedule[i],
                      index: i,
                      itemWidth: widget.durationLineWidth,
                    )
              ],
            ),
            if (context
                .watch<CreateScheduleStore>()
                .isDurationOnlyScheduleDragging)
              Positioned.fill(
                  child: Column(
                children: [
                  for (int i = 0; i < durationSchedule.length; i++)
                    if (i ==
                        context
                            .watch<CreateScheduleStore>()
                            .indexOfcurrentlyDraggingPlaceDurationOnly)
                      OnDurationOnlyScheduleBoxLongPress(
                        placeDurationOnly: durationSchedule[i],
                        width: widget.durationLineWidth,
                      )
                    else
                      SizedBox(
                        height: durationSchedule[i].toHeight(),
                      )
                ],
              ))
          ])
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Positioned 사용하기 위해 Stack 사용함
      // 스케줄 Reorder시에 0시에 생기는 DragTarget때문에 이같은 과정이 필요
      children: [
        Positioned(
          top: -reorderDragTargetHeight / 2,
          left: 0,
          right: 0,
          bottom: 0,
          // Scroll 위해서는 모든 방향 position 지정해주어야 작동함
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Stack(children: [
              DurationlineBackground(
                  durationLineWidth: widget.durationLineWidth),
              Positioned.fill(
                  child: Row(
                children: [
                  const SizedBox(
                    width: 42,
                  ),
                  Stack(children: [
                    _buildDurationScheduleBoxTimeLine(),
                    if (context
                        .watch<CreateScheduleStore>()
                        .isDurationOnlyScheduleDragging)
                      const Positioned.fill(
                          child: DurationLineReorderDragTargetCol()),
                  ])
                ],
              ))
            ]),
          ),
        ),
      ],
    );
  }
}

class DurationlineBackground extends StatelessWidget {
  const DurationlineBackground({Key? key, required this.durationLineWidth})
      : super(key: key);

  final double durationLineWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 37,
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
                              (i.toString() + '시간'),
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
        Column(
          children: [
            const SizedBox(
              height: reorderDragTargetHeight / 2,
            ),
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              width: durationLineWidth,
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
        )
      ],
    );
  }
}

class DurationLineReorderDragTargetCol extends StatelessWidget {
  const DurationLineReorderDragTargetCol({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0;
            i <
                context.read<CreateScheduleStore>().durationSchedule.length *
                        2 +
                    1;
            i++)
          if (i % 2 == 0)
            DurationOnlyScheduleBoxDragTarget(targetId: i)
          else
            SizedBox(
              height: context
                      .read<CreateScheduleStore>()
                      .durationSchedule[(i / 2).floor()]
                      .toHeight() -
                  reorderDragTargetHeight,
            ),
      ],
    );
  }
}
