import 'package:get/get.dart';

import '../controllers/pilotcrewdetailcc_controller.dart';

class PilotcrewdetailccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PilotcrewdetailccController>(
      () => PilotcrewdetailccController(),
    );
  }
}
