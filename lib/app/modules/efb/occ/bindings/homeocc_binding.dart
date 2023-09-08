import 'package:get/get.dart';

import '../controllers/homeocc_controller.dart';

class HomeOCCBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeOCCController>(
          () => HomeOCCController(),
    );
  }
}
