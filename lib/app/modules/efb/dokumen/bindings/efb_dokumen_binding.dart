import 'package:get/get.dart';

import '../controllers/efb_dokumen_controller.dart';

class EfbDokumenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EfbDokumenController>(
      () => EfbDokumenController(),
    );
  }
}
