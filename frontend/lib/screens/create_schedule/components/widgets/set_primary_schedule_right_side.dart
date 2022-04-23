import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/notification_text.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_constants.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/create_schedule_store.dart';
import 'package:dayplan_it/screens/create_schedule/components/core/place.dart';
import 'package:dayplan_it/screens/create_schedule/components/widgets/buttons.dart';

class DecidePrimarySchedule extends StatefulWidget {
  const DecidePrimarySchedule({Key? key}) : super(key: key);

  @override
  State<DecidePrimarySchedule> createState() => _DecidePrimaryScheduleState();
}

class _DecidePrimaryScheduleState extends State<DecidePrimarySchedule> {
  late DateTime _dateTime;
  late PlaceDurationOnly currentlyDecidingSchedule;

  @override
  void initState() {
    _dateTime = context
        .read<CreateScheduleStore>()
        .scheduleDate
        .add(const Duration(hours: 9));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currentlyDecidingSchedule = context
            .watch<CreateScheduleStore>()
            .durationSchedule[
        context.watch<CreateScheduleStore>().currentlyDecidingPrimarySchedule];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: currentlyDecidingSchedule.color,
                    borderRadius: defaultBoxRadius,
                    boxShadow: defaultBoxShadow),
                padding: const EdgeInsets.all(5),
                width: detailTimeLineWidth,
                height: itemHeight / 2,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    currentlyDecidingSchedule.nameKor,
                    style: mainFont(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15),
                  ),
                )),
            const SizedBox(
              height: 10,
            ),
            Text(
              "시작 시간을 선택하세요",
              style: mainFont(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 15),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "설정하신 시각을 기준으로",
              style: mainFont(color: subTextColor, fontSize: 12),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              "전체 스케줄의 시간이 결정됩니다",
              style: mainFont(color: subTextColor, fontSize: 12),
            )
          ],
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: defaultBoxRadius,
              boxShadow: defaultBoxShadow),
          height: 140,
          alignment: Alignment.center,
          child: TimePickerSpinner(
            time: context
                .read<CreateScheduleStore>()
                .scheduleDate
                .add(const Duration(hours: 9)),
            is24HourMode: false,
            normalTextStyle: mainFont(color: subTextColor),
            highlightedTextStyle:
                mainFont(color: primaryColor, fontWeight: FontWeight.w600),
            itemHeight: 40,
            isForce2Digits: true,
            onTimeChange: (time) {
              setState(() {
                _dateTime = time;
              });
            },
          ),
        ),
        Column(
          children: [
            if (context
                .watch<CreateScheduleStore>()
                .checkIfPrimaryScheduleDecideAble(_dateTime))
              const SizedBox(height: 23)
            else
              const NotificationText(
                title: "스케줄이 하루를 넘어서게 됩니다",
                isRed: true,
              ),
            ElevatedButton(
                onPressed: context
                        .watch<CreateScheduleStore>()
                        .checkIfPrimaryScheduleDecideAble(_dateTime)
                    ? () => context
                        .read<CreateScheduleStore>()
                        .setPrimarySchedule(_dateTime)
                    : null,
                style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                    minimumSize: const Size(double.maxFinite, 40),
                    shape:
                        RoundedRectangleBorder(borderRadius: buttonBoxRadius)),
                child: Text(
                  "스케줄 시간 설정하기",
                  style: mainFont(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )),
            ElevatedButton(
                onPressed: () => context
                    .read<CreateScheduleStore>()
                    .onEndDecidePrimarySchedule(),
                style: ElevatedButton.styleFrom(
                    primary: pointColor,
                    minimumSize: const Size(double.maxFinite, 40),
                    shape:
                        RoundedRectangleBorder(borderRadius: buttonBoxRadius)),
                child: Text(
                  "취소",
                  style: mainFont(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )),
          ],
        ),
      ],
    );
  }
}
