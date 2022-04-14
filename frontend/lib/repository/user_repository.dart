import 'package:dio/dio.dart';

class LoginRepository {
  Future<String> loadToken(emaill, pass) async {
    var dio = Dio();
    var token = "null";
    var url = 'http://127.0.0.1:8000/users/login';
    Map data = {'email': emaill, 'password': pass};
    try {
      Response response = await dio.post(url, data: data);
      var token = response.data["token"];
      return token;
    } catch (e) {
      //에러발생시
    }
    return token;
  }
}

class SignupRepository {
  Future<String> sendSignup(
      name, password1, password2, email, nickname, phone) async {
    var dio = Dio();
    var token = "null";
    var url = 'http://127.0.0.1:8000/users/signup';
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
