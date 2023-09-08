import 'package:get/get.dart';

import '../controllers/home_instructorcc_controller.dart';

class HomeInstructorccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeInstructorccController>(
      () => HomeInstructorccController(),
    );
  }
}
