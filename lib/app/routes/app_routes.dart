part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const MAIN_HOME = _Paths.MAIN_HOME;
  static const main = _Paths.main;
  static const login = _Paths.login;
  static const home = _Paths.home;

  static const allUsers = _Paths.allUsers;
  static const addUser = _Paths.addUser;
  static const detailUser = _Paths.detailUser;
  static const updateUser = _Paths.updateUser;

  static const newAssessmentSimulatorFlight =
      _Paths.newAssessmentSimulatorFlight;
  static const newAssessmentCandidate = _Paths.newAssessmentCandidate;
  static const newAssessmentFlightDetails = _Paths.newAssessmentFlightDetails;
  static const newAssessmentVariables = _Paths.newAssessmentVariables;
  static const newAssessmentVariablesSecond =
      _Paths.newAssessmentVariablesSecond;
  static const newAssessmentHumanFactorVariables =
      _Paths.newAssessmentHumanFactorVariables;
  static const newAssessmentOverallPerformance =
      _Paths.newAssessmentOverallPerformance;
  static const newAssessmentDeclaration = _Paths.newAssessmentDeclaration;
  static const newAssessmentSuccess = _Paths.newAssessmentSuccess;
  static const newAssessmentInstructorNotes =
      _Paths.newAssessmentInstructorNotes;

  static const allAssessmentPeriods = _Paths.allAssessmentPeriods;
  static const detailAssessmentPeriod = _Paths.detailAssessmentPeriod;
  static const addAssessmentPeriod = _Paths.addAssessmentPeriod;
  static const updateAssessmentPeriod = _Paths.updateAssessmentPeriod;

  static const resultAssessmentVariables = _Paths.resultAssessmentVariables;
  static const resultAssessmentOverall = _Paths.resultAssessmentOverall;
  static const resultAssessmentDeclaration = _Paths.resultAssessmentDeclaration;
  static const NAVADMIN = _Paths.NAVADMIN;
  static const HOMECC = _Paths.HOMECC;
  static const PROFILECC = _Paths.PROFILECC;

  //EFB
  static const NAVOCC = _Paths.NAVOCC;
  static const HOMEOCC = _Paths.HOMEOCC;
  static const LISTDEVICEOCC = _Paths.LISTDEVICEOCC;
  static const ANALYTICS = _Paths.ANALYTICS;

  //EFB PILOT
  static const HOMEPILOT = _Paths.HOMEPILOT;

  //EFB FO
  static const HOMEFO = _Paths.HOMEFO;

  static const TRAININGCC = _Paths.TRAININGCC;
  static const PILOTCREWCC = _Paths.PILOTCREWCC;
  static const TRAININGTYPECC = _Paths.TRAININGTYPECC;
  static const ADD_ATTENDANCECC = _Paths.ADD_ATTENDANCECC;
  static String ATTENDANCE_CONFIRCC(String attendanceId) {
    return _Paths.ATTENDANCE_CONFIRCC(attendanceId);
  }

  static const NAVCAPTAIN = _Paths.NAVCAPTAIN;
  static const HOME_INSTRUCTORCC = _Paths.HOME_INSTRUCTORCC;
  static const TRAINING_INSTRUCTORCC = _Paths.TRAINING_INSTRUCTORCC;
  static const HOME_ADMINCC = _Paths.HOME_ADMINCC;
  static const INSTRUCTOR_MAIN_HOMECC = _Paths.INSTRUCTOR_MAIN_HOMECC;
  static const NAVINSTRUCTOR = _Paths.NAVINSTRUCTOR;
  static const ATTENDANCE_PENDINGCC = _Paths.ATTENDANCE_PENDINGCC;
  // static const ANALYTICS = _Paths.EFB + _Paths.ANALYTICS;
  static const PROFILE = _Paths.PROFILE;
}

abstract class _Paths {
  _Paths._();
  static const MAIN_HOME = '/main-home';

  static const main = '/';
  static const login = '/login';
  static const home = '/home';

  static const allUsers = '/allUsers';
  static const addUser = '/addUser';
  static const detailUser = '/detailUser';
  static const updateUser = '/updateUser';

  static const newAssessmentSimulatorFlight = '/newAssessmentSimulatorFlight';
  static const newAssessmentCandidate = '/newAssessmentCandidate';
  static const newAssessmentFlightDetails = '/newAssessmentFlightDetails';
  static const newAssessmentVariables = '/newAssessmentVariables';
  static const newAssessmentVariablesSecond = '/newAssessmentVariablesSecond';
  static const newAssessmentHumanFactorVariables =
      '/newAssessmentHumanFactorVariables';
  static const newAssessmentOverallPerformance =
      '/newAssessmentOverallPerformance';
  static const newAssessmentDeclaration = '/newAssessmentDeclaration';
  static const newAssessmentSuccess = '/newAssessmentSuccess';
  static const newAssessmentInstructorNotes = '/newAssessmentInstructorNotes';

  static const allAssessmentPeriods = '/allAssessmentPeriods';
  static const detailAssessmentPeriod = '/detailAssessmentPeriod';
  static const addAssessmentPeriod = '/addAssessmentPeriod';
  static const updateAssessmentPeriod = '/updateAssessmentPeriod';

  static const resultAssessmentVariables = '/resultAssessmentVariables';
  static const resultAssessmentOverall = '/resultAssessmentOverall';
  static const resultAssessmentDeclaration = '/resultAssessmentDeclaration';

  //Control Card
  static const NAVADMIN = '/navadmin';
  static const HOMECC = '/homecc';
  static const PROFILECC = '/profilecc';

  //EFB
  static const NAVOCC = '/navocc';
  static const HOMEOCC = '/homeocc';
  static const LISTDEVICEOCC = '/listdeviceocc';
  static const ANALYTICS = '/analytics';

  //PILOT EFB
  static const HOMEPILOT = '/homepilot';

  //OCC EFB
  static const HOMEFO = '/homefo';

  static const TRAININGCC = '/trainingcc';
  static const PILOTCREWCC = '/pilotcrewcc';
  static const TRAININGTYPECC = '/trainingtypecc';
  static const ADD_ATTENDANCECC = '/add-attendancecc';
  static String ATTENDANCE_CONFIRCC(String attendanceId) {
    return '/attendance-confircc/$attendanceId';
  }

  static const NAVCAPTAIN = '/navcaptain';
  static const HOME_INSTRUCTORCC = '/home-instructorcc';
  static const TRAINING_INSTRUCTORCC = '/training-instructorcc';
  static const HOME_ADMINCC = '/home-admincc';
  static const INSTRUCTOR_MAIN_HOMECC = '/instructor-main-homecc';
  static const NAVINSTRUCTOR = '/navinstructor';
  static const ATTENDANCE_PENDINGCC = '/attendance-pendingcc';
  static const PROFILE = '/profile';
}
