import 'package:get/get.dart';

import '../controllers/edit_attendancecc_controller.dart';

class EditAttendanceccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditAttendanceccController>(
      () => EditAttendanceccController(),
    );
  }
}
