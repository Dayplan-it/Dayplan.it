import 'package:dayplan_it/constants.dart';
import 'package:flutter/material.dart';
import 'components/timeline_vertical.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/screens/create_schedule/components/dragNdropAbles.dart';

class CreateScheduleScreen extends StatelessWidget {
  const CreateScheduleScreen({Key? key, required this.date}) : super(key: key);
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DayplanitAppBar(
        title: "일정 생성하기",
        subtitle: "${date.month.toString()}월 ${date.day.toString()}일",
        isHomePage: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
        child: Row(
          children: [
            Expanded(flex: 47, child: TimeLine()),
            Expanded(
                flex: 53,
                child: Column(
                  children: [
                    Expanded(flex: 50, child: RecommendedSchedulesGrid()),
                    Expanded(
                        flex: 50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "일정이 없습니다",
                                  style: mainFont(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "일정 블록을 선택하거나",
                                  style: mainFont(color: subTextColor),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "커스텀 블록을 만들어주세요",
                                  style: mainFont(color: subTextColor),
                                )
                              ],
                            )
                          ],
                        )),
                    ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                            primary: primaryColor,
                            minimumSize: const Size(double.maxFinite, 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text(
                          "일정 결정",
                          style: mainFont(),
                        ))
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
