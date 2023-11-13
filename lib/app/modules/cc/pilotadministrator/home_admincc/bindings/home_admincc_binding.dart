import 'package:get/get.dart';

import '../../../profilecc/controllers/profilecc_controller.dart';
import '../controllers/home_admincc_controller.dart';

class HomeAdminccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeAdminccController>(
      () => HomeAdminccController(),
    );
    Get.lazyPut<ProfileccController>(
          () => ProfileccController(),
    );
  }
}
