import 'package:get/get.dart';
import 'package:ts_one/app/modules/profilecc/controllers/profilecc_controller.dart';

import '../controllers/navadmin_controller.dart';

class NavadminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavadminController>(
      () => NavadminController(),
    );
    Get.lazyPut<ProfileccController>(
          () => ProfileccController(),
    );
  }
}
