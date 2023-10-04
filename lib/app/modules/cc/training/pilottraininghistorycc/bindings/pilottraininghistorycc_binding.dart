import 'package:get/get.dart';

import '../controllers/pilottraininghistorycc_controller.dart';

class PilottraininghistoryccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PilottraininghistoryccController>(
      () => PilottraininghistoryccController(),
    );
  }
}
