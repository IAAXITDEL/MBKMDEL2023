import 'package:get/get.dart';

import '../controllers/list_absentcptscc_controller.dart';

class ListAbsentcptsccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListAbsentcptsccController>(
      () => ListAbsentcptsccController(),
    );
  }
}
