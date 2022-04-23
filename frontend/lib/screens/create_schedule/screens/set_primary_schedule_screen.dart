import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/components/app_bar.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/create_duration_schedule_right_side.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/durationLine_vertical.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';

class SetPrimaryScheduleScreen extends StatefulWidget {
  const SetPrimaryScheduleScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SetPrimaryScheduleScreen> createState() => _SetPrimaryScheduleScreen();
}

class _SetPrimaryScheduleScreen extends State<SetPrimaryScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    DateTime date = context.read<CreateScheduleStore>().scheduleDate;
    return WillPopScope(
      onWillPop: () async {
        // context.read<CreateScheduleStore>().onPopCreateRoughScheduleScreen();
        return true;
      },
      child: Scaffold(
          appBar: DayplanitAppBar(
            title: "일정 시작시간 정하기",
            subtitle: "${date.month.toString()}월 ${date.day.toString()}일",
            isHomePage: false,
          ),
          body: SetPrimaryScheduleScreenBody(
            date: date,
          )),
    );
  }
}

class SetPrimaryScheduleScreenBody extends StatelessWidget {
  const SetPrimaryScheduleScreenBody({Key? key, required this.date})
      : super(key: key);
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
        child: Row(children: [
          const Expanded(
              flex: 47,
              child: DurationLine(
                durationLineWidth: roughTimeLineWidth,
              )),
          Expanded(flex: 53, child: SizedBox())
        ]));
  }
}
