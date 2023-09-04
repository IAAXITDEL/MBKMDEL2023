import 'package:get/get.dart';

import '../controllers/main_home_controller.dart';

class MainHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainHomeController>(
      () => MainHomeController(),
    );
  }
}
