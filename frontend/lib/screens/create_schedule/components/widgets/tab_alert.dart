import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';

/// tab 페이지에 띄우는 전체화면 회색조 Alert
class GreyTabAlert extends StatelessWidget {
  final String title1;
  final String? title2;
  final IconData icon;
  final bool isFaIcon;

  const GreyTabAlert(
      {Key? key,
      required this.title1,
      this.title2,
      required this.icon,
      this.isFaIcon = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                borderRadius: defaultBoxRadius,
                color: const Color.fromARGB(212, 39, 39, 39)),
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isFaIcon) ...[
                    FaIcon(
                      icon,
                      size: 50,
                      color: Colors.white,
                    ),
                  ] else ...[
                    Icon(
                      icon,
                      size: 50,
                      color: Colors.white,
                    ),
                  ],
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    title1,
                    style: mainFont(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  if (title2 != null)
                    Text(
                      title2!,
                      style: mainFont(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            )));
  }
}
