import 'package:dayplan_it/components/app_bar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: DayplanitAppBar(
        isHomePage: true,
      ),
      body: Center(
        child: Text('프로필 스크린입니다.'),
      ),
    );
  }
}
