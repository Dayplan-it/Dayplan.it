import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:dayplan_it/notification/notification.dart';
import 'package:dayplan_it/screens/home/components/calender.dart';
import 'package:dayplan_it/screens/home/components/schedule.dart';
import 'package:dayplan_it/screens/home/components/googlemap.dart';
import 'package:dayplan_it/components/floating_btn.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:dayplan_it/screens/home/components/repository/home_repository.dart';
import 'package:dayplan_it/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _homeRepository = HomeRepository();

  @override
  void initState() {
    super.initState();
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
            FutureBuilder(
                future: _homeRepository.getScheduleList(context),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
                  if (snapshot.hasData == false) {
                    return Column(children: [
                      const SizedBox(height: 65),
                      Text("일정을 불러오는 중입니다!",
                          style: mainFont(
                              textStyle: const TextStyle(color: subTextColor),
                              fontSize: 12)),
                      const CircularProgressIndicator()
                    ]);
                  }
                  // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
                  else {
                    return const WeeklyCalander();
                  }
                }),
            Padding(padding: EdgeInsets.all(0.007 * deviceheight)),
            const Schedule(),
            Padding(padding: EdgeInsets.all(0.007 * deviceheight)),
            const Googlemap(),
          ])),
      floatingActionButton: DayplanitFloatingBtn(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
