import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../../presentation/view_model/attendance_model.dart';

class PilottraininghistoryccController extends GetxController {
  RxInt idTraining = 0.obs;
  RxInt idTrainingType = 0.obs;
  RxString expiryC = "".obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late final Rx<DateTime> from= DateTime(1900, 1, 1).obs;
  late final Rx<DateTime> to = DateTime.now().add(Duration(days: 4 * 365)).obs;

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
  Stream<List<Map<String, dynamic>>> historyStream({DateTime? from, DateTime? to}) {
    return firestore
        .collection('attendance')
        .where("idTrainingType", isEqualTo: idTrainingType.value)
        .where("status", isEqualTo: "done")
        .where("is_delete", isEqualTo: 0)
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
              .where("score", isEqualTo: "PASS")
              .get();
          attendanceDetailData
              .addAll(attendanceDetailQuery.docs.map((doc) => doc.data()));

        }else{
          return [];
        }

        if (attendanceDetailData.isNotEmpty) {
          final usersQuery = await firestore
              .collection('users')
              .where("ID NO", isEqualTo: idTraining.value)
              .get();
          usersData.addAll(usersQuery.docs.map((doc) => doc.data()));

        }else{
          return [];
        }
      }else{
        return [];
      }

      // Filter attendanceQuery based on whether there is a corresponding attendanceDetail
      final filteredAttendanceQuery = attendanceQuery.docs.where((doc) {
        final attendanceModel = AttendanceModel.fromJson(doc.data());
        return attendanceDetailData.any((attendanceDetail) => attendanceDetail['idattendance'] == attendanceModel.id);
      });

      final attendanceData = <Map<String, dynamic>>[];
      for (var doc in filteredAttendanceQuery) {
        final attendanceModel = AttendanceModel.fromJson(doc.data());
        final attendanceDetail = attendanceDetailData.firstWhere(
              (attendanceDetail) => attendanceDetail['idattendance'] == attendanceModel.id,
          orElse: () => <String, dynamic>{}, // Return an empty map
        );

        attendanceData.add(attendanceModel.toJson());
      }

      // Sort attendanceData based on valid_to in descending order
      attendanceData.sort((a, b) {
        Timestamp timestampA =
        Timestamp.fromMillisecondsSinceEpoch(a['date'].millisecondsSinceEpoch);
        Timestamp timestampB =
        Timestamp.fromMillisecondsSinceEpoch(b['date'].millisecondsSinceEpoch);
        return timestampB.compareTo(timestampA);
      });

      if (from != null && to != null) {
        final filteredAttendance = attendanceData.where((attendance) {
          DateTime attendanceDate = attendance["date"].toDate();

          // Compare dates only, ignoring the time component
          DateTime fromDate = DateTime(from.year, from.month, from.day);
          DateTime toDate = DateTime(to.year, to.month, to.day);
          DateTime attendanceDateOnly = DateTime(attendanceDate.year, attendanceDate.month, attendanceDate.day);

          return attendanceDateOnly.isAtSameMomentAs(fromDate) ||
              (attendanceDateOnly.isAfter(fromDate) && attendanceDateOnly.isBefore(toDate)) ||
              attendanceDateOnly.isAtSameMomentAs(toDate);
        }).toList();

        if (attendanceData.isNotEmpty) {
          expiryC.value = attendanceData[0]["expiry"];
        }

        return filteredAttendance;
      }

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
