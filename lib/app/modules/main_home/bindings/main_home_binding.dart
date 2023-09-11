import 'package:get/get.dart';
import 'package:ts_one/app/modules/home_pilotcc/controllers/home_pilotcc_controller.dart';
import 'package:ts_one/app/modules/home_pilotcc/views/home_pilotcc_view.dart';

import '../../home_instructorcc/controllers/home_instructorcc_controller.dart';
import '../../homecc/controllers/homecc_controller.dart';
import '../../pilotcrewcc/controllers/pilotcrewcc_controller.dart';
import '../../profilecc/controllers/profilecc_controller.dart';
import '../../trainingcc/controllers/trainingcc_controller.dart';
import '../controllers/main_home_controller.dart';

class MainHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainHomeController>(
      () => MainHomeController(),
    );
    Get.lazyPut<HomeccController>(
          () => HomeccController(),
    );
    Get.lazyPut<HomeInstructorccController>(
          () => HomeInstructorccController(),
    );
    Get.lazyPut<HomePilotccController>(
          () => HomePilotccController(),
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
  }
}
