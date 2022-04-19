import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place_rough.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/timeline_vertical.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';

/// 상세 일정 결정 페이지
class CreateDetailScheduleScreen extends StatefulWidget {
  const CreateDetailScheduleScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateDetailScheduleScreen> createState() =>
      _CreateDetailScheduleScreenState();
}

class _CreateDetailScheduleScreenState
    extends State<CreateDetailScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    var roughSchedule = context.read<CreateScheduleStore>().roughSchedule;
    DateTime date = context.read<CreateScheduleStore>().scheduleDate;
    for (int i = 0; i < roughSchedule.length; i++) {
      print(
          "${i + 1}번째 스케줄 ${roughSchedule[i].nameKor}\n${roughSchedule[i].startsAt} ~ ${roughSchedule[i].endsAt}");
    }
    return WillPopScope(
      onWillPop: () async {
        context.read<CreateScheduleStore>().toggleIsDetailBeingMade();
        return true;
      },
      child: Scaffold(
        appBar: DayplanitAppBar(
          title: "상세 일정 결정하기",
          subtitle: "${date.month.toString()}월 ${date.day.toString()}일",
          isHomePage: false,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: TimeLine(
                    timeLineWidth: detailTimeLineWidth,
                  )),
              Expanded(
                flex: 6,
                child: Container(
                  color: Colors.red,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
