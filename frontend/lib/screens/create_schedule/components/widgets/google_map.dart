import 'dart:typed_data';

import 'package:dayplan_it/screens/create_schedule/components/widgets/place_detail_popup.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/custom_shapes.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';

class MapWithCustomInfoWindow extends StatefulWidget {
  const MapWithCustomInfoWindow(
      {Key? key, required this.onMapCreated, required this.initPosition})
      : super(key: key);
  final Function(GoogleMapController) onMapCreated;
  final Position initPosition;

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
        markers:
            Set<Marker>.of(context.watch<CreateScheduleStore>().markers.values),
        initialCameraPosition: CameraPosition(
            target: LatLng(
                widget.initPosition.latitude, widget.initPosition.longitude),
            zoom: 15));
  }
}

Future<Marker> markerWithCustomInfoWindow(
    BuildContext context,
    MarkerId markerId,
    LatLng placeLatLng,
    String title,
    String? rating,
    int? length,
    {bool isRecommended = false}) async {
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

  Future<Map> _fetchPlaceDetail(
      {required String placeId, bool shouldGetImg = false}) async {
    try {
      final response = await Dio().get(
          '$commonUrl/api/placedetail?place_id=$placeId&should_get_img=$shouldGetImg');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('서버에 문제가 발생했습니다');
      }
    } catch (error) {
      rethrow;
    }
  }

  _onTap() async {
    context
        .read<CreateScheduleStore>()
        .setSelectedPlace(markerId.value, title, placeLatLng);

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: defaultBoxRadius),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.7,
              child: PlaceDetail(
                fetchPlaceDetail: _fetchPlaceDetail,
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: PlaceDetailConfirmButton(
                    marker:
                        context.read<CreateScheduleStore>().markers[markerId]!,
                    markerId: markerId),
              )
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        });
  }

  return Marker(
    markerId: markerId,
    position: placeLatLng,
    icon: BitmapDescriptor.fromBytes(_createdWidgetByte),
    onTap: _onTap,
  );
}
