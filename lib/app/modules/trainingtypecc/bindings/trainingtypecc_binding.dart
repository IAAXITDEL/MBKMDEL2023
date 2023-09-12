import 'package:get/get.dart';

import '../../trainingcc/controllers/trainingcc_controller.dart';
import '../controllers/trainingtypecc_controller.dart';

class TrainingtypeccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainingtypeccController>(
      () => TrainingtypeccController(),
    );
    Get.lazyPut<TrainingccController>(
          () => TrainingccController(),
    );
  }
}
