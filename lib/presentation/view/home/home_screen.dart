import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/assessments/assessment_results.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/data/users/users.dart';
import 'package:ts_one/di/locator.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view_model/assessment_results_viewmodel.dart';
import 'package:ts_one/util/util.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  void initState() {
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

    viewModel = Provider.of<AssessmentResultsViewModel>(context, listen: false);
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
      getAssessmentResults();
      checkInstructor();
    });

    super.initState();
  }

  void getAssessmentResults() async {
    if (userPreferences.getPrivileges().contains(UserModel.keyPrivilegeViewAllAssessments) &&
        userPreferences.getInstructor().contains(UserModel.keyCPTS)) {
      assessmentResultsNotConfirmedByCPTS = await viewModel.getAssessmentResultsNotConfirmByCPTS();
      _isCPTS = true;
    }
    log("dwadaw${assessmentResultsNotConfirmedByCPTS.length}");

    if(_isPilotAdministrator) {
      assessmentResults = await viewModel.getAssessmentResultsLimited(5);
      // return;
    }
    else {
      assessmentResults = await viewModel.getAssessmentResultsByCurrentUserNotConfirm();
    }
  }

  void checkInstructor() {
    log("HomeScreen: ${userPreferences.getPrivileges()}");
    if(userPreferences.getPrivileges().contains(UserModel.keyPrivilegeCreateAssessment)) {
      _isInstructor = true;
    }
    log("HomeScreen: $_isInstructor");
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        getAssessmentResults();
      },
      onVisibilityGained: () {
        getAssessmentResults();
      },
      onForegroundGained: () {
        getAssessmentResults();
      },
      child: Consumer<AssessmentResultsViewModel>(
        builder: (_, model, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hi, $titleToGreet!",
                          style: tsOneTextTheme.headlineLarge,
                        ),
                        // const Icon(
                        //   Icons.notifications,
                        //   color: Colors.black,
                        // )
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Good $timeToGreet',
                        style: tsOneTextTheme.labelMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: Icon(
                              Icons.calendar_month_outlined,
                              color: TsOneColor.onSecondary,
                              size: 32,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Util.convertDateTimeDisplay(DateTime.now().toString(), "EEEE"),
                                style: tsOneTextTheme.labelSmall,
                              ),
                              Text(
                                Util.convertDateTimeDisplay(DateTime.now().toString(), "dd MMMM yyyy"),
                                style: tsOneTextTheme.labelSmall,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assessment',
                            style: tsOneTextTheme.headlineLarge,
                          ),
                          _isInstructor
                          ? OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, NamedRoute.newAssessmentSimulatorFlight);
                            },
                            icon: const Icon(
                              Icons.add,
                              color: TsOneColor.primary,
                            ),
                            label: const Text('New Assessment'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: TsOneColor.primary),
                              backgroundColor: TsOneColor.onPrimary,
                            ),
                          )
                          : Container()
                        ],
                      ),
                    ),

                    // DONT REMOVE - PILOT HOME
                    if (userPreferences.getRank() != "Pilot Administrator")
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Need Confirmations',
                                style: tsOneTextTheme.headlineLarge,
                              ),
                            ),
                          ),
                          viewModel.isLoading
                              ? const Center(
                            child: CircularProgressIndicator(),
                          )
                              : assessmentResults.isNotEmpty
                          // Confirmation Assessment For Pilot
                              ? Column(
                            children: cardAssessment(assessmentResults, false),
                          )
                              : const Center(child: Text('There is no data that needs confirmation')),
                          if (_isCPTS)
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Need Confirmations - CPTS',
                                      style: tsOneTextTheme.headlineLarge,
                                    ),
                                  ),
                                ),
                                viewModel.isLoading
                                    ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                    : assessmentResultsNotConfirmedByCPTS.isNotEmpty
                                // Confirmation Assessment For CPTS
                                    ? Column(
                                  children: cardAssessment(assessmentResultsNotConfirmedByCPTS, true),
                                )
                                    : const Center(child: Text('There is no data that needs confirmation')),
                              ],
                            ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          viewModel.isLoading
                              ? const Center(
                            child: CircularProgressIndicator(),
                          )
                              : assessmentResults.isNotEmpty
                          // Confirmation Assessment For Pilot
                              ? Column(
                            children: cardAssessment(assessmentResults, false),
                          )
                              : const Center(child: Text('There is no data')),
                        ],
                      )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> cardAssessment(List<AssessmentResults> dataAssessment, bool isCPTS) {
    List<Widget> widgets = [];

    for (var data in dataAssessment) {
      widgets.add(
        Card(
          color: TsOneColor.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: InkWell(
            onTap: () {
              data.isCPTS = isCPTS;
              data.isFromHistory = false;
              if(_isPilotAdministrator) {
                data.isFromHistory = true;
              }
              Navigator.pushNamed(context, NamedRoute.resultAssessmentVariables, arguments: data);
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(color: TsOneColor.secondary),
                      ),
                      isCPTS
                          ? const Text(
                              'Examinee ID',
                              style: TextStyle(color: TsOneColor.secondary),
                            )
                          : Container(),
                      const Text(
                        'Instructor ID',
                        style: TextStyle(color: TsOneColor.secondary),
                      ),
                      const Text(
                        'Type of Session',
                        style: TextStyle(color: TsOneColor.secondary),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Column(
                    children: [
                      const Text(
                        ':',
                        style: TextStyle(color: TsOneColor.secondary),
                      ),
                      isCPTS
                          ? const Text(
                              ':',
                              style: TextStyle(color: TsOneColor.secondary),
                            )
                          : Container(),
                      const Text(
                        ':',
                        style: TextStyle(color: TsOneColor.secondary),
                      ),
                      const Text(
                        ':',
                        style: TextStyle(color: TsOneColor.secondary),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Util.convertDateTimeDisplay(data.date.toString()),
                          style: const TextStyle(color: TsOneColor.secondary, overflow: TextOverflow.ellipsis),
                        ),
                        isCPTS
                            ? Text(
                                data.examineeStaffIDNo.toString(),
                                style: const TextStyle(color: TsOneColor.secondary),
                                overflow: TextOverflow.ellipsis,
                              )
                            : Container(),
                        Text(
                          data.instructorStaffIDNo.toString(),
                          style: const TextStyle(color: TsOneColor.secondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          data.sessionDetails,
                          style: const TextStyle(color: TsOneColor.secondary, overflow: TextOverflow.ellipsis),
                        )
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: TsOneColor.secondary,
                    size: 48,
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
