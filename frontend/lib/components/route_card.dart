import 'package:dayplan_it/class/route_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/class/schedule_class.dart';
import 'package:dayplan_it/functions/google_map_move_to.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class ScheduleOrderCardListView extends StatefulWidget {
  const ScheduleOrderCardListView(
      {Key? key,
      required this.scheduleOrderList,
      required this.routeMapController})
      : super(key: key);

  final List scheduleOrderList;
  final GoogleMapController routeMapController;

  @override
  State<ScheduleOrderCardListView> createState() =>
      _ScheduleOrderCardListViewState();
}

class _ScheduleOrderCardListViewState extends State<ScheduleOrderCardListView> {
  late List<bool> clickedRouteState;

  void resetRouteState() {
    setState(() {
      clickedRouteState = [
        for (int i = 0; i < (widget.scheduleOrderList.length / 2).floor(); i++)
          false,
      ];
    });
  }

  @override
  void initState() {
    resetRouteState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        itemCount: widget.scheduleOrderList.length,
        itemBuilder: (context, index) {
          Widget orderCard(IconData iconData, Color mainColor, String? title,
              String instructions, String durationStr,
              {bool isRoute = false, List<RouteStep>? steps}) {
            return InkWell(
              onTap: () async {
                if (isRoute) {
                  if (!clickedRouteState[(index / 2).floor()]) {
                    resetRouteState();
                    setState(() {
                      clickedRouteState[(index / 2).floor()] = true;
                    });
                  } else {
                    resetRouteState();
                  }
                  await widget.routeMapController.animateCamera(moveToPolyLine(
                      polyLineStr: widget.scheduleOrderList[index].polyline));
                } else {
                  resetRouteState();
                  await widget.routeMapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                          widget.scheduleOrderList[index].place, 16));
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    decoration: BoxDecoration(
                        boxShadow: defaultBoxShadow,
                        borderRadius: defaultBoxRadius,
                        color: isRoute
                            ? const Color.fromARGB(255, 186, 186, 186)
                            : Colors.white),
                    height: isRoute
                        ? (clickedRouteState[(index / 2).floor()]
                            ? steps!.length * 42 +
                                40 +
                                (steps.isNotEmpty ? 10 : 0)
                            : 40)
                        : 70,
                    child: isRoute
                        ? SizedBox(
                            height: clickedRouteState[(index / 2).floor()]
                                ? steps!.length * 42 +
                                    40 +
                                    (steps.isNotEmpty ? 10 : 0)
                                : 40,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Icon(
                                        iconData,
                                        color: mainColor,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              instructions,
                                              style: mainFont(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                              textAlign: TextAlign.start,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        durationStr,
                                        style: mainFont(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15),
                                      )
                                    ],
                                  ),
                                ),
                                if (clickedRouteState[(index / 2).floor()])
                                  SizedBox(
                                    height: steps!.length * 42 +
                                        (steps.isNotEmpty ? 10 : 0),
                                    child: Column(
                                      children: [
                                        for (RouteStep step
                                            in (widget.scheduleOrderList[index]
                                                    as RouteOrder)
                                                .steps)
                                          Expanded(
                                              child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: InkWell(
                                              onTap: () {
                                                widget.routeMapController
                                                    .animateCamera(
                                                        moveToPolyLine(
                                                            polyLineStr:
                                                                step.polyline));
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 2),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          defaultBoxRadius,
                                                      boxShadow:
                                                          defaultBoxShadow),
                                                  width: double.infinity,
                                                  height: 40,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 0, 10, 0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            step.instruction,
                                                            style: mainFont(
                                                              color: (step
                                                                      is TransitStep)
                                                                  ? step.color
                                                                  : const Color
                                                                          .fromARGB(
                                                                      255,
                                                                      141,
                                                                      141,
                                                                      141),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          (step.runtimeType ==
                                                                  TransitStep
                                                              ? ((step as TransitStep)
                                                                          .transitType ==
                                                                      'BUS'
                                                                  ? CupertinoIcons
                                                                      .bus
                                                                  : CupertinoIcons
                                                                      .train_style_one)
                                                              : Icons
                                                                  .directions_walk),
                                                          color: (step
                                                                  is TransitStep)
                                                              ? step.color
                                                              : const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  141,
                                                                  141,
                                                                  141),
                                                          size: 18,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )),
                                        const SizedBox(
                                          height: 10,
                                        )
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              Icon(
                                iconData,
                                color: mainColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title!,
                                      style: mainFont(
                                          color: mainColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      instructions,
                                      style: mainFont(
                                          color: subTextColor, fontSize: 14),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                durationStr,
                                style: mainFont(
                                    color: mainColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15),
                              )
                            ],
                          )),
              ),
            );
          }

          List _placeColorAndIconDataByPlaceType(String placeTypeName) {
            if (placeTypeName == 'custom') {
              return [pointColor, Icons.edit];
            }
            for (List placeType in placeTypes) {
              if (placeType[0] == placeTypeName) {
                return [placeType[2], placeType[3]];
              }
            }

            throw 'No Theme Color Found';
          }

          if (widget.scheduleOrderList[index] is Place) {
            List colorAndIconData = _placeColorAndIconDataByPlaceType(
                widget.scheduleOrderList[index].placeType);
            Map<String, String> instruction =
                widget.scheduleOrderList[index].getInstruction();

            return orderCard(
                colorAndIconData[1],
                colorAndIconData[0],
                widget.scheduleOrderList[index].placeName,
                "${instruction["startsAt"]}부터 ${instruction["endsAt"]}까지",
                instruction["duration"]!);
          } else {
            bool _isTransitRoute =
                widget.scheduleOrderList[index].isTransitRoute();
            String transitType = widget.scheduleOrderList[index].getType();
            IconData icon = (_isTransitRoute
                ? (transitType == 'BUS'
                    ? CupertinoIcons.bus
                    : (transitType == 'SUB'
                        ? CupertinoIcons.train_style_one
                        : Icons.directions_rounded))
                : Icons.directions_walk);
            Map<String, String> instruction =
                widget.scheduleOrderList[index].getInstruction();

            return orderCard(icon, Colors.white, null,
                instruction["instruction"]!, instruction["duration"]!,
                isRoute: true,
                steps: (widget.scheduleOrderList[index] as RouteOrder).steps);
          }
        });
  }
}
