import 'package:get/get.dart';

import '../../../profilecc/controllers/profilecc_controller.dart';
import '../controllers/pilotcrewdetailcc_controller.dart';

class PilotcrewdetailccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PilotcrewdetailccController>(
      () => PilotcrewdetailccController(),
    );
  }
}
