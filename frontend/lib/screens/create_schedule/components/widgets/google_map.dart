import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/custom_shapes.dart';
import 'package:screenshot/screenshot.dart';

class MapWithCustomInfoWindow extends StatefulWidget {
  const MapWithCustomInfoWindow(
      {Key? key,
      required this.onMapCreated,
      required this.initPosition,
      required this.markers})
      : super(key: key);
  final Function(GoogleMapController) onMapCreated;
  final Position initPosition;
  final Map<MarkerId, Marker> markers;

  @override
  State<MapWithCustomInfoWindow> createState() =>
      _MapWithCustomInfoWindowState();
}

class _MapWithCustomInfoWindowState extends State<MapWithCustomInfoWindow> {
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        onMapCreated: widget.onMapCreated,
        onTap: (position) async {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
          }
        },
        myLocationEnabled: true,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        markers: Set<Marker>.of(widget.markers.values),
        initialCameraPosition: CameraPosition(
            target: LatLng(
                widget.initPosition.latitude, widget.initPosition.longitude),
            zoom: 15));
  }
}

Future<Marker> markerWithCustomInfoWindow(
    BuildContext context,
    GoogleMapController googleMapController,
    MarkerId markerId,
    LatLng placeLatLng,
    String title,
    String? rating,
    int? length,
    VoidCallback onTap) async {
  Widget _widget() {
    return FittedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flex(
              crossAxisAlignment: CrossAxisAlignment.center,
              direction: Axis.horizontal,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
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
                      if (length != null) ...[
                        const SizedBox(
                          width: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(double.infinity),
                              color: Colors.white),
                          child: Text(
                            length.toString() + "m",
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
            size: const Size(20, 15),
            painter: DrawTriangleShape(),
          )
        ],
      ),
    );
  }

  ScreenshotController screenshotController = ScreenshotController();

  Uint8List _createdWidgetByte = await screenshotController
      .captureFromWidget(_widget(), delay: const Duration(seconds: 0));

  return Marker(
    markerId: markerId,
    position: placeLatLng,
    icon: BitmapDescriptor.fromBytes(_createdWidgetByte),
    onTap: onTap,
  );
}
