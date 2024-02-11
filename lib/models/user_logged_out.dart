import 'dart:convert';

import 'package:busfeed_driver/models/user.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';

class UserLoggedOut {
  final String email;

  UserLoggedOut({required this.email});

  Future<User> login({required String password}) async {
    final url = Uri.https(API_URL, 'api/login');
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
      throw Exception('Login Failed: ${response.body}');
    }
    var responseBody = jsonDecode(response.body)['data'];
    return User(
        id: responseBody['id'].toString(),
        email: email,
        appId: responseBody['app_id'].toString(),
        authorization: response.headers['authorization']!);
  }
}
