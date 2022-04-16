import 'package:dayplan_it/provider_th/login_provider.dart';
import 'package:dayplan_it/screens/start/signuppage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dayplan_it/constants.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:dayplan_it/screens/mainpage.dart';
import 'package:provider/provider.dart';
import 'package:dayplan_it/repository/user_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginProvider _loginProvider = new LoginProvider();
  bool showProgress = false;
  final formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _loginProvider = Provider.of<LoginProvider>(context, listen: false);
    LoginRepository _loginRepository = LoginRepository();

    return Scaffold(body: Consumer<LoginProvider>(
        builder: (BuildContext context, provider, widget) {
      //데이터가 Null일떄 로딩화면

      return Container(
          child: showProgress
              ? Center(child: CircularProgressIndicator())
              : Column(
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
                        padding: EdgeInsetsDirectional.fromSTEB(30, 40, 0, 0),
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
                                      textStyle:
                                          const TextStyle(color: Colors.black),
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
                              '로그인을 해주세요!',
                              style: mainFont(
                                  textStyle: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 124, 124, 124)),
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
                              SizedBox(height: 70.0),
                              TextField(
                                controller: _usernameController,
                                style: TextStyle(
                                  height: 1.5,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  labelText: 'Email',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 5, 93, 164),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _passwordController,
                                style: TextStyle(
                                  height: 1.5,
                                ),
                                decoration: InputDecoration(
                                    filled: true,
                                    labelText: 'Password',
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(
                                        color: Color.fromARGB(255, 5, 93, 164),
                                      ),
                                    )),
                                obscureText: true,
                              ),
                              ButtonBar(
                                children: <Widget>[
                                  FlatButton(
                                    child: Text('CANCEL'),
                                    onPressed: () {
                                      _usernameController.clear();
                                      _passwordController.clear();
                                    },
                                  ),
                                  RaisedButton(
                                    child: Text('NEXT'),
                                    onPressed: () async {
                                      Future<List<String>> response_login =
                                          _loginRepository.loadToken(
                                              _usernameController.text,
                                              _passwordController.text);
                                      //일단 토큰을 서버에서 받아오기 전까지 로딩창 띄우기
                                      response_login.then((val) {
                                        if (val[1] == '200') {
                                          setState(() {
                                            showProgress = false;
                                          });
                                          Provider.of<LoginProvider>(context,
                                                  listen: false)
                                              .setToken(val[0]
                                                  .toString()); // Provider.of<Counter>(context, listen: false) 사용.

                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MainPage()));
                                        } else {
                                          FlutterDialog();
                                        }

                                        // int가 나오면 해당 값을 출력
                                      }).catchError((error) {
                                        setState(() {
                                          showProgress = false;
                                        });
                                        FlutterDialog();
                                      });

                                      setState(() {
                                        showProgress = true;
                                      });
                                    },
                                  )
                                ],
                              ),
                              Center(
                                child: ButtonBar(
                                  children: <Widget>[
                                    FlatButton(
                                      child: Text('회원가입'),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SignupPage()));
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )),
                  ],
                ));
    }));
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
                  "오류발생(예외종류 구분필요), 이메일인증안했거나, 서버통신 잘못됬거나, 중복된이름,이메일,전화번호가있거나 등등 가능성",
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
}
