import 'package:get/get.dart';

import '../controllers/instructor_main_homecc_controller.dart';

class InstructorMainHomeccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InstructorMainHomeccController>(
      () => InstructorMainHomeccController(),
    );
  }
}
