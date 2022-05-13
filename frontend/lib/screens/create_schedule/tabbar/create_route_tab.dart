import 'dart:io';

import 'package:dayplan_it/components/route_card.dart';
import 'package:dayplan_it/functions/google_map_move_to.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/class/route_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/class/schedule_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/google_map.dart';

class CreateRouteTab extends StatefulWidget {
  const CreateRouteTab({Key? key}) : super(key: key);

  @override
  State<CreateRouteTab> createState() => _CreateRouteTabState();
}

class _CreateRouteTabState extends State<CreateRouteTab>
    with AutomaticKeepAliveClientMixin {
  late GoogleMapController _routeMapController;

  // CameraUpdate moveToPolyLine(String polyLineStr) {
  //   List<LatLng> points = decodePolyline(polyLineStr)
  //       .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
  //       .toList();

  //   LatLng? southWest;
  //   LatLng? northEast;

  //   for (int i = 0; i < points.length; i++) {
  //     if (i == 0) {
  //       southWest = points[i];
  //       northEast = points[i];
  //     } else {
  //       List<double> listLat = [
  //         southWest!.latitude,
  //         northEast!.latitude,
  //         points[i].latitude
  //       ];
  //       List<double> listLng = [
  //         southWest.longitude,
  //         northEast.longitude,
  //         points[i].longitude
  //       ];

  //       listLat.sort();
  //       listLng.sort();

  //       // 안드로이드는 다르게 넣어줘야 함 (Google Map Bug)
  //       southWest = Platform.isAndroid
  //           ? LatLng(listLat[0], listLng[0])
  //           : LatLng(listLat[0], listLng[2]);
  //       northEast = Platform.isAndroid
  //           ? LatLng(listLat[2], listLng[2])
  //           : LatLng(listLat[2], listLng[0]);
  //     }
  //   }

  //   return CameraUpdate.newLatLngBounds(
  //       LatLngBounds(southwest: southWest!, northeast: northEast!), 20);
  // }

  Future _createScheduleAndAddMarkerAndLine() async {
    int routeReCreateFlag =
        context.read<CreateScheduleStore>().checkShouldRouteBeReCreated();

    if (routeReCreateFlag == 0) {
      return;
    } else if (routeReCreateFlag == 2) {
      context.read<CreateScheduleStore>().onFindingRouteStart();
      context.read<CreateScheduleStore>().setSchduleCreated(
          await ScheduleCreated.create(
              scheduleList: context.read<CreateScheduleStore>().scheduleList,
              scheduleDate: context.read<CreateScheduleStore>().scheduleDate));

      Map<MarkerId, Marker> newMarkers = {};
      Map<PolylineId, Polyline> newPolylines = {};

      List _createdScheduleList =
          context.read<CreateScheduleStore>().scheduleCreated.list;
      for (int i = 0; i < _createdScheduleList.length; i++) {
        if (_createdScheduleList[i].runtimeType == RouteOrder) {
          for (RouteStep step in _createdScheduleList[i].steps) {
            newPolylines[PolylineId(step.polyline)] = step.getPolyline();
          }
        } else {
          Marker marker = await markerForCreatedRoute(
              order: (i / 2).round() + 1, place: _createdScheduleList[i]);

          newMarkers[MarkerId(_createdScheduleList[i].placeId!)] = marker;
        }
      }

      context.read<CreateScheduleStore>().onFindingRouteEnd();
      _routeMapController
          .moveCamera(moveToSchedule(scheduleOrder: _createdScheduleList));
      setState(() {
        markers = newMarkers;
        polylines = newPolylines;
      });
    } else {
      _routeMapController.moveCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: context
                  .read<CreateScheduleStore>()
                  .scheduleCreated
                  .list[0]
                  .place,
              zoom: 16)));
    }
  }

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    context.read<CreateScheduleStore>().tabController.addListener(() async {
      if (mounted) {
        if (context.read<CreateScheduleStore>().tabController.index == 2) {
          await _createScheduleAndAddMarkerAndLine();
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: [
      Column(
        children: [
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: defaultBoxRadius,
              child: GoogleMap(
                  onMapCreated: (controller) => setState(() {
                        _routeMapController = controller;
                      }),
                  mapToolbarEnabled: false,
                  myLocationEnabled: true,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  myLocationButtonEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  markers: Set<Marker>.of(markers.values),
                  polylines: Set<Polyline>.of(polylines.values),
                  initialCameraPosition: CameraPosition(
                      target: context.read<CreateScheduleStore>().userLocation,
                      zoom: 15)),
            ),
          ),
          if (context.watch<CreateScheduleStore>().isScheduleCreated)
            Expanded(
                flex: 3,
                child: ScheduleOrderCardListView(
                  scheduleOrderList:
                      context.read<CreateScheduleStore>().scheduleCreated.list,
                  routeMapController: _routeMapController,
                ))
        ],
      ),
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
                child: FittedBox(
                  fit: BoxFit.fitWidth,
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
                  ),
                )))
      else if (context.watch<CreateScheduleStore>().isFindingRoute)
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
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 5,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "경로를 탐색중입니다",
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
