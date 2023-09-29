import 'package:get/get.dart';
import 'package:ts_one/app/modules/homecc/controllers/homecc_controller.dart';

import '../controllers/attendance_confircc_controller.dart';

class AttendanceConfirccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceConfirccController>(
      () => AttendanceConfirccController(),
    );
    Get.lazyPut<HomeccController>(
          () => HomeccController(),
    );
  }
}
