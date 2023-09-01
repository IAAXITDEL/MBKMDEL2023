import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/assessments/assessment_period.dart';
import 'package:ts_one/data/assessments/assessment_variable_results.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';

import '../../../data/assessments/assessment_variables.dart';
import '../../../data/assessments/new_assessment.dart';
import '../../view_model/assessment_viewmodel.dart';

class NewAssessmentVariables extends StatefulWidget {
  const NewAssessmentVariables({Key? key, required this.dataCandidate}) : super(key: key);

  final NewAssessment dataCandidate;

  @override
  State<NewAssessmentVariables> createState() => _NewAssessmentVariablesState();
}

class _NewAssessmentVariablesState extends State<NewAssessmentVariables> {
  late AssessmentViewModel viewModel;

  late AssessmentPeriod dataAssessmentPeriod;
  late AssessmentPeriod dataAssessmentPeriodHumanFactor;

  late NewAssessment _newAssessment;

  late List<AssessmentVariables> assessmentVariables;
  late List<String> assessmentCategories;

  late List<AssessmentVariables> assessmentVariablesHumanFactor;
  late List<String> assessmentCategoriesHumanFactor;

  late List<String> manualAssessmentCategories;
  late int lengthOfManualAssessmentVariables;

  late List<Map<String, dynamic>> inputs1;
  late List<Map<String, dynamic>> inputs2;

  late List<Map<String, dynamic>> inputs1HumanFactor;
  late List<Map<String, dynamic>> inputs2HumanFactor;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    viewModel = Provider.of<AssessmentViewModel>(context, listen: false);
    _newAssessment = widget.dataCandidate;

    _newAssessment.assessmentVariablesFlights1 = [];
    _newAssessment.assessmentVariablesFlights2 = [];

    _newAssessment.assessmentVariablesFlightsHumanFactor1 = [];
    _newAssessment.assessmentVariablesFlightsHumanFactor2 = [];

    dataAssessmentPeriod = AssessmentPeriod();
    assessmentVariables = [];
    assessmentCategories = [];

    dataAssessmentPeriodHumanFactor = AssessmentPeriod();
    assessmentVariablesHumanFactor = [];
    assessmentCategoriesHumanFactor = [];

    manualAssessmentCategories = AssessmentVariables.aircraftSystemCategory;
    lengthOfManualAssessmentVariables = 5;

    inputs1 = [];
    inputs2 = [];

