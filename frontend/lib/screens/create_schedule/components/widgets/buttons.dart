import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
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
            minimumSize: const Size.fromHeight(50),
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

class SquareButtonWithLoading extends StatefulWidget {
  const SquareButtonWithLoading({
    Key? key,
    required this.title,
    this.activate = false,
    required this.futureFunction,
  }) : super(key: key);
  final String title;
  final bool activate;
  final Future<void> Function() futureFunction;

  @override
  State<SquareButtonWithLoading> createState() =>
      _SquareButtonWithLoadingState();
}

class _SquareButtonWithLoadingState extends State<SquareButtonWithLoading> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: ElevatedButton(
          onPressed: (widget.activate
              ? () async {
                  setState(() {
                    isLoading = true;
                  });
                  await widget.futureFunction();
                  setState(() {
                    isLoading = false;
                  });
                }
              : null),
          style: ElevatedButton.styleFrom(
              primary: primaryColor,
              minimumSize: Size(
                  (screenWidth - 24) *
                      (context
                              .watch<CreateScheduleStore>()
                              .tabWidthFlex
                              .toDouble() /
                          100),
                  50),
              shape: RoundedRectangleBorder(borderRadius: buttonBoxRadius)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                widget.title,
                style: mainFont(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (isLoading) ...[
                const SizedBox(
                  width: 5,
                ),
                const SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ]
            ],
          )),
    );
  }
}
