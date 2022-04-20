import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(5, 10, 0, 0),
            child: Image.asset(
              'assets/icons/loginpage_icon.png',
              width: 0.8 * MediaQuery.of(context).size.width,
              height: 0.15 * MediaQuery.of(context).size.height,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 200,
              height: 100,
              alignment: const AlignmentDirectional(-1, 0),
              child: Text(
                'Sign in',
                style: mainFont(
                    textStyle: const TextStyle(color: Colors.black),
                    fontWeight: FontWeight.w700,
                    fontSize: 45),
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              '회원정보를 입력해주세요!',
              style: mainFont(
                  textStyle: const TextStyle(
                      color: Color.fromARGB(255, 124, 124, 124)),
                  fontSize: 20),
            )
          ],
        ),
      ],
    );
  }
}
