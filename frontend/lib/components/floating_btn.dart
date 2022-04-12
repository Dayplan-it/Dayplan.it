import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dayplan_it/constants.dart';

class DayplanitFloatingBtn extends StatelessWidget {
  const DayplanitFloatingBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {},
        child: const Icon(
          CupertinoIcons.calendar_badge_plus,
          color: backgroundColor,
        ));
  }
}
