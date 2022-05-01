import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _hasToken = false; //토큰의 유무 판별하는 state
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  ///@brief 로컬 토큰 유무 검사 후 페이지 이동
  ///@return void
  ///@param void
  _checkToken() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasToken = (_prefs.getString('apiToken') == null ? false : true);
    });

    if (_hasToken == false) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [Color(0xFF01578D), Color(0xFF80AFCC)],
        stops: [0, 1],
        begin: AlignmentDirectional(1, -1),
        end: AlignmentDirectional(-1, 1),
      )),
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/landingpage_icon.png',
              width: 500,
              height: 200,
              fit: BoxFit.fitHeight,
            ),
            const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ]),
    );
  }
}
