import 'package:get/get.dart';

import '../controllers/pilotfeedbackformcc_controller.dart';

class PilotfeedbackformccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PilotfeedbackformccController>(
      () => PilotfeedbackformccController(),
    );
  }
}
