import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../data/users/users.dart';
import '../../../../../../di/locator.dart';
import '../../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../../presentation/view_model/attendance_model.dart';
import '../../../../../routes/app_pages.dart';
import '../../../pilotadministrator/trainingtypecc/controllers/trainingtypecc_controller.dart';
import '../../training_instructorcc/controllers/training_instructorcc_controller.dart';

class TrainingTypeinstructorccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late UserPreferences userPreferences;

  final RxInt argumentid = 0.obs;
  final RxString argumentname = "".obs;

  final RxBool cekPilot = false.obs;
  RxBool isAdministrator = false.obs;
  final RxString passwordKey = "".obs;

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
        .where("is_delete", isEqualTo: 0)
        .snapshots();
  }

  Future<bool> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if (userPreferences.getInstructor().contains(UserModel.keyCPTS) &&
        userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
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
      Get.toNamed(Routes.TRAINING_INSTRUCTORCC,
          arguments: {"id": argumentid.value, "name": argumentname.value});
      Get.find<TrainingInstructorccController>().onInit();
    }
    // SEBAGAI PILOT
    else if (userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      cekPilot.value = true;
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if (userPreferences.getRank().contains("Pilot Administrator")) {
      Get.toNamed(Routes.TRAININGTYPECC,
          arguments: {"id": argumentid.value, "name": argumentname.value});
      Get.find<TrainingtypeccController>().onInit();
    }
    // SEBAGAI ALL STAR
    else {
      return false;
    }
    return false;
  }

  Future<bool> cekAdministrator() async {
    userPreferences = getItLocator<UserPreferences>();

    if (userPreferences.getRank().contains("Pilot Administrator")) {
      isAdministrator.value = true;
      return true;
    }
    // SEBAGAI ALL STAR
    else {
      return false;
    }
    return false;
  }

  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(
      List<String> statuses) {
    userPreferences = getItLocator<UserPreferences>();
    return firestore
        .collection('attendance')
        .where("idTrainingType", isEqualTo: argumentid.value)
        .where("instructor", isEqualTo: userPreferences.getIDNo())
        .where("status", whereIn: statuses)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      final usersQuery = await firestore
          .collection('users')
          .where("ID NO", isEqualTo: userPreferences.getIDNo())
          .get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere(
                  (user) => user['ID NO'] == attendanceModel.instructor,
              orElse: () => {});
          attendanceModel.name = user['NAME'];
          attendanceModel.photoURL = user['PHOTOURL'];
          return attendanceModel.toJson();
        }),
      );

      return attendanceData;
    });
  }


  @override
  void onInit() {
    super.onInit();
    cekAdministrator();
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
