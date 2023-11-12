import 'package:get/get.dart';

import '../../../cc/pilotadministrator/home_admincc/controllers/home_admincc_controller.dart';
import '../../../cc/pilotadministrator/pilotcrewcc/controllers/pilotcrewcc_controller.dart';
import '../../../cc/profilecc/controllers/profilecc_controller.dart';
import '../../../cc/trainingcc/controllers/trainingcc_controller.dart';
import '../controllers/navadmin_controller.dart';

class NavadminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavadminController>(
      () => NavadminController(),
    );
    Get.lazyPut<HomeAdminccController>(
          () => HomeAdminccController(),
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

  }
}
