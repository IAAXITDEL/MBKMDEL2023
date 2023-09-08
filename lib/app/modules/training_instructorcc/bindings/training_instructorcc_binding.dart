import 'package:get/get.dart';

import '../controllers/training_instructorcc_controller.dart';

class TrainingInstructorccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainingInstructorccController>(
      () => TrainingInstructorccController(),
    );
  }
}
