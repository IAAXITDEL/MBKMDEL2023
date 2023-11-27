import 'package:get/get.dart';

import '../../home_pilotcc/controllers/home_pilotcc_controller.dart';
import '../controllers/pilotfeedbackformcc_controller.dart';

class PilotfeedbackformccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PilotfeedbackformccController>(
      () => PilotfeedbackformccController(),
    );
    Get.lazyPut<HomePilotccController>(
          () => HomePilotccController(),
    );
  }
}
