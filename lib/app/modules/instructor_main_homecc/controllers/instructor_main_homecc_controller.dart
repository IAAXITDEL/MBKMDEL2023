import 'package:get/get.dart';

import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../routes/app_pages.dart';

class InstructorMainHomeccController extends GetxController {

  late UserPreferences userPreferences;

  Future<void> cekInstructor() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI INSTRUCTOR
    if( userPreferences.getInstructor().contains(UserModel.keySubPositionICC) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      print(userPreferences.getRank());
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
