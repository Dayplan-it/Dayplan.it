import 'package:dayplan_it/constants.dart';
import 'package:flutter/material.dart';

///startpage dialog를 위한 클래스
class StartPageDialog {
  DayplanitStyles dayplanitStyle = DayplanitStyles();

  ///로그인예외
  ///input - CONTEXT
  ///output - ErrorDialog
  void loginErrorDialog(context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return dayplanitStyle.getAlertDialog(
              context, '착륙 실패 🚀 💣', '아이디 또는 비밀번호를 잘못 입력하셨습니다.');
        });
  }

  //회원가입예외
  ///input - CONTEXT
  ///output - ErrorDialog
  void signupErrorDialog(context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return dayplanitStyle.getAlertDialog(
              context, '착륙 실패 🚀 💣', '회원정보가 잘못 입력됐습니다.');
        });
  }

  //회원가입성공메세지
  ///input - CONTEXT
  ///output - SuccessDialog
  void signupSuccessDialog(context) {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return dayplanitStyle.getAlertDialog(
              context, '성공적으로 착륙! 🚀💯', '회원가입에 성공하였습니다. 어서 오세요!');
        });
  }
}
