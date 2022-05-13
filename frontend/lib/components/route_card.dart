import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/functions/google_map_move_to.dart';
import 'package:dayplan_it/screens/create_schedule/components/class/schedule_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class ScheduleOrderCardListView extends StatelessWidget {
  const ScheduleOrderCardListView(
      {Key? key,
      required this.scheduleOrderList,
      required this.routeMapController})
      : super(key: key);

  final List scheduleOrderList;
  final GoogleMapController routeMapController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        itemCount: scheduleOrderList.length,
        itemBuilder: (context, index) {
          Widget orderCard(IconData iconData, Color mainColor, String? title,
              String instructions,
              {bool isRoute = false}) {
            bool isRouteClicked = false;
            return InkWell(
              onTap: () async {
                if (isRoute) {
                  await routeMapController.animateCamera(moveToPolyLine(
                      polyLineStr: scheduleOrderList[index].polyline));
                  isRouteClicked = true;
                } else {
                  await routeMapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                          scheduleOrderList[index].place, 16));
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    decoration: BoxDecoration(
                        boxShadow: defaultBoxShadow,
                        borderRadius: defaultBoxRadius,
                        color: isRoute
                            ? const Color.fromARGB(255, 137, 137, 137)
                            : Colors.white),
                    height: isRoute ? 40 : 70,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isRoute)
                                Text(
                                  title!,
                                  style: mainFont(
                                      color: mainColor,
                                      fontWeight: FontWeight.w700),
                                ),
                              Text(
                                instructions,
                                style: mainFont(
                                    color:
                                        isRoute ? Colors.white : subTextColor,
                                    fontSize: isRoute ? null : 11),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
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

          if (scheduleOrderList[index].runtimeType == Place) {
            List colorAndIconData = _placeColorAndIconDataByPlaceType(
                scheduleOrderList[index].placeType);
            return orderCard(
                colorAndIconData[1],
                colorAndIconData[0],
                scheduleOrderList[index].placeName,
                scheduleOrderList[index].getInstruction());
          } else {
            bool _isTransitRoute = scheduleOrderList[index].isTransitRoute();
            String transitType = scheduleOrderList[index].getType();
            IconData icon = (_isTransitRoute
                ? (transitType == 'BUS'
                    ? CupertinoIcons.bus
                    : (transitType == 'SUB'
                        ? CupertinoIcons.train_style_one
                        : Icons.directions_rounded))
                : Icons.directions_walk);
            return orderCard(icon, Colors.white, null,
                scheduleOrderList[index].getInstruction(),
                isRoute: true);
          }
        });
  }
}
