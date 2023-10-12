import 'package:get/get.dart';
import 'package:ts_one/app/modules/cc/pilotadministrator/homecc/controllers/homecc_controller.dart';

import '../../instructor/training_instructorcc/controllers/training_instructorcc_controller.dart';
import '../../pilotadministrator/trainingtypecc/controllers/trainingtypecc_controller.dart';
import '../../traininghistorycc_cpts/controllers/traininghistorycc_cpts_controller.dart';
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
    Get.lazyPut<HomeccController>(
          () => HomeccController(),
    );
    Get.lazyPut<TrainingtypeccController>(
          () => TrainingtypeccController(),
    );
    Get.lazyPut<TraininghistoryccCptsController>(
          () => TraininghistoryccCptsController(),
    );
  }
}
