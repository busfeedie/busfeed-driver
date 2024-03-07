import 'dart:convert';

import 'package:busfeed_driver/helpers/api.dart';
import 'package:busfeed_driver/helpers/storage.dart';
import 'package:busfeed_driver/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/flutter_secure_storage.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    LocalStorage().setMockStoreForTest(MockFlutterSecureStorage());
  });

  testWidgets('Main shows login page by default', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Busfeed'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
  group('user is logged in with routes', () {
    var store = MockFlutterSecureStorage();
    setUp(() {
      HttpClient().setMockClientForTest(MockClient((request) async {
        if (request.url.path == 'api/routes') {
          final mapJson = [
            {
              'id': 123,
              'app_id': 'test',
              'gtfs_route_id': 'test',
              'agency_id': 'test',
              'route_short_name': 'short name',
              'route_long_name': 'long name',
            }
          ];
          return Response(json.encode(mapJson), 200);
        }
        final mapJson = {'error': "not found"};
        return Response(json.encode(mapJson), 404);
      }));
      store = MockFlutterSecureStorage();
      when(store.read(key: 'userAuthorization'))
          .thenAnswer((_) async => 'Bearer test');
      when(store.read(key: 'userEmail'))
          .thenAnswer((_) async => 'example@busfeed.ie');
      when(store.read(key: 'userId')).thenAnswer((_) async => '1');
      when(store.read(key: 'userAppId')).thenAnswer((_) async => '1');
      LocalStorage().setMockStoreForTest(store);
    });
    testWidgets('shows routes page', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('Busfeed'), findsOneWidget);
      expect(find.text('short name'), findsOneWidget);
    });
    testWidgets('does not fail if store fails', (tester) async {
      when(store.read(key: 'userEmail')).thenThrow(ArgumentError());
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('Busfeed'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });
  });
  group('routes returns not authorized', () {
    setUp(() {
      HttpClient().setMockClientForTest(MockClient((request) async {
        if (request.url.path == 'api/routes') {
          return Response(json.encode({'error': "signature expired"}), 401);
        }
        final mapJson = {'error': "not found"};
        return Response(json.encode(mapJson), 404);
      }));
      var store = MockFlutterSecureStorage();
      when(store.read(key: 'userAuthorization'))
          .thenAnswer((_) async => 'Bearer test');
      when(store.read(key: 'userEmail'))
          .thenAnswer((_) async => 'example@busfeed.ie');
      when(store.read(key: 'userId')).thenAnswer((_) async => '1');
      when(store.read(key: 'userAppId')).thenAnswer((_) async => '1');
      LocalStorage().setMockStoreForTest(store);
    });
    testWidgets('returns to login page', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('Busfeed'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });
  });
}
