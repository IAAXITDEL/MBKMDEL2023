import 'package:get/get.dart';

import '../controllers/navadmin_controller.dart';

class NavadminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavadminController>(
      () => NavadminController(),
    );

  }
}
