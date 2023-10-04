import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PilotcrewdetailccController extends GetxController {
  final RxInt argumentid = 0.obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxInt idTraining = 0.obs;

  @override
  void onInit() {
    super.onInit();
    argumentid.value = Get.arguments["id"];
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

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
