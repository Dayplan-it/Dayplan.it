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
      delay: const Duration(seconds: 0));
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
    infoWindow: InfoWindow(
        onTap: _onTap,
        title: title,
        snippet:
            "${rating != null ? "$rating점 " : ""}${length != null ? length < 1000 ? length.toString() + "m" : (length.toDouble() / 1000).toStringAsFixed(1) + "km" : ""}"),
  );
}

/// 센터타겟 마커 생성
Future<Marker> markerForCenterTarget({
  required LatLng placeLatLng,
}) async {
  Widget _widget() {
    return const Icon(
      Icons.location_searching_rounded,
      size: 10,
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
    infoWindow: InfoWindow(
        title: (isOtherPlace ? "(다른 일정) " : "") + place.placeName!,
        snippet:
            "${printDateTimeHourAndMinuteOnly(place.startsAt!)} ~ ${printDateTimeHourAndMinuteOnly(place.endsAt!)}",
        onTap: _onTap),
  );
}

/// 순서 번호 마커 생성
Future<Marker> markerForCreatedRoute({
  required int order,
  required Place place,
}) async {
  return Marker(
      anchor: const Offset(0.5, 0.5),
      markerId: MarkerId(place.placeId!),
      position: place.place!,
      infoWindow:
          InfoWindow(title: order.toString() + ". " + place.placeName!));
}
