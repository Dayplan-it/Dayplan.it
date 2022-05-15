import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/start/components/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:dayplan_it/screens/start/components/dialog.dart';
import 'package:dayplan_it/screens/mainpage.dart';
import 'package:dayplan_it/screens/start/signuppage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  DayplanitStyles dayplanitStyles = DayplanitStyles();
  bool showProgress = false;
  final formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginRepository _loginRepository = LoginRepository();
  final StartPageDialog dialog = StartPageDialog();

  @override
  Widget build(BuildContext context) {
    return showProgress
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              const CircularProgressIndicator(
                color: primaryColor,
              ),
              Text(
                "착륙중...🚀",
                style: mainFont(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
              )
            ],
          )
        : Form(
            key: formkey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 50.0),
                dayplanitStyles.getTextField(
                    _usernameController, false, 'Email'),
                const SizedBox(height: 20),
                dayplanitStyles.getTextField(
                    _passwordController, true, 'Password'),
                ButtonBar(
                  children: <Widget>[
                    //폼의 모든내용을 지우는 CANCEL버튼
                    TextButton(
                      child: Text(
                        '모두 지우기',
                        style: mainFont(
                            color: primaryColor, fontWeight: FontWeight.w500),
                      ),
                      onPressed: () {
                        _usernameController.clear();
                        _passwordController.clear();
                        if (FocusScope.of(context).hasFocus) {
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                    //회원가입요청을 보내는 버튼
                    ElevatedButton(
                      child: const Text(
                        '로그인',
                      ),
                      style: ElevatedButton.styleFrom(
                          textStyle: mainFont(fontWeight: FontWeight.w600),
                          primary: primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () async {
                        Future<List<dynamic>> responseLogin =
                            _loginRepository.loadToken(_usernameController.text,
                                _passwordController.text);
                        //일단 토큰을 서버에서 받아오기 전까지 로딩창 띄우기
                        responseLogin.then((val) async {
                          if (val[1] == 200) {
                            setState(() {
                              showProgress = false;
                            });
                            //토큰을 로컬디바이스에 저장한다.
                            _savelocaltoken(val[0]);
                            //로그인 성공시 메인페이지로 이동
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MainPage()));
                          } else {
                            dialog.loginErrorDialog(context);
                          }
                        }).catchError((error) {
                          setState(() {
                            showProgress = false;
                          });
                          dialog.loginErrorDialog(context);
                        });

                        setState(() {
                          showProgress = true;
                        });
                      },
                    )
                  ],
                ),
                ButtonBar(children: <Widget>[
                  ElevatedButton(
                    child: const Text('회원가입'),
                    style: ElevatedButton.styleFrom(
                        textStyle: mainFont(fontWeight: FontWeight.w600),
                        primary: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupPage()));
                    },
                  )
                ])
              ],
            ),
          );
  }

  ///로컬에 토큰을 저장하는 함수
  ///input - (String)token
  ///output - void
  void _savelocaltoken(token) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('apiToken', token);
  }
}
