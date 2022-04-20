import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 앱에서 사용할 색상
const primaryColor = Color.fromARGB(255, 1, 87, 141); // Dayplan.it 파랑
const pointColor = Color.fromARGB(255, 210, 55, 55); // 포인트컬러
const subTextColor = Color.fromARGB(255, 175, 169, 169); // 회색조 컬러
const defaultTextColor = Colors.black;
const backgroundColor = Colors.white;
const DayplanitLogoFont = GoogleFonts.poppins; // 로고용 폰트
const mainFont = GoogleFonts.notoSans;
const double dafaultPadding = 20.0;
const commonUrl = 'http://127.0.0.1';

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
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 5, 93, 164),
                ))));
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
