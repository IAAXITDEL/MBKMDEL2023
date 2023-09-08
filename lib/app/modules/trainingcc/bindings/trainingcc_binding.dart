import 'package:get/get.dart';

import '../controllers/trainingcc_controller.dart';

class TrainingccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainingccController>(
      () => TrainingccController(),
    );
  }
}
