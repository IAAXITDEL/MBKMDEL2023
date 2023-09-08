import 'package:get/get.dart';

import '../controllers/add_attendancecc_controller.dart';

class AddAttendanceccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddAttendanceccController>(
      () => AddAttendanceccController(),
    );
  }
}
