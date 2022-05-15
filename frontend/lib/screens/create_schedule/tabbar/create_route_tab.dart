import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/class/schedule_class.dart';
import 'package:dayplan_it/class/route_class.dart';
import 'package:dayplan_it/components/route_card.dart';
import 'package:dayplan_it/functions/google_map_move_to.dart';
import 'package:dayplan_it/screens/create_schedule/exceptions/exceptions.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/tab_alert.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/google_map.dart';

class CreateRouteTab extends StatefulWidget {
  const CreateRouteTab({Key? key}) : super(key: key);

  @override
  State<CreateRouteTab> createState() => _CreateRouteTabState();
}

class _CreateRouteTabState extends State<CreateRouteTab>
    with AutomaticKeepAliveClientMixin {
  late GoogleMapController _routeMapController;

  Future _createScheduleAndAddMarkerAndLine() async {
    int routeReCreateFlag =
        context.read<CreateScheduleStore>().checkShouldRouteBeReCreated();

    if (routeReCreateFlag == 0) {
      return;
    } else if (routeReCreateFlag == 2) {
      context.read<CreateScheduleStore>().onFindingRouteStart();

      ScheduleCreated _tempScheduleCreated;
      try {
        _tempScheduleCreated = await ScheduleCreated.create(
            scheduleList: context.read<CreateScheduleStore>().scheduleList,
            scheduleDate: context.read<CreateScheduleStore>().scheduleDate);
        context
            .read<CreateScheduleStore>()
            .setSchduleCreated(_tempScheduleCreated);
      } on TravelTimeException catch (e) {
        context.read<CreateScheduleStore>().onFindingRouteEnd(
            isTravelTimeExceedsSchedule: true,
            indexOfTravelTimeExceededSchedule: e.scheduleIndex);
        return;
      }

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
              zoom: 17)));
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
  void dispose() {
    _routeMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: [
      Column(
        children: [
          Expanded(
            flex: 3,
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
          if (context.watch<CreateScheduleStore>().isScheduleCreated) ...[
            Expanded(
                flex: 4,
                child: ScheduleOrderCardListView(
                  scheduleOrderList:
                      context.read<CreateScheduleStore>().scheduleCreated.list,
                  routeMapController: _routeMapController,
                ))
          ] else ...[
            const Expanded(flex: 4, child: SizedBox.shrink())
          ]
        ],
      ),
      if (context.watch<CreateScheduleStore>().scheduleList.isEmpty)
        const GreyTabAlert(
          title1: "경로를 생성할",
          title2: "일정이 없습니다",
          icon: FontAwesomeIcons.calendarXmark,
          isFaIcon: true,
        )
      else if (!context.watch<CreateScheduleStore>().isRouteCreateAble())
        const GreyTabAlert(
          title1: "장소가 선택되지 않은",
          title2: "일정이 있습니다",
          icon: Icons.wrong_location_rounded,
        )
      else if (context.watch<CreateScheduleStore>().isTravelTimeExceedsSchedule)
        GreyTabAlert(
          title1:
              "${context.read<CreateScheduleStore>().indexOfTravelTimeExceededSchedule + 1}번째 스케줄이 이동시간보다 짧습니다",
          title2: "장소를 바꾸거나 시간을 조정해주세요",
          icon: Icons.wrong_location_rounded,
        )
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
