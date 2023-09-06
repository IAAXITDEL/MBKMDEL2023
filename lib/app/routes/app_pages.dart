import 'package:get/get.dart';

import '../../data/assessments/assessment_results.dart';
import '../../data/assessments/new_assessment.dart';
import '../../presentation/main_view.dart';
import '../../presentation/view/assessment/add_assessment_period.dart';
import '../../presentation/view/assessment/all_assessment_periods.dart';
import '../../presentation/view/assessment/detail_assessment_period.dart';
import '../../presentation/view/assessment/new_assessment_candidate.dart';
import '../../presentation/view/assessment/new_assessment_declaration.dart';
import '../../presentation/view/assessment/new_assessment_flight_details.dart';
import '../../presentation/view/assessment/new_assessment_human_factor.dart';
import '../../presentation/view/assessment/new_assessment_instructor_notes.dart';
import '../../presentation/view/assessment/new_assessment_overall_performance.dart';
import '../../presentation/view/assessment/new_assessment_simulator_flight.dart';
import '../../presentation/view/assessment/new_assessment_success.dart';
import '../../presentation/view/assessment/new_assessment_variables.dart';
import '../../presentation/view/assessment/result_assessment_declaration.dart';
import '../../presentation/view/assessment/result_assessment_overall.dart';
import '../../presentation/view/assessment/result_assessment_variables.dart';
import '../../presentation/view/assessment/update_assessment_period.dart';
import '../../presentation/view/users/add_user.dart';
import '../../presentation/view/users/all_users.dart';
import '../../presentation/view/users/detail_user.dart';
import '../../presentation/view/users/login.dart';
import '../../presentation/view/users/update_user.dart';
import '../modules/add_attendancecc/bindings/add_attendancecc_binding.dart';
import '../modules/add_attendancecc/views/add_attendancecc_view.dart';
import '../modules/attendance_confircc/bindings/attendance_confircc_binding.dart';
import '../modules/attendance_confircc/views/attendance_confircc_view.dart';
import '../modules/homecc/bindings/homecc_binding.dart';
import '../modules/homecc/views/homecc_view.dart';
import '../modules/main_home/bindings/main_home_binding.dart';
import '../modules/main_home/views/main_home_view.dart';
import '../modules/pa/navadmin/bindings/navadmin_binding.dart';
import '../modules/pa/navadmin/views/navadmin_view.dart';
import '../modules/pilotcrewcc/bindings/pilotcrewcc_binding.dart';
import '../modules/pilotcrewcc/views/pilotcrewcc_view.dart';
import '../modules/profilecc/bindings/profilecc_binding.dart';
import '../modules/profilecc/views/profilecc_view.dart';
import '../modules/trainingcc/bindings/trainingcc_binding.dart';
import '../modules/trainingcc/views/trainingcc_view.dart';
import '../modules/trainingtypecc/bindings/trainingtypecc_binding.dart';
import '../modules/trainingtypecc/views/trainingtypecc_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAIN_HOME;

  static final routes = [
    GetPage(
      name: _Paths.MAIN_HOME,
      page: () => const MainHomeView(),
      binding: MainHomeBinding(),
    ),
    GetPage(
      name: _Paths.home,
      page: () => const MainView(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: _Paths.allUsers,
      page: () => const AllUsersView(),
    ),
    GetPage(
      name: _Paths.addUser,
      page: () => const AddUserView(),
    ),
    GetPage(
      name: _Paths.detailUser,
      page: () => DetailUserView(userIDNo: Get.arguments as String),
    ),
    GetPage(
      name: _Paths.updateUser,
      page: () => UpdateUserView(userEmail: Get.arguments as String),
    ),
    GetPage(
      name: _Paths.newAssessmentSimulatorFlight,
      page: () => const NewAssessmentSimulatorFlightView(),
    ),
    GetPage(
      name: _Paths.newAssessmentCandidate,
      page: () => NewAssessmentCandidate(
        newAssessment: Get.arguments as NewAssessment,
      ),
    ),
    GetPage(
      name: _Paths.newAssessmentCandidate,
      page: () => NewAssessmentCandidate(
        newAssessment: Get.arguments as NewAssessment,
      ),
    ),
    GetPage(
      name: _Paths.newAssessmentFlightDetails,
      page: () => NewAssessmentFlightDetails(
        dataCandidate: Get.arguments as NewAssessment,
      ),
    ),
    GetPage(
      name: _Paths.newAssessmentVariables,
      page: () => NewAssessmentVariables(
        dataCandidate: Get.arguments as NewAssessment,
      ),
    ),
    GetPage(
      name: _Paths.newAssessmentHumanFactorVariables,
      page: () => NewAssessmentHumanFactor(
        dataCandidate: Get.arguments as NewAssessment,
      ),
    ),
    GetPage(
      name: _Paths.newAssessmentOverallPerformance,
      page: () => NewAssessmentOverallPerformance(
        dataCandidate: Get.arguments as NewAssessment,
      ),
    ),
    GetPage(
      name: _Paths.newAssessmentInstructorNotes,
      page: () =>
          NewAssessmentInstructorNotes(examineeId: Get.arguments as int),
    ),
    GetPage(
      name: _Paths.newAssessmentDeclaration,
      page: () => NewAssessmentDeclaration(
        newAssessment: Get.arguments as NewAssessment,
      ),
    ),
    GetPage(
      name: _Paths.newAssessmentSuccess,
      page: () => const NewAssessmentSuccess(),
    ),

    //----------------------------------------------------------------------
    GetPage(
      name: _Paths.allAssessmentPeriods,
      page: () => const AllAssessmentPeriodsView(),
    ),

    GetPage(
      name: _Paths.detailAssessmentPeriod,
      page: () => DetailAssessmentPeriodView(
          assessmentPeriodId: Get.arguments as String),
    ),

    GetPage(
      name: _Paths.addAssessmentPeriod,
      page: () => const AddAssessmentPeriodView(),
    ),

    GetPage(
      name: _Paths.updateAssessmentPeriod,
      page: () => UpdateAssessmentPeriodView(
          assessmentPeriodId: Get.arguments as String),
    ),

    GetPage(
      name: _Paths.resultAssessmentVariables,
      page: () => ResultAssessmentVariables(
        assessmentResults: Get.arguments as AssessmentResults,
      ),
    ),

    GetPage(
      name: _Paths.resultAssessmentOverall,
      page: () => ResultAssessmentOverall(
        assessmentResults: Get.arguments as AssessmentResults,
      ),
    ),

    GetPage(
      name: _Paths.resultAssessmentDeclaration,
      page: () => ResultAssessmentDeclaration(
        assessmentResults: Get.arguments as AssessmentResults,
      ),
    ),

    //-------------CONTROL CARD-----------------
    GetPage(
      name: _Paths.NAVADMIN,
      page: () => NavadminView(
        initialIndex: 0,
      ),
      binding: NavadminBinding(),
    ),
    GetPage(
      name: _Paths.HOMECC,
      page: () => const HomeccView(),
      binding: HomeccBinding(),
    ),
    GetPage(
      name: _Paths.PROFILECC,
      page: () => const ProfileccView(),
      binding: ProfileccBinding(),
    ),
    GetPage(
      name: _Paths.TRAININGCC,
      page: () => const TrainingccView(),
      binding: TrainingccBinding(),
    ),
    GetPage(
      name: _Paths.PILOTCREWCC,
      page: () => const PilotcrewccView(),
      binding: PilotcrewccBinding(),
    ),
    GetPage(
      name: _Paths.TRAININGTYPECC,
      page: () => TrainingtypeccView(),
      binding: TrainingtypeccBinding(),
    ),
    GetPage(
      name: _Paths.ADD_ATTENDANCECC,
      page: () => AddAttendanceccView(),
      binding: AddAttendanceccBinding(),
    ),
    GetPage(
      name: _Paths.ATTENDANCE_CONFIRCC(':attendanceId'),
      page: () =>  AttendanceConfirccView(),
      binding: AttendanceConfirccBinding(),
    ),

  ];
}
