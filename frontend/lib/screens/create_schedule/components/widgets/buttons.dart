import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

class SquareButton extends StatelessWidget {
  const SquareButton({
    Key? key,
    required this.title,
    this.activate = false,
    required this.onPressed,
    this.isCancle = false,
  }) : super(key: key);
  final String title;
  final bool activate;
  final VoidCallback onPressed;
  final bool isCancle;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: isCancle ? onPressed : (activate ? onPressed : null),
        style: ElevatedButton.styleFrom(
            primary: isCancle ? pointColor : primaryColor,
            minimumSize: const Size(double.maxFinite, 40),
            shape: RoundedRectangleBorder(borderRadius: buttonBoxRadius)),
        child: Text(
          title,
          style: mainFont(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ));
  }
}
