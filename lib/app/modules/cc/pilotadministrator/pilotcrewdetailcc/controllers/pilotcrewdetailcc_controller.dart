import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/modules/cc/profilecc/controllers/profilecc_controller.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../data/users/users.dart';
import '../../../../../../di/locator.dart';

class PilotcrewdetailccController extends GetxController {
  final RxInt argumentid = 0.obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxInt idTraining = 0.obs;

  late UserPreferences userPreferences;
  RxBool isCPTS = false.obs;

  @override
  void onInit() {
    super.onInit();
    argumentid.value = Get.arguments["id"];
    cekRole();
  }

  //Mendapatkan data pribadi
  Stream<QuerySnapshot<Map<String, dynamic>>> profileList() {
    return firestore
        .collection('users')
        .where("ID NO", isEqualTo: argumentid.value)
        .snapshots();
  }

  // List untuk training stream
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return firestore
        .collection('trainingType')
        .where("is_delete", isEqualTo : 0)
        .snapshots();
  }


  Future<bool> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if (userPreferences.getInstructor().contains(UserModel.keyCPTS) &&
        userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      isCPTS.value = true;
    }
    // SEBAGAI INSTRUCTOR
    else if (userPreferences
        .getInstructor()
        .contains(UserModel.keySubPositionCCP) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionPGI) &&
            userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
    }
    // SEBAGAI PILOT
    else if (userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {

    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if (userPreferences.getRank().contains("Pilot Administrator")) {
    }
    // SEBAGAI ALL STAR
    else {
      return false;
    }
    return false;
  }




  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
