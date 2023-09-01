import 'package:flutter/material.dart';
import 'package:ts_one/data/assessments/assessment_results.dart';
import 'package:ts_one/data/assessments/new_assessment.dart';
import 'package:ts_one/presentation/main_view.dart';
import 'package:ts_one/presentation/view/assessment/add_assessment_period.dart';
import 'package:ts_one/presentation/view/assessment/all_assessment_periods.dart';
import 'package:ts_one/presentation/view/assessment/detail_assessment_period.dart';
import 'package:ts_one/presentation/view/assessment/new_assessment_candidate.dart';
import 'package:ts_one/presentation/view/assessment/new_assessment_declaration.dart';
import 'package:ts_one/presentation/view/assessment/new_assessment_flight_details.dart';
import 'package:ts_one/presentation/view/assessment/new_assessment_human_factor.dart';
import 'package:ts_one/presentation/view/assessment/new_assessment_instructor_notes.dart';
import 'package:ts_one/presentation/view/assessment/new_assessment_overall_performance.dart';
import 'package:ts_one/presentation/view/assessment/new_assessment_success.dart';
import 'package:ts_one/presentation/view/assessment/new_assessment_simulator_flight.dart';
import 'package:ts_one/presentation/view/assessment/new_assessment_variables.dart';
import 'package:ts_one/presentation/view/assessment/result_assessment_declaration.dart';
import 'package:ts_one/presentation/view/assessment/result_assessment_overall.dart';
import 'package:ts_one/presentation/view/assessment/result_assessment_variables.dart';
import 'package:ts_one/presentation/view/assessment/update_assessment_period.dart';
import 'package:ts_one/presentation/view/users/add_user.dart';
import 'package:ts_one/presentation/view/users/all_users.dart';
import 'package:ts_one/presentation/view/users/detail_user.dart';
import 'package:ts_one/presentation/view/users/login.dart';
import 'package:ts_one/presentation/view/users/update_user.dart';

class AppRoutes {
  AppRoutes._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case NamedRoute.home:
        return MaterialPageRoute<void>(
          builder: (context) => const MainView(),
          settings: settings,
        );

      case NamedRoute.login:
        return MaterialPageRoute<void>(
          builder: (context) => const LoginView(),
          settings: settings,
        );

      case NamedRoute.allUsers:
        return MaterialPageRoute<void>(
          builder: (context) => const AllUsersView(),
          settings: settings,
        );

      case NamedRoute.addUser:
        return MaterialPageRoute<void>(
          builder: (context) => const AddUserView(),
          settings: settings,
        );

      case NamedRoute.detailUser:
        return MaterialPageRoute<void>(
          builder: (context) => DetailUserView(userIDNo: settings.arguments as String),
          settings: settings,
        );

      case NamedRoute.updateUser:
        return MaterialPageRoute<void>(
          builder: (context) => UpdateUserView(userEmail: settings.arguments as String),
          settings: settings,
        );

      case NamedRoute.newAssessmentSimulatorFlight:
        return MaterialPageRoute<void>(
          builder: (context) => const NewAssessmentSimulatorFlightView(),
          settings: settings,
        );

      case NamedRoute.newAssessmentCandidate:
        return MaterialPageRoute<void>(
          builder: (context) => NewAssessmentCandidate(
            newAssessment: settings.arguments as NewAssessment,
          ),
          settings: settings,
        );

      case NamedRoute.newAssessmentFlightDetails:
        return MaterialPageRoute<void>(
          builder: (context) => NewAssessmentFlightDetails(
            dataCandidate: settings.arguments as NewAssessment,
          ),
          settings: settings,
        );

      case NamedRoute.newAssessmentVariables:
        return MaterialPageRoute<void>(
          builder: (context) => NewAssessmentVariables(
            dataCandidate: settings.arguments as NewAssessment,
          ),
          settings: settings,
        );

      case NamedRoute.newAssessmentHumanFactorVariables:
        return MaterialPageRoute<void>(
          builder: (context) => NewAssessmentHumanFactor(
            dataCandidate: settings.arguments as NewAssessment,
          ),
          settings: settings,
        );

      case NamedRoute.newAssessmentOverallPerformance:
        return MaterialPageRoute<void>(
          builder: (context) => NewAssessmentOverallPerformance(
            dataCandidate: settings.arguments as NewAssessment,
          ),
          settings: settings,
        );

