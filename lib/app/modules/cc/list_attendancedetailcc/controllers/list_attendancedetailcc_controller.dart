import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../data/users/users.dart';
import '../../../../../di/locator.dart';
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

  RxBool isCPTS = false.obs;

  late UserPreferences userPreferences;

  @override
  void onInit() {
    super.onInit();
    argumentid.value = Get.arguments["id"];
    argumentstatus.value = Get.arguments["status"];
    print("this");
    print(argumentstatus.value);
    argumentidattendance.value = Get.arguments["idattendance"];
    cekRole();
  }

  Future<bool> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if (userPreferences.getInstructor().contains(UserModel.keyCPTS) &&
        userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      isCPTS.value = true;
    }
    // SEBAGAI INSTRUCTOR
    else if (userPreferences
        .getInstructor()
        .contains(UserModel.keySubPositionCCP) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionPGI) &&
            userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {

    }
    // SEBAGAI PILOT
    else if (userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {

    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if (userPreferences.getRank().contains("Pilot Administrator")) {

    }
    // SEBAGAI ALL STAR
    else {
      return false;
    }
    return false;
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

  Future<bool> isCertificatemandatoryAlreadyUsed(String certificatemandatory) async {
    final attendanceDetailQuery = await firestore
        .collection('attendance-detail')
        .where("certificatemandatory", isEqualTo: certificatemandatory)
        .get();

    return attendanceDetailQuery.docs.isNotEmpty;
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

          final attendances = await Future.wait(
            totalAttendanceQuery.docs.map((doc) async {
              final attendanceModel = AttendanceModel.fromJson(doc.data() as Map<String, dynamic>);
              return attendanceModel.toJson();
            }),
          );

          //mengambil data year dan month yang sama
          final filteredAttendance = attendances.where((attendance) {
            final attendanceDate = attendance["date"].toDate();
            final attendanceYear = attendanceDate.year;
            final attendanceMonth = attendanceDate.month;

            return attendanceYear == year && attendanceMonth == month;
          }).toList();

          final attendanceIds = <String>[];

          filteredAttendance.forEach((attendance) {
            final attendanceId = attendance['id'];
            if (attendanceId != null) {
              attendanceIds.add(attendanceId);
            }
          });

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
          String newCertificatemandatory;
          bool isCertificatemandatoryUsed;

          do {
            newCertificatemandatory = "1${getRandomString(32)}";
            isCertificatemandatoryUsed = await isCertificatemandatoryAlreadyUsed(newCertificatemandatory);
          } while (isCertificatemandatoryUsed);

          // Lakukan pembaruan certificatemandatory
          await attendance.doc(idattendancedetail.value).update({
            "formatNo": "${attendanceData.subject}-${totalAttendanceCountString}",
            "certificatemandatory": newCertificatemandatory,
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
