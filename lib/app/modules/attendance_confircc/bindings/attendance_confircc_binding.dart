import 'package:get/get.dart';

import '../controllers/attendance_confircc_controller.dart';

class AttendanceConfirccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceConfirccController>(
      () => AttendanceConfirccController(),
    );
  }
}
