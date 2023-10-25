import 'package:get/get.dart';

import '../../cc/instructor/home_instructorcc/controllers/home_instructorcc_controller.dart';
import '../../cc/instructor/training_instructorcc/controllers/training_instructorcc_controller.dart';
import '../../cc/instructor/training_typeinstructorcc/controllers/training_typeinstructorcc_controller.dart';
import '../../cc/pilotadministrator/home_admincc/controllers/home_admincc_controller.dart';
import '../../cc/pilotadministrator/homecc/controllers/homecc_controller.dart';
import '../../cc/pilotadministrator/pilotcrewcc/controllers/pilotcrewcc_controller.dart';
import '../../cc/profilecc/controllers/profilecc_controller.dart';
import '../../cc/trainingcc/controllers/trainingcc_controller.dart';
import '../../cc/home_cptscc/controllers/home_cptscc_controller.dart';
import '../../cc/traininghistorycc_cpts/controllers/traininghistorycc_cpts_controller.dart';
import '../controllers/main_home_controller.dart';

class MainHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainHomeController>(
      () => MainHomeController(),
    );
    Get.lazyPut<HomeAdminccController>(
          () => HomeAdminccController(),
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
    Get.lazyPut<PilotcrewccController>(
          () => PilotcrewccController(),
    );
    Get.lazyPut<TrainingccController>(
          () => TrainingccController(),
    );
    Get.lazyPut<TrainingInstructorccController>(
          () => TrainingInstructorccController(),
    );
    Get.lazyPut<TrainingTypeinstructorccController>(
          () => TrainingTypeinstructorccController(),
    );
    Get.lazyPut<HomeCptsccController>(
          () => HomeCptsccController(),
    );
    Get.lazyPut<TraininghistoryccCptsController>(
          () => TraininghistoryccCptsController(),
    );
  }
}
