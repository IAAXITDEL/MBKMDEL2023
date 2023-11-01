import 'package:get/get.dart';

import '../../../profilecc/controllers/profilecc_controller.dart';
import '../controllers/pilotcrewcc_controller.dart';

class PilotcrewccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PilotcrewccController>(
      () => PilotcrewccController(),
    );
    Get.lazyPut<ProfileccController>(
          () => ProfileccController(),
    );
  }
}
