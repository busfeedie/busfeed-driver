// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:busfeed_driver/helpers/api.dart';
import 'package:busfeed_driver/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/user.mocks.dart';

void main() {
  group('makeRequest', () {
    group('returns unauthorized', () {
      BusfeedApi api = BusfeedApi();
      setUp(() {
        api = BusfeedApi();
        api.client = MockClient((request) async {
          final mapJson = {'id': 123};
          return Response(json.encode(mapJson), 401);
        });
      });
      test("User is marked as expired", () async {
        User user = User(
            id: "test",
            email: "test@busfeed.ie",
            appId: "test",
            authorization: "Bearer test");
        final response = await api.makeRequest(user: user, path: 'api/routes');
        expect(user.expired, true);
        expect(response, {'id': 123});
      });
      test("User expiry method is called", () async {
        User user = MockUser();
        await api.makeRequest(user: user, path: 'api/routes');
        verify(user.expired = true);
      });
    });
  });
  group('makePostRequest', () {
    group('returns unauthorized', () {
      BusfeedApi api = BusfeedApi();
      setUp(() {
        api = BusfeedApi();
        api.client = MockClient((request) async {
          final mapJson = {'id': 123};
          return Response(json.encode(mapJson), 401);
        });
      });
      test("User is marked as expired", () async {
        User user = User(
            id: "test",
            email: "test@busfeed.ie",
            appId: "test",
            authorization: "Bearer test");
        final response =
            await api.makePostRequest(user: user, path: 'api/routes');
        expect(user.expired, true);
        expect(response, {'id': 123});
      });
      test("User expiry method is called", () async {
        User user = MockUser();
        await api.makePostRequest(user: user, path: 'api/routes');
        verify(user.expired = true);
      });
    });
  });
}
