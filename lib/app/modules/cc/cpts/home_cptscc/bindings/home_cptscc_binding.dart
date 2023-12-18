import 'package:get/get.dart';
import '../controllers/home_cptscc_controller.dart';


class HomeCptsccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeCptsccController>(
          () => HomeCptsccController(),
    );
  }
}