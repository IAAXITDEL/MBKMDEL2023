import 'package:get/get.dart';

import '../../instructor/training_instructorcc/controllers/training_instructorcc_controller.dart';
import '../controllers/trainingcc_controller.dart';

class TrainingccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainingccController>(
      () => TrainingccController(),
    );
    Get.lazyPut<TrainingInstructorccController>(
          () => TrainingInstructorccController(),
    );
  }
}
