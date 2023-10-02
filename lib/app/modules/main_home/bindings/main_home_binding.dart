import 'package:get/get.dart';

import '../../home_admincc/controllers/home_admincc_controller.dart';
import '../../home_instructorcc/controllers/home_instructorcc_controller.dart';
import '../../homecc/controllers/homecc_controller.dart';
import '../../pilotadministrator/pilotcrewcc/controllers/pilotcrewcc_controller.dart';
import '../../profilecc/controllers/profilecc_controller.dart';
import '../../training_instructorcc/controllers/training_instructorcc_controller.dart';
import '../../trainingcc/controllers/trainingcc_controller.dart';
import '../controllers/main_home_controller.dart';

class MainHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainHomeController>(
      () => MainHomeController(),
    );
    Get.lazyPut<HomeAdminccController>(
          () => HomeAdminccController(),
    );
    Get.lazyPut<HomeccController>(
          () => HomeccController(),
    );
    Get.lazyPut<HomeInstructorccController>(
          () => HomeInstructorccController(),
    );
    Get.lazyPut<ProfileccController>(
          () => ProfileccController(),
    );
    Get.lazyPut<PilotcrewccController>(
          () => PilotcrewccController(),
    );
    Get.lazyPut<TrainingccController>(
          () => TrainingccController(),
    );
    Get.lazyPut<TrainingInstructorccController>(
          () => TrainingInstructorccController(),
    );
  }
}
