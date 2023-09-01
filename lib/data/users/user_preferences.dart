import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ts_one/data/users/users.dart';

class UserPreferences extends ChangeNotifier {
  UserPreferences({
    required this.preferences
  });

  final SharedPreferences preferences;

  static String keyIsLogin = "IS_LOGIN";
  static String keyUserID = "USER_ID";
  static String keyEmail = "EMAIL";
  static String keyName = "NAME";
  static String keyPhotoURL = "PHOTO_URL";
  static String keyStaffNo = "STAFF_NO";
  static String keyPosition = "POSITION";
  static String keySubPosition = "SUB_POSITION";
  static String keyLicenseNo = "LICENSE_NO";
  static String keyLicenseLastPassed = "LICENSE_LAST_PASSED";
  static String keyLicenseExpiry = "LICENSE_EXPIRY";
  static String keyPrivileges = "PRIVILEGES";

  void saveUser(UserAuth userAuth) {
    preferences.setBool(UserPreferences.keyIsLogin, true);
    preferences.setString(UserPreferences.keyUserID, userAuth.userCredential!.user!.uid);

    preferences.setString(UserPreferences.keyPhotoURL, userAuth.userCredential!.user!.photoURL.toString());
    String? photoUrl = preferences.getString(keyPhotoURL);
    if(photoUrl != null) {
      photoUrl = photoUrl.replaceAll("s96-c", "s384-c");
    }
    preferences.setString(UserPreferences.keyPhotoURL, photoUrl ?? "");

    preferences.setString(UserModel.keyEmail, userAuth.userCredential!.user!.email!);
    preferences.setString(UserModel.keyName, userAuth.userModel!.name);
    preferences.setInt(UserModel.keyIDNo, userAuth.userModel!.idNo);
    preferences.setString(UserModel.keyRank, userAuth.userModel!.rank);
    preferences.setStringList(UserModel.keyInstructor, userAuth.userModel!.instructor);
    preferences.setString(UserModel.keyLicenseNo, userAuth.userModel!.licenseNo);
    preferences.setString(UserModel.keyLicenseExpiry, userAuth.userModel!.licenseExpiry.toString());
    preferences.setStringList(UserModel.keyPrivileges, userAuth.userModel!.privileges);
    notifyListeners();
  }

  void clearUser() {
    preferences.setBool(UserPreferences.keyIsLogin, false);
    preferences.setString(UserPreferences.keyUserID, "");
    preferences.setString(UserPreferences.keyPhotoURL, "");

    preferences.setString(UserModel.keyEmail, "");
    preferences.setString(UserModel.keyName, "");
    preferences.setInt(UserModel.keyIDNo, 0);
    preferences.setString(UserModel.keyRank, "");
    preferences.setStringList(UserModel.keyInstructor, []);
    preferences.setString(UserModel.keyLicenseNo, "");
    preferences.setString(UserModel.keyLicenseExpiry, "");
    preferences.setStringList(UserModel.keyPrivileges, []);
    notifyListeners();
  }

  bool isLogin() {
    return preferences.getBool(UserPreferences.keyIsLogin) ?? false;
  }

  String getUserID() {
    return preferences.getString(UserPreferences.keyUserID) ?? "";
  }

  String getPhotoURL() {
    return preferences.getString(UserPreferences.keyPhotoURL) ?? "";
  }

  String getEmail() {
    return preferences.getString(UserModel.keyEmail) ?? "";
  }

  String getName() {
    return preferences.getString(UserModel.keyName) ?? "";
  }

  int getIDNo() {
    return preferences.getInt(UserModel.keyIDNo) ?? 0;
  }

  String getRank() {
    return preferences.getString(UserModel.keyRank) ?? "";
  }

  List<String> getInstructor() {
    return preferences.getStringList(UserModel.keyInstructor) ?? [];
  }

  String getInstructorString() {
    String instructor = "";
    for(int i = 0; i < getInstructor().length; i++) {
      instructor += getInstructor()[i];
      if(i < getInstructor().length - 1) {
        instructor += ", ";
      }
    }
    return instructor;
  }

  String getLicenseNo() {
    return preferences.getString(UserModel.keyLicenseNo) ?? "";
  }

  String getLicenseExpiry() {
    return preferences.getString(UserModel.keyLicenseExpiry) ?? "";
  }

  List<String> getPrivileges() {
    return preferences.getStringList(UserModel.keyPrivileges) ?? [];
  }

  String getPrivilegesString() {
    String privileges = "";
    for(int i = 0; i < getPrivileges().length; i++) {
      privileges += getPrivileges()[i];
      if(i < getPrivileges().length - 1) {
        privileges += ", ";
      }
    }
    return privileges;
  }

  bool isPrivilege(String privilege) {
    return getPrivileges().contains(privilege);
  }
}