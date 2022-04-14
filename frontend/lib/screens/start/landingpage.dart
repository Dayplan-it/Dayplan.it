import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dayplan_it/screens/mainpage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    //이부분에서 로그인체크하고 로그인되어있을 떄 사용자정보 불러옴
    Timer(Duration(seconds: 2), () {
      //이부분에서 로그인 체크하여 로그인페이지갈지 메인페이지갈지 결정
      //로컬저장소에서 토큰확인, 토큰 사용가능한지 확인
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Color(0xFF01578D), Color(0xFF80AFCC)],
        stops: [0, 1],
        begin: AlignmentDirectional(1, -1),
        end: AlignmentDirectional(-1, 1),
      )),
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/landingpage_icon.png',
              width: 500,
              height: 200,
              fit: BoxFit.fitHeight,
            ),
            CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ]),
    );
  }
}
