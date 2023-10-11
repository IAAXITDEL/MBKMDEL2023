import 'package:get/get.dart';

import '../controllers/add_trainingcc_controller.dart';

class AddTrainingccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddTrainingccController>(
      () => AddTrainingccController(),
    );
  }
}
