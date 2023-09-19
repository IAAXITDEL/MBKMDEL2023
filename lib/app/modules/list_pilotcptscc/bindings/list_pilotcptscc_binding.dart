import 'package:get/get.dart';

import '../controllers/list_pilotcptscc_controller.dart';

class ListPilotcptsccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListPilotcptsccController>(
      () => ListPilotcptsccController(),
    );
  }
}
