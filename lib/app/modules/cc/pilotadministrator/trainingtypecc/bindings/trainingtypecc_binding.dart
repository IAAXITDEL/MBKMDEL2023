import 'package:get/get.dart';

import '../../../profilecc/controllers/profilecc_controller.dart';
import '../../../trainingcc/controllers/trainingcc_controller.dart';
import '../../home_admincc/controllers/home_admincc_controller.dart';
import '../../homecc/controllers/homecc_controller.dart';
import '../../pilotcrewcc/controllers/pilotcrewcc_controller.dart';
import '../controllers/trainingtypecc_controller.dart';

class TrainingtypeccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainingtypeccController>(
      () => TrainingtypeccController(),
    );
    Get.lazyPut<TrainingccController>(
          () => TrainingccController(),
    );
    Get.lazyPut<ProfileccController>(
          () => ProfileccController(),
    );
    Get.lazyPut<HomeccController>(
          () => HomeccController(),
    );
    Get.lazyPut<HomeAdminccController>(
          () => HomeAdminccController(),
    );
    Get.lazyPut<PilotcrewccController>(
          () => PilotcrewccController(),
    );
  }
}
