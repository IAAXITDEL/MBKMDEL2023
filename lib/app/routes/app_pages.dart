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
import '../modules/cc/pilotadministrator/attendance_confircc/bindings/attendance_confircc_binding.dart';
import '../modules/cc/pilotadministrator/attendance_confircc/views/attendance_confircc_view.dart';
import '../modules/cc/cpts/detailhistorycc_cpts/bindings/detailhistorycc_cpts_binding.dart';
import '../modules/cc/cpts/detailhistorycc_cpts/views/detailhistorycc_cpts_view.dart';
import '../modules/cc/cpts/home_cptscc/bindings/home_cptscc_binding.dart';
import '../modules/cc/cpts/home_cptscc/views/home_cptscc_view.dart';
import '../modules/cc/instructor/attendance_instructorconfircc/bindings/attendance_instructorconfircc_binding.dart';
import '../modules/cc/instructor/attendance_instructorconfircc/views/attendance_instructorconfircc_view.dart';
import '../modules/cc/instructor/home_instructorcc/bindings/home_instructorcc_binding.dart';
import '../modules/cc/instructor/home_instructorcc/views/home_instructorcc_view.dart';
import '../modules/cc/instructor/training_instructorcc/bindings/training_instructorcc_binding.dart';
import '../modules/cc/instructor/training_instructorcc/views/training_instructorcc_view.dart';
import '../modules/cc/instructor/training_typeinstructorcc/bindings/training_typeinstructorcc_binding.dart';
import '../modules/cc/instructor/training_typeinstructorcc/views/training_typeinstructorcc_view.dart';
import '../modules/cc/cpts/list_absentcptscc/bindings/list_absentcptscc_binding.dart';
import '../modules/cc/cpts/list_absentcptscc/views/list_absentcptscc_view.dart';
import '../modules/cc/list_attendancecc/bindings/list_attendancecc_binding.dart';
import '../modules/cc/list_attendancecc/views/list_attendancecc_view.dart';
import '../modules/cc/list_attendancedetailcc/bindings/list_attendancedetailcc_binding.dart';
import '../modules/cc/list_attendancedetailcc/views/list_attendancedetailcc_view.dart';
import '../modules/cc/cpts/list_pilotcptscc/bindings/list_pilotcptscc_binding.dart';
import '../modules/cc/cpts/list_pilotcptscc/views/list_pilotcptscc_view.dart';
import '../modules/cc/pilotadministrator/add_attendancecc/bindings/add_attendancecc_binding.dart';
import '../modules/cc/pilotadministrator/add_attendancecc/views/add_attendancecc_view.dart';
import '../modules/cc/pilotadministrator/add_trainingcc/bindings/add_trainingcc_binding.dart';
import '../modules/cc/pilotadministrator/add_trainingcc/views/add_trainingcc_view.dart';
import '../modules/cc/pilotadministrator/attendance_pendingcc/bindings/attendance_pendingcc_binding.dart';
import '../modules/cc/pilotadministrator/attendance_pendingcc/views/attendance_pendingcc_view.dart';
import '../modules/cc/pilotadministrator/edit_attendancecc/bindings/edit_attendancecc_binding.dart';
import '../modules/cc/pilotadministrator/edit_attendancecc/views/edit_attendancecc_view.dart';
import '../modules/cc/pilotadministrator/home_admincc/bindings/home_admincc_binding.dart';
import '../modules/cc/pilotadministrator/home_admincc/views/home_admincc_view.dart';
import '../modules/cc/pilotadministrator/homecc/bindings/homecc_binding.dart';
import '../modules/cc/pilotadministrator/homecc/views/homecc_view.dart';
import '../modules/cc/pilotadministrator/pilotcrewcc/bindings/pilotcrewcc_binding.dart';
import '../modules/cc/pilotadministrator/pilotcrewcc/views/pilotcrewcc_view.dart';
import '../modules/cc/pilotadministrator/pilotcrewdetailcc/bindings/pilotcrewdetailcc_binding.dart';
import '../modules/cc/pilotadministrator/pilotcrewdetailcc/views/pilotcrewdetailcc_view.dart';
import '../modules/cc/pilotadministrator/trainingtypecc/bindings/trainingtypecc_binding.dart';
import '../modules/cc/pilotadministrator/trainingtypecc/views/trainingtypecc_view.dart';
import '../modules/cc/profilecc/bindings/profilecc_binding.dart';
import '../modules/cc/profilecc/views/profilecc_view.dart';
import '../modules/cc/training/attendance_pilotcc/bindings/attendance_pilotcc_binding.dart';
import '../modules/cc/training/attendance_pilotcc/views/attendance_pilotcc_view.dart';
import '../modules/cc/training/home_pilotcc/bindings/home_pilotcc_binding.dart';
import '../modules/cc/training/home_pilotcc/views/home_pilotcc_view.dart';
import '../modules/cc/training/pilotfeedbackformcc/bindings/pilotfeedbackformcc_binding.dart';
import '../modules/cc/training/pilotfeedbackformcc/views/pilotfeedbackformcc_view.dart';
import '../modules/cc/training/pilottraininghistorycc/bindings/pilottraininghistorycc_binding.dart';
import '../modules/cc/training/pilottraininghistorycc/views/pilottraininghistorycc_view.dart';
import '../modules/cc/training/pilottraininghistorydetailcc/bindings/pilottraininghistorydetailcc_binding.dart';
import '../modules/cc/training/pilottraininghistorydetailcc/views/pilottraininghistorydetailcc_view.dart';
import '../modules/cc/cpts/training_cptscc/bindings/training_cptscc_binding.dart';
import '../modules/cc/cpts/training_cptscc/views/training_cptscc_view.dart';
import '../modules/cc/trainingcc/bindings/trainingcc_binding.dart';
import '../modules/cc/trainingcc/views/trainingcc_view.dart';
import '../modules/cc/cpts/traininghistorycc_cpts/bindings/traininghistorycc_cpts_binding.dart';
import '../modules/cc/cpts/traininghistorycc_cpts/views/traininghistorycc_cpts_view.dart';
import '../modules/efb/analytics/bindings/analytics_binding.dart';
import '../modules/efb/analytics/views/analytics_view.dart';
import '../modules/efb/dokumen/bindings/efb_dokumen_binding.dart';
import '../modules/efb/dokumen/views/efb_dokumen_view.dart';
import '../modules/efb/occ/bindings/device_binding.dart';
import '../modules/efb/occ/bindings/homeocc_binding.dart';
import '../modules/efb/occ/views/homeocc_view.dart';
import '../modules/efb/occ/views/listdevice/listdevice.dart';
import '../modules/efb/pilot/bindings/homepilot_binding.dart';
import '../modules/efb/pilot/views/main_view_pilot.dart';
import '../modules/efb/profile/bindings/profile_binding.dart';
import '../modules/efb/profile/views/profile_view.dart';
import '../modules/main_home/bindings/main_home_binding.dart';
import '../modules/main_home/views/main_home_view.dart';
import '../modules/pa/navadmin/bindings/navadmin_binding.dart';
import '../modules/pa/navadmin/views/navadmin_view.dart';
import '../modules/pa/navcpts/bindings/navcpts_binding.dart';
import '../modules/pa/navcpts/views/navcpts_view.dart';
import '../modules/pa/navinstructor/bindings/navinstructor_binding.dart';
import '../modules/pa/navinstructor/views/navinstructor_view.dart';
import '../modules/pa/navpilot/bindings/navpilot_binding.dart';
import '../modules/pa/navpilot/views/navpilot_view.dart';
import '../modules/pa/occ/bindings/navocc_binding.dart';
import '../modules/pa/occ/views/navocc_view.dart';

