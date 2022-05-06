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

    return FloatingActionButton(
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
        ));
  }
}
