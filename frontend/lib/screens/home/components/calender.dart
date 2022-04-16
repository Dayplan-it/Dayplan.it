import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:dayplan_it/screens/home/provider/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/home/repository/home_repository.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class WeeklyCalander extends StatefulWidget {
  @override
  State<WeeklyCalander> createState() => _WeeklyCalanderState();
}

class _WeeklyCalanderState extends State<WeeklyCalander> {
  bool showProgress = false;
  HomeProvider _homeProvider = new HomeProvider();
  DateTime _selectedDate = DateTime.now().add(Duration(days: 5));
  List<DecorationItem> decoration_list = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    HomeRepository _homeRepository = HomeRepository();
    Completer<GoogleMapController> _completer = Completer();

    _homeProvider = Provider.of<HomeProvider>(context, listen: false);

    decoration_list = _homeProvider.decoration_list;
    return Container(
        height: 120,
        child: CalendarWeek(
          controller: CalendarWeekController(),
          showMonth: true,
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
          minDate: DateTime.now().add(
            Duration(days: -365),
          ),
          maxDate: DateTime.now().add(
            Duration(days: 365),
          ),
          onDatePressed: (DateTime datetime) async {
            Provider.of<HomeProvider>(context, listen: false)
                .selectDate(datetime);
            Provider.of<HomeProvider>(context, listen: false).deleteData();
            Future<Map<String, List<dynamic>>> response_detail =
                _homeRepository.getScheduleDetail(
                    Provider.of<HomeProvider>(context, listen: false).id,
                    datetime);
            response_detail.then((value) {
              if (value.length > 2) {
                Provider.of<HomeProvider>(context, listen: false)
                    .setScheduleDetail(value);

//-----------------구글지도 관련 프로바이더 설정하기-------------//
                Map<dynamic, dynamic> mapdata =
                    _homeRepository.setRouteData(value);

                Provider.of<HomeProvider>(context, listen: false)
                    .setGeom(mapdata);
                //카메라 이동하기

                Future<void> animateTo(double lat, double lng) async {
                  final c = await _completer.future;
                  final p =
                      CameraPosition(target: LatLng(lat, lng), zoom: 14.4746);
                  c.animateCamera(CameraUpdate.newCameraPosition(p));
                }
              } else {}
            }).catchError((onError) {});
          },
          onDateLongPressed: (DateTime datetime) {
            // Do something
          },
          onWeekChanged: () {
            // Do something
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
          decorations: decoration_list,
        ));
  }

  void FlutterDialog() {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Column(
              children: <Widget>[
                new Text("오류"),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "오류발생",
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
