import 'package:get/get.dart';

import '../controllers/homepilot_controller.dart';

class HomePilotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomePilotController>(
          () => HomePilotController(),
    );
  }
}
