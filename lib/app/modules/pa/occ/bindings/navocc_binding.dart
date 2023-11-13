import 'package:get/get.dart';

import 'package:ts_one/app/modules/pa/occ/controllers/navocc_controller.dart';

import '../../../cc/profilecc/controllers/profilecc_controller.dart';

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
