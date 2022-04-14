import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/components/floating_btn.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DayplanitAppBar(
        isHomePage: true,
      ),
      body: const Center(
        child: Text('홈스크린입니다.\n플로팅 버튼 눌러 스케쥴 생성 페이지로 이동'),
      ),
      floatingActionButton: DayplanitFloatingBtn(
        date: DateTime.now().toLocal(), // 여기에 날짜 집어넣으면 해당 날짜 스케쥴 생성 페이지로 이동
      ),
    );
  }
}
