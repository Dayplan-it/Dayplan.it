import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:flutter/material.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/notification/notification.dart';
import 'package:dayplan_it/components/floating_btn.dart';
import 'package:dayplan_it/screens/home/components/calender.dart';
import 'package:dayplan_it/screens/home/components/schedule.dart';
import 'package:dayplan_it/screens/home/components/googlemap.dart';
import 'package:dayplan_it/screens/home/components/repository/home_repository.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _homeRepository = HomeRepository();

  late Widget weekCalendar;

  @override
  void initState() {
    super.initState();
    weekCalendar = FutureBuilder(
        future: HomeRepository.getScheduleList(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
          if (snapshot.hasData == false) {
            return SizedBox(
              height: 120,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("일정을 불러오는 중입니다!",
                        style: mainFont(
                            textStyle: const TextStyle(color: subTextColor),
                            fontSize: 12)),
                    const CircularProgressIndicator(
                      color: primaryColor,
                    )
                  ]),
            );
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
    return Scaffold(
      appBar: const DayplanitAppBar(
        isHomePage: true,
      ),
      body: Center(
          child: Column(
              // 주 축 기준 중앙
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            weekCalendar,
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: const [
                  Expanded(child: Schedule()),
                  SizedBox(height: 8),
                  Expanded(child: Googlemap())
                ],
              ),
            )),
          ])),
      floatingActionButton: const DayplanitFloatingBtn(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
