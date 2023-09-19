import 'package:get/get.dart';

import '../controllers/list_attendancedetailcc_controller.dart';

class ListAttendancedetailccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListAttendancedetailccController>(
      () => ListAttendancedetailccController(),
    );
  }
}
