import 'package:dayplan_it/constants.dart';
import 'package:dayplan_it/screens/start/components/user_repository.dart';
import 'package:dayplan_it/screens/start/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:dayplan_it/screens/start/components/dialog.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  State<SignupForm> createState() => _SignupFormState();
}

///@회원가입폼 컴포넌트
class _SignupFormState extends State<SignupForm> {
  ///text필드 스타일
  DayplanitStyles dayplanitStyles = DayplanitStyles();

  ///회원가입dio http통신을 위한 레포지토리
  final SignupRepository _signupRepository = SignupRepository();

  //오류, 메세지를 위한 dialog클래스
  final StartPageDialog dialog = StartPageDialog();

  ///로딩중표시 state
  bool showProgress = false;

  ///Form관련
  final formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _password1Controller = TextEditingController();
  final _password2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return showProgress
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: formkey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 12.0),
                dayplanitStyles.getTextField(
                    _usernameController, false, 'Username'),
                const SizedBox(height: 12.0),
                dayplanitStyles.getTextField(
                    _password1Controller, true, 'Password'),
                const SizedBox(height: 12.0),
                dayplanitStyles.getTextField(
                    _password2Controller, true, 'Confirm password'),
                const SizedBox(height: 12.0),
                dayplanitStyles.getTextField(_emailController, false, 'Email'),
                const SizedBox(height: 12.0),
                dayplanitStyles.getTextField(
                    _nicknameController, false, 'nickname'),
                const SizedBox(height: 12.0),
                dayplanitStyles.getTextField(_phoneController, false, 'Phone'),
                ButtonBar(
                  children: <Widget>[
                    TextButton(
                      child: const Text('CANCEL'),
                      onPressed: () {
                        _usernameController.clear();
                        _password1Controller.clear();
                        _password2Controller.clear();
                        _emailController.clear();
                        _nicknameController.clear();
                        _phoneController.clear();
                      },
                    ),
                    ElevatedButton(
                      child: const Text('NEXT'),
                      onPressed: () {
                        Future<String> tempp = _signupRepository.sendSignup(
                          _usernameController.text,
                          _password1Controller.text,
                          _password2Controller.text,
                          _emailController.text,
                          _nicknameController.text,
                          _phoneController.text,
                        );

                        ///tempp의 응답이 200일때 회원가입성공 dialog띄우고 로그인페이지로이동
                        tempp.then((val) {
                          if (val == '200') {
                            setState(() {
                              showProgress = false;
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()));
                            dialog.signupSuccessDialog(context);
                            //status가 200이 아닐때 에러 메세지
                          } else {
                            dialog.signupErrorDialog(context);
                          }

                          //예외발생시 에러메세지
                        }).catchError((error) {
                          setState(() {
                            showProgress = false;
                          });
                          dialog.signupErrorDialog(context);
                        });

                        setState(() {
                          showProgress = true;
                        });
                      },
                    )
                  ],
                ),
              ],
            ),
          );
  }
}
