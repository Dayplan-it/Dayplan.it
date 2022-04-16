import 'package:flutter/material.dart';
import 'package:dayplan_it/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  String _token = "null";
  String get token => _token;

  //리파지토리 접근해서  데이터불라오기
  void setToken(token) {
    _token = token;
    savelocaltoken(_token);
    notifyListeners();
  }

  void savelocaltoken(token) async {
    print("토큰저장");
    var prefs = await SharedPreferences.getInstance();
    // Set
    prefs.setString('apiToken', token);
    print(prefs.getString('apiToken'));
    // Get
    //String token = prefs.getString('apiToken');
  }
}
