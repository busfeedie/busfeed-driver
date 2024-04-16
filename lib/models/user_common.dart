import 'package:busfeed_driver/models/user.dart';
import 'package:busfeed_driver/models/user_logged_out.dart';

import '../helpers/storage.dart';

const String userEmailKey = 'userEmail';
const String userAuthKey = 'userAuthorization';
const String userIdKey = 'userId';
const String userAppId = 'userAppId';
const String userLocationPermission = 'userLocationPermission';

abstract class UserCommon {
  final String email;
  bool locationPermission = false;
  static LocalStorage secureStorage = LocalStorage();

  UserCommon({required this.email, this.locationPermission = false});

  bool get authenticated => false;

  static Future<bool> anyUserInStorage() async {
    return (await storedEmail) != null;
  }

  static Future<String?> get storedEmail async {
    return secureStorage.read(key: userEmailKey);
  }

  static Future<String?> get storedLocationPermission async {
    return secureStorage.read(key: userLocationPermission);
  }

  static Future<bool> authenticatedUserInStorage() async {
    return (await secureStorage.read(key: userAuthKey)) != null;
  }

  writeLocationPermissionToStore() async {
    await UserCommon.secureStorage.write(
        key: userLocationPermission,
        value: locationPermission ? 'true' : 'false');
  }

  static Future<UserCommon?> loadFromStorage() async {
    try {
      if (await anyUserInStorage()) {
        if (await authenticatedUserInStorage()) {
          try {
            return User.loadFromStorage();
          } catch (e) {
            return UserLoggedOut(
                email: (await storedEmail)!,
                locationPermission: (await storedLocationPermission) == 'true');
          }
        }
        return UserLoggedOut(
            email: (await storedEmail)!,
            locationPermission: (await storedLocationPermission) == 'true');
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
