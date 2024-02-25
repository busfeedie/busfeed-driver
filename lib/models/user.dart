import 'user_common.dart';

class User extends UserCommon {
  final String id;
  final String appId;
  late String _authorization;
  bool _expired = false;
  Function()? userExpiryCallback;

  User(
      {required this.id,
      required super.email,
      required this.appId,
      required String authorization}) {
    _authorization = authorization;
  }

  static Future<User?> loadFromStorage() async {
    try {
      return User(
        email: (await UserCommon.storedEmail)!,
        authorization: (await storedAuth)!,
        id: (await storedId)!,
        appId: (await storedAppId)!,
      );
    } catch (e) {
      return null;
    }
  }

  writeToStore() async {
    await writeEmailToStore();
    await writeAuthToStore();
    await writeIdToStore();
    await writeAppIdToStore();
  }

  @override
  get authenticated {
    return !expired;
  }

  String get authorization {
    return _authorization;
  }

  set authorization(String value) {
    _authorization = value;
    writeAuthToStore();
  }

  bool get expired {
    return _expired;
  }

  set expired(bool value) {
    _expired = value;
    if (_expired && userExpiryCallback != null) {
      userExpiryCallback!();
    }
  }

  static Future<String?> get storedAuth async {
    return UserCommon.storage.read(key: userAuthKey);
  }

  static Future<String?> get storedId async {
    return UserCommon.storage.read(key: userIdKey);
  }

  static Future<String?> get storedAppId async {
    return UserCommon.storage.read(key: userAppId);
  }

  writeEmailToStore() async {
    await UserCommon.storage.write(key: userEmailKey, value: email);
  }

  writeAuthToStore() async {
    await UserCommon.storage.write(key: userAuthKey, value: authorization);
  }

  writeIdToStore() async {
    await UserCommon.storage.write(key: userIdKey, value: id);
  }

  writeAppIdToStore() async {
    await UserCommon.storage.write(key: userAppId, value: appId);
  }
}
