import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TrainingccController extends GetxController {


  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List untuk training remark
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
        .orderBy("id", descending: false)
        .snapshots();
  }





}
