import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api.dart';
import '../models/user.dart';

class HttpClient {
  static final HttpClient _singleton = HttpClient._internal();

  var _client = http.Client();

  factory HttpClient() {
    return _singleton;
  }

  HttpClient._internal();

  setMockClientForTest(client) {
    _client = client;
  }

  Future<dynamic> makeRequest(
      {required User user,
      required String path,
      Map<String, String>? queryParameters}) async {
    final url = Uri.https(API_URL, path, queryParameters);
    http.Response? response;
    try {
      response = await _client.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': user.authorization,
        },
      );
    } catch (e) {
      if (response?.statusCode == 401) {
        user.expired = true;
      } else {
        rethrow;
      }
    }
    if (response == null) {
      throw Exception('Failed to send request');
    } else if (response.statusCode == 401) {
      user.expired = true;
    } else if (response.statusCode != 200) {
      throw Exception('Failed to send request');
    }
    if (response.headers['authorization'] != null) {
      user.authorization = response.headers['authorization']!;
    }
    return jsonDecode(response.body);
  }

  Future<dynamic> makePostRequest(
      {required User user,
      required String path,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? body}) async {
    final url = Uri.https(API_URL, path, queryParameters);
    final response = await _client.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': user.authorization,
        },
        body: json.encode(body));
    if (response.statusCode == 401) {
      user.expired = true;
    } else if (response.statusCode != 200) {
      throw Exception('Failed to send request');
    }
    if (response.headers['authorization'] != null) {
      user.authorization = response.headers['authorization']!;
    }
    var responseBody = jsonDecode(response.body);
    return responseBody;
  }
}
