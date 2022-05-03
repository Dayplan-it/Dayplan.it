import 'dart:async';
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
            ///provider 현재날짜설정
            DateTime datetime = DateTime(date.year, date.month, date.day);
            Provider.of<HomeProvider>(context, listen: false)
                .selectDate(datetime);

            ///provider 기존 지도, 스케줄 초기화
            Provider.of<HomeProvider>(context, listen: false).deleteData();

            ///선택일정의 일정상세정보 불러오기
            Future<Map<String, List<dynamic>>> responseDetail =
                _homeRepository.getScheduleDetail(
                    Provider.of<HomeProvider>(context, listen: false).id,
                    datetime);

            responseDetail.then((value) {
              if (value.length > 2) {
                //스케줄디테일 부분에서 일정이없습니다 메세지 출력을 위해!
                Provider.of<HomeProvider>(context, listen: false)
                    .setNoSchedult(false);

                Provider.of<HomeProvider>(context, listen: false)
                    .setScheduleDetail(value);
                Map<dynamic, dynamic> mapdata =
                    _homeRepository.setRouteData(value);

                Provider.of<HomeProvider>(context, listen: false)
                    .setGeom(mapdata);
              } else {
                //스케줄디테일 부분에서 일정이없습니다 메세지 출력을 위해!
                Provider.of<HomeProvider>(context, listen: false)
                    .setNoSchedult(true);
              }
            }).catchError((onError) {
              Provider.of<HomeProvider>(context, listen: false)
                  .setNoSchedult(true);
            });
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
