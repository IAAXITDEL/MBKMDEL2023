import 'package:get/get.dart';

import '../controllers/attendance_instructorconfircc_controller.dart';

class AttendanceInstructorconfirccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceInstructorconfirccController>(
          () => AttendanceInstructorconfirccController(),
    );
  }
}