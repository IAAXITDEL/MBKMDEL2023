import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/assessments/assessment_period.dart';
import 'package:ts_one/data/assessments/assessment_variable_results.dart';
import 'package:ts_one/data/assessments/assessment_variables.dart';
import 'package:ts_one/data/assessments/new_assessment.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view_model/assessment_viewmodel.dart';

class NewAssessmentHumanFactor extends StatefulWidget {
  const NewAssessmentHumanFactor({super.key, required this.dataCandidate});

  final NewAssessment dataCandidate;

  @override
  State<NewAssessmentHumanFactor> createState() => _NewAssessmentHumanFactorState();
}

class _NewAssessmentHumanFactorState extends State<NewAssessmentHumanFactor> {
  late AssessmentViewModel viewModel;
  late AssessmentPeriod dataAssessmentPeriodHumanFactor;
  late NewAssessment _newAssessment;
  late List<AssessmentVariables> assessmentVariablesHumanFactor;
  late List<String> assessmentCategoriesHumanFactor;
  late List<String> manualAssessmentCategories;
  late List<Map<String, dynamic>> inputs1HumanFactor;
  late List<Map<String, dynamic>> inputs2HumanFactor;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    viewModel = Provider.of<AssessmentViewModel>(context, listen: false);
    _newAssessment = widget.dataCandidate;
    _newAssessment.assessmentVariablesFlightsHumanFactor1 = [];
    _newAssessment.assessmentVariablesFlightsHumanFactor2 = [];
    dataAssessmentPeriodHumanFactor = AssessmentPeriod();
    assessmentVariablesHumanFactor = [];
    assessmentCategoriesHumanFactor = [];
    manualAssessmentCategories = AssessmentVariables.aircraftSystemCategory;
    inputs1HumanFactor = [];
    inputs2HumanFactor = [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllAssessment();
    });

    super.initState();
  }

  void getAllAssessment() async {
    assessmentVariablesHumanFactor.clear();
    assessmentCategoriesHumanFactor.clear();
    _newAssessment.assessmentVariablesFlightsHumanFactor1.clear();
    _newAssessment.assessmentVariablesFlightsHumanFactor2.clear();

    dataAssessmentPeriodHumanFactor = await viewModel.getAllHumanFactorAssessmentVariablesFromLastPeriod();

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
    return Consumer<AssessmentViewModel>(
      builder: (_, model, child){
        return Scaffold(
          appBar: AppBar(
            title: const Text("Human Factor"),
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: _expansionTilesForNewAssessmentHumanFactorVariables(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
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
    );
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
          buildInputFlightCrew1(assessmentVariable, indexOfVariable);
          buildInputFlightCrew2(assessmentVariable, indexOfVariable);
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

    return expansionTiles;
  }

  void buildInputFlightCrew1(AssessmentVariables assessmentVariable, int indexOfVariable) {
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

    inputs1HumanFactor.add({
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

    inputs2HumanFactor.add({
      "checkbox": checkbox,
      "dropdown1": dropdown1,
      "dropdown2": dropdown2,
      "assessmentVariable": assessmentVariable,
      "assessmentName": assessmentVariable.name,
    });
  }
}
