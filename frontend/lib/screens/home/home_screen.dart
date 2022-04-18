import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calendar_strip/calendar_strip.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dayplan_it/screens/home/components/calender.dart';
import 'package:dayplan_it/screens/home/components/schedule.dart';
import 'package:dayplan_it/screens/home/components/googlemap.dart';
import 'package:dayplan_it/components/floating_btn.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //샘플 데이터 입력

  List<DateTime> markedDates = [
    DateTime.parse("2022-04-13 00:00:00.000"),
    DateTime.parse("2022-04-15 00:00:00.000"),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //구글맵 기 위치
    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
          child: Column(
              // 주 축 기준 중앙
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            WeeklyCalander(markedDates),
            Padding(padding: EdgeInsets.all(0.007 * deviceheight)),
            Schedule(),
            Padding(padding: EdgeInsets.all(0.007 * deviceheight)),
            Googlemap(),
          ])),
      floatingActionButton: const DayplanitFloatingBtn(),
    );
  }
}
