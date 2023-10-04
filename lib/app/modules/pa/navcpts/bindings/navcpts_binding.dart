import 'package:get/get.dart';

import '../controllers/navcpts_controller.dart';

class NavcptsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavcptsController>(
      () => NavcptsController(),
    );
  }
}
