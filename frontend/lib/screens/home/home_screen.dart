import 'package:flutter/material.dart';
import 'package:dayplan_it/screens/home/components/calender.dart';
import 'package:dayplan_it/screens/home/components/schedule.dart';
import 'package:dayplan_it/screens/home/components/googlemap.dart';
import 'package:dayplan_it/components/floating_btn.dart';
import 'package:dayplan_it/screens/home/components/repository/home_repository.dart';

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
    _homeRepository.getScheduleList(context);
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
            const WeeklyCalander(),
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
