import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';

import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:dayplan_it/screens/home/components/repository/home_repository.dart';

class WeeklyCalander extends StatefulWidget {
  const WeeklyCalander({Key? key}) : super(key: key);

  @override
  State<WeeklyCalander> createState() => _WeeklyCalanderState();
}

class _WeeklyCalanderState extends State<WeeklyCalander> {
  bool showProgress = false;

  @override
  Widget build(BuildContext context) {
    DateTime todayTime = DateTime.now();
    DateTime today = DateTime(todayTime.year, todayTime.month, todayTime.day);
    HomeRepository _homeRepository = HomeRepository();
    List<DecorationItem> decorationList =
        Provider.of<HomeProvider>(context, listen: false).decorationList;
    if (Provider.of<HomeProvider>(context, listen: false).hasTodaySchedule) {
      _homeRepository.setSchedule(today, context);
    }
    return SizedBox(
        height: 130,
        child: CalendarWeek(
          controller: CalendarWeekController(),
          showMonth: true,
          minDate: today.add(
            const Duration(days: -30),
          ),
          maxDate: today.add(
            const Duration(days: 30),
          ),
          dayOfWeekStyle: mainFont(
            color: subTextColor,
            fontWeight: FontWeight.w600,
          ),
          weekendsStyle: mainFont(
              color: const Color.fromARGB(255, 135, 17, 17),
              fontWeight: FontWeight.w600),
          pressedDateBackgroundColor: primaryColor,
          todayDateStyle:
              mainFont(color: Colors.white, fontWeight: FontWeight.w600),
          todayBackgroundColor: const Color.fromARGB(181, 1, 87, 141),
          dateStyle: mainFont(
              color: const Color.fromARGB(255, 68, 68, 68),
              fontWeight: FontWeight.w600),
          pressedDateStyle:
              mainFont(color: Colors.white, fontWeight: FontWeight.w600),

          ///날짜를 클릭했을 때 해당 날짜 지도, 스케줄, provider 설정
          onDatePressed: (DateTime date) async {
            DateTime datetime = DateTime(date.year, date.month, date.day);

            Provider.of<HomeProvider>(context, listen: false)
                .selectDate(datetime);
            Provider.of<HomeProvider>(context, listen: false).deleteData();

            context.read<HomeProvider>().onDateNewlySelectedStart();
            await _homeRepository.setSchedule(date, context);
            context.read<HomeProvider>().onDateNewlySelectedEnd();
          },
          monthViewBuilder: (DateTime time) => Align(
            alignment: FractionalOffset.center,
            child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  time.year.toString() + "년 " + time.month.toString() + "월",
                  textAlign: TextAlign.center,
                  style: mainFont(
                      fontSize: 20,
                      color: const Color.fromARGB(221, 72, 72, 72),
                      fontWeight: FontWeight.w800),
                )),
          ),

          ///프로바이더의 캘린더 마커 불러와서 표시
          decorations: decorationList,
        ));
  }
}
