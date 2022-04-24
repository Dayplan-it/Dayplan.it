import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/create_schedule_screen.dart';

class DayplanitFloatingBtn extends StatelessWidget {
  const DayplanitFloatingBtn({Key? key, required this.date}) : super(key: key);
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateScheduleScreen(
                        date: date,
                      )));
        },
        child: const Icon(
          CupertinoIcons.calendar_badge_plus,
          color: backgroundColor,
        ));
  }
}
