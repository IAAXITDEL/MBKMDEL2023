import 'package:get/get.dart';

import '../controllers/homecc_controller.dart';

class HomeccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeccController>(
      () => HomeccController(),
    );
  }
}
