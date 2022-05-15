import 'package:dayplan_it/screens/home/components/repository/home_repository.dart';
import 'package:dayplan_it/screens/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/create_schedule_screen.dart';
import 'package:provider/provider.dart';

import '../screens/home/components/provider/home_provider.dart';

class DayplanitFloatingBtn extends StatelessWidget {
  const DayplanitFloatingBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime date = Provider.of<HomeProvider>(context, listen: true).nowDate;

    bool showNoSchedule =
        Provider.of<HomeProvider>(context, listen: true).showNoSchedule;
    DateTime selectedDate = DateTime(date.year, date.month, date.day);
    DateTime todayDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return showNoSchedule
        ? FloatingActionButton(
            backgroundColor:
                DateTime.now().isBefore(date) ? primaryColor : subTextColor,
            onPressed: () {
              if (DateTime.now().isBefore(date)) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateScheduleScreen(
                              date: date,
                            )));
              }
            },
            child: const Icon(
              CupertinoIcons.calendar_badge_plus,
              color: backgroundColor,
            ))
        : FloatingActionButton(
            backgroundColor:
                DateTime.now().isBefore(date) || selectedDate == todayDate
                    ? pointColor
                    : subTextColor,
            onPressed: () {
              DateTime.now().isBefore(date) || selectedDate == todayDate
                  ? _getDeleteAlertDialog(
                      context, "일정 삭제", "일정을 삭제하시겠습니?", date)
                  : _getImpossibleAlertDialog(
                      context, "삭제 불가", "지난 알람은 삭제가 불가능 합니다.");
            },
            child: const Icon(
              CupertinoIcons.delete,
              color: backgroundColor,
            ));
  }

  _getDeleteAlertDialog(context, title, content, date) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            //Dialog Main Title
            title: Text(title),
            content: Text(
              content,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("확인", style: mainFont(color: pointColor)),
                onPressed: () async {
                  String message = await HomeRepository.deleteSchedule(date);
                  Navigator.pop(context);
                  _getImpossibleAlertDialog(context, "일정삭제", message);
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  "취소",
                  style: mainFont(),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  _getImpossibleAlertDialog(context, title, content) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            //Dialog Main Title
            title: Text(title),
            content: Text(
              content,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("확인", style: mainFont()),
                onPressed: () async {
                  await HomeRepository.getScheduleList(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainPage()));
                },
              ),
            ],
          );
        });
  }
}
