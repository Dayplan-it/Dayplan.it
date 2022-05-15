import 'package:dayplan_it/class/route_class.dart';
import 'package:dayplan_it/class/schedule_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dayplan_it/screens/home/components/provider/home_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayplan_it/screens/home/components/repository/home_repository.dart';

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

//기본설정메소드
Future<void> initNotification() async {
  await _configureLocalTimeZone();
  await _initializeNotification();
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

Future<void> _initializeNotification() async {
  const IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

//메세지 등록
Future<void> registerMessage({
  required int id,
  required DateTime date,
  required message,
}) async {
  tz.TZDateTime scheduledDate = tz.TZDateTime.from(
    date,
    tz.local,
  );
  //로컬에알람정보저장
  print(date.toString() + "의 알람설징" + message);

  await _flutterLocalNotificationsPlugin.zonedSchedule(
    id ~/ 1000,
    '다음 일정 출발 20분전입니다!',
    message,
    scheduledDate,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true,
        styleInformation: BigTextStyleInformation(message),
        icon: 'app_icon',
      ),
      iOS: const IOSNotificationDetails(
        badgeNumber: 1,
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

//알람설정 메소드

setNotification(date, context) async {
  HomeRepository homeRepository = HomeRepository();

  final prefs = await SharedPreferences.getInstance();
  print(date.toString() + "이건 로컬에 저장된 이름");
  prefs.setInt(date.toString(), 1);
  //아이디+날짜로 일정시작 알람
  ScheduleCreated detail = await homeRepository.getScheduleDetail(date);
  //이동시작 20분전에 알람
  for (int i = 0; i < detail.list.length; i++) {
    if (detail.list[i] is RouteOrder) {
      //다음장소에 대한 comments
      String message =
          "${(detail.list[i + 1] as Place).placeName}에서 ${(detail.list[i + 1] as Place).getInstruction()["duration"]}동안";
      DateTime date2 = (detail.list[i] as RouteOrder)
          .startsAt
          .subtract(const Duration(minutes: 20));

      var time = tz.TZDateTime.from(
        date2,
        tz.local,
      );
      //알림의 고유한 아이디 만들기
      int notId = int.parse(date2.year.toString().substring(1) +
          date2.month.toString() +
          date2.day.toString() +
          date2.hour.toString() +
          date2.minute.toString());
      //알람등록

      await registerMessage(
        id: notId,
        date: time,
        message: message,
      );
    }
  }
}

cancelNotification(date, context) async {
  HomeRepository homeRepository = HomeRepository();

  final prefs = await SharedPreferences.getInstance();
  print(date.toString() + "이건 로컬에 삭제된 이름");
  prefs.remove(date.toString());
  //아이디+날짜로 일정시작
  ScheduleCreated detail = await homeRepository.getScheduleDetail(date);
  //이동시작 20분전에 알람
  for (int i = 0; i < detail.list.length; i++) {
    if (detail.list[i] is RouteOrder) {
      DateTime date2 = (detail.list[i] as RouteOrder)
          .startsAt
          .subtract(const Duration(minutes: 20));

      //알림의 고유한 아이디 만들기
      int notId = int.parse(date2.year.toString().substring(1) +
          date2.month.toString() +
          date2.day.toString() +
          date2.hour.toString() +
          date2.minute.toString());
      //알람삭제
      await _flutterLocalNotificationsPlugin.cancel(notId);
    }
  }
}
