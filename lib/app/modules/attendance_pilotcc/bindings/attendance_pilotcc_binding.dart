import 'package:get/get.dart';

import '../controllers/attendance_pilotcc_controller.dart';

class AttendancePilotccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendancePilotccController>(
      () => AttendancePilotccController(),
    );
  }
}
