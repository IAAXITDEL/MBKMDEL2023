import 'package:get/get.dart';
import 'package:ts_one/app/modules/cc/instructor/home_instructorcc/controllers/home_instructorcc_controller.dart';
import 'package:ts_one/app/modules/cc/instructor/training_typeinstructorcc/controllers/training_typeinstructorcc_controller.dart';

import '../../../pilotadministrator/homecc/controllers/homecc_controller.dart';
import '../controllers/attendance_instructorconfircc_controller.dart';

class AttendanceInstructorconfirccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceInstructorconfirccController>(
          () => AttendanceInstructorconfirccController(),
    );
    Get.lazyPut<TrainingTypeinstructorccController>(
          () => TrainingTypeinstructorccController(),
    );
    Get.lazyPut<HomeInstructorccController>(
          () => HomeInstructorccController(),
    );
    Get.lazyPut<HomeccController>(
          () => HomeccController(),
    );
  }
}