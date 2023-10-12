import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../../presentation/view_model/attendance_model.dart';

class PilottraininghistoryccController extends GetxController {
  RxInt idTraining = 0.obs;
  RxInt idTrainingType = 0.obs;
  RxString expiryC = "".obs;

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
    return firestore
        .collection('attendance')
        .where("idTrainingType", isEqualTo: idTrainingType.value)
        .where("status", isEqualTo: "done")
        .snapshots()
        .asyncMap((attendanceQuery) async {
      final attendanceDetailData = <Map<String, dynamic>>[];

      final usersData = <Map<String, dynamic>>[];

      if (attendanceQuery.docs.isNotEmpty) {
        final attendanceIds = attendanceQuery.docs
            .map((doc) => AttendanceModel.fromJson(doc.data()).id)
            .toList();

        print(attendanceIds);
        if (attendanceIds.isNotEmpty) {
          final attendanceDetailQuery = await firestore
              .collection('attendance-detail')
              .where("idtraining", isEqualTo: idTraining.value)
              .where("idattendance", whereIn: attendanceIds)
              .get();
          attendanceDetailData
              .addAll(attendanceDetailQuery.docs.map((doc) => doc.data()));

          print("disini 1");
          print(attendanceDetailData);
        }else{
          return [];
        }

        if (attendanceDetailData.isNotEmpty) {
          final usersQuery = await firestore
              .collection('users')
              .where("ID NO", isEqualTo: idTraining.value)
              .get();
          usersData.addAll(usersQuery.docs.map((doc) => doc.data()));

          print("disini 2");
          print(usersData);
        }else{
          return [];
        }
      }else{
        return [];
      }

      final attendanceData = attendanceQuery.docs.map((doc) {
        final attendanceModel = AttendanceModel.fromJson(doc.data());
        final attendanceDetail = attendanceDetailData.firstWhere(
              (attendanceDetail) =>
          attendanceDetail['idattendance'] == attendanceModel.id,
        );
        return attendanceModel.toJson();
      }).toList();

      // Sort attendanceData based on valid_to in descending order
      attendanceData.sort((a, b) {
        Timestamp timestampA =
        Timestamp.fromMillisecondsSinceEpoch(a['valid_to'].millisecondsSinceEpoch);
        Timestamp timestampB =
        Timestamp.fromMillisecondsSinceEpoch(b['valid_to'].millisecondsSinceEpoch);
        return timestampB.compareTo(timestampA);
      });

      if (attendanceData.isNotEmpty) {
        expiryC.value = attendanceData[0]["expiry"];
      }
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
