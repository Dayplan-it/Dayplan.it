import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

import 'package:dayplan_it/class/schedule_class.dart';
import 'package:dayplan_it/class/route_class.dart';

Map<String, LatLng> _findBoundary(List<LatLng> points) {
  LatLng? southWest;
  LatLng? northEast;

  for (int i = 0; i < points.length; i++) {
    if (i == 0) {
      southWest = points[i];
      northEast = points[i];
    } else {
      List<double> listLat = [
        southWest!.latitude,
        northEast!.latitude,
        points[i].latitude
      ];
      List<double> listLng = [
        southWest.longitude,
        northEast.longitude,
        points[i].longitude
      ];

      listLat.sort();
      listLng.sort();

      // 안드로이드는 다르게 넣어줘야 함 (Google Map Bug)
      southWest = LatLng(listLat[0], listLng[0]);

      northEast = LatLng(listLat[2], listLng[2]);
    }
  }

  return {'southWest': southWest!, 'northEast': northEast!};
}

CameraUpdate moveToPolyLine({required String polyLineStr}) {
  List<LatLng> points = decodePolyline(polyLineStr)
      .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
      .toList();

  Map<String, LatLng> boundary = _findBoundary(points);

  return CameraUpdate.newLatLngBounds(
      LatLngBounds(
          southwest: boundary['southWest']!, northeast: boundary['northEast']!),
      50);
}

CameraUpdate moveToSchedule({required List scheduleOrder}) {
  List<LatLng> points = [];

  for (var order in scheduleOrder) {
    if (order.runtimeType == Place) {
      points.add((order as Place).place!);
    } else {
      decodePolyline((order as RouteOrder).polyline)
          .map((e) => points.add(LatLng(e[0].toDouble(), e[1].toDouble())));
    }
  }

  Map<String, LatLng> boundary = _findBoundary(points);

  return CameraUpdate.newLatLngBounds(
      LatLngBounds(
          southwest: boundary['southWest']!, northeast: boundary['northEast']!),
      50);
}
