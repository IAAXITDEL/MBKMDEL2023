import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../presentation/view_model/attendance_detail_model.dart';

class ListAttendancedetailccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxInt argumentid = 0.obs;
  final RxString argumentstatus = "".obs;
  final RxString argumentidattendance = "".obs;
  RxBool checkAgree = false.obs;
  final RxBool showText = false.obs;
  RxString idattendancedetail = "".obs;

  @override
  void onInit() {
    super.onInit();
    argumentid.value = Get.arguments["id"];
    argumentstatus.value = Get.arguments["status"];
    argumentidattendance.value = Get.arguments["idattendance"];
  }

  Stream<List<Map<String, dynamic>>> profileList() {
    return firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: argumentidattendance.value)
        .where("idtraining", isEqualTo: argumentid.value)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      List<int?> traineeIds = attendanceQuery.docs
          .map((doc) => AttendanceDetailModel.fromJson(doc.data()).idtraining)
          .toList();

      final usersData = <Map<String, dynamic>>[];

      if (traineeIds.isNotEmpty) {
        final usersQuery = await firestore
            .collection('users')
            .where("ID NO", whereIn: traineeIds)
            .get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }
      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceDetailModel.fromJson(doc.data());
          final user = usersData.firstWhere(
            (user) => user['ID NO'] == attendanceModel.idtraining,
            orElse: () => {},
          );
          attendanceModel.name = user['NAME'];
          attendanceModel.photoURL = user['PHOTOURL'];
          attendanceModel.email = user['EMAIL'];
          attendanceModel.rank = user['RANK'];
          attendanceModel.license = user['LICENSE NO.'];

          return attendanceModel.toJson();
        }),
      );
      return attendanceData;
    });
  }

  // Update score dan feedback dilakukan oleh instructor
  Future<void> updateScoring(String score, String feedback) async {
    CollectionReference attendance = firestore.collection('attendance-detail');
    await attendance.doc(idattendancedetail.value).update({
      "score": score,
      "feedback": feedback,
      "status": "donescoring",
      "updatedTime": DateTime.now().toIso8601String(),
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
