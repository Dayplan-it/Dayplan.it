import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/icons/loginpage_icon.png',
          width: 0.8 * MediaQuery.of(context).size.width,
          height: 0.15 * MediaQuery.of(context).size.height,
          fit: BoxFit.fitWidth,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const SizedBox(width: 30),
              Text(
                'Sign in',
                style: mainFont(
                    textStyle: const TextStyle(color: Colors.black),
                    fontWeight: FontWeight.w700,
                    fontSize: 45),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const SizedBox(width: 30),
              Text(
                '로그인을 해주세요!',
                style: mainFont(
                    textStyle: const TextStyle(
                        color: Color.fromARGB(255, 124, 124, 124)),
                    fontSize: 20),
              )
            ],
          ),
        ),
      ],
    );
  }
}
