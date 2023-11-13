import 'package:get/get.dart';

import '../../../cc/instructor/training_instructorcc/controllers/training_instructorcc_controller.dart';
import '../controllers/navinstructor_controller.dart';

class NavinstructorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavinstructorController>(
      () => NavinstructorController(),
    );
    Get.lazyPut<TrainingInstructorccController>(
          () => TrainingInstructorccController(),
    );
  }
}
