import 'package:busfeed_driver/helpers/storage.dart';
import 'package:busfeed_driver/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/flutter_secure_storage.mocks.dart';

void main() {
  group('authorization', () {
    test('returns the correct authorization', () {
      User user = User(
          id: "test", email: "", appId: 'test', authorization: "Bearer test");
      expect(user.authorization, "Bearer test");
    });
    test('setting the authorization updates its value', () {
      var storageMock = MockFlutterSecureStorage();
      LocalStorage().setMockStoreForTest(storageMock);
      User user = User(
          id: "test", email: "", appId: 'test', authorization: "Bearer test");
      expect(user.authorization, "Bearer test");
      user.authorization = "Bearer 123";
      expect(user.authorization, "Bearer 123");
      verify(storageMock.write(key: 'userAuthorization', value: 'Bearer 123'))
          .called(1);
    });
  });
  group('expired', () {
    test('returns the expired value', () {
      User user = User(
          id: "test", email: "", appId: 'test', authorization: "Bearer test");
      expect(user.expired, false);
    });
    test('setting expired to false does not call the callback', () {
      var callbackCalled = false;
      expiryCallback() {
        callbackCalled = true;
      }

      User user = User(
          id: "test",
          email: "",
          appId: 'test',
          authorization: "Bearer test",
          userExpiryCallback: expiryCallback);
      expect(user.expired, false);
      user.expired = false;
      expect(user.expired, false);
      expect(callbackCalled, false);
    });
    test('setting expired to true calls the callback', () {
      var callbackCalled = false;
      expiryCallback() {
        callbackCalled = true;
      }

      User user = User(
          id: "test",
          email: "",
          appId: 'test',
          authorization: "Bearer test",
          userExpiryCallback: expiryCallback);
      expect(user.expired, false);
      user.expired = true;
      expect(user.expired, true);
      expect(callbackCalled, true);
    });
  });
}
