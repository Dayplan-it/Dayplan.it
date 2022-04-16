import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dayplan_it/screens/home/components/calender.dart';
import 'package:dayplan_it/screens/home/components/schedule.dart';
import 'package:dayplan_it/screens/home/components/googlemap.dart';
import 'package:dayplan_it/components/floating_btn.dart';
import 'package:dayplan_it/screens/home/provider/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //샘플 데이터 입력
  HomeProvider _homeProvider = new HomeProvider();

  void getScheduleList() async {
    int id = Provider.of<HomeProvider>(context, listen: false).id;
    var dio = Dio();
    var url = 'http://127.0.0.1:8000/schedules/findlist?user_id=${id}';
    try {
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
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getScheduleList();
  }

  @override
  Widget build(BuildContext context) {
    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
          child: Column(
              // 주 축 기준 중앙
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            WeeklyCalander(),
            Padding(padding: EdgeInsets.all(0.007 * deviceheight)),
            Schedule(),
            Padding(padding: EdgeInsets.all(0.007 * deviceheight)),
            Googlemap(),
          ])),
      floatingActionButton: const DayplanitFloatingBtn(),
    );
  }
}
