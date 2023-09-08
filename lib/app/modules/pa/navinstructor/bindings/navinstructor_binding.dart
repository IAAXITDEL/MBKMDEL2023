import 'package:get/get.dart';

import '../controllers/navinstructor_controller.dart';

class NavinstructorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavinstructorController>(
      () => NavinstructorController(),
    );
  }
}
