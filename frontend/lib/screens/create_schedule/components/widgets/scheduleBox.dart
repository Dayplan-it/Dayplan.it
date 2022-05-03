import 'package:dayplan_it/screens/create_schedule/components/class/route_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/class/schedule_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class ScheduleBox extends StatelessWidget {
  const ScheduleBox({
    Key? key,
    required this.place,
    required this.index,
  }) : super(key: key);

  final Place place;
  final int index;

  @override
  Widget build(BuildContext context) {
    bool isEmpty = (place.placeType == "empty");
    Widget _fixedToggle(String title) {
      return Positioned(
        top: itemHeight / 10,
        right: itemHeight / 10,
        child: GestureDetector(
          onTap: () =>
              context.read<CreateScheduleStore>().tabController.index == 0
                  ? context
                      .read<CreateScheduleStore>()
                      .toggleScheduleFixedOrNot(index)
                  : null,
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
            alignment: Alignment.center,
            height: durationToHeight(minimumScheduleBoxDuration) / 2,
            decoration: BoxDecoration(
                color: const Color.fromARGB(83, 255, 255, 255),
                borderRadius: BorderRadius.circular(30)),
            child: Text(
              title,
              style: mainFont(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: durationToHeight(minimumScheduleBoxDuration) / 3.5,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    }

    return Container(
        decoration: BoxDecoration(
            color: place.color,
            borderRadius: defaultBoxRadius,
            boxShadow: defaultBoxShadow),
        height: place.toHeight(),
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Center(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Column(
                  children: [
                    if (!isEmpty)
                      Text(
                        place.nameKor,
                        style: mainFont(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: itemHeight / 5,
                            letterSpacing: 1),
                      ),
                    Visibility(
                      visible: place.toHeight() > 60,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "${place.startsAt?.hour.toString().padLeft(2, "0")}:${place.startsAt?.minute.toString().padLeft(2, "0")} ~ ${place.endsAt?.hour.toString().padLeft(2, "0")}:${place.endsAt?.minute.toString().padLeft(2, "0")}",
                            style: mainFont(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: itemHeight / 7,
                                letterSpacing: 1),
                          ),
                          Text(
                            ((place.duration.inMinutes >= 60)
                                    ? place.duration.inHours.toString() + "시간 "
                                    : "") +
                                ((place.duration.inMinutes % 60) != 0
                                    ? (place.duration.inMinutes % 60)
                                            .toString() +
                                        "분"
                                    : ""),
                            style: mainFont(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: itemHeight / 7,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: !context
                .read<CreateScheduleStore>()
                .scheduleList[index]
                .isFixed,
            child: Positioned.fill(
              child: Column(
                children: [
                  ScheduleBoxUpDownHandle(
                    isUp: true,
                    index: index,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (context
                                .read<CreateScheduleStore>()
                                .tabController
                                .index ==
                            0) {
                          context
                              .read<CreateScheduleStore>()
                              .onBeforeStartTapEnd();
                          context
                              .read<CreateScheduleStore>()
                              .setIndexOfcurrentlyDecidingStartsAtSchedule(
                                  index);
                          context
                              .read<CreateScheduleStore>()
                              .onDecidingScheduleStartsAtStart();
                        } else if (context
                                .read<CreateScheduleStore>()
                                .tabController
                                .index ==
                            1) {
                          context
                              .read<CreateScheduleStore>()
                              .setIndexOfPlaceDecidingSchedule(index);
                        }
                      },
                      child: LongPressDraggable(
                        feedback: OnScheduleBoxLongPress(
                          place: place,
                          isFeedback: true,
                        ),
                        delay: const Duration(milliseconds: 300),
                        data: index,
                        onDragEnd: (DraggableDetails details) => context
                            .read<CreateScheduleStore>()
                            .onScheduleBoxDragEnd(),
                        onDragStarted: () => context
                            .read<CreateScheduleStore>()
                            .onScheduleBoxDragStart(index),
                        onDraggableCanceled: (velocity, offset) => context
                            .read<CreateScheduleStore>()
                            .onScheduleBoxDragEnd(),
                        child: Container(
                          color: const Color.fromRGBO(0, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  ScheduleBoxUpDownHandle(
                    isUp: false,
                    index: index,
                  ),
                ],
              ),
            ),
          ),
          place.isFixed ? _fixedToggle('고정') : _fixedToggle('유동')
        ]));
  }
}

class OnScheduleBoxLongPress extends StatelessWidget {
  const OnScheduleBoxLongPress({
    Key? key,
    required this.place,
    this.isFeedback = false,
  }) : super(key: key);

  final Place place;
  final bool isFeedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: place.color.withAlpha((isFeedback ? 150 : 255)),
          borderRadius: defaultBoxRadius,
          border: Border.all(color: Colors.blue, width: 4)),
      height: place.toHeight(),
      width: isFeedback
          ? context.watch<CreateScheduleStore>().timeLineBoxAreaWidth
          : double.infinity,
      // 다른 컨테이너들은 모두 Expanded로 너비는 명시할 필요가 없지만
      // isFeedback = true인 경우 부모 위젯이 없어 너비를 직접 명시해주어야 함
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(
              children: [
                if (place.nameKor.isNotEmpty)
                  Text(
                    place.nameKor,
                    style: mainFont(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: itemHeight / 5,
                        letterSpacing: 1),
                  ),
                Visibility(
                  visible: place.toHeight() > 60,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${place.startsAt?.hour.toString().padLeft(2, "0")}:${place.startsAt?.minute.toString().padLeft(2, "0")} ~ ${place.endsAt?.hour.toString().padLeft(2, "0")}:${place.endsAt?.minute.toString().padLeft(2, "0")}",
                        style: mainFont(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: itemHeight / 7,
                            letterSpacing: 1),
                      ),
                      Text(
                        ((place.duration.inMinutes >= 60)
                                ? place.duration.inHours.toString() + "시간 "
                                : "") +
                            ((place.duration.inMinutes % 60) != 0
                                ? (place.duration.inMinutes % 60).toString() +
                                    "분"
                                : ""),
                        style: mainFont(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: itemHeight / 7,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScheduleBoxUpDownHandle extends StatelessWidget {
  const ScheduleBoxUpDownHandle({
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
      feedback: const SizedBox(),
      data: isUp,
      child: Container(
        height: upDownHandleHeight,
        width: double.maxFinite,
        color: const Color.fromARGB(0, 255, 255, 255),
      ),
      childWhenDragging: Container(
        height: upDownHandleHeight,
        width: double.maxFinite,
        color: const Color.fromARGB(71, 255, 255, 255),
      ),
      onDragUpdate: (detail) {
        context.read<CreateScheduleStore>().toggleIsScheduleBoxDragging();
        context
            .read<CreateScheduleStore>()
            .changeDurationOfScheduleForUpDownBtn(index, detail.delta.dy, isUp);
      },
      onDragEnd: (detail) {
        context.read<CreateScheduleStore>().toggleIsScheduleBoxDragging();
      },
      onDragCompleted: () {
        context.read<CreateScheduleStore>().toggleIsScheduleBoxDragging();
      },
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
        /// isFixed의 순서 조정시 로직은
        /// 구현되지 않음
        /// 추후 추가로 구현이 필요함

        // var scheduleList = context.read<CreateScheduleStore>().scheduleList;
        // int index = (widget.targetId / 2).floor();
        // if (index == 0 || scheduleList.length == index) {
        //   // return const SizedBox(
        //   //   height: reorderDragTargetHeight,
        //   // );
        // } else if (index != 0 && scheduleList.length != 1) {
        //   if (scheduleList[index].isFixed || scheduleList[index - 1].isFixed) {
        //     return const SizedBox(
        //       height: reorderDragTargetHeight,
        //     );
        //   } else if (index != scheduleList.length - 1) {
        //     if (scheduleList[index + 1].isFixed) {
        //       return const SizedBox(
        //         height: reorderDragTargetHeight,
        //       );
        //     }
        //   }
        // } else {
        //   return const SizedBox(
        //     height: reorderDragTargetHeight,
        //   );
        // }
        return Container(
          height: reorderDragTargetHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: defaultBoxRadius,
            color: isHovered
                ? const Color.fromARGB(232, 129, 197, 253)
                : const Color.fromARGB(148, 33, 149, 243),
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
        context.read<CreateScheduleStore>().onScheduleBoxDragEnd();
      },
    );
  }
}

class ScheduleBoxForCreatedSchedule extends StatelessWidget {
  const ScheduleBoxForCreatedSchedule({
    Key? key,
    required this.place,
  }) : super(key: key);

  final Place place;

  Widget _fixedToggle(String title) {
    return Positioned(
      top: itemHeight / 10,
      right: itemHeight / 10,
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
        alignment: Alignment.center,
        height: durationToHeight(minimumScheduleBoxDuration) / 2,
        decoration: BoxDecoration(
            color: const Color.fromARGB(83, 255, 255, 255),
            borderRadius: BorderRadius.circular(30)),
        child: Text(
          title,
          style: mainFont(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontSize: durationToHeight(minimumScheduleBoxDuration) / 3.5,
              fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEmpty = (place.placeType == "empty");

    return Container(
        decoration: BoxDecoration(
            color: place.color,
            borderRadius: defaultBoxRadius,
            boxShadow: defaultBoxShadow),
        height: place.toHeight(),
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Center(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Column(
                  children: [
                    if (!isEmpty)
                      Text(
                        place.nameKor,
                        style: mainFont(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: itemHeight / 5,
                            letterSpacing: 1),
                      ),
                    Visibility(
                      visible: place.toHeight() > 60,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "${place.startsAt?.hour.toString().padLeft(2, "0")}:${place.startsAt?.minute.toString().padLeft(2, "0")} ~ ${place.endsAt?.hour.toString().padLeft(2, "0")}:${place.endsAt?.minute.toString().padLeft(2, "0")}",
                            style: mainFont(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: itemHeight / 7,
                                letterSpacing: 1),
                          ),
                          Text(
                            ((place.duration.inMinutes >= 60)
                                    ? place.duration.inHours.toString() + "시간 "
                                    : "") +
                                ((place.duration.inMinutes % 60) != 0
                                    ? (place.duration.inMinutes % 60)
                                            .toString() +
                                        "분"
                                    : ""),
                            style: mainFont(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: itemHeight / 7,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          place.isFixed ? _fixedToggle('고정') : _fixedToggle('유동')
        ]));
  }
}

class RouteBox extends StatelessWidget {
  const RouteBox({Key? key, required this.route}) : super(key: key);

  final RouteOrder route;

  @override
  Widget build(BuildContext context) {
    bool _isTransitRoute = route.isTransitRoute();
    String transitType = route.getType();
    IconData icon = (_isTransitRoute
        ? (transitType == 'BUS'
            ? CupertinoIcons.bus
            : (transitType == 'SUB'
                ? CupertinoIcons.train_style_one
                : Icons.directions_rounded))
        : Icons.directions_walk);
    return GestureDetector(
      onTap: () {},
      child: Container(
          decoration: BoxDecoration(
              color: const Color.fromARGB(206, 88, 88, 88),
              borderRadius: defaultBoxRadius,
              boxShadow: defaultBoxShadow),
          height: route.toHeight(),
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: (route.toHeight() > 10)
              ? Center(
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: Colors.white,
                        ),
                        Text(
                          _isTransitRoute ? "대중교통" : "도보",
                          style: mainFont(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: itemHeight / 5,
                              letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox()),
    );
  }
}
