import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/assessments/assessment_results.dart';
import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/view_model/assessment_results_viewmodel.dart';
import '../../../../presentation/view_model/attendance_model.dart';
import '../../../routes/app_pages.dart';

class MainHomeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late UserPreferences userPreferences;
  RxBool isTsOne = false.obs;
  RxBool isCC = false.obs;
  RxBool isEFB = false.obs;

  @override
  void onInit() {
    cekRoleAccess();
    print(isTsOne.value);
    print(isCC.value);
    print(isEFB.value);
    print("sdadsa");
    super.onInit();
    updateInvalidAttendances();
  }

  Future<void> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if (userPreferences.getInstructor().contains(UserModel.keyCPTS) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      Get.toNamed(Routes.NAVCPTS);
    }
    // SEBAGAI INSTRUCTOR
    else if (userPreferences.getInstructor().contains(UserModel.keySubPositionCCP) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionPGI) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      Get.toNamed(Routes.NAVINSTRUCTOR);
    }
    // SEBAGAI PILOT
    else if (userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      Get.toNamed(Routes.NAVPILOT);
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if (userPreferences.getRank().contains("Pilot Administrator")) {
      Get.toNamed(Routes.NAVADMIN);
    } else if (userPreferences.getPrivileges().contains("manage-device-occ")) {
    }
    // SEBAGAI ALL STAR
    else {}
  }

  Future<void> cekRoleAccess() async {
    userPreferences = getItLocator<UserPreferences>();

    print("akses");
    // SEBAGAI CPTS
    if (userPreferences.getInstructor().contains(UserModel.keyCPTS) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      isTsOne.value = true;
      isCC.value = true;
      isEFB.value = true;
      print("satu");
    }
    // SEBAGAI INSTRUCTOR
    else if (userPreferences.getInstructor().contains(UserModel.keySubPositionCCP) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionPGI) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      isTsOne.value = true;
      isCC.value = true;
      isEFB.value = true;
      print("dua");
    }
    // SEBAGAI PILOT
    else if (userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      isTsOne.value = true;
      isCC.value = true;
      isEFB.value = true;
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if (userPreferences.getRank().contains("Pilot Administrator")) {
      isTsOne.value = true;
      isCC.value = true;
    } else if (userPreferences.getPrivileges().contains(UserModel.keyPrivilegeOCC)) {
      isEFB.value = true;
      print("ada");
    }
    // SEBAGAI ALL STAR
    else {
      Get.snackbar(
        'Access Denied',
        'You do not have access.',
        duration: const Duration(milliseconds: 1000),
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> checkRoleEFB() async {
    userPreferences = getItLocator<UserPreferences>();

    // AS OCC
    if (userPreferences.getPrivileges().contains(UserModel.keyPrivilegeOCC)) {
      Get.toNamed(Routes.NAVOCC);
    }
    // AS PILOT
    else if (userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      Get.toNamed(Routes.NAVOCC);
    } else {
      Get.snackbar(
        'Access Denied',
        'You do not have access.',
        duration: const Duration(milliseconds: 1000),
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // List Training History
  Future<void> updateInvalidAttendances() async {
    final now = DateTime.now();
    final invalidSubjects = ["BASIC INDOC", "LOAD SHEET / WEIGHT & BALANCE", "RVSM"];

    final querySnapshot = await firestore
        .collection('attendance')
        .where("status", isEqualTo: "done")
        .where("expiry", isEqualTo: "VALID")
        .where("is_delete", isEqualTo: 0)
        .get();

    for (final doc in querySnapshot.docs) {
      final attendanceModel = AttendanceModel.fromJson(doc.data());
      final subject = attendanceModel.subject;
      final validTo = attendanceModel.valid_to?.toDate();

      if (!invalidSubjects.contains(subject) && (validTo != null && now.isAfter(validTo))) {
        print("Attendance with ID ${attendanceModel.id} is invalid. Updating to NOT VALID.");

        // Update status ke "NOT VALID"
        await firestore.collection('attendance').doc(attendanceModel.id).update({
          "expiry": "NOT VALID",
        });
      }
    }
  }
}
