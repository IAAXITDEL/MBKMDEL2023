import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/modules/cc/profilecc/controllers/profilecc_controller.dart';

class PilotcrewdetailccController extends GetxController {
  final RxInt argumentid = 0.obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxInt idTraining = 0.obs;

  RxBool isReady = false.obs;
  @override
  void onInit() {
    super.onInit();
    argumentid.value = Get.arguments["id"];
    fetchAttendanceData(argumentid.value);
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

  Future<void> fetchAttendanceData(int idCrew) async {
    try {
      isReady.value = await Get.find<ProfileccController>().fetchAttendanceData(idCrew);
    }catch (e) {
      print("Error generating PDF: $e");
      return ;

    }
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
