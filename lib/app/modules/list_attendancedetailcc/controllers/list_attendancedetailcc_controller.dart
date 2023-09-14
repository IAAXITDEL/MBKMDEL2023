import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ListAttendancedetailccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxInt argumentid = 0.obs;


  @override
  void onInit() {
    super.onInit();
    final int id = (Get.arguments as Map<String, dynamic>)["id"] as int;
    argumentid.value = id;
    print(argumentid.value);
  }



  Stream<QuerySnapshot<Map<String, dynamic>>> profileList() {
    return firestore
        .collection('users')
        .where("ID NO", isEqualTo: argumentid.value)
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
