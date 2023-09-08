import 'package:get/get.dart';
import 'package:ts_one/app/modules/profilecc/controllers/profilecc_controller.dart';

import 'package:ts_one/app/modules/pa/occ/controllers/navocc_controller.dart';

class NavOCCBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavOCCController>(
          () => NavOCCController(),
    );
    Get.lazyPut<ProfileccController>(
          () => ProfileccController(),
    );
  }
}
