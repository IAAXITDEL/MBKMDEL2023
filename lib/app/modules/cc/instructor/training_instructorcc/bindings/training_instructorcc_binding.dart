import 'package:get/get.dart';
import 'package:ts_one/app/modules/cc/instructor/home_instructorcc/controllers/home_instructorcc_controller.dart';

import '../../../pilotadministrator/homecc/controllers/homecc_controller.dart';
import '../../../profilecc/controllers/profilecc_controller.dart';
import '../../../trainingcc/controllers/trainingcc_controller.dart';
import '../../training_typeinstructorcc/controllers/training_typeinstructorcc_controller.dart';
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
    Get.lazyPut<TrainingTypeinstructorccController>(
          () => TrainingTypeinstructorccController(),
    );
    Get.lazyPut<HomeccController>(
          () => HomeccController(),
    );
    Get.lazyPut<HomeInstructorccController>(
          () => HomeInstructorccController(),
    );
    Get.lazyPut<ProfileccController>(
          () => ProfileccController(),
    );
  }
}
