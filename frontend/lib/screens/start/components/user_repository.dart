import 'package:dio/dio.dart';
import 'package:dayplan_it/constants.dart';

class LoginRepository {
  Future<List<dynamic>> loadToken(emaill, pass) async {
    var dio = Dio();
    var url = '$commonUrl:8000/users/login';
    Map data = {'email': emaill, 'password': pass};
    Response response = await dio.post(url, data: data);
    return [response.data["token"].toString(), response.statusCode];
  }
}

class SignupRepository {
  Future<String> sendSignup(
      name, password1, password2, email, nickname, phone) async {
    var dio = Dio();

    var url = '$commonUrl:8000/users/signup';
    Map data = {
      'username': name,
      'password1': password1,
      'password2': password2,
      'email': email,
      'nickname': nickname,
      'phone': phone,
    };

    Response response = await dio.post(url, data: data);
    return response.statusCode.toString();
  }
}
