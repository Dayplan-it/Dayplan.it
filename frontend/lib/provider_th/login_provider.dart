import 'package:flutter/material.dart';
import 'package:dayplan_it/repository/user_repository.dart';

class LoginProvider extends ChangeNotifier {
  LoginRepository _loginRepository = LoginRepository();
  String _token = "null";
  String get token => _token;
  loadToken(emaill, pass) async {
    String temp = await _loginRepository.loadToken(emaill, pass);
    _token = temp;
    notifyListeners();
    //리파지토리 접근해서  데이터불라오기
  }
}