    inputs1HumanFactor = [];
    inputs2HumanFactor = [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllAssessment();
    });

    super.initState();
  }

  void getAllAssessment() async {
    assessmentVariables.clear();
    assessmentCategories.clear();
    _newAssessment.assessmentVariablesFlights1.clear();
    _newAssessment.assessmentVariablesFlights2.clear();
    assessmentVariablesHumanFactor.clear();
    assessmentCategoriesHumanFactor.clear();
    _newAssessment.assessmentVariablesFlightsHumanFactor1.clear();
    _newAssessment.assessmentVariablesFlightsHumanFactor2.clear();

    dataAssessmentPeriod = await viewModel.getAllFlightAssessmentVariablesFromLastPeriod();
    dataAssessmentPeriodHumanFactor = await viewModel.getAllHumanFactorAssessmentVariablesFromLastPeriod();

    for (var assessmentVariable in dataAssessmentPeriod.assessmentVariables) {
      if (!assessmentCategories.contains(assessmentVariable.category)) {
        assessmentCategories.add(assessmentVariable.category);
      }
      assessmentVariables.add(assessmentVariable);

      _newAssessment.assessmentVariablesFlights1.add(AssessmentVariableResults(
        assessmentVariableId: assessmentVariable.id,
        assessmentVariableName: assessmentVariable.name,
        assessmentVariableCategory: assessmentVariable.category,
        assessmentType: assessmentVariable.typeOfAssessment,
      ));
      _newAssessment.assessmentVariablesFlights2.add(AssessmentVariableResults(
        assessmentVariableId: assessmentVariable.id,
        assessmentVariableName: assessmentVariable.name,
        assessmentVariableCategory: assessmentVariable.category,
        assessmentType: assessmentVariable.typeOfAssessment,
      ));
    }

    // manual assessment
    assessmentCategories.addAll(manualAssessmentCategories);

    for(var assessmentCategory in manualAssessmentCategories) {
      for(int i = 0; i < lengthOfManualAssessmentVariables; i++) {
        assessmentVariables.add(AssessmentVariables(
            id: "manual-${assessmentCategory.toLowerCase()}-${i + 1}",
            name: "Manual $assessmentCategory ${i + 1}",
            category: assessmentCategory,
          typeOfAssessment: AssessmentVariables.keyPFPM,
        ));
      }
    }

    for (var assessmentCategory in manualAssessmentCategories) {
      for(int i = 0; i < lengthOfManualAssessmentVariables; i++) {
        _newAssessment.assessmentVariablesFlights1.add(AssessmentVariableResults(
          assessmentVariableId: "manual-${assessmentCategory.toLowerCase()}-${i + 1}",
          // assessmentVariableName: "Manual ${assessmentCategory.toLowerCase()} ${i + 1}",
          assessmentVariableCategory: assessmentCategory,
          assessmentType: AssessmentVariables.keyPFPM,
        ));

        _newAssessment.assessmentVariablesFlights2.add(AssessmentVariableResults(
          assessmentVariableId: "manual-${assessmentCategory.toLowerCase()}-${i + 1}",
          // assessmentVariableName: "Manual ${assessmentCategory.toLowerCase()} ${i + 1}",
          assessmentVariableCategory: assessmentCategory,
          assessmentType: AssessmentVariables.keyPFPM,
        ));
      }
    }

    // human factor
    for (var assessmentVariable in dataAssessmentPeriodHumanFactor.assessmentVariables) {
      if (!assessmentCategoriesHumanFactor.contains(assessmentVariable.category)) {
        assessmentCategoriesHumanFactor.add(assessmentVariable.category);
      }
      assessmentVariablesHumanFactor.add(assessmentVariable);

      _newAssessment.assessmentVariablesFlightsHumanFactor1.add(AssessmentVariableResults(
        assessmentVariableId: assessmentVariable.id,
        assessmentVariableName: assessmentVariable.name,
        assessmentVariableCategory: assessmentVariable.category,
        assessmentType: assessmentVariable.typeOfAssessment,
      ));
      _newAssessment.assessmentVariablesFlightsHumanFactor2.add(AssessmentVariableResults(
        assessmentVariableId: assessmentVariable.id,
        assessmentVariableName: assessmentVariable.name,
        assessmentVariableCategory: assessmentVariable.category,
        assessmentType: assessmentVariable.typeOfAssessment,
      ));
    }
  }

  void calculateOverallPerformance() {
    _newAssessment.setOverallPerformance1();
    _newAssessment.setOverallPerformance2();
    log("Overall Performance 1: ${_newAssessment.overallPerformance1}");
    log("Overall Performance 2: ${_newAssessment.overallPerformance2}");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: showExitPopup,
      child: Consumer<AssessmentViewModel>(
        builder: (_, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "New Assessment",
              ),
            ),
            body: Form(
              key: _formKey,
              child: Column(
                  children: [
                    Expanded(
                      child: model.isLoading
                      ? const Center(
                        child: CircularProgressIndicator(),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      'Main Assessments',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: _expansionTilesForNewAssessmentVariables(),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0, right: 16.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      'Human Factor Assessments',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: _expansionTilesForNewAssessmentHumanFactorVariables(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {
                          log(_newAssessment.toString());
                          if(_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            calculateOverallPerformance();
                            Navigator.pushNamed(
                              context,
                              NamedRoute.newAssessmentOverallPerformance,
                              arguments: _newAssessment,
                            );
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Please fill all the fields"),
                                duration: const Duration(milliseconds: 3000),
                                action: SnackBarAction(
                                  label: 'Close',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                          backgroundColor: TsOneColor.primary,
                          foregroundColor: TsOneColor.primaryContainer,
                          surfaceTintColor: TsOneColor.primaryContainer,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 48,
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Next",
                              style: TextStyle(color: TsOneColor.secondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _expansionTilesForNewAssessmentVariables() {
    inputs1.clear();
    inputs2.clear();
    List<Widget> expansionTiles = [];
    int indexOfVariable = 0;
    int startingIndexForInputsList = 0;

    for (var assessmentCategory in assessmentCategories) {
      startingIndexForInputsList = indexOfVariable;
      for (var assessmentVariable in assessmentVariables) {
        if (assessmentVariable.category == assessmentCategory) {
          // if not in manual assessment categories
          if (!manualAssessmentCategories.contains(assessmentCategory)) {
            buildInputFlightCrew1(assessmentVariable, indexOfVariable);
            buildInputFlightCrew2(assessmentVariable, indexOfVariable);
          }
          else{
            buildInputManualFlightCrew1(indexOfVariable);
            buildInputManualFlightCrew2(indexOfVariable);
          }

          indexOfVariable++;
        }
      }

      if(!manualAssessmentCategories.contains(assessmentCategory)) {
        expansionTiles.add(
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: ExpansionTile(
                title: Text(assessmentCategory),
                backgroundColor: TsOneColor.primary,
                collapsedBackgroundColor: TsOneColor.surface,
                textColor: TsOneColor.onPrimary,
                collapsedTextColor: TsOneColor.onSecondary,
                iconColor: TsOneColor.onPrimary,
                collapsedIconColor: TsOneColor.onSecondary,
                collapsedShape: RoundedRectangleBorder(
                  side: BorderSide(color: TsOneColor.primary.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: TsOneColor.primary.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                // keep the expansion tile open when user tap on it
                maintainState: true,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(5.0),
                        ),
                        color: TsOneColor.secondary
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0
                      ),
                      child: Column(
                        children: [
                          for (var i = startingIndexForInputsList; i < inputs1.length; i++)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inputs1[i]["assessmentName"],
                                  style: tsOneTextTheme.headlineMedium,
                                ),
                                const Text("Crew 1"),
                                ValueListenableBuilder<bool>(
                                  valueListenable: _newAssessment.assessmentVariablesFlights1[i].isNotApplicableNotifier,
                                  builder: (context, value, child) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: ListTileTheme(
                                            horizontalTitleGap: 0.0,
                                            contentPadding: EdgeInsets.zero,
                                            child: inputs1[i]["checkbox"],
                                          ),
                                        ),
                                        !value
                                            ? Flexible(
                                            flex: 7,
                                            child: Row(
                                              children: [
                                                Flexible(
                                                    flex: 5,
                                                    child: inputs1[i]["dropdown1"]
                                                ),
                                                const SizedBox(
                                                  width: 3,
                                                ),
                                                Flexible(
                                                    flex: 3, child: inputs1[i]["dropdown2"]
                                                ),
                                              ],
                                            )
                                        )
                                            : const SizedBox.shrink()
                                      ],
                                    );
                                  },
                                ),
                                const Text("Crew 2"),
                                ValueListenableBuilder(
                                  valueListenable: _newAssessment.assessmentVariablesFlights2[i].isNotApplicableNotifier,
                                  builder: (context, value, child) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: ListTileTheme(
                                            horizontalTitleGap: 0.0,
                                            contentPadding: EdgeInsets.zero,
                                            child: inputs2[i]["checkbox"],
                                          ),
                                        ),
                                        !value
                                            ? Flexible(
                                            flex: 7,
                                            child: Row(
                                              children: [
                                                Flexible(
                                                    flex: 5,
                                                    child: inputs2[i]["dropdown1"]
                                                ),
                                                const SizedBox(
                                                  width: 3,
                                                ),
                                                Flexible(
                                                    flex: 3, child: inputs2[i]["dropdown2"]
                                                ),
                                              ],
                                            )
                                        )
                                            : const SizedBox.shrink()
                                      ],
                                    );
                                  },
                                ),
                                const Divider(
                                  color: TsOneColor.onSecondary,
                                  thickness: 1.0,
                                )
                              ],
                            )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
        );
      }
      else {
        expansionTiles.add(
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: ExpansionTile(
                title: Text(assessmentCategory),
                backgroundColor: TsOneColor.primary,
                collapsedBackgroundColor: TsOneColor.surface,
                textColor: TsOneColor.onPrimary,
                collapsedTextColor: TsOneColor.onSecondary,
                iconColor: TsOneColor.onPrimary,
                collapsedIconColor: TsOneColor.onSecondary,
                collapsedShape: RoundedRectangleBorder(
                  side: BorderSide(color: TsOneColor.primary.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: TsOneColor.primary.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                // keep the expansion tile open when user tap on it
                maintainState: true,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(5.0),
                        ),
                        color: TsOneColor.secondary
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0
                      ),
                      child: Column(
                        children: [
                          for (var i = inputs1.length - lengthOfManualAssessmentVariables; i < inputs1.length; i++)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inputs1[i]["assessmentName"],
                                  style: tsOneTextTheme.headlineMedium,
                                ),
                                const Text("Crew 1"),
                                ValueListenableBuilder<bool>(
                                  valueListenable: _newAssessment.assessmentVariablesFlights1[i].isNotApplicableNotifier,
                                  builder: (context, value, child) {
                                    return Column(
                                      children: [
                                        !value
                                            ? Padding(
                                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                          child: inputs1[i]["textField"],
                                        )
                                            : const SizedBox.shrink(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              flex: 3,
                                              child: ListTileTheme(
                                                horizontalTitleGap: 0.0,
                                                contentPadding: EdgeInsets.zero,
                                                child: inputs1[i]["checkbox"],
                                              ),
                                            ),
                                            !value
                                                ? Flexible(
                                                flex: 7,
                                                child: Row(
                                                  children: [
                                                    Flexible(
                                                        flex: 5,
                                                        child: inputs1[i]["dropdown1"]
                                                    ),
                                                    const SizedBox(
                                                      width: 3,
                                                    ),
                                                    Flexible(
                                                        flex: 3, child: inputs1[i]["dropdown2"]
                                                    ),
                                                  ],
                                                )
                                            )
                                                : const SizedBox.shrink()
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const Text("Crew 2"),
                                ValueListenableBuilder(
                                  valueListenable: _newAssessment.assessmentVariablesFlights2[i].isNotApplicableNotifier,
                                  builder: (context, value, child) {
                                    return Column(
                                      children: [
                                        !value
                                            ?Padding(
                                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                          child: inputs2[i]["textField"],
                                        )
                                            :const SizedBox.shrink(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              flex: 3,
                                              child: ListTileTheme(
                                                horizontalTitleGap: 0.0,
                                                contentPadding: EdgeInsets.zero,
                                                child: inputs2[i]["checkbox"],
                                              ),
                                            ),
                                            !value
                                                ? Flexible(
                                                flex: 7,
                                                child: Row(
                                                  children: [
                                                    Flexible(
                                                        flex: 5,
                                                        child: inputs2[i]["dropdown1"]
                                                    ),
                                                    const SizedBox(
                                                      width: 3,
                                                    ),
                                                    Flexible(
                                                        flex: 3, child: inputs2[i]["dropdown2"]
                                                    ),
                                                  ],
                                                )
                                            )
                                                : const SizedBox.shrink()
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const Divider(
                                  color: TsOneColor.onSecondary,
                                  thickness: 1.0,
                                )
                              ],
                            )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
        );
      }
    }

    return expansionTiles;
  }

  void buildInputFlightCrew1(AssessmentVariables assessmentVariable, int indexOfVariable) {
    final checkbox = StatefulBuilder(
      builder: (context, setState) {
        return CheckboxListTile(
          title: const Text("N/A"),
          controlAffinity: ListTileControlAffinity.leading,
          value: _newAssessment.assessmentVariablesFlights1[indexOfVariable].isNotApplicable,
          dense: true,
          onChanged: (value) {
            setState(() {
              // _newAssessment.assessmentVariablesFlights1[indexOfVariable].isNotApplicable = value!;
              // _newAssessment.assessmentVariablesFlights1[indexOfVariable].reset();
              _newAssessment.assessmentVariablesFlights1[indexOfVariable].toggleIsNotApplicable();
            });
          },
        );
      }
    );

    Widget? dropdown1;
    Widget? dropdown2;

    if(assessmentVariable.typeOfAssessment == AssessmentVariables.keySatisfactory) {
      // assessment dropdown
      dropdown1 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlights1[indexOfVariable].assessmentSatisfactory,
        padding: const EdgeInsets.all(0),
        isExpanded: true,
        isDense: true,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlights1[indexOfVariable].assessmentSatisfactory = value as String;
          });
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          label: Text(
            "Assessment",
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        items: AssessmentVariables.satisfactoryList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
      // markers dropdown
      dropdown2 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlights1[indexOfVariable].assessmentMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlights1[indexOfVariable].assessmentMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "Markers",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
    }
    else {
      // pilot flying markers dropdown
      dropdown1 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlights1[indexOfVariable].pilotFlyingMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlights1[indexOfVariable].pilotFlyingMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "PF",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
      // pilot monitoring markers dropdown
      dropdown2 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlights1[indexOfVariable].pilotMonitoringMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlights1[indexOfVariable].pilotMonitoringMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "PM",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
    }

    inputs1.add({
      "checkbox": checkbox,
      "dropdown1": dropdown1,
      "dropdown2": dropdown2,
      "assessmentVariable": assessmentVariable,
      "assessmentName": assessmentVariable.name,
    });
  }

  void buildInputFlightCrew2(AssessmentVariables assessmentVariable, int indexOfVariable) {
    final checkbox = StatefulBuilder(
        builder: (context, setState) {
          return CheckboxListTile(
            title: const Text("N/A"),
            controlAffinity: ListTileControlAffinity.leading,
            value: _newAssessment.assessmentVariablesFlights2[indexOfVariable].isNotApplicable,
            dense: true,
            onChanged: (value) {
              setState(() {
                // _newAssessment.assessmentVariablesFlights2[indexOfVariable].isNotApplicable = value!;
                // _newAssessment.assessmentVariablesFlights2[indexOfVariable].reset();
                _newAssessment.assessmentVariablesFlights2[indexOfVariable].toggleIsNotApplicable();
              });
            },
          );
        }
    );

    Widget? dropdown1;
    Widget? dropdown2;

    if(assessmentVariable.typeOfAssessment == AssessmentVariables.keySatisfactory) {
      // assessment dropdown
      dropdown1 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlights2[indexOfVariable].assessmentSatisfactory,
        padding: const EdgeInsets.all(0),
        isExpanded: false,
        isDense: true,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlights2[indexOfVariable].assessmentSatisfactory = value as String;
          });
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          label: Text(
            "Assessment",
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        items: AssessmentVariables.satisfactoryList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
      // markers dropdown
      dropdown2 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlights2[indexOfVariable].assessmentMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlights2[indexOfVariable].assessmentMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "Markers",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
    }
    else {
      // pilot flying markers dropdown
      dropdown1 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlights2[indexOfVariable].pilotFlyingMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlights2[indexOfVariable].pilotFlyingMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "PF",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
      // pilot monitoring markers dropdown
      dropdown2 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlights2[indexOfVariable].pilotMonitoringMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlights2[indexOfVariable].pilotMonitoringMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "PM",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
    }

    inputs2.add({
      "checkbox": checkbox,
      "dropdown1": dropdown1,
      "dropdown2": dropdown2,
      "assessmentVariable": assessmentVariable,
      "assessmentName": assessmentVariable.name,
    });
  }

  void buildInputManualFlightCrew1(int indexOfVariable) {
    Widget? dropdown1;
    Widget? dropdown2;

    final textField = TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Name',
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the name variable assessed';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        setState(() {
          _newAssessment.assessmentVariablesFlights1[indexOfVariable].assessmentVariableName = value;
        });
      },
    );

    final checkbox = StatefulBuilder(
        builder: (context, setState) {
          return CheckboxListTile(
            title: const Text("N/A"),
            controlAffinity: ListTileControlAffinity.leading,
            value: _newAssessment.assessmentVariablesFlights1[indexOfVariable].isNotApplicable,
            dense: true,
            onChanged: (value) {
              setState(() {
                // _newAssessment.assessmentVariablesFlights1[indexOfVariable].isNotApplicable = value!;
                // _newAssessment.assessmentVariablesFlights1[indexOfVariable].reset();
                _newAssessment.assessmentVariablesFlights1[indexOfVariable].toggleIsNotApplicable();
              });
            },
          );
        }
    );

    // pilot flying markers dropdown
    dropdown1 = StatefulBuilder(
      builder: (context, setState) {
        return DropdownButtonFormField(
          value: _newAssessment.assessmentVariablesFlights1[indexOfVariable].pilotFlyingMarkers,
          validator: (value) {
            if (value == null) {
              return "Please select an option";
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            setState(() {
              _newAssessment.assessmentVariablesFlights1[indexOfVariable].pilotFlyingMarkers = value!;
            });
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintMaxLines: 1,
              label: Text(
                "PF",
                style: TextStyle(
                  fontSize: 12,
                ),
              )
          ),
          items: AssessmentVariables.markerList.map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(
                value.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            );
          }).toList(),
        );
      },
    );
    // pilot monitoring markers dropdown
    dropdown2 = StatefulBuilder(
      builder: (context, setState) {
        return DropdownButtonFormField(
          value: _newAssessment.assessmentVariablesFlights1[indexOfVariable].pilotMonitoringMarkers,
          validator: (value) {
            if (value == null) {
              return "Please select an option";
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            setState(() {
              _newAssessment.assessmentVariablesFlights1[indexOfVariable].pilotMonitoringMarkers = value!;
            });
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintMaxLines: 1,
              label: Text(
                "PM",
                style: TextStyle(
                  fontSize: 12,
                ),
              )
          ),
          items: AssessmentVariables.markerList.map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(
                value.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            );
          }).toList(),
        );
      },
    );

    inputs1.add({
      "checkbox": checkbox,
      "textField": textField,
      "dropdown1": dropdown1,
      "dropdown2": dropdown2,
      "assessmentName": "Manual ${indexOfVariable + 1}",
    });
  }

  void buildInputManualFlightCrew2(int indexOfVariable) {
    Widget? dropdown1;
    Widget? dropdown2;

    final textField = TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Name',
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the name variable assessed';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        setState(() {
          _newAssessment.assessmentVariablesFlights2[indexOfVariable].assessmentVariableName = value;
        });
      },
    );

    final checkbox = StatefulBuilder(
        builder: (context, setState) {
          return CheckboxListTile(
            title: const Text("N/A"),
            controlAffinity: ListTileControlAffinity.leading,
            value: _newAssessment.assessmentVariablesFlights2[indexOfVariable].isNotApplicable,
            dense: true,
            onChanged: (value) {
              setState(() {
                // _newAssessment.assessmentVariablesFlights2[indexOfVariable].isNotApplicable = value!;
                // _newAssessment.assessmentVariablesFlights2[indexOfVariable].reset();
                _newAssessment.assessmentVariablesFlights2[indexOfVariable].toggleIsNotApplicable();
              });
            },
          );
        }
    );

    // pilot flying markers dropdown
    dropdown1 = DropdownButtonFormField(
      value: _newAssessment.assessmentVariablesFlights2[indexOfVariable].pilotFlyingMarkers,
      validator: (value) {
        if (value == null) {
          return "Please select an option";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        setState(() {
          _newAssessment.assessmentVariablesFlights2[indexOfVariable].pilotFlyingMarkers = value!;
        });
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintMaxLines: 1,
          label: Text(
            "PF",
            style: TextStyle(
              fontSize: 12,
            ),
          )
      ),
      items: AssessmentVariables.markerList.map((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(
            value.toString(),
            style: const TextStyle(fontSize: 10),
          ),
        );
      }).toList(),
    );
    // pilot monitoring markers dropdown
    dropdown2 = DropdownButtonFormField(
      value: _newAssessment.assessmentVariablesFlights2[indexOfVariable].pilotMonitoringMarkers,
      validator: (value) {
        if (value == null) {
          return "Please select an option";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        setState(() {
          _newAssessment.assessmentVariablesFlights2[indexOfVariable].pilotMonitoringMarkers = value!;
        });
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintMaxLines: 1,
          label: Text(
            "PM",
            style: TextStyle(
              fontSize: 12,
            ),
          )
      ),
      items: AssessmentVariables.markerList.map((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(
            value.toString(),
            style: const TextStyle(fontSize: 10),
          ),
        );
      }).toList(),
    );

    inputs2.add({
      "checkbox": checkbox,
      "textField": textField,
      "dropdown1": dropdown1,
      "dropdown2": dropdown2,
      "assessmentName": "Manual ${indexOfVariable + 1}",
    });
  }

  List<Widget> _expansionTilesForNewAssessmentHumanFactorVariables() {
    inputs1HumanFactor.clear();
    inputs2HumanFactor.clear();
    List<Widget> expansionTiles = [];
    int indexOfVariable = 0;
    int startingIndexForInputsList = 0;

    for (var assessmentCategory in assessmentCategoriesHumanFactor) {
      startingIndexForInputsList = indexOfVariable;
      for (var assessmentVariable in assessmentVariablesHumanFactor) {
        if (assessmentVariable.category == assessmentCategory) {
          buildInputHumanFactorFlightCrew1(assessmentVariable, indexOfVariable);
          buildInputHumanFactorFlightCrew2(assessmentVariable, indexOfVariable);
          indexOfVariable++;
        }
      }

      expansionTiles.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: ExpansionTile(
              title: Text(assessmentCategory),
              backgroundColor: TsOneColor.primary,
              collapsedBackgroundColor: TsOneColor.surface,
              textColor: TsOneColor.onPrimary,
              collapsedTextColor: TsOneColor.onSecondary,
              iconColor: TsOneColor.onPrimary,
              collapsedIconColor: TsOneColor.onSecondary,
              collapsedShape: RoundedRectangleBorder(
                side: BorderSide(color: TsOneColor.primary.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(5.0),
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: TsOneColor.primary.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(5.0),
              ),
              // keep the expansion tile open when user tap on it
              maintainState: true,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(5.0),
                      ),
                      color: TsOneColor.secondary
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0
                    ),
                    child: Column(
                      children: [
                        for (var i = startingIndexForInputsList; i < inputs1HumanFactor.length; i++)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inputs1HumanFactor[i]["assessmentName"],
                                style: tsOneTextTheme.headlineMedium,
                              ),
                              const Text("Crew 1"),
                              ValueListenableBuilder<bool>(
                                valueListenable: _newAssessment.assessmentVariablesFlightsHumanFactor1[i].isNotApplicableNotifier,
                                builder: (context, value, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 3,
                                        child: ListTileTheme(
                                          horizontalTitleGap: 0.0,
                                          contentPadding: EdgeInsets.zero,
                                          child: inputs1HumanFactor[i]["checkbox"],
                                        ),
                                      ),
                                      !value
                                          ? Flexible(
                                          flex: 7,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                  flex: 5,
                                                  child: inputs1HumanFactor[i]["dropdown1"]
                                              ),
                                              const SizedBox(
                                                width: 3,
                                              ),
                                              Flexible(
                                                  flex: 3, child: inputs1HumanFactor[i]["dropdown2"]
                                              ),
                                            ],
                                          )
                                      )
                                          : const SizedBox.shrink()
                                    ],
                                  );
                                },
                              ),
                              const Text("Crew 2"),
                              ValueListenableBuilder(
                                valueListenable: _newAssessment.assessmentVariablesFlightsHumanFactor2[i].isNotApplicableNotifier,
                                builder: (context, value, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 3,
                                        child: ListTileTheme(
                                          horizontalTitleGap: 0.0,
                                          contentPadding: EdgeInsets.zero,
                                          child: inputs2HumanFactor[i]["checkbox"],
                                        ),
                                      ),
                                      !value
                                          ? Flexible(
                                          flex: 7,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                  flex: 5,
                                                  child: inputs2HumanFactor[i]["dropdown1"]
                                              ),
                                              const SizedBox(
                                                width: 3,
                                              ),
                                              Flexible(
                                                  flex: 3, child: inputs2HumanFactor[i]["dropdown2"]
                                              ),
                                            ],
                                          )
                                      )
                                          : const SizedBox.shrink()
                                    ],
                                  );
                                },
                              ),
                              const Divider(
                                color: TsOneColor.onSecondary,
                                thickness: 1.0,
                              )
                            ],
                          )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
      );
    }

    // log(inputs1HumanFactor.toString());

    return expansionTiles;
  }

  void buildInputHumanFactorFlightCrew1(AssessmentVariables assessmentVariable, int indexOfVariable) {
    final checkbox = StatefulBuilder(
        builder: (context, setState) {
          return CheckboxListTile(
            title: const Text("N/A"),
            controlAffinity: ListTileControlAffinity.leading,
            value: _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].isNotApplicable,
            dense: true,
            onChanged: (value) {
              setState(() {
                // _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].isNotApplicable = value!;
                // _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].reset();
                _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].toggleIsNotApplicable();
              });
            },
          );
        }
    );

    Widget? dropdown1;
    Widget? dropdown2;

    if(assessmentVariable.typeOfAssessment == AssessmentVariables.keySatisfactory) {
      // assessment dropdown
      dropdown1 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].assessmentSatisfactory,
        padding: const EdgeInsets.all(0),
        isExpanded: true,
        isDense: true,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].assessmentSatisfactory = value as String;
          });
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          label: Text(
            "Assessment",
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        items: AssessmentVariables.satisfactoryList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
      // markers dropdown
      dropdown2 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].assessmentMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].assessmentMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "Markers",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
    }
    else {
      // pilot flying markers dropdown
      dropdown1 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].pilotFlyingMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].pilotFlyingMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "PF",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
      // pilot monitoring markers dropdown
      dropdown2 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].pilotMonitoringMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlightsHumanFactor1[indexOfVariable].pilotMonitoringMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "PM",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
    }

    inputs1HumanFactor.add({
      "checkbox": checkbox,
      "dropdown1": dropdown1,
      "dropdown2": dropdown2,
      "assessmentVariable": assessmentVariable,
      "assessmentName": assessmentVariable.name,
    });
  }

  void buildInputHumanFactorFlightCrew2(AssessmentVariables assessmentVariable, int indexOfVariable) {
    final checkbox = StatefulBuilder(
        builder: (context, setState) {
          return CheckboxListTile(
            title: const Text("N/A"),
            controlAffinity: ListTileControlAffinity.leading,
            value: _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].isNotApplicable,
            dense: true,
            onChanged: (value) {
              setState(() {
                // _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].isNotApplicable = value!;
                // _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].reset();
                _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].toggleIsNotApplicable();
              });
            },
          );
        }
    );

    Widget? dropdown1;
    Widget? dropdown2;

    if(assessmentVariable.typeOfAssessment == AssessmentVariables.keySatisfactory) {
      // assessment dropdown
      dropdown1 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].assessmentSatisfactory,
        padding: const EdgeInsets.all(0),
        isExpanded: false,
        isDense: true,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].assessmentSatisfactory = value as String;
          });
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          label: Text(
            "Assessment",
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        items: AssessmentVariables.satisfactoryList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
      // markers dropdown
      dropdown2 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].assessmentMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].assessmentMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "Markers",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
    }
    else {
      // pilot flying markers dropdown
      dropdown1 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].pilotFlyingMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].pilotFlyingMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "PF",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
      // pilot monitoring markers dropdown
      dropdown2 = DropdownButtonFormField(
        value: _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].pilotMonitoringMarkers,
        validator: (value) {
          if (value == null) {
            return "Please select an option";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            _newAssessment.assessmentVariablesFlightsHumanFactor2[indexOfVariable].pilotMonitoringMarkers = value!;
          });
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintMaxLines: 1,
            label: Text(
              "PM",
              style: TextStyle(
                fontSize: 12,
              ),
            )
        ),
        items: AssessmentVariables.markerList.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      );
    }

    inputs2HumanFactor.add({
      "checkbox": checkbox,
      "dropdown1": dropdown1,
      "dropdown2": dropdown2,
      "assessmentVariable": assessmentVariable,
      "assessmentName": assessmentVariable.name,
    });
  }


  Future<bool> showExitPopup() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("Exiting will discard all changes and you have to refill all the fields again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ?? false;
  }
}
