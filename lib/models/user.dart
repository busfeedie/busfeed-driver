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
      required String authorization,
      this.userExpiryCallback,
      super.locationPermission}) {
    _authorization = authorization;
  }

  static Future<User?> loadFromStorage() async {
    try {
      return User(
        email: (await UserCommon.storedEmail)!,
        authorization: (await storedAuth)!,
        id: (await storedId)!,
        appId: (await storedAppId)!,
        locationPermission:
            (await UserCommon.storedLocationPermission) == 'true',
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
    await writeLocationPermissionToStore();
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
    return UserCommon.secureStorage.read(key: userAuthKey);
  }

  static Future<String?> get storedId async {
    return UserCommon.secureStorage.read(key: userIdKey);
  }

  static Future<String?> get storedAppId async {
    return UserCommon.secureStorage.read(key: userAppId);
  }

  writeEmailToStore() async {
    await UserCommon.secureStorage.write(key: userEmailKey, value: email);
  }

  writeAuthToStore() async {
    await UserCommon.secureStorage
        .write(key: userAuthKey, value: authorization);
  }

  writeIdToStore() async {
    await UserCommon.secureStorage.write(key: userIdKey, value: id);
  }

  writeAppIdToStore() async {
    await UserCommon.secureStorage.write(key: userAppId, value: appId);
  }
}
