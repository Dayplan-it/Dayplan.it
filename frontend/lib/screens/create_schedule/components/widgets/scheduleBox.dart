import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/class/schedule_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/google_map.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class ScheduleBox extends StatelessWidget {
  const ScheduleBox(
      {Key? key,
      required this.place,
      required this.index,
      this.isLongPress = false,
      this.isFeedBack = false})
      : super(key: key);

  final Place place;
  final int index;
  final bool isLongPress;
  final bool isFeedBack;

  @override
  Widget build(BuildContext context) {
    bool isEmpty = (place.placeType == "empty");
    Widget _fixedToggle(String title) {
      return Positioned(
        top: itemHeight / 10 - (isLongPress ? 4 : 0),
        right: itemHeight / 10 - (isLongPress ? 4 : 0),
        child: GestureDetector(
          onTap: () {
            if (context.read<CreateScheduleStore>().tabController.index == 2) {
              context.read<CreateScheduleStore>().tabController.animateTo(1);
            }

            context.read<CreateScheduleStore>().toggleScheduleFixedOrNot(index);
          },
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
            color: isFeedBack ? place.color.withAlpha(200) : place.color,
            borderRadius: defaultBoxRadius,
            boxShadow: defaultBoxShadow,
            border:
                isLongPress ? Border.all(color: Colors.blue, width: 4) : null),
        height: place.toHeight(),
        width: isFeedBack
            ? context.watch<CreateScheduleStore>().timeLineBoxAreaWidth
            : double.infinity,
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Padding(
            padding: isLongPress
                ? const EdgeInsets.fromLTRB(4, 0, 4, 0)
                : const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isEmpty)
                    Text(
                        place.placeType == 'custom'
                            ? place.nameKor
                            : place.placeName ?? place.nameKor,
                        style: mainFont(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: itemHeight / 6,
                          letterSpacing: 1,
                        ),
                        overflow: TextOverflow.ellipsis),
                  Visibility(
                    visible: place.toHeight() > 60,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "${printDateTimeHourAndMinuteOnly(place.startsAt!)} ~ ${printDateTimeHourAndMinuteOnly(place.endsAt!)}",
                            style: mainFont(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: itemHeight / 7,
                                letterSpacing: 1),
                          ),
                          Text(
                            printDurationKor(place.duration),
                            style: mainFont(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: itemHeight / 7,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (!context
              .read<CreateScheduleStore>()
              .scheduleList[index]
              .isFixed) ...[
            Positioned.fill(
              child: Column(
                children: [
                  ScheduleBoxUpDownHandle(
                    isUp: true,
                    index: index,
                  ),
                  Expanded(
                    child: DetectBoxTapAndDrag(index: index, place: place),
                  ),
                  ScheduleBoxUpDownHandle(
                    isUp: false,
                    index: index,
                  ),
                ],
              ),
            ),
          ] else
            Positioned.fill(
              child: DetectBoxTapAndDrag(index: index, place: place),
            ),
          place.isFixed ? _fixedToggle('고정') : _fixedToggle('유동')
        ]));
  }
}

class DetectBoxTapAndDrag extends StatelessWidget {
  const DetectBoxTapAndDrag({
    Key? key,
    required this.index,
    required this.place,
  }) : super(key: key);

  final int index;
  final Place place;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        context.read<CreateScheduleStore>().onConvexHullControllOff();
        context
            .read<CreateScheduleStore>()
            .setIndexOfPlaceDecidingSchedule(index);
        if (context.read<CreateScheduleStore>().tabController.index != 1) {
          context.read<CreateScheduleStore>().tabController.animateTo(1);
          await Future.delayed(Duration(
              milliseconds:
                  (tabResizeAnimationDuration.inMilliseconds / 2).round()));
        }

        if (context.read<CreateScheduleStore>().scheduleList[index].place !=
            null) {
          Place _place =
              context.read<CreateScheduleStore>().scheduleList[index];

          context.read<CreateScheduleStore>().setMarkers(newMarkers: {
            MarkerId(_place.placeId!): await markerForPlace(
              place: _place,
              parentKey: context.read<CreateScheduleStore>().screenKey,
            )
          });

          await context
              .read<CreateScheduleStore>()
              .googleMapController!
              .animateCamera(CameraUpdate.newLatLngZoom(_place.place!, 17));
        } else {
          var temp = context
              .read<CreateScheduleStore>()
              .checkAndGetIndexForPlaceRecommend();
          if (temp.runtimeType == int &&
              context.read<CreateScheduleStore>().markers.isNotEmpty) {
            context.read<CreateScheduleStore>().setMarkers(
              newMarkers: {
                MarkerId(
                    context
                        .read<CreateScheduleStore>()
                        .scheduleList[temp]
                        .placeId!): await markerForPlace(
                    place:
                        context.read<CreateScheduleStore>().scheduleList[temp],
                    parentKey: context.read<CreateScheduleStore>().screenKey,
                    isOtherPlace: true),
                centertargetId: await markerForCenterTarget(
                    placeLatLng: context
                        .read<CreateScheduleStore>()
                        .scheduleList[temp]
                        .place!)
              },
            );
            await context
                .read<CreateScheduleStore>()
                .googleMapController!
                .animateCamera(CameraUpdate.newLatLngZoom(
                    context
                        .read<CreateScheduleStore>()
                        .scheduleList[temp]
                        .place!,
                    17));
          } else {
            context.read<CreateScheduleStore>().clearMarkers();
            context
                .read<CreateScheduleStore>()
                .googleMapController!
                .animateCamera(CameraUpdate.newLatLngZoom(
                    context.read<CreateScheduleStore>().userLocation, 16));
          }
        }
      },
      child: LongPressDraggable(
        feedback: ScheduleBox(
          place: place,
          index: index,
          isFeedBack: true,
        ),
        delay: const Duration(milliseconds: 300),
        data: index,
        onDragEnd: (DraggableDetails details) =>
            context.read<CreateScheduleStore>().onScheduleBoxDragEnd(),
        onDragStarted: () =>
            context.read<CreateScheduleStore>().onScheduleBoxDragStart(index),
        onDraggableCanceled: (velocity, offset) =>
            context.read<CreateScheduleStore>().onScheduleBoxDragEnd(),
        child: Container(
          color: const Color.fromRGBO(0, 0, 0, 0),
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
    final List _scheduleList = context.read<CreateScheduleStore>().scheduleList;
    final int _currentIndex = (widget.targetId / 2).floor();

    bool _isFirst = false;
    bool _isLast = false;

    if (_currentIndex == 0) {
      _isFirst = true;
    } else if (_currentIndex == _scheduleList.length) {
      _isLast = true;
    }

    double _beforeHeight =
        _isFirst ? 0 : _scheduleList[_currentIndex - 1].toHeight();
    double _afterHeight = _isLast ? 0 : _scheduleList[_currentIndex].toHeight();

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
        return Column(
          children: [
            if (!_isFirst)
              Container(
                  height: _beforeHeight / 2 - reorderDragTargetHeight / 2,
                  width: double.infinity,
                  color: const Color.fromARGB(0, 255, 255, 255)),
            Container(
              height: reorderDragTargetHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: defaultBoxRadius,
                color: isHovered
                    ? const Color.fromARGB(232, 129, 197, 253)
                    : const Color.fromARGB(148, 33, 149, 243),
              ),
            ),
            if (!_isLast)
              Container(
                  height: _afterHeight / 2 - reorderDragTargetHeight / 2,
                  width: double.infinity,
                  color: const Color.fromARGB(0, 255, 255, 255)),
          ],
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

// class ScheduleBoxForCreatedSchedule extends StatelessWidget {
//   const ScheduleBoxForCreatedSchedule({
//     Key? key,
//     required this.place,
//   }) : super(key: key);

//   final Place place;

//   // Widget _fixedToggle(String title) {
//   //   return Positioned(
//   //     top: itemHeight / 10,
//   //     right: itemHeight / 10,
//   //     child: Container(
//   //       padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
//   //       alignment: Alignment.center,
//   //       height: durationToHeight(minimumScheduleBoxDuration) / 2,
//   //       decoration: BoxDecoration(
//   //           color: const Color.fromARGB(83, 255, 255, 255),
//   //           borderRadius: BorderRadius.circular(30)),
//   //       child: Text(
//   //         title,
//   //         style: mainFont(
//   //             color: const Color.fromARGB(255, 255, 255, 255),
//   //             fontSize: durationToHeight(minimumScheduleBoxDuration) / 3.5,
//   //             fontWeight: FontWeight.w800),
//   //       ),
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     bool isEmpty = (place.placeType == "empty");

//     return Container(
//         decoration: BoxDecoration(
//             color: place.color,
//             borderRadius: defaultBoxRadius,
//             boxShadow: defaultBoxShadow),
//         height: place.toHeight(),
//         width: double.infinity,
//         clipBehavior: Clip.antiAlias,
//         child: Stack(children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (!isEmpty)
//                     Text(
//                         place.placeType == 'custom'
//                             ? place.nameKor
//                             : place.placeName ?? place.nameKor,
//                         style: mainFont(
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                             fontSize: itemHeight / 6,
//                             letterSpacing: 1),
//                         overflow: TextOverflow.ellipsis),
//                   Visibility(
//                     visible: place.toHeight() > 60,
//                     child: FittedBox(
//                       fit: BoxFit.fitWidth,
//                       child: Column(
//                         children: [
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           Text(
//                             "${place.startsAt?.hour.toString().padLeft(2, "0")}:${place.startsAt?.minute.toString().padLeft(2, "0")} ~ ${place.endsAt?.hour.toString().padLeft(2, "0")}:${place.endsAt?.minute.toString().padLeft(2, "0")}",
//                             style: mainFont(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.white,
//                                 fontSize: itemHeight / 7,
//                                 letterSpacing: 1),
//                           ),
//                           Text(
//                             ((place.duration.inMinutes >= 60)
//                                     ? place.duration.inHours.toString() + "시간 "
//                                     : "") +
//                                 ((place.duration.inMinutes % 60) != 0
//                                     ? (place.duration.inMinutes % 60)
//                                             .toString() +
//                                         "분"
//                                     : ""),
//                             style: mainFont(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.white,
//                                 fontSize: itemHeight / 7,
//                                 letterSpacing: 1),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           // place.isFixed ? _fixedToggle('고정') : _fixedToggle('유동')
//         ]));
//   }
// }

// class RouteBox extends StatelessWidget {
//   const RouteBox({Key? key, required this.route}) : super(key: key);

//   final RouteOrder route;

//   @override
//   Widget build(BuildContext context) {
//     bool _isTransitRoute = route.isTransitRoute();
//     String transitType = route.getType();
//     IconData icon = (_isTransitRoute
//         ? (transitType == 'BUS'
//             ? CupertinoIcons.bus
//             : (transitType == 'SUB'
//                 ? CupertinoIcons.train_style_one
//                 : Icons.directions_rounded))
//         : Icons.directions_walk);
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//           decoration: BoxDecoration(
//               color: const Color.fromARGB(206, 88, 88, 88),
//               borderRadius: defaultBoxRadius,
//               boxShadow: defaultBoxShadow),
//           height: route.toHeight(),
//           width: double.infinity,
//           clipBehavior: Clip.antiAlias,
//           padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
//           child: (route.toHeight() > 10)
//               ? Center(
//                   child: FittedBox(
//                     fit: BoxFit.fitWidth,
//                     child: Row(
//                       children: [
//                         Icon(
//                           icon,
//                           color: Colors.white,
//                         ),
//                         // Text(
//                         //   _isTransitRoute ? "대중교통" : "도보",
//                         //   style: mainFont(
//                         //       fontWeight: FontWeight.w700,
//                         //       color: Colors.white,
//                         //       fontSize: itemHeight / 5,
//                         //       letterSpacing: 1),
//                         // ),
//                       ],
//                     ),
//                   ),
//                 )
//               : const SizedBox.shrink()),
//     );
//   }
// }
