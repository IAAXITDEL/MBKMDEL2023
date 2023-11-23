import 'package:get/get.dart';

import '../controllers/training_cptscc_controller.dart';

class TrainingCptsccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainingCptsccController>(
      () => TrainingCptsccController(),
    );
  }
}
