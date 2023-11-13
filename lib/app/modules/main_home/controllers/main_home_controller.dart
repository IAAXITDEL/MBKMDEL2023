import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/assessments/assessment_results.dart';
import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/view_model/assessment_results_viewmodel.dart';
import '../../../routes/app_pages.dart';

class MainHomeController extends GetxController {
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

    assessmentResults = [];
    assessmentResultsNotConfirmedByCPTS = [];

    var hour = DateTime.now().hour;
    if (hour < 12) {
      timeToGreet = "Morning";
    } else if (hour < 17) {
      timeToGreet = "Afternoon";
    } else {
      timeToGreet = "Evening";
    }

    _isCPTS = false;
    _isInstructor = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkInstructor();
    });
    super.onInit();
  }

  void checkInstructor() {
    if (userPreferences.getPrivileges().contains(UserModel.keyPrivilegeCreateAssessment)) {
      _isInstructor = true;
    }
  }

  Future<void> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if (userPreferences.getInstructor().contains(UserModel.keyCPTS) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      print(userPreferences.getRank());
    }
    // SEBAGAI INSTRUCTOR
    else if (userPreferences.getInstructor().contains(UserModel.keySubPositionICC) &&
            userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      Get.toNamed(Routes.INSTRUCTOR_MAIN_HOMECC);
    }
    // SEBAGAI PILOT
    else if (userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      Get.toNamed(Routes.NAVCAPTAIN);
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if (userPreferences.getRank().contains("Pilot Administrator")) {
      Get.toNamed(Routes.NAVADMIN);
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
}
