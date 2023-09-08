import 'package:get/get.dart';

import '../controllers/home_admincc_controller.dart';

class HomeAdminccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeAdminccController>(
      () => HomeAdminccController(),
    );
  }
}
