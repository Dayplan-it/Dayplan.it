import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/buttons.dart';
import 'package:dayplan_it/screens/create_schedule/components/class/route_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/class/schedule_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class CreateRouteTab extends StatefulWidget {
  const CreateRouteTab({Key? key}) : super(key: key);

  @override
  State<CreateRouteTab> createState() => _CreateRouteTabState();
}

class _CreateRouteTabState extends State<CreateRouteTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: [
      MapForRouteFind(),
      if (context.watch<CreateScheduleStore>().scheduleList.isEmpty)
        Positioned.fill(
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                    borderRadius: defaultBoxRadius,
                    color: const Color.fromARGB(212, 39, 39, 39)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "경로를 생성할",
                      style: mainFont(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "일정이 없습니다",
                      style: mainFont(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )))
      else if (!context.watch<CreateScheduleStore>().isRouteCreateAble())
        Positioned.fill(
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                    borderRadius: defaultBoxRadius,
                    color: const Color.fromARGB(212, 39, 39, 39)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "장소가 선택되지 않은",
                      style: mainFont(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "일정이 있습니다",
                      style: mainFont(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )))
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}

class MapForRouteFind extends StatefulWidget {
  const MapForRouteFind({
    Key? key,
  }) : super(key: key);

  @override
  State<MapForRouteFind> createState() => _MapForRouteFindState();
}

class _MapForRouteFindState extends State<MapForRouteFind> {
  Future _createSchedule() async {
    if (context.read<CreateScheduleStore>().isRouteCreateAble()) {
      context.read<CreateScheduleStore>().setSchduleCreated(
          await ScheduleCreated.create(
              scheduleList: context.read<CreateScheduleStore>().scheduleList,
              scheduleDate: context.read<CreateScheduleStore>().scheduleDate));

      for (var order
          in context.read<CreateScheduleStore>().scheduleCreated.list) {
        if (order.runtimeType == RouteOrder) {
          _addPolyLine(
              decodePolyline(order.polyline)
                  .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
                  .toList(),
              order.polyline,
              Colors.blue,
              8);
        } else {
          _addMarker(
            order.place,
            order.placeId,
          );
        }
      }
    }
  }

  _addPolyLine(List<LatLng> polylineCoordinates, String lineId, Color color,
      int lineWidth) {
    PolylineId id = PolylineId(lineId);
    Polyline polyline = Polyline(
      polylineId: id,
      color: color,
      points: polylineCoordinates,
      width: lineWidth,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }

  _addMarker(LatLng position, String markerId) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(markerId: id, position: position);

    setState(() {
      markers[id] = marker;
    });
  }

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (context.watch<CreateScheduleStore>().isScheduleCreated) ...[
          const Expanded(flex: 1, child: SizedBox.shrink()),
          Expanded(
              flex: 15,
              child: ClipRRect(
                borderRadius: defaultBoxRadius,
                child: Stack(
                  children: [
                    GoogleMap(
                        onTap: (position) async {
                          // if (FocusScope.of(context).hasFocus) {
                          //   FocusScope.of(context).unfocus();
                          //   // InfoWindow의 위치를 변경해야 하는데,
                          //   // 키보드 높이의 변경된 값을 얻으려면 약간의 딜레이가 필요함
                          //   // 추후 퍼포먼스 보고 값을 바꿀 수 있음
                          //   await Future.delayed(const Duration(milliseconds: 1000));
                          //   widget.customInfoWindowController.updateInfoWindow!();
                          // }
                          // else {
                          //   // widget.customInfoWindowController.hideAllInfoWindow!();

                          //   context.read<CreateScheduleStore>().onLookingPlaceDetailEnd();
                          //   await Future.delayed(const Duration(milliseconds: 1000));
                          //   widget.customInfoWindowController.updateInfoWindow!();
                          // }
                        },
                        onCameraMove: (position) {},
                        myLocationEnabled: true,
                        // myLocationButtonEnabled:
                        //     context.watch<CreateScheduleStore>().isLookingPlaceDetail
                        //         ? false
                        //         : true,
                        gestureRecognizers: <
                            Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        },
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        markers: Set<Marker>.of(markers.values),
                        polylines: Set<Polyline>.of(polylines.values),
                        initialCameraPosition: CameraPosition(
                            target: context
                                .read<CreateScheduleStore>()
                                .scheduleCreated
                                .list[0]
                                .place,
                            zoom: 15)),
                    // ModifiedCustomInfoWindow(
                    //   controller: widget.customInfoWindowController,
                    //   offset: 40,
                    // ),
                  ],
                ),
              )),
        ],
        Expanded(
          flex: 3,
          child: Center(
            child: SquareButtonWithLoading(
                title: context.watch<CreateScheduleStore>().isScheduleCreated
                    ? "경로 다시 생성하기"
                    : "경로 생성하기",
                futureFunction: _createSchedule,
                activate:
                    context.watch<CreateScheduleStore>().isRouteCreateAble()),
          ),
        ),
      ],
    );
  }
}
