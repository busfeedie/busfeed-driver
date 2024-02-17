import 'package:busfeed_driver/models/user.dart';
import 'package:busfeed_driver/models/user_logged_out.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String userEmailKey = 'userEmail';
const String userAuthKey = 'userAuthorization';
const String userIdKey = 'userId';
const String userAppId = 'userAppId';

abstract class UserCommon {
  final String email;
  static const storage = FlutterSecureStorage();

  UserCommon({required this.email});

  bool get authenticated => false;

  static Future<bool> anyUserInStorage() async {
    return (await storedEmail) != null;
  }

  static Future<String?> get storedEmail async {
    return storage.read(key: userEmailKey);
  }

  static Future<bool> authenticatedUserInStorage() async {
    return (await storage.read(key: userAuthKey)) != null;
  }

  static Future<UserCommon?> loadFromStorage() async {
    if (await anyUserInStorage()) {
      if (await authenticatedUserInStorage()) {
        try {
          return User.loadFromStorage();
        } catch (e) {
          return UserLoggedOut(email: (await storedEmail)!);
        }
      }
      return UserLoggedOut(email: (await storedEmail)!);
    }
    return null;
  }
}
