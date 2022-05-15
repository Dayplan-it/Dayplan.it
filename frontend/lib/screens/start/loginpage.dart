import 'package:dayplan_it/screens/start/components/loginform.dart';
import 'package:dayplan_it/screens/start/components/loginheader.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 100, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                //로그인 Header
                LoginHeader(),
                //로그인 Form
                LoginForm(),
              ],
            )));
  }
}
