import 'package:dayplan_it/constants.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:provider/provider.dart';

class HomeRepository {
  Future<Map<String, List<dynamic>>> getScheduleDetail(id, date) async {
    //datetime to timestamp

    DateTime date2 = DateTime(date.year, date.month, date.day);

    final List<String> comments = [];
    final List<String> icons = [];
    final List<String> stratTime = [];
    final List<String> endTime = [];
    final List<dynamic> geom = [];
    final List<dynamic> detail = [];
    final List<String> type = [];
    final timestamp1 = date2.millisecondsSinceEpoch;
    var dio = Dio();
    var url =
        '$commonUrl/schedules/find?user_id=$id&date=${timestamp1 ~/ 1000}';
    Response response = await dio.get(url);
    var res = response.data;

    for (int i = 0; i < res["order"].length; i++) {
      if (res["order"][i]["type"] == "PL") {
        comments.add(
            "${res["order"][i]["detail"]["place_name"]} - ${res["order"][i]["detail"]["duration"]} 소요");
        icons.add("loc");
        stratTime.add("${res["order"][i]["detail"]["starts_at"]}");
        endTime.add("${res["order"][i]["detail"]["ends_at"]}");
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
        stratTime.add("${res["order"][i]["detail"]["starts_at"]}");
        endTime.add("${res["order"][i]["detail"]["ends_at"]}");
        geom.add(res["order"][i]["detail"]["polyline"]);
        detail.add(res["order"][i]["step"]);
        type.add("RO");
      }
    }
    Map<String, List<dynamic>> result = {};
    result['comments'] = comments;
    result['icons'] = icons;
    result['start_time'] = stratTime;
    result['end_time'] = endTime;
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
        List<PointLatLng> geom =
            polylinePoints.decodePolyline(mapdata["geom"][i]);

        PolylineId id = PolylineId(mapdata["geom"][i]);

        if (geom.isNotEmpty) {
          for (var point in geom) {
            LatLng temp = LatLng(point.longitude, point.latitude);
            polylineCoordinates.add(temp);
          }
        }
        Polyline polyline = Polyline(
            polylineId: id,
            color: const Color.fromARGB(255, 227, 0, 0),
            points: polylineCoordinates);
        polylines[id] = polyline;
      }
    }
    Map map = {};
    map["PL"] = markers;
    map["RO"] = polylines;
    //카메라 위치관련 geom
    map["camera_point_lat"] = mapdata["geom"][0][0];
    map["camera_point_lng"] = mapdata["geom"][0][1];
    return map;
  }

  //userid로 사용자의 일정정보 조회  API 요청
  getScheduleList(context) async {
    int id = Provider.of<HomeProvider>(context, listen: false).id;
    var dio = Dio();
    var url = '$commonUrl/schedules/findlist?user_id=$id';
    var response = await dio.get(url);
    if (response.statusCode == 200) {
      List<int> list = response.data["found_schedule_dates"].cast<int>();

      List<DateTime> datetime = [];
      for (int i = 0; i < list.length; i++) {
        datetime.add(DateTime.fromMillisecondsSinceEpoch(list[i] * 1000));
      }

      Provider.of<HomeProvider>(context, listen: false)
          .setallschdulelist(datetime);
    }
  }
}
