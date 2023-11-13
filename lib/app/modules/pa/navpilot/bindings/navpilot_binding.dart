import 'package:get/get.dart';
import '../../../cc/profilecc/controllers/profilecc_controller.dart';
import '../../../cc/training/home_pilotcc/controllers/home_pilotcc_controller.dart';
import '../../../cc/trainingcc/controllers/trainingcc_controller.dart';
import '../controllers/navpilot_controller.dart';

class NavpilotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavpilotController>(
          () => NavpilotController(),
    );
    Get.lazyPut<HomePilotccController>(
          () => HomePilotccController(),
    );
    Get.lazyPut<TrainingccController>(
          () => TrainingccController(),
    );
    Get.lazyPut<ProfileccController>(
          () => ProfileccController(),
    );
  }
}