import 'package:get/get.dart';

import '../controllers/homefo_controller.dart';

class HomeFOBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeFOController>(
          () => HomeFOController(),
    );
  }
}
