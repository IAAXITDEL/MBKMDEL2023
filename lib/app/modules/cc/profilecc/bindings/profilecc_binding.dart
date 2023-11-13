import 'package:get/get.dart';

import '../controllers/profilecc_controller.dart';

class ProfileccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileccController>(
      () => ProfileccController(),
    );
  }
}
