import 'package:get/get.dart';

import '../../../cc/profilecc/controllers/profilecc_controller.dart';
import '../../../cc/training_cptscc/controllers/training_cptscc_controller.dart';
import '../controllers/navcpts_controller.dart';

class NavcptsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavcptsController>(
      () => NavcptsController(),
    );
    Get.lazyPut<ProfileccController>(
          () => ProfileccController(),
    );
    Get.lazyPut<TrainingCptsccController>(
          () => TrainingCptsccController(),
    );
  }
}
