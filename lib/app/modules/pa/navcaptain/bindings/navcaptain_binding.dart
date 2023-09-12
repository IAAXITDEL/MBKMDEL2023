import 'package:get/get.dart';

import '../controllers/navcaptain_controller.dart';

class NavcaptainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavcaptainController>(
      () => NavcaptainController(),
    );
  }
}
