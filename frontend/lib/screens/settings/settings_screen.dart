import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/screens/start/loginpage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future withdrawal() async {
    var dio = Dio();

    var url = '$commonUrl/users/delete';
    var prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('apiToken')!;
    dio.options.headers['Authorization'] = token.toString();
    var response = await dio.post(url);

    if (response.statusCode == 200) {
      await prefs.clear();
      return;
    } else {
      throw '회원탈퇴 실패';
    }
  }

  Future<bool> logout() async {
    var prefs = await SharedPreferences.getInstance();
    return await prefs.remove('apiToken');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DayplanitAppBar(
        title: "설정",
        isHomePage: false,
        isAlarmScreen: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 20, 0, 10),
                child: Text(
                  "회원정보",
                  style: mainFont(
                      color: primaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                            title: const Text('잠시 떠나실건가요?'),
                            content: const Text('언제든지 다시 찾아올 수 있어요!'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                child: Text('로그아웃',
                                    style: mainFont(
                                        color: pointColor,
                                        fontWeight: FontWeight.w600)),
                                onPressed: () async {
                                  if (await logout()) {
                                    return showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) =>
                                            CupertinoAlertDialog(
                                              title: const Text(
                                                  '데이플래닛에서 이륙했습니다😢'),
                                              content:
                                                  const Text('다음에 또 놀러오세요!👋'),
                                              actions: <Widget>[
                                                CupertinoDialogAction(
                                                  child: const Text('로그인'),
                                                  onPressed: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LoginPage())),
                                                ),
                                                CupertinoDialogAction(
                                                  child: const Text('앱 종료'),
                                                  onPressed: () => exit(0),
                                                ),
                                              ],
                                            ));
                                  }
                                },
                              ),
                              CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: Text('취소', style: mainFont()),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                            ],
                          ));
                },
                child: Text(
                  '로그아웃',
                  style: mainFont(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                            title: const Text('데이플래닛에서 이륙하실건가요?'),
                            content: const Text('한번 떠나면 모든 데이터가 사라져요!'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                child: Text('회원 탈퇴',
                                    style: mainFont(
                                        color: pointColor,
                                        fontWeight: FontWeight.w600)),
                                onPressed: () async {
                                  await withdrawal();
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) =>
                                          CupertinoAlertDialog(
                                            title:
                                                const Text('데이플래닛에서 이륙했습니다😢'),
                                            content:
                                                const Text('다음에 또 놀러오세요!👋'),
                                            actions: <Widget>[
                                              CupertinoDialogAction(
                                                child: const Text('앱 종료'),
                                                onPressed: () => exit(0),
                                              ),
                                            ],
                                          ));

                                  await Future.delayed(
                                      const Duration(seconds: 5));
                                  exit(0);
                                },
                              ),
                              CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: Text('취소', style: mainFont()),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                            ],
                          ));
                },
                child: Text(
                  '회원탈퇴',
                  style: mainFont(
                      color: pointColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
