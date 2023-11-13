import 'package:get/get.dart';

import '../controllers/pilottraininghistorydetailcc_controller.dart';

class PilottraininghistorydetailccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PilottraininghistorydetailccController>(
      () => PilottraininghistorydetailccController(),
    );
  }
}
