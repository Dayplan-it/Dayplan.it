import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// 앱에서 사용할 색상
const primaryColor = Color.fromARGB(255, 1, 87, 141); // Dayplan.it 파랑
const pointColor = Color.fromARGB(255, 210, 55, 55); // 포인트컬러
const subTextColor = Color.fromARGB(255, 150, 150, 150); // 회색조 컬러
const defaultTextColor = Colors.black;
const backgroundColor = Colors.white;
const skyBlue = Color.fromARGB(255, 203, 235, 255);
const DayplanitLogoFont = GoogleFonts.poppins; // 로고용 폰트

// class MainFont extends TextStyle {
//   super.fontFamily = 'Noto_Sans_KR';
// }

const mainFont = GoogleFonts.notoSans;

const double titleSize = 20;
const double subtitleSize = 15;

const double dafaultPadding = 20.0;

const List placeTypes = [
  ['cafe', '카페', Color.fromARGB(255, 134, 98, 6), FontAwesomeIcons.mugSaucer],
  ['restaurant', '식당', Color.fromARGB(255, 215, 154, 11), Icons.restaurant],
  [
    'department_store',
    '백화점',
    Color.fromARGB(255, 190, 34, 156),
    FontAwesomeIcons.bagShopping
  ],
  ['drugstore', '약국', Color.fromARGB(255, 68, 34, 190), FontAwesomeIcons.pills],
  //['pharmacy', '약국2'],
  ['gym', '헬스장', Color.fromARGB(255, 111, 184, 183), FontAwesomeIcons.dumbbell],
  [
    'hospital',
    '병원',
    Color.fromARGB(255, 200, 56, 116),
    FontAwesomeIcons.hospital
  ],
  [
    'convenience_store',
    '편의점',
    Color.fromARGB(255, 121, 189, 104),
    FontAwesomeIcons.store
  ],
  [
    'supermarket',
    '마트',
    Color.fromARGB(255, 169, 34, 190),
    Icons.local_grocery_store
  ],
  [
    'laundry',
    '세탁소',
    Color.fromARGB(255, 126, 208, 233),
    Icons.local_laundry_service
  ],
  [
    'bowling_alley',
    '볼링장',
    Color.fromARGB(255, 190, 144, 34),
    FontAwesomeIcons.bowlingBall
  ],
  ['church', '교회', Color.fromARGB(255, 34, 190, 154), FontAwesomeIcons.church],
  [
    'post_office',
    '우체국',
    Color.fromARGB(255, 178, 32, 34),
    Icons.local_post_office
  ],
  ['car_wash', '세차장', Color.fromARGB(255, 34, 42, 190), Icons.local_car_wash],
  ['car_repair', '정비소', Color.fromARGB(255, 62, 60, 54), Icons.car_repair],
  ['police', '경찰', Color.fromARGB(255, 34, 63, 190), Icons.local_police],
];
