import 'package:dayplan_it/components/app_bar_back.dart';
import 'package:dayplan_it/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:dayplan_it/screens/home/components/repository/home_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _checkState = 0;
  DayplanitStyles dayplanitStyles = DayplanitStyles();
  HomeRepository homeRepository = HomeRepository();
  List disableButton = [];
  @override
  Widget build(BuildContext context) {
    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;
    List<DateTime> allSchedules =
        Provider.of<HomeProvider>(context, listen: false).allSchedule;
    int len = allSchedules.length;
    return FutureBuilder(
        future: setOnOffstate(allSchedules),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
          } else {
            return Scaffold(
                appBar: const DayplanitAppBarWithBack(),
                body: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    key: GlobalKey(),
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Column(
                          children: [
                            Container(
                              child: Center(
                                child: Text("All Notifications",
                                    style: mainFont(
                                        textStyle: const TextStyle(
                                            color: primaryColor),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20)),
                              ),
                              color: Color.fromARGB(255, 251, 251, 251),
                            ),
                            Container(
                                height: deviceheight * 0.35,
                                width: devicewidth * 0.8,
                                child: ListView.separated(
                                  padding: const EdgeInsets.all(5),
                                  itemCount: len,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              onTap: () {},
                                              leading: Switch(
                                                  value: snapshot.data[index],
                                                  onChanged: (value) {
                                                    //알람이 설정되있을 경우 누르면 삭제
                                                    if (snapshot.data[index] ==
                                                        true) {
                                                      notificationDisable(
                                                          allSchedules[index],
                                                          context);
                                                    } else {
                                                      notificationEnable(
                                                          allSchedules[index],
                                                          context);
                                                    }
                                                    setState(() {
                                                      // setState() 추가.
                                                      _checkState++;
                                                    });
                                                  }),
                                              title: Text(
                                                allSchedules[index]
                                                        .year
                                                        .toString() +
                                                    "년 " +
                                                    allSchedules[index]
                                                        .month
                                                        .toString() +
                                                    "월 " +
                                                    allSchedules[index]
                                                        .day
                                                        .toString() +
                                                    "일",
                                                style: DayplanitLogoFont(
                                                    textStyle: const TextStyle(
                                                        color: Color.fromARGB(
                                                            221, 72, 72, 72)),
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ]),
                                    );
                                  },

                                  ///구분선추가
                                  separatorBuilder: (context, index) {
                                    return const Divider();
                                  },
                                )),
                          ],
                        ))));
          }
        });
  }

  Future<bool> calculateWhetherDisabledReturnsBool(date) async {
    final prefs = await SharedPreferences.getInstance();
    final counter = prefs.getInt(date.toString()) ?? 0;
    if (counter > 0) {
      return true;
    } else {
      return false;
    }
  }

  //알림설정버튼
  void notificationEnable(date, context) {
    setNotification(date, context);
  }

  //알림삭제
  void notificationDisable(date, context) {
    cancelNotification(date, context);
  }

  //알람스위치 온오프목록 초기화
  Future<List> setOnOffstate(allSchedules) async {
    List disableButton = [];
    int len = allSchedules.length;
    for (int i = 0; i < len; i++) {
      bool disableButtonBool =
          await calculateWhetherDisabledReturnsBool(allSchedules[i]);
      disableButton.add(disableButtonBool);
    }
    return disableButton;
  }
}
