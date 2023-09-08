import 'package:get/get.dart';

import '../controllers/attendance_pendingcc_controller.dart';

class AttendancePendingccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendancePendingccController>(
      () => AttendancePendingccController(),
    );
  }
}