      case NamedRoute.newAssessmentInstructorNotes:
        return MaterialPageRoute<void>(
          builder: (context) => NewAssessmentInstructorNotes(
              examineeId: settings.arguments as int
          ),
          settings: settings
        );


      case NamedRoute.newAssessmentDeclaration:
        return MaterialPageRoute<void>(
          builder: (context) => NewAssessmentDeclaration(
            newAssessment: settings.arguments as NewAssessment,
          ),
          settings: settings,
        );

      case NamedRoute.newAssessmentSuccess:
        return MaterialPageRoute<void>(builder: (context) => const NewAssessmentSuccess(), settings: settings);

      // =============================================================================

      case NamedRoute.allAssessmentPeriods:
        return MaterialPageRoute<void>(
          builder: (context) => const AllAssessmentPeriodsView(),
          settings: settings,
        );

      case NamedRoute.detailAssessmentPeriod:
        return MaterialPageRoute<void>(
          builder: (context) => DetailAssessmentPeriodView(assessmentPeriodId: settings.arguments as String),
          settings: settings,
        );

      case NamedRoute.addAssessmentPeriod:
        return MaterialPageRoute<void>(
          builder: (context) => const AddAssessmentPeriodView(),
          settings: settings,
        );

      case NamedRoute.updateAssessmentPeriod:
        return MaterialPageRoute<void>(
          builder: (context) => UpdateAssessmentPeriodView(assessmentPeriodId: settings.arguments as String),
          settings: settings,
        );

      case NamedRoute.resultAssessmentVariables:
        return MaterialPageRoute<void>(
          builder: (context) => ResultAssessmentVariables(
            assessmentResults: settings.arguments as AssessmentResults,
          ),
          settings: settings,
        );

      case NamedRoute.resultAssessmentOverall:
        return MaterialPageRoute<void>(
          builder: (context) => ResultAssessmentOverall(
            assessmentResults: settings.arguments as AssessmentResults,
          ),
          settings: settings,
        );

      case NamedRoute.resultAssessmentDeclaration:
        return MaterialPageRoute<void>(
          builder: (context) => ResultAssessmentDeclaration(
            assessmentResults: settings.arguments as AssessmentResults,
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute<void>(
          builder: (_) => _UndefinedView(name: settings.name),
          settings: settings,
        );
    }
  }
}

class _UndefinedView extends StatelessWidget {
  const _UndefinedView({Key? key, this.name}) : super(key: key);
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Something went wrong for $name'),
      ),
    );
  }
}

class NamedRoute {
  NamedRoute._();

  static const String main = '/';
  static const String login = '/login';
  static const String home = '/home';

  static const String allUsers = '/allUsers';
  static const String addUser = '/addUser';
  static const String detailUser = '/detailUser';
  static const String updateUser = '/updateUser';

  static const String newAssessmentSimulatorFlight = '/newAssessmentSimulatorFlight';
  static const String newAssessmentCandidate = '/newAssessmentCandidate';
  static const String newAssessmentFlightDetails = '/newAssessmentFlightDetails';
  static const String newAssessmentVariables = '/newAssessmentVariables';
  static const String newAssessmentVariablesSecond = '/newAssessmentVariablesSecond';
  static const String newAssessmentHumanFactorVariables = '/newAssessmentHumanFactorVariables';
  static const String newAssessmentOverallPerformance = '/newAssessmentOverallPerformance';
  static const String newAssessmentDeclaration = '/newAssessmentDeclaration';
  static const String newAssessmentSuccess = '/newAssessmentSuccess';
  static const String newAssessmentInstructorNotes = '/newAssessmentInstructorNotes';

  static const String allAssessmentPeriods = '/allAssessmentPeriods';
  static const String detailAssessmentPeriod = '/detailAssessmentPeriod';
  static const String addAssessmentPeriod = '/addAssessmentPeriod';
  static const String updateAssessmentPeriod = '/updateAssessmentPeriod';

  static const String resultAssessmentVariables = '/resultAssessmentVariables';
  static const String resultAssessmentOverall = '/resultAssessmentOverall';
  static const String resultAssessmentDeclaration = '/resultAssessmentDeclaration';
}
