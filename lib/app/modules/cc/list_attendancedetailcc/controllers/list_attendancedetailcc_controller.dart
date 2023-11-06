import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../presentation/view_model/attendance_model.dart';

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

      // Get attendance detail
      final attendanceDetailQuery = await attendance
          .where("id", isEqualTo: idattendancedetail.value)
          .get();

      if (attendanceDetailQuery.docs.isNotEmpty) {
        final attendanceDetailData = AttendanceDetailModel.fromJson(attendanceDetailQuery.docs.first.data() as Map<String, dynamic>);


        if (score == "SUCCESS") {
          // Add Format No if it's not present
          if (attendanceDetailData.formatNo == null) {

            final attendanceQuery = await firestore
                .collection('attendance')
                .where("id", isEqualTo: attendanceDetailData.idattendance)
                .get();

            if (attendanceQuery.docs.isNotEmpty) {
              final attendanceData = AttendanceModel.fromJson(attendanceQuery.docs.first.data());

              // Get total successful attendance
              final totalAttendanceQuery = await attendance
                  .where("idattendance", isEqualTo: attendanceDetailData.idattendance)
                  .where("score", isEqualTo: "SUCCESS")
                  .get();

              final totalAttendanceCount = totalAttendanceQuery.docs.length + 1;
              final totalAttendanceCountString = totalAttendanceCount.toString().padLeft(3, '0');

              // Update attendance detail
              await attendance.doc(idattendancedetail.value).update({
                "formatNo": "${attendanceData.subject}-${totalAttendanceCountString}",
              });
            }
          }
        }else if(score == "FAIL"){
          if (attendanceDetailData.score == "SUCCESS") {
            await attendance.doc(idattendancedetail.value).update({
              "formatNo": null,
            });
          }
        }
      }
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
