import 'package:dayplan_it/screens/start/components/signupform.dart';
import 'package:dayplan_it/screens/start/components/signupheader.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 100, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    //회원가입페이지 header
                    SignupHeader(),
                    //회원가입폼
                    SignupForm(),
                  ],
                ))));
  }
}
