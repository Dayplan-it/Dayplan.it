import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:dayplan_it/notification/notification.dart';
import 'package:dayplan_it/screens/home/components/calender.dart';
import 'package:dayplan_it/screens/home/components/schedule.dart';
import 'package:dayplan_it/screens/home/components/googlemap.dart';
import 'package:dayplan_it/components/floating_btn.dart';
import 'package:dayplan_it/screens/home/components/repository/home_repository.dart';
import 'package:dayplan_it/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _homeRepository = HomeRepository();

  late Widget weekCalendar;

  _getUserLocPermission() async {
    var status = await Permission.location.status;

    if (status != PermissionStatus.granted) {
      await Permission.location.request();

      if (await Permission.location.request() != PermissionStatus.granted) {
        // 위치정보 사용 거절당했을 경우 필요하다는 다이얼로그 띄우기
        await showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: const Text('데이플래닛에 착륙🚀하려면'),
                  content: const Text('데이플래닛을 사용하기 위해서는 위치 권한이 필요합니다.'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text('거절'),
                      onPressed: () => exit(0),
                    ),
                    CupertinoDialogAction(
                      child: const Text('설정'),
                      onPressed: () => openAppSettings(),
                    ),
                  ],
                ));
      }
    }
  }

  @override
  void initState() {
    _getUserLocPermission();
    super.initState();
    weekCalendar = FutureBuilder(
        future: _homeRepository.getScheduleList(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
          if (snapshot.hasData == false) {
            return Column(children: [
              const SizedBox(height: 55),
              Text("일정을 불러오는 중입니다!",
                  style: mainFont(
                      textStyle: const TextStyle(color: subTextColor),
                      fontSize: 12)),
              const SizedBox(height: 10),
              const CircularProgressIndicator()
            ]);
          }
          // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
          else {
            return const WeeklyCalander();
          }
        });
    initNotification();
  }

  @override
  Widget build(BuildContext context) {
    final deviceheight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
          child: Column(
              // 주 축 기준 중앙
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            weekCalendar,
            Padding(padding: EdgeInsets.all(0.007 * deviceheight)),
            const Schedule(),
            Padding(padding: EdgeInsets.all(0.007 * deviceheight)),
            const Googlemap(),
          ])),
      floatingActionButton: const DayplanitFloatingBtn(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
