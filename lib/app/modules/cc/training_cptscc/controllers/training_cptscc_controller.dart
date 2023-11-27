import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../data/users/users.dart';
import '../../../../../di/locator.dart';
import '../../../../routes/app_pages.dart';
import '../../traininghistorycc_cpts/controllers/traininghistorycc_cpts_controller.dart';

class TrainingCptsccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late UserPreferences userPreferences;
  final RxInt argumentid = 0.obs;
  final RxString argumentname = "".obs;

  RxBool iscpts = false.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> trainingRemarkStream() {
    return firestore
        .collection('trainingRemark')
        .orderBy("id", descending: false)
        .where("remark", isNotEqualTo: null)
        .snapshots();
  }

  // List untuk training stream
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return firestore
        .collection('trainingType')
        .where("is_delete", isEqualTo: 0)
        .snapshots();
  }

  Future<bool> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if (userPreferences.getInstructor().contains(UserModel.keyCPTS) &&
        userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      iscpts.value = true;
      Get.toNamed(Routes.TRAININGHISTORYCC_CPTS, arguments: {"id": argumentid.value});
      Get.find<TraininghistoryccCptsController>().onInit();
    }

    // SEBAGAI ALL STAR
    else {
      return false;
    }


    return false;
  }


  @override
  void onClose() {
    super.onClose();
  }

}
