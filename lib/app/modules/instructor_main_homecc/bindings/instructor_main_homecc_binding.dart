import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/instructor_main_homecc_controller.dart';

class InstructorMainHomeccBinding extends Bindings {

  late SharedPreferences preferences;

  @override
  void dependencies() {
    Get.lazyPut<InstructorMainHomeccController>(
      () => InstructorMainHomeccController(),
    );
    Get.lazyPut<UserPrefer>(
          () => UserPrefer(preferences: preferences),
    );
  }
}
