import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
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
    HomeRepository _homeRepository = HomeRepository();
    List<DecorationItem> decorationList =
        Provider.of<HomeProvider>(context, listen: false).decorationList;
    if (Provider.of<HomeProvider>(context, listen: false).hasTodaySchedule) {
      DateTime todayTime = DateTime.now();
      DateTime today = DateTime(todayTime.year, todayTime.month, todayTime.day);
      _homeRepository.setSchedule(today, context);
    }
    return SizedBox(
        height: 120,
        child: CalendarWeek(
          controller: CalendarWeekController(),
          showMonth: true,
          minDate: DateTime.now().add(
            const Duration(days: -30),
          ),
          maxDate: DateTime.now().add(
            const Duration(days: 30),
          ),
          dayOfWeekStyle: const TextStyle(
              color: Color.fromARGB(255, 195, 195, 195),
              fontWeight: FontWeight.w600),
          weekendsStyle: const TextStyle(
              color: Color.fromARGB(255, 135, 17, 17),
              fontWeight: FontWeight.w600),
          pressedDateBackgroundColor: primaryColor,
          todayDateStyle: const TextStyle(
              color: Color.fromARGB(255, 68, 68, 68),
              fontWeight: FontWeight.w600),
          dateStyle: const TextStyle(
              color: Color.fromARGB(255, 68, 68, 68),
              fontWeight: FontWeight.w600),

          ///날짜를 클릭했을 때 해당 날짜 지도, 스케줄, provider 설정
          onDatePressed: (DateTime date) async {
            DateTime datetime = DateTime(date.year, date.month, date.day);

            Provider.of<HomeProvider>(context, listen: false)
                .selectDate(datetime);
            Provider.of<HomeProvider>(context, listen: false).deleteData();
            await _homeRepository.setSchedule(date, context);
          },
          monthViewBuilder: (DateTime time) => Align(
            alignment: FractionalOffset.center,
            child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  time.year.toString() + "년 " + time.month.toString() + "월",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: DayplanitLogoFont(
                      textStyle: const TextStyle(
                          fontSize: 20, color: Color.fromARGB(221, 72, 72, 72)),
                      fontWeight: FontWeight.w600),
                )),
          ),

          ///프로바이더의 캘린더 마커 불러와서 표시
          decorations: decorationList,
        ));
  }
}
