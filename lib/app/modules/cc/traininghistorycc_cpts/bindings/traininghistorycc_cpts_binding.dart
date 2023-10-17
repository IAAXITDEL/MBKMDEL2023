import 'package:get/get.dart';

import '../controllers/traininghistorycc_cpts_controller.dart';

class TraininghistoryccCptsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TraininghistoryccCptsController>(
      () => TraininghistoryccCptsController(),
    );
  }
}
