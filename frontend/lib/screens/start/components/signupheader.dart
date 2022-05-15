import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Image.asset(
            'assets/icons/dayplanit_icon_blue.png',
            width: 60,
            fit: BoxFit.fitWidth,
          ),
        ),
        Text(
          'Sign up',
          style: mainFont(
              textStyle: const TextStyle(color: Colors.black),
              fontWeight: FontWeight.w700,
              fontSize: 25),
        ),
        Text(
          '회원정보를 입력해주세요!',
          style: mainFont(
              textStyle:
                  const TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
              fontSize: 20),
        )
      ],
    );
  }
}
