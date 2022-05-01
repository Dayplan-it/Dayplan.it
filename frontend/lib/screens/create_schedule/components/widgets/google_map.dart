import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/custom_shapes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/screens/create_schedule/components/widgets/modified_custom_info_window.dart';

class MapWithCustomInfoWindow extends StatefulWidget {
  const MapWithCustomInfoWindow(
      {Key? key,
      required this.onMapCreated,
      required this.initPosition,
      required this.customInfoWindowController,
      required this.markers})
      : super(key: key);
  final Function(GoogleMapController) onMapCreated;
  final Position initPosition;
  final Map<MarkerId, Marker> markers;
  final ModifiedCustomInfoWindowController customInfoWindowController;

  @override
  State<MapWithCustomInfoWindow> createState() =>
      _MapWithCustomInfoWindowState();
}

class _MapWithCustomInfoWindowState extends State<MapWithCustomInfoWindow> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
            onMapCreated: widget.onMapCreated,
            onTap: (position) async {
              if (FocusScope.of(context).hasFocus) {
                FocusScope.of(context).unfocus();
                // InfoWindow의 위치를 변경해야 하는데,
                // 키보드 높이의 변경된 값을 얻으려면 약간의 딜레이가 필요함
                // 추후 퍼포먼스 보고 값을 바꿀 수 있음
                await Future.delayed(Duration(milliseconds: 1000));
                widget.customInfoWindowController.updateInfoWindow!();
              } else {
                // widget.customInfoWindowController.hideAllInfoWindow!();

                context.read<CreateScheduleStore>().onLookingPlaceDetailEnd();
                await Future.delayed(Duration(milliseconds: 1000));
                widget.customInfoWindowController.updateInfoWindow!();
              }
            },
            onCameraMove: (position) {
              widget.customInfoWindowController.onCameraMove!();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled:
                context.watch<CreateScheduleStore>().isLookingPlaceDetail
                    ? false
                    : true,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            markers: Set<Marker>.of(widget.markers.values),
            initialCameraPosition: CameraPosition(
                target: LatLng(widget.initPosition.latitude,
                    widget.initPosition.longitude),
                zoom: 15)),
        ModifiedCustomInfoWindow(
          controller: widget.customInfoWindowController,
          offset: 40,
        ),
      ],
    );
  }
}

Marker markerWithCustomInfoWindow(
    MarkerId markerId,
    LatLng placeLatLng,
    ModifiedCustomInfoWindowController customInfoWindowController,
    String title,
    String? rating,
    int? minute,
    VoidCallback onTap) {
  customInfoWindowController.addInfoWindow!(
    InkWell(
      onTap: onTap,
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flex(
                crossAxisAlignment: CrossAxisAlignment.center,
                direction: Axis.horizontal,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: defaultBoxRadius,
                        boxShadow: defaultBoxShadow,
                        border: Border.all(color: primaryColor, width: 2),
                        color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: mainFont(
                              color: primaryColor, fontWeight: FontWeight.w700),
                        ),
                        if (minute != null) ...[
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(double.infinity),
                                color: Colors.white),
                            child: Text(
                              minute == 25 ? "20분 이상" : minute.toString() + "분",
                              style: mainFont(
                                  color: subTextColor,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                        if (rating != null) ...[
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(double.infinity),
                                color: Colors.white),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: pointColor,
                                  size: 12,
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  rating.toString(),
                                  style: mainFont(
                                      color: pointColor,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ]),
            CustomPaint(
              size: const Size(20, 10),
              painter: DrawTriangleShape(),
            )
          ],
        ),
      ),
    ),
    placeLatLng,
    markerId,
  );
  return Marker(
    markerId: markerId,
    position: placeLatLng,
    onTap: () {
      customInfoWindowController.googleMapController!
          .animateCamera(CameraUpdate.newLatLng(placeLatLng));
      customInfoWindowController.showInfoWindow!(markerId);
      customInfoWindowController.updateInfoWindow!();
    },
  );
}
