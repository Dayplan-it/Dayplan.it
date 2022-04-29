import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/custom_shapes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
            onTap: (position) {
              widget.customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              widget.customInfoWindowController.onCameraMove!();
            },
            myLocationEnabled: true,
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
          height: 100,
          width: 150,
          offset: 20,
        ),
      ],
    );
  }
}

Marker markerWithCustomInfoWindow(
    MarkerId markerId,
    LatLng placeLatLng,
    ModifiedCustomInfoWindowController customInfoWindowController,
    String title) {
  return Marker(
    markerId: markerId,
    position: placeLatLng,
    onTap: () {
      customInfoWindowController.addInfoWindow!(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flex(
                  mainAxisAlignment: MainAxisAlignment.center,
                  direction: Axis.horizontal,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: defaultBoxRadius,
                          boxShadow: defaultBoxShadow,
                          color: primaryColor),
                      child: Row(
                        children: [
                          Text(
                            title,
                            style: mainFont(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
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
          placeLatLng);
    },
  );
}
