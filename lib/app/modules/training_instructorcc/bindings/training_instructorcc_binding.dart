import 'package:get/get.dart';

import '../../trainingcc/controllers/trainingcc_controller.dart';
import '../controllers/training_instructorcc_controller.dart';

class TrainingInstructorccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainingInstructorccController>(
      () => TrainingInstructorccController(),
    );
    Get.lazyPut<TrainingccController>(
          () => TrainingccController(),
    );
  }
}
