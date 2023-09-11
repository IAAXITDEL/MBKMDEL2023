import 'package:get/get.dart';

import '../controllers/navpilot_controller.dart';

class NavpilotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavpilotController>(
      () => NavpilotController(),
    );
  }
}