// import '../modules/add_attendancecc/bindings/add_attendancecc_binding.dart';
// import '../modules/add_attendancecc/views/add_attendancecc_view.dart';
// import '../modules/attendance_confircc/bindings/attendance_confircc_binding.dart';
// import '../modules/attendance_confircc/views/attendance_confircc_view.dart';
// import '../modules/attendance_pendingcc/bindings/attendance_pendingcc_binding.dart';
// import '../modules/attendance_pendingcc/views/attendance_pendingcc_view.dart';

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
      page: () => NewAssessmentInstructorNotes(examineeId: Get.arguments as int),
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
      page: () => DetailAssessmentPeriodView(assessmentPeriodId: Get.arguments as String),
    ),

    GetPage(
      name: _Paths.addAssessmentPeriod,
      page: () => const AddAssessmentPeriodView(),
    ),

    GetPage(
      name: _Paths.updateAssessmentPeriod,
      page: () => UpdateAssessmentPeriodView(assessmentPeriodId: Get.arguments as String),
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

    //EFB -------------------------------------------------
    GetPage(
      name: _Paths.NAVOCC,
      page: () => NavOCCView(),
      binding: NavOCCBinding(),
    ),
    GetPage(
      name: _Paths.HOMEOCC,
      page: () => HomeOCCView(),
      binding: HomeOCCBinding(),
    ),
    GetPage(
      name: _Paths.LISTDEVICEOCC,
      page: () => ListDevice(),
      binding: DeviceBinding(),
    ),

    //Pilot EFB
    GetPage(
      name: _Paths.HOMEPILOT,
      page: () => HomePilotView(),
      binding: HomePilotBinding(),
    ),
    GetPage(
      name: _Paths.NAVOCC,
      page: () => const NavOCCView(),
      binding: NavOCCBinding(),
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
      name: _Paths.HOME_INSTRUCTORCC,
      page: () => const HomeInstructorccView(),
      binding: HomeInstructorccBinding(),
    ),
    GetPage(
      name: _Paths.TRAINING_INSTRUCTORCC,
      page: () => TrainingInstructorccView(),
      binding: TrainingInstructorccBinding(),
    ),
    GetPage(
      name: _Paths.HOME_ADMINCC,
      page: () => const HomeAdminccView(),
      binding: HomeAdminccBinding(),
    ),
    GetPage(
      name: _Paths.NAVINSTRUCTOR,
      page: () => NavinstructorView(
        initialIndex: 0,
      ),
      binding: NavinstructorBinding(),
    ),
    GetPage(
      name: _Paths.ATTENDANCE_PENDINGCC,
      page: () => AttendancePendingccView(),
      binding: AttendancePendingccBinding(),
    ),
    GetPage(
      name: _Paths.ATTENDANCE_CONFIRCC,
      page: () => AttendanceConfirccView(),
      binding: AttendanceConfirccBinding(),
    ),
    GetPage(
      name: _Paths.ATTENDANCE_INSTRUCTORCONFIRCC,
      page: () => AttendanceInstructorconfirccView(),
      binding: AttendanceInstructorconfirccBinding(),
    ),
    GetPage(
      name: _Paths.HOME_PILOTCC,
      page: () => const HomePilotccView(),
      binding: HomePilotccBinding(),
    ),
    GetPage(
      name: _Paths.NAVPILOT,
      page: () => NavpilotView(
        initialIndex: 0,
      ),
      binding: NavpilotBinding(),
    ),
    GetPage(
      name: _Paths.ATTENDANCE_PILOTCC,
      page: () => const AttendancePilotccView(),
      binding: AttendancePilotccBinding(),
    ),
    GetPage(
      name: _Paths.LIST_ATTENDANCECC,
      page: () => const ListAttendanceccView(),
      binding: ListAttendanceccBinding(),
    ),
    GetPage(
      name: _Paths.HOME_CPTSCC,
      page: () => HomeCptsccView(),
      binding: HomeCptsccBinding(),
    ),
    GetPage(
      name: _Paths.LIST_PILOTCPTSCC,
      page: () => const ListPilotcptsccView(),
      binding: ListPilotcptsccBinding(),
    ),
    GetPage(
      name: _Paths.LIST_ATTENDANCEDETAILCC,
      page: () => ListAttendancedetailccView(),
      binding: ListAttendancedetailccBinding(),
    ),
    GetPage(
      name: _Paths.NAVCPTS,
      page: () => NavcptsView(
        initialIndex: 0,
      ),
      binding: NavcptsBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_ATTENDANCECC,
      page: () => EditAttendanceccView(),
      binding: EditAttendanceccBinding(),
    ),
    GetPage(
      name: _Paths.PILOTCREWDETAILCC,
      page: () => const PilotcrewdetailccView(),
      binding: PilotcrewdetailccBinding(),
    ),
    GetPage(
      name: _Paths.PILOTTRAININGHISTORYCC,
      page: () => PilottraininghistoryccView(),
      binding: PilottraininghistoryccBinding(),
    ),
    GetPage(
      name: _Paths.PILOTTRAININGHISTORYDETAILCC,
      page: () => const PilottraininghistorydetailccView(),
      binding: PilottraininghistorydetailccBinding(),
    ),
    GetPage(
      name: _Paths.PILOTFEEDBACKFORMCC,
      page: () => PilotfeedbackformccView(),
      binding: PilotfeedbackformccBinding(),
    ),
    GetPage(
      name: Routes.TRAINING_TYPEINSTRUCTORCC,
      page: () => const TrainingTypeinstructorccView(),
      binding: TrainingTypeinstructorccBinding(),
    ),
    GetPage(
      name: _Paths.ADD_TRAININGCC,
      page: () => AddTrainingccView(),
      binding: AddTrainingccBinding(),
    ),
    GetPage(
      name: _Paths.TRAININGHISTORYCC_CPTS,
      page: () => TraininghistoryccCptsView(),
      binding: TraininghistoryccCptsBinding(),
    ),
    GetPage(
      name: _Paths.DETAILHISTORYCC_CPTS,
      page: () => DetailhistoryccCptsView(),
      binding: DetailhistoryccCptsBinding(),
    ),
    GetPage(
      name: _Paths.LIST_ABSENTCPTSCC,
      page: () => const ListAbsentcptsccView(),
      binding: ListAbsentcptsccBinding(),
    ),
    GetPage(
      name: _Paths.ANALYTICS,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.TRAINING_CPTSCC,
      page: () => const TrainingCptsccView(),
      binding: TrainingCptsccBinding(),
    ),

    GetPage(
      name: _Paths.EFB_DOKUMEN,
      page: () => const EfbDokumenView(),
      binding: EfbDokumenBinding(),
    ),
  ];
}
