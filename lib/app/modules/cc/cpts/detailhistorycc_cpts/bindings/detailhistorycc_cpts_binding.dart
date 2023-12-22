import 'package:get/get.dart';

import '../controllers/detailhistorycc_cpts_controller.dart';

class DetailhistoryccCptsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailhistoryccCptsController>(
      () => DetailhistoryccCptsController(),
    );
  }
}
