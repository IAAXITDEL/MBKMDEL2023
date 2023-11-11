import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
  late String titleToGreet;
  late String timeToGreet;
  late AssessmentResultsViewModel viewModel;
  late List<AssessmentResults> assessmentResults;
  late List<AssessmentResults> assessmentResultsNotConfirmedByCPTS;
  late bool _isCPTS;
  late bool _isInstructor;
  late bool _isPilotAdministrator;


  @override
  void onInit() {
    userPreferences = getItLocator<UserPreferences>();
    _isPilotAdministrator = false;

    switch (userPreferences.getRank()) {
      case 'CAPT':
        titleToGreet = 'Captain';
        break;
      case 'CPTS':
        titleToGreet = 'Chief Pilot';
        break;
      case 'FO':
        titleToGreet = 'First Officer';
        break;
      case 'Pilot Administrator':
        titleToGreet = 'Pilot Administrator';
        _isPilotAdministrator = true;
        break;
      default:
        titleToGreet = 'Allstar';
    }
    _isCPTS = false;
    _isInstructor = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkInstructor();
    });
    super.onInit();
    updateInvalidAttendances();
    print("sudah cek?");
  }

  void checkInstructor() {
    if(userPreferences.getPrivileges().contains(UserModel.keyPrivilegeCreateAssessment)) {
      _isInstructor = true;
    }
  }

  Future<void> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if( userPreferences.getInstructor().contains(UserModel.keyCPTS) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      Get.toNamed(Routes.NAVCPTS);
    }
    // SEBAGAI INSTRUCTOR
    else if( userPreferences.getInstructor().contains(UserModel.keySubPositionCCP) || userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) || userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) || userPreferences.getInstructor().contains(UserModel.keySubPositionPGI)&& userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      Get.toNamed(Routes.NAVINSTRUCTOR);
    }
    // SEBAGAI PILOT
    else if( userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      Get.toNamed(Routes.NAVPILOT);
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if( userPreferences.getRank().contains("Pilot Administrator")){
      Get.toNamed(Routes.NAVADMIN);
    }
    // SEBAGAI ALL STAR
    else{
    }

  }

  // List Training History
  Future<void> updateInvalidAttendances() async {
    final now = DateTime.now();
    final invalidSubjects = ["BASIC INDOC", "LOAD SHEET / WEIGHT & BALANCE", "RVSM"];

    final querySnapshot = await firestore.collection('attendance')
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
