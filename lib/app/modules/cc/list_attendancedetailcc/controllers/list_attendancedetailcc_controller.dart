import 'dart:async';
import 'dart:math';

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


  //Membuat random string untuk key attendance
  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));


  // Update score dan feedback dilakukan oleh instructor
  Future<void> updateScoring(String score, String feedback) async {
    CollectionReference attendance = firestore.collection('attendance-detail');

    // Get attendance detail
    final attendanceDetailQuery = await attendance
        .where("id", isEqualTo: idattendancedetail.value)
        .get();

    if (attendanceDetailQuery.docs.isNotEmpty) {
      final attendanceDetailData = AttendanceDetailModel.fromJson(attendanceDetailQuery.docs.first.data() as Map<String, dynamic>);

      if (score == "SUCCESS" && attendanceDetailData.formatNo == null) {
        final attendanceQuery = await firestore
            .collection('attendance')
            .where("id", isEqualTo: attendanceDetailData.idattendance)
            .get();

        if (attendanceQuery.docs.isNotEmpty) {
          final attendanceData = AttendanceModel.fromJson(attendanceQuery.docs.first.data());
          final date = attendanceData.date?.toDate();
          final year = date?.year;
          final month = date?.month;

          final totalAttendanceQuery = await firestore.collection('attendance')
              .where("subject", isEqualTo: attendanceData.subject)
              .where("is_delete", isEqualTo: 0)
              .get();

          print("satu");
          print(attendanceData.subject);


          print("dua");
          print(totalAttendanceQuery.docs.length);

          final attendances = await Future.wait(
            totalAttendanceQuery.docs.map((doc) async {
              final attendanceModel = AttendanceModel.fromJson(doc.data() as Map<String, dynamic>);
              return attendanceModel.toJson();
            }),
          );

          print("ini attendance");
          print(attendances);
          //mengambil data year dan month yang sama
          final filteredAttendance = attendances.where((attendance) {
            final attendanceDate = attendance["date"].toDate();
            final attendanceYear = attendanceDate.year;
            final attendanceMonth = attendanceDate.month;

            return attendanceYear == year && attendanceMonth == month;
          }).toList();
          print("ini filtered");
          print(filteredAttendance);

          final attendanceIds = <String>[];

          filteredAttendance.forEach((attendance) {
            final attendanceId = attendance['id'];
            if (attendanceId != null) {
              attendanceIds.add(attendanceId);
            }
          });

          print("ini attendance ID");
          print(attendanceIds);

          final attendanceDetailData = <Map<String, dynamic>>[];

          int totalAttendanceCount = 0;
          if (attendanceIds.isNotEmpty) {
            final attendanceDetailQuery = await firestore
                .collection('attendance-detail')
                .where("idattendance", whereIn: attendanceIds)
                .where("score", isEqualTo: "SUCCESS")
                .get();
            attendanceDetailData.addAll(attendanceDetailQuery.docs.map((doc) => doc.data()));
          }

          print("ini attendance detail");
          print(attendanceDetailData.length);

          totalAttendanceCount =  attendanceDetailData.length+1;
          final totalAttendanceCountString = totalAttendanceCount.toString().padLeft(3, '0');

          // Update attendance detail
          await attendance.doc(idattendancedetail.value).update({
            "formatNo": "${attendanceData.subject}-${totalAttendanceCountString}",
            "certificatemandatory" : "1${getRandomString(32)}"
          });
        }
      } else if (score == "FAIL" && attendanceDetailData.score == "SUCCESS") {
        await attendance.doc(idattendancedetail.value).update({
          "formatNo": null,
          "certificatemandatory" : null
        });
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
