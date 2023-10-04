import 'package:get/get.dart';

import '../controllers/home_pilotcc_controller.dart';

class HomePilotccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomePilotccController>(
      () => HomePilotccController(),
    );
  }
}
