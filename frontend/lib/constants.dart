import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
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
const double dafaultPadding = 20.0;

/// 공통컴포넌트 스타일
class DayplanitStyles {
  ///TextFieldStyle(폼에서 텍스트필드의 스타일)
  ///input - 텍스트필드컨트롤러, 숨김여부, 라벨텍스트
  ///output - TextField
  TextField getTextField(controller, obscureText, labeText) {
    return TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          labelText: labeText,
          fillColor: const Color.fromARGB(255, 255, 255, 255),
          border: const UnderlineInputBorder(),
        ));
  }

  ///AlertDialog 스타일
  ///input - Context, 제목, 내용
  ///output - AlertDialog
  AlertDialog getAlertDialog(context, title, content) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      //Dialog Main Title
      title: Text(title),
      //
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            content,
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text("확인"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

const double titleSize = 20;
const double subtitleSize = 15;

const List placeTypes = [
  ['cafe', '카페', Color.fromARGB(255, 134, 98, 6), FontAwesomeIcons.mugSaucer],
  ['restaurant', '식당', Color.fromARGB(255, 215, 154, 11), Icons.restaurant],
  [
    'shopping_mall',
    '쇼핑',
    Color.fromARGB(255, 190, 34, 156),
    FontAwesomeIcons.bagShopping
  ],
  ['pharmacy', '약국', Color.fromARGB(255, 68, 34, 190), FontAwesomeIcons.pills],
  //['pharmacy', '약국2'],
  [
    'hospital',
    '병원',
    Color.fromARGB(255, 200, 56, 116),
    FontAwesomeIcons.hospital
  ],
  ['gym', '헬스장', Color.fromARGB(255, 111, 184, 183), FontAwesomeIcons.dumbbell],
  [
    'supermarket',
    '마트',
    Color.fromARGB(255, 169, 34, 190),
    Icons.local_grocery_store
  ],
  ['park', '공원', Color.fromARGB(255, 11, 173, 51), Icons.park_rounded],
  [
    'bowling_alley',
    '볼링장',
    Color.fromARGB(255, 115, 34, 190),
    FontAwesomeIcons.bowlingBall
  ],
  [
    'movie_theater',
    '영화관',
    Color.fromARGB(255, 34, 190, 154),
    Icons.theaters_rounded
  ],
  [
    'amusement_park',
    '놀이공원',
    Color.fromARGB(255, 34, 63, 190),
    Icons.attractions_rounded
  ],
  ['museum', '박물관', Color.fromARGB(255, 7, 127, 255), Icons.museum_rounded],
  ['library', '도서관', Color.fromARGB(255, 93, 1, 1), Icons.local_library],
  [
    'post_office',
    '우체국',
    Color.fromARGB(255, 178, 32, 34),
    Icons.local_post_office
  ],
  ['bank', '은행', Colors.amber, CupertinoIcons.money_dollar_circle_fill],
  [
    'laundry',
    '세탁소',
    Color.fromARGB(255, 126, 208, 233),
    Icons.local_laundry_service
  ],
  // ['car_wash', '세차장', Color.fromARGB(255, 34, 42, 190), Icons.local_car_wash],
  // ['car_repair', '정비소', Color.fromARGB(255, 62, 60, 54), Icons.car_repair],
  // 추후 자동차 서비스 하면 추가하는게 좋을듯
// ['accounting, '회계', , ],
// ['airport
// ['amusement_park
// ['aquarium
// ['art_gallery
// ['atm
// ['bakery
// ['bank
// ['bar
// ['beauty_salon
// ['bicycle_store
// ['book_store
// ['bowling_alley
// ['bus_station
// ['cafe
// ['campground
// ['car_dealer
// ['car_rental
// ['car_repair
// ['car_wash
// ['casino
// ['cemetery
// ['church
// ['city_hall
// ['clothing_store
// ['convenience_store
// ['courthouse
// ['dentist
// ['department_store
// ['doctor
// ['drugstore
// ['electrician
// ['electronics_store
// ['embassy
// ['fire_station
// ['florist
// ['funeral_home
// ['furniture_store
// ['gas_station
// ['gym
// ['hair_care
// ['hardware_store
// ['hindu_temple
// ['home_goods_store
// ['hospital
// ['insurance_agency
// ['jewelry_store
// ['laundry
// ['lawyer
// ['library
// ['light_rail_station
// ['liquor_store
// ['local_government_office
// ['locksmith
// ['lodging
// ['meal_delivery
// ['meal_takeaway
// ['mosque
// ['movie_rental
// ['movie_theater
// ['moving_company
// ['museum
// ['night_club
// ['painter
// ['park
// ['parking
// ['pet_store
// ['pharmacy
// ['physiotherapist
// ['plumber
// ['police
// ['post_office
// ['primary_school
// ['real_estate_agency
// ['restaurant
// ['roofing_contractor
// ['rv_park
// ['school
// ['secondary_school
// ['shoe_store
// ['shopping_mall
// ['spa
// ['stadium
// ['storage
// ['store
// ['subway_station
// ['supermarket
// ['synagogue
// ['taxi_stand
// ['tourist_attraction
// ['train_station
// ['transit_station
// ['travel_agency
// ['university
// ['veterinary_care
// ['zoo
];

final String commonUrl =
    Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';
