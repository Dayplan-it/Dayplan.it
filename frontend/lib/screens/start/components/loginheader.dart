import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Image.asset(
          'assets/icons/loginpage_icon.png',
          width: 0.8 * MediaQuery.of(context).size.width,
          height: 0.15 * MediaQuery.of(context).size.height,
          fit: BoxFit.fitWidth,
        ),
        Row(
          children: [
            Text(
              'Sign in',
              style: mainFont(
                  textStyle: const TextStyle(color: Colors.black),
                  fontWeight: FontWeight.w700,
                  fontSize: 45),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              '로그인을 해주세요!',
              style: mainFont(
                  textStyle: const TextStyle(
                      color: Color.fromARGB(255, 124, 124, 124)),
                  fontSize: 20),
            )
          ],
        ),
      ],
    ));
  }
}
