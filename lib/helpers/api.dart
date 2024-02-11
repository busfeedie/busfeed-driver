import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api.dart';
import '../models/user.dart';

class BusfeedApi {
  static Future<dynamic> makeRequest(
      {required User user,
      required String path,
      Map<String, String>? queryParameters}) async {
    final url = Uri.https(API_URL, path, queryParameters);
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': user.authorization,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch');
    }
    if (response.headers['authorization'] != null) {
      user.authorization = response.headers['authorization']!;
    }
    var responseBody = jsonDecode(response.body);
    return responseBody;
  }

  static Future<dynamic> makePostRequest(
      {required User user,
      required String path,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? body}) async {
    final url = Uri.https(API_URL, path, queryParameters);
    final response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': user.authorization,
        },
        body: json.encode(body));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch');
    }
    if (response.headers['authorization'] != null) {
      user.authorization = response.headers['authorization']!;
    }
    var responseBody = jsonDecode(response.body);
    return responseBody;
  }
}
