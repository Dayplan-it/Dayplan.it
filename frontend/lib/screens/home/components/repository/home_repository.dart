import 'package:dayplan_it/constants.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeRepository {
  Future<Map<String, List<dynamic>>> getScheduleDetail(date) async {
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
    var prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('apiToken');
    dio.options.headers['Authorization'] = token.toString();
    var url = '$commonUrl/schedules/find?date=${timestamp1 ~/ 1000}';
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
        detail.add([
          res["order"][i]["detail"]["point"]["latitude"],
          res["order"][i]["detail"]["point"]["longitude"],
          res["order"][i]["detail"]["place_id"]
        ]);
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
        MarkerId markerId = MarkerId(mapdata["detail"][i][2]);
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
            LatLng temp = LatLng(point.latitude, point.longitude);
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
  Future<bool> getScheduleList(context) async {
    DateTime today = DateTime.now();
    bool hasTodaySchedule = false;
    var dio = Dio();

    var url = '$commonUrl/schedules/findlist';
    //사용자토큰가져오기
    var prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('apiToken');
    dio.options.headers['Authorization'] = token.toString();
    var response = await dio.get(url);

    if (response.statusCode == 200) {
      List<int> list = response.data["found_schedule_dates"].cast<int>();

      List<DateTime> datetime = [];

      for (int i = 0; i < list.length; i++) {
        //datetime 저장하고 알람설정
        DateTime tempDate = DateTime.fromMillisecondsSinceEpoch(list[i] * 1000);
        if (tempDate.year == today.year &&
            tempDate.month == today.month &&
            tempDate.day == today.day) {
          hasTodaySchedule = true;
        }
        datetime.add(tempDate);
      }
      Provider.of<HomeProvider>(context, listen: false)
          .setallschdulelist(datetime);

      //오늘 일정이 있을 때 로직수행
      if (hasTodaySchedule) {
        Provider.of<HomeProvider>(context, listen: false)
            .setTodaySchedule(true);
      }
    }
    return true;
  }

  //일정상세정보 새로고침
  Future<void> setSchedule(date, context) async {
    ///provider 현재날짜설정
    DateTime datetime = DateTime(date.year, date.month, date.day);

    ///선택일정의 일정상세정보 불러오기
    Future<Map<String, List<dynamic>>> responseDetail =
        getScheduleDetail(datetime);

    responseDetail.then((value) {
      if (value.length > 2) {
        //스케줄디테일 부분에서 일정이없습니다 메세지 출력을 위해!
        Provider.of<HomeProvider>(context, listen: false).setNoSchedult(false);

        Provider.of<HomeProvider>(context, listen: false)
            .setScheduleDetail(value);
        Map<dynamic, dynamic> mapdata = setRouteData(value);

        Provider.of<HomeProvider>(context, listen: false).setGeom(mapdata);
      } else {
        //스케줄디테일 부분에서 일정이없습니다 메세지 출력을 위해!
        Provider.of<HomeProvider>(context, listen: false).setNoSchedult(true);
      }
    }).catchError((onError) {
      Provider.of<HomeProvider>(context, listen: false).setNoSchedult(true);
    });
  }
}
