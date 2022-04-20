import 'dart:convert';
import 'package:dayplan_it/constants.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class HomeRepository {
  Future<Map<String, List<dynamic>>> getScheduleDetail(id, date) async {
    //datetime to timestamp

    DateTime date2 = DateTime(date.year, date.month, date.day);

    final List<String> comments = [];
    final List<String> icons = [];
    final List<String> strat_time = [];
    final List<String> end_time = [];
    final List<dynamic> geom = [];
    final List<dynamic> detail = [];
    final List<String> type = [];
    final timestamp1 = date2.millisecondsSinceEpoch;
    var dio = Dio();
    var url =
        '${homedir}/schedules/find?user_id=${id}&date=${(timestamp1 / 1000).toInt()}';
    Response response = await dio.get(url);
    var res = response.data;

    for (int i = 0; i < res["order"].length; i++) {
      if (res["order"][i]["type"] == "PL") {
        comments.add(
            "${res["order"][i]["detail"]["place_name"]} - ${res["order"][i]["detail"]["duration"]} 소요");
        icons.add("loc");
        strat_time.add("${res["order"][i]["detail"]["starts_at"]}");
        end_time.add("${res["order"][i]["detail"]["ends_at"]}");
        geom.add([
          res["order"][i]["detail"]["point"]["latitude"],
          res["order"][i]["detail"]["point"]["longitude"]
        ]);
        detail.add(res["order"][i]["detail"]["place_id"]);
        type.add("PL");
      } else {
        comments.add(
            "${res["order"][i]["detail"]["distance"]} km 이동 ${res["order"][i]["detail"]["duration"]} 소요");
        icons.add("transit");
        strat_time.add("${res["order"][i]["detail"]["starts_at"]}");
        end_time.add("${res["order"][i]["detail"]["ends_at"]}");
        geom.add(res["order"][i]["detail"]["polyline"]);
        detail.add(res["order"][i]["step"]);
        type.add("RO");
      }
    }
    Map<String, List<dynamic>> result = {};
    result['comments'] = comments;
    result['icons'] = icons;
    result['start_time'] = strat_time;
    result['end_time'] = end_time;
    result['type'] = type;
    result['geom'] = geom;
    result['detail'] = detail;

    return result;
  }

  //<Map<String, List<dynamic>>>를 받아옴
  //Map<MarkerId, Marker>와
  //Map<PolylineId, Polyline>를 반환
  Map<dynamic, dynamic> setRouteData(mapdata) {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    Map<MarkerId, Marker> markers = {};
    Map<PolylineId, Polyline> polylines = {};

    for (int i = 0; i < mapdata["comments"].length; i++) {
      if (mapdata["type"][i] == "PL") {
        MarkerId markerId = MarkerId(mapdata["detail"][i]);
        double lat = mapdata["geom"][i][0];
        double lng = mapdata["geom"][i][1];
        LatLng position = LatLng(lat, lng);

        BitmapDescriptor descriptor = BitmapDescriptor.defaultMarkerWithHue(90);
        Marker marker =
            Marker(markerId: markerId, icon: descriptor, position: position);
        markers[markerId] = marker;
      } else {
        //print(mapdata["type"][i]);
        List<PointLatLng> geom =
            polylinePoints.decodePolyline(mapdata["geom"][i]);

        PolylineId id = PolylineId(mapdata["geom"][i]);

        if (geom.isNotEmpty) {
          geom.forEach((PointLatLng point) {
            //왜 값자기 long이랑 lat이랑 바뀐거지???
            LatLng temp = LatLng(point.longitude, point.latitude);
            print(point.latitude);
            polylineCoordinates.add(temp);
          });
        }
        Polyline polyline = Polyline(
            polylineId: id,
            color: Color.fromARGB(255, 227, 0, 0),
            points: polylineCoordinates);
        polylines[id] = polyline;
        print(polyline);
      }
    }
    Map map = {};

    map["PL"] = markers;
    map["RO"] = polylines;
    map["camera_point_lat"] = mapdata["geom"][0][0];
    map["camera_point_lng"] = mapdata["geom"][0][1];
    return map;
  }
}
