import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/constants.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DayplanitAppBar(
        isHomePage: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              color: subTextColor,
              size: 50,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              '프로필 스크린 개발중',
              style: mainFont(color: subTextColor, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
