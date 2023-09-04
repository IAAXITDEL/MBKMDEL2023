

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:googleapis/connectors/v1.dart';

import '../../../../data/assessments/assessment_results.dart';
import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/view_model/assessment_results_viewmodel.dart';

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
    if(userPreferences.getPrivileges().contains(UserModel.keyPrivilegeCreateAssessment)) {
      _isInstructor = true;
    }
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
