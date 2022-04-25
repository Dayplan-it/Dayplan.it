import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// class UserLocation {
//   UserLocation();

//   /// 기기로부터 위치정보를 가져오는 함수
//   Future<Position> getLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     return position;
//   }

//   /// 기기로부터 위치정보 사용 권한을 받고 위치정보를 가져오거나
//   /// AlertDialog를 띄우는 함수
//   Future<dynamic> geoloc() async {
//     if (await Permission.location.request().isGranted) {
//       return await getLocation();
//     } else {
//       // 위치정보 사용 거절당했을 경우 필요하다는 다이얼로그 띄우기
//       showDialog(
//           context: context,
//           builder: (BuildContext context) => CupertinoAlertDialog(
//                 title: const Text('위치정보 요청'),
//                 content: const Text('데이플래닛을 사용하기 위해서는 위치정보가 필요합니다.'),
//                 actions: <Widget>[
//                   CupertinoDialogAction(
//                     child: const Text('거절'),
//                     onPressed: () {
//                       context
//                           .read<CreateScheduleStore>()
//                           .tabController
//                           .animateTo(0);
//                     },
//                   ),
//                   CupertinoDialogAction(
//                     child: const Text('설정'),
//                     onPressed: () => openAppSettings(),
//                   ),
//                 ],
//               ));
//     }
//   }
// }

// class Info {
//   final int id;
//   final String userName;
//   final int account;
//   final int balance;

//   Info(
//       {required this.id,
//       required this.userName,
//       required this.account,
//       required this.balance});

//   factory Info.fromJson(Map<dynamic, dynamic> json) {
//     final Map<dynamic, dynamic> predictions = json['predictions'];
//     return Info(
//         id: json['id'],
//         userName: json['userName'],
//         account: json['account'],
//         balance: json['balance']);
//   }
// }
