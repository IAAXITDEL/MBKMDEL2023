import 'package:get/get.dart';
import 'package:ts_one/app/modules/home_pilotcc/controllers/home_pilotcc_controller.dart';

import '../../../profilecc/controllers/profilecc_controller.dart';
import '../../../trainingcc/controllers/trainingcc_controller.dart';
import '../controllers/navpilot_controller.dart';

class NavpilotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavpilotController>(
      () => NavpilotController(),
    );
    Get.lazyPut<HomePilotccController>(
          () => HomePilotccController(),
    );
    Get.lazyPut<TrainingccController>(
          () => TrainingccController(),
    );
    Get.lazyPut<ProfileccController>(
          () => ProfileccController(),
    );
  }
}
