import 'dart:convert';

import 'package:busfeed_driver/models/user.dart';
import 'package:busfeed_driver/models/user_common.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';

class UserLoggedOut extends UserCommon {
  UserLoggedOut({required super.email});

  Future<User> login(
      {required String password, String path = 'users/sign_in'}) async {
    final url = Uri.https(API_URL, path);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "user": {
          'password': password,
          'email': email,
        }
      }),
    );
    if (response.statusCode != 200) {
      if (path != 'api/login') {
        return login(password: password, path: 'api/login');
      }
      throw Exception('Login Failed: ${response.body}');
    }
    var responseBody = jsonDecode(response.body)['data'];
    var user = User(
        id: responseBody['id'].toString(),
        email: email,
        appId: responseBody['app_id'].toString(),
        authorization: response.headers['authorization']!);
    user.writeToStore();
    return user;
  }
}
