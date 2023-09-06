import 'package:get/get.dart';

import '../controllers/trainingtypecc_controller.dart';

class TrainingtypeccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainingtypeccController>(
      () => TrainingtypeccController(),
    );
  }
}
