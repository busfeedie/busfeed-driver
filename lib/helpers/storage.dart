import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static final LocalStorage _singleton = LocalStorage._internal();

  var _storage = const FlutterSecureStorage();

  factory LocalStorage() {
    return _singleton;
  }

  LocalStorage._internal();

  setMockStoreForTest(store) {
    _storage = store;
  }

  Future<String?> read({required String key}) async {
    return _storage.read(key: key);
  }

  Future<void> write({required String key, required String value}) async {
    return _storage.write(key: key, value: value);
  }
}
