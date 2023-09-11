import 'package:get/get.dart';

import '../controllers/list_attendancecc_controller.dart';

class ListAttendanceccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListAttendanceccController>(
      () => ListAttendanceccController(),
    );
  }
}
