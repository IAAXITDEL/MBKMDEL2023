import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../presentation/view_model/attendance_model.dart';

class PilottraininghistoryccController extends GetxController {

  RxInt idTraining = 0.obs;
  RxInt idTrainingType = 0.obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    idTrainingType.value = Get.arguments["idTrainingType"];
    idTraining.value = Get.arguments["idTraining"];
  }

  //Mendapatkan Training
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return firestore
        .collection('trainingType')
        .where("id", isEqualTo: idTrainingType.value)
        .snapshots();
  }

  // List Training History
  Stream<List<Map<String, dynamic>>> historyStream() {
    return firestore.collection('attendance').where("idTrainingType", isEqualTo: idTrainingType.value).where("status", isEqualTo: "done").snapshots().asyncMap((attendanceQuery) async {
      final attendanceDetailQuery = await firestore.collection('attendance-detail').where("idtraining", isEqualTo: idTraining.value).get();
      final attendanceDetailData = attendanceDetailQuery.docs.map((doc) => doc.data()).toList();
      if (attendanceDetailData.isEmpty) {
        return [];
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final attendanceDetail = attendanceDetailData.firstWhere((attendanceDetail) => attendanceDetail['idattendance'] == attendanceModel.id, orElse: () => {});
          return attendanceModel.toJson();
        }),
      );
      return attendanceData;
    });
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
