import 'package:get/get.dart';

import '../controllers/training_typeinstructorcc_controller.dart';

class TrainingTypeinstructorccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainingTypeinstructorccController>(
      () => TrainingTypeinstructorccController(),
    );
  }
}
