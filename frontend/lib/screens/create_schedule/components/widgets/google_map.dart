import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/class/schedule_class.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/place_detail_popup.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/custom_shapes.dart';

class MapWithCustomInfoWindow extends StatefulWidget {
  const MapWithCustomInfoWindow(
      {Key? key, required this.onMapCreated, required this.initPosition})
      : super(key: key);
  final Function(GoogleMapController) onMapCreated;
  final LatLng initPosition;

  @override
  State<MapWithCustomInfoWindow> createState() =>
      _MapWithCustomInfoWindowState();
}

class _MapWithCustomInfoWindowState extends State<MapWithCustomInfoWindow> {
  @override
  Widget build(BuildContext context) {
    print('build');
    return GoogleMap(
        onMapCreated: widget.onMapCreated,
        onTap: (position) async {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
          }
        },
        onLongPress: (position) async {},
        myLocationEnabled: true,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        mapToolbarEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        markers:
            Set<Marker>.of(context.watch<CreateScheduleStore>().markers.values),
        initialCameraPosition:
            CameraPosition(target: widget.initPosition, zoom: 15));
  }
}

Future<Uint8List> _widgetToUint8List(Widget widget) async {
  ScreenshotController screenshotController = ScreenshotController();

  return await screenshotController.captureFromWidget(widget,
      delay: const Duration(seconds: 0), pixelRatio: 1);
}

Future<Marker> markerWithCustomInfoWindow(
    GlobalKey parentKey,
    MarkerId markerId,
    LatLng placeLatLng,
    String title,
    String? rating,
    int? length,
    {bool isRecommended = false,
    required bool isForDecidingPlace}) async {
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
                            length < 1000
                                ? length.toString() + "m"
                                : (length.toDouble() / 1000)
                                        .toStringAsFixed(1) +
                                    "km",
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

  _onTap() {
    return showDialog(
        context: parentKey.currentContext!,
        builder: (context) {
          context.read<CreateScheduleStore>().selectedPlaceId = markerId.value;
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: defaultBoxRadius),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.7,
              child: PlaceDetail(
                context,
                markerId,
                placeLatLng,
                title,
                rating,
                length,
                isForDecidingPlace: isForDecidingPlace,
              ),
            ),
          );
        });
  }

  return Marker(
    markerId: markerId,
    position: placeLatLng,
    icon: BitmapDescriptor.fromBytes(await _widgetToUint8List(_widget())),
    onTap: _onTap,
  );
}

/// 센터타겟 마커 생성
Future<Marker> markerForCenterTarget({
  required LatLng placeLatLng,
}) async {
  Widget _widget() {
    return const Icon(
      Icons.location_searching_rounded,
      size: 30,
      color: primaryColor,
    );
  }

  return Marker(
    anchor: const Offset(0.5, 0.5),
    markerId: centertargetId,
    position: placeLatLng,
    icon: BitmapDescriptor.fromBytes(await _widgetToUint8List(_widget())),
  );
}

/// 장소가 결정된 일정 위젯 생성
Future<Marker> markerForPlace(
    {required Place place,
    required GlobalKey parentKey,
    bool isOtherPlace = false}) async {
  MarkerId markerId = MarkerId(place.placeId!);
  Widget _widget() {
    if (!isOtherPlace) {
      Color placeColor = placeColorByPlaceType(place.placeType);
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: defaultBoxRadius,
                        boxShadow: defaultBoxShadow,
                        color: placeColor),
                    child: Column(
                      children: [
                        Text(
                          place.placeName!,
                          style: mainFont(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "${printDateTimeHourAndMinuteOnly(place.startsAt!)} ~ ${printDateTimeHourAndMinuteOnly(place.endsAt!)}",
                          style: mainFont(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 1),
                        ),
                        Text(
                          printDurationKor(place.duration),
                          style: mainFont(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ]),
            CustomPaint(
              size: const Size(20, 15),
              painter: DrawTriangleShape(fillColor: placeColor),
            )
          ],
        ),
      );
    } else {
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: defaultBoxRadius,
                        boxShadow: defaultBoxShadow,
                        border: Border.all(color: primaryColor, width: 2),
                        color: Colors.white),
                    child: Column(
                      children: [
                        Text(
                          "다른 일정",
                          style: mainFont(
                              color: pointColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          place.placeName!,
                          style: mainFont(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "${printDateTimeHourAndMinuteOnly(place.startsAt!)} ~ ${printDateTimeHourAndMinuteOnly(place.endsAt!)}",
                          style: mainFont(
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                              fontSize: 12,
                              letterSpacing: 1),
                        ),
                        Text(
                          printDurationKor(place.duration),
                          style: mainFont(
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                              fontSize: 12,
                              letterSpacing: 1),
                        ),
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
  }

  _onTap() {
    return showDialog(
        context: parentKey.currentContext!,
        builder: (context) {
          context.read<CreateScheduleStore>().selectedPlaceId = markerId.value;
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: defaultBoxRadius),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.7,
              child: PlaceDetail(
                context,
                markerId,
                place.place!,
                place.placeName!,
                null,
                null,
                isForDecidingPlace: false,
              ),
            ),
          );
        });
  }

  return Marker(
    markerId: markerId,
    position: place.place!,
    icon: BitmapDescriptor.fromBytes(await _widgetToUint8List(_widget())),
    onTap: _onTap,
  );
}

/// 순서 번호 마커 생성
Future<Marker> markerForCreatedRoute({
  required int order,
  required Place place,
}) async {
  Widget _widget() {
    Color placeColor = placeColorByPlaceType(place.placeType);
    return Container(
      alignment: Alignment.center,
      //padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: defaultBoxRadius,
          boxShadow: defaultBoxShadow,
          border: Border.all(color: placeColor, width: 7),
          color: Colors.white),
      width: 35,
      height: 35,
      child: FittedBox(
        child: Text(
          order.toString(),
          style: mainFont(color: placeColor, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  return Marker(
    anchor: const Offset(0.5, 0.5),
    markerId: MarkerId(place.placeId!),
    position: place.place!,
    icon: BitmapDescriptor.fromBytes(await _widgetToUint8List(_widget())),
  );
}
