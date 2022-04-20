import 'dart:async';
import 'package:dayplan_it/screens/start/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/repository/user_repository.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool showProgress = false;
  final formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _password1Controller = TextEditingController();
  final _password2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SignupRepository _signupRepository = SignupRepository();
    return showProgress
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            body: SingleChildScrollView(
                child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: AlignmentDirectional(0, 0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 10, 0, 0),
                  child: Image.asset(
                    'assets/icons/loginpage_icon.png',
                    width: 0.8 * MediaQuery.of(context).size.width,
                    height: 0.15 * MediaQuery.of(context).size.height,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 40, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 200,
                        height: 100,
                        alignment: AlignmentDirectional(-1, 0),
                        child: Container(
                          child: Text(
                            'Sign in',
                            style: mainFont(
                                textStyle: const TextStyle(color: Colors.black),
                                fontWeight: FontWeight.w700,
                                fontSize: 45),
                          ),
                        ),
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(30, 0, 0, 0),
                  child: Row(
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
                  )),
              Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
                  child: Form(
                    key: formkey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 12.0),
                        TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                                filled: true,
                                labelText: 'Username',
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 5, 93, 164),
                                    )))),
                        SizedBox(height: 12.0),
                        TextField(
                            obscureText: true,
                            controller: _password1Controller,
                            decoration: InputDecoration(
                                filled: true,
                                labelText: 'Password',
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 5, 93, 164),
                                    )))),
                        SizedBox(height: 12.0),
                        TextField(
                            obscureText: true,
                            controller: _password2Controller,
                            decoration: InputDecoration(
                                filled: true,
                                labelText: 'Confirm Password',
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 5, 93, 164),
                                    )))),
                        SizedBox(height: 12.0),
                        TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                                filled: true,
                                labelText: 'Email',
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 5, 93, 164),
                                    )))),
                        SizedBox(height: 12.0),
                        TextField(
                            controller: _nicknameController,
                            decoration: InputDecoration(
                                filled: true,
                                labelText: 'Nickname',
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 5, 93, 164),
                                    )))),
                        SizedBox(height: 12.0),
                        TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                                filled: true,
                                labelText: 'Phone',
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 5, 93, 164),
                                    )))),
                        ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text('CANCEL'),
                              onPressed: () {
                                _usernameController.clear();
                                _password1Controller.clear();
                                _password2Controller.clear();
                                _emailController.clear();
                                _nicknameController.clear();
                                _phoneController.clear();
                              },
                            ),
                            RaisedButton(
                              child: Text('NEXT'),
                              onPressed: () {
                                Future<String> tempp =
                                    _signupRepository.sendSignup(
                                  _usernameController.text,
                                  _password1Controller.text,
                                  _password2Controller.text,
                                  _emailController.text,
                                  _nicknameController.text,
                                  _phoneController.text,
                                );
                                tempp.then((val) {
                                  if (val == '200') {
                                    setState(() {
                                      showProgress = false;
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()));
                                  } else {
                                    FlutterDialog();
                                  }

                                  // int가 나오면 해당 값을 출력
                                }).catchError((error) {
                                  setState(() {
                                    showProgress = false;
                                  });
                                  print(error.toString());

                                  FlutterDialog();
                                });

                                setState(() {
                                  showProgress = true;
                                });
                                // stat.then((val) {
                                //   if (val != 200) {
                                //     FlutterDialog();
                                //   } else {
                                //     Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //             builder: (context) => SuccessSignupScreen(
                                //                 _usernameController.text)));
                                //   }
                                // }).catchError((error) {
                                //   FlutterDialog();
                                // });
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
            ],
          )));
  }

  void FlutterDialog() {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Column(
              children: <Widget>[
                new Text("오류"),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "오류발생(예외종류에 대한 처리는 yet~)",
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void SignupSucessMessage() {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Column(
              children: <Widget>[
                new Text("회원가입성공"),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "이메일 인증을 완료해주세요!",
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("확인"),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          );
        });
  }
}
