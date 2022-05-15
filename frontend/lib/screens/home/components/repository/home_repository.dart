import 'package:dayplan_it/class/route_class.dart';
import 'package:dayplan_it/class/schedule_class.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/functions/google_map_move_to.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/google_map.dart';
import 'package:dayplan_it/screens/create_schedule/exceptions/exceptions.dart';
import 'package:dayplan_it/screens/start/landingpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

class HomeRepository {
  Future<ScheduleCreated> getScheduleDetail(DateTime date) async {
    final int timestamp = date.millisecondsSinceEpoch;

    try {
      return await ScheduleCreated.getSchedule(
          date: (timestamp / 1000).floor());
    } on NoScheduleFound {
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> setRouteData(ScheduleCreated schedule) async {
    Map<MarkerId, Marker> markers = {};
    Map<PolylineId, Polyline> polylines = {};

    for (int i = 0; i < schedule.list.length; i++) {
      if (i % 2 == 0) {
        markers[MarkerId((schedule.list[i] as Place).placeId!)] =
            await markerForCreatedRoute(
                order: (i / 2).round() + 1, place: schedule.list[i]);
      } else {
        for (RouteStep step in (schedule.list[i] as RouteOrder).steps) {
          polylines[PolylineId(step.polyline)] = step.getPolyline();
        }
      }
    }

    Map map = {};
    map["PL"] = markers;
    map["RO"] = polylines;
    map["camera"] = moveToSchedule(scheduleOrder: schedule.list);
    return map;
  }

  //userid로 사용자의 일정정보 조회  API 요청
  static Future<bool> getScheduleList(context) async {
    DateTime today = DateTime.now();
    bool hasTodaySchedule = false;
    var dio = Dio();

    var url = '$commonUrl/schedules/findlist';
    //사용자토큰가져오기
    var prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('apiToken');
    dio.options.headers['Authorization'] = token.toString();

    try {
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        List<int> list = response.data["found_schedule_dates"].cast<int>();

        List<DateTime> datetime = [];

        for (int i = 0; i < list.length; i++) {
          //datetime 저장하고 알람설정
          DateTime tempDate =
              DateTime.fromMillisecondsSinceEpoch(list[i] * 1000);
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
    } on DioError catch (e) {
      if (e.response!.statusCode == 500) {
        /// 회원탈퇴된 상태라고 간주함
        ///
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => const CupertinoAlertDialog(
                  title: Text('사용자 정보가 바뀌었습니다'),
                  content: Text('앱을 다시 시작합니다'),
                ));

        await Future.delayed(const Duration(seconds: 2));

        await prefs.clear();

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LandingPage()));
      } else {
        rethrow;
      }
    }
    return true;
  }

//일정상세정보 새로고침
  Future<void> setSchedule(DateTime date, BuildContext context) async {
    ///선택일정의 일정상세정보 불러오기
    Future<ScheduleCreated> responseDetail = getScheduleDetail(date);

    await responseDetail.then((schedule) async {
      //스케줄디테일 부분에서 일정이없습니다 메세지 출력을 위해!
      Provider.of<HomeProvider>(context, listen: false).setNoSchedule(false);

      Provider.of<HomeProvider>(context, listen: false)
          .setScheduleDetail(schedule);
      Map<dynamic, dynamic> mapdata = await setRouteData(schedule);

      Provider.of<HomeProvider>(context, listen: false).setGeom(mapdata);
    }).catchError((error) {
      if (error is NoScheduleFound) {
        Provider.of<HomeProvider>(context, listen: false).setNoSchedule(true);
      }
    });
  }

  static Future<String> deleteSchedule(date) async {
    var dio = Dio();
    var url = '$commonUrl/schedules/delete';
    var prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('apiToken');
    dio.options.headers['Authorization'] = token.toString();
    int dateString = ((date.millisecondsSinceEpoch / 1000).toInt());
    var response = await dio.delete(url, data: {'date': dateString});
    var res = response.data;
    return res["message"];
  }
}
