import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../routes/app_pages.dart';

class InstructorMainHomeccController extends GetxController {

  late UserPreferences userPreferences;
  late SharedPreferences preferences;

  @override
  void onInit() {
    initializePreferences();
    super.onInit();
  }


  Future<void> cekInstructor() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI INSTRUCTOR
    if( userPreferences.getInstructor().contains(UserModel.keySubPositionCCP) || userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) || userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) || userPreferences.getInstructor().contains(UserModel.keySubPositionPGI) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){

    }
  }

  Future<void> initializePreferences() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<void> asTraining() async {
    Get.find<UserPrefer>().clearInstructor();
    Get.toNamed(Routes.NAVPILOT);
  }
}

class UserPrefer extends ChangeNotifier {
  UserPrefer({
    required this.preferences
  });

  final SharedPreferences preferences;

  void clearInstructor() {
    preferences.setStringList(UserModel.keyInstructor, []);
    notifyListeners();
  }

}
