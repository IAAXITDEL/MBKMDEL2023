import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/assessments/new_assessment.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/view_model/assessment_viewmodel.dart';

import '../../theme.dart';

class NewAssessmentFlightDetails extends StatefulWidget {
  const NewAssessmentFlightDetails({Key? key, required this.dataCandidate}) : super(key: key);

  final NewAssessment dataCandidate;

  @override
  State<NewAssessmentFlightDetails> createState() => _NewAssessmentFlightDetailsState();
}

class _NewAssessmentFlightDetailsState extends State<NewAssessmentFlightDetails> {
  late AssessmentViewModel viewModel;

  late Map<String, bool> assessmentFlightDetails1;
  late int assessmentFlightDetails1Count;
  late bool assessmentFlightDetails1Error;

  late bool _flightCrew2Enabled;
  late Map<String, bool> assessmentFlightDetails2;
  late int assessmentFlightDetails2Count;
  late bool assessmentFlightDetails2Error;

  late Map<String, Map<String, bool>> assessmentFlightDetailsWhichCanBeSelectedAgainS1;
  late Map<String, Map<String, bool>> assessmentFlightDetailsWhichCanBeSelectedAgainS2;

  late NewAssessment dataCandidate;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    viewModel = Provider.of<AssessmentViewModel>(context, listen: false);
    assessmentFlightDetails1 = {};
    assessmentFlightDetails1Count = 0;
    assessmentFlightDetails1Error = false;
    assessmentFlightDetailsWhichCanBeSelectedAgainS1 = {};
    assessmentFlightDetailsWhichCanBeSelectedAgainS2 = {};

    if (widget.dataCandidate.typeOfAssessment == NewAssessment.keyTypeOfAssessmentSimulator) {
      _flightCrew2Enabled = true;
    } else {
      _flightCrew2Enabled = false;
    }

    assessmentFlightDetails2 = {};
    assessmentFlightDetails2Count = 0;
    assessmentFlightDetails2Error = false;

    dataCandidate = widget.dataCandidate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getAssessmentFlightDetails();
    });

    super.initState();
  }

  void _getAssessmentFlightDetails() async {
    var allAssessmentFlightDetails = await viewModel.getAllAssessmentFlightDetails();
    assessmentFlightDetails1 = allAssessmentFlightDetails;
    assessmentFlightDetails2 = await viewModel.getAllAssessmentFlightDetails();

    for (var element in allAssessmentFlightDetails.keys.toList()) {
      var splitFlightDetails = element.split("/");

      if (splitFlightDetails.length > 1) {
        for (var data in splitFlightDetails) {
          // assessmentFlightDetailsWhichCanBeSelectedAgain[element];
          if (assessmentFlightDetailsWhichCanBeSelectedAgainS1[element] == null) {
            assessmentFlightDetailsWhichCanBeSelectedAgainS1.addAll({
              element: {data.trim(): false}
            });
            assessmentFlightDetailsWhichCanBeSelectedAgainS2.addAll({
              element: {data.trim(): false}
            });
          } else {
            if (!assessmentFlightDetailsWhichCanBeSelectedAgainS1[element]!.containsKey(data.trim())) {
              assessmentFlightDetailsWhichCanBeSelectedAgainS1[element]!.addAll({data.trim(): false});
              assessmentFlightDetailsWhichCanBeSelectedAgainS2[element]!.addAll({data.trim(): false});
            }
          }
        }
      }
    }

    // log(assessmentFlightDetailsWhichCanBeSelectedAgainS1.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentViewModel>(
      builder: (_, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Training/Checking Details",
              style: tsOneTextTheme.headlineMedium,
            ),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!model.isLoading)
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // flight crew 1
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
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
                                    'Flight Crew 1',
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
                          DropdownButtonFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Training or Checking Details',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: NewAssessment.keySessionDetailsTraining,
                                child: Text(NewAssessment.keySessionDetailsTraining),
                              ),
                              DropdownMenuItem(
                                value: NewAssessment.keySessionDetailsCheck,
                                child: Text(NewAssessment.keySessionDetailsCheck),
                              ),
                              DropdownMenuItem(
                                value: NewAssessment.keySessionDetailsRetraining,
                                child: Text(NewAssessment.keySessionDetailsRetraining),
                              )
                            ],
                            validator: (value) {
                              if (value == null) {
                                return "Select one of the options available";
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            value: dataCandidate.sessionDetails1,
                            onChanged: (value) {
                              setState(() {
                                dataCandidate.sessionDetails1 = value.toString();
                              });
                            },
                          ),
                          assessmentFlightDetails1Error
                              ? const Padding(
                                  padding: EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
                                  child: Text(
                                    "Select at least one option",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                              : const SizedBox(),
                          Column(
                            children: assessmentFlightDetails1.keys
                                .map<Widget>(
                                  (item) => ListTileTheme(
                                    contentPadding: const EdgeInsets.all(0),
                                    child: item.split("/").length > 1
                                        ? ExpansionTile(
                                            controlAffinity: ListTileControlAffinity.leading,
                                            tilePadding: const EdgeInsets.only(left: 9),
                                            title: Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Text(
                                                item,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            children: assessmentFlightDetailsWhichCanBeSelectedAgainS1[item]!
                                                .keys
                                                .map<Widget>(
                                                  (subItem) => CheckboxListTile(
                                                    contentPadding: const EdgeInsets.only(left: 20),
                                                    dense: true,
                                                    title: Text(
                                                      subItem,
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                    controlAffinity: ListTileControlAffinity.leading,
                                                    value: assessmentFlightDetailsWhichCanBeSelectedAgainS1[item]![subItem],
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        assessmentFlightDetailsWhichCanBeSelectedAgainS1[item]![subItem] = newValue!;

                                                        if (newValue == true) {
                                                          assessmentFlightDetailsWhichCanBeSelectedAgainS1[item]!.forEach((key, value) {
                                                            if (key != subItem) {
                                                              assessmentFlightDetailsWhichCanBeSelectedAgainS1[item]![key] = false;
                                                            }
                                                          });
                                                        } else {
                                                          assessmentFlightDetailsWhichCanBeSelectedAgainS1[item]![subItem] = false;
                                                          dataCandidate.assessmentFlightDetails1.flightDetails.remove("$item:$subItem");
                                                        }

                                                        if (!dataCandidate.assessmentFlightDetails1.flightDetails.contains("$item:$subItem")) {
                                                          dataCandidate.assessmentFlightDetails1.flightDetails.add("$item:$subItem");
                                                          assessmentFlightDetails1Count++;
                                                        } else {
                                                          dataCandidate.assessmentFlightDetails1.flightDetails.remove("$item:$subItem");
                                                          assessmentFlightDetails1Count--;
                                                        }

                                                        if (assessmentFlightDetails1Count == 0) {
                                                          setState(() {
                                                            assessmentFlightDetails1Error = true;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            assessmentFlightDetails1Error = false;
                                                          });
                                                        }
                                                      });
                                                    },
                                                  ),
                                                )
                                                .toList(),
                                          )
                                        : item == "Recurrent …." || item == "Other ...."
                                        ? ExpansionTile(
                                      controlAffinity: ListTileControlAffinity.leading,
                                      tilePadding: const EdgeInsets.only(left: 9),
                                      title: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text(
                                          item,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 50, bottom: 16.0, top: 5),
                                          child: TextFormField(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Input',
                                            ),
                                            textInputAction: TextInputAction.next,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter the data';
                                              }
                                              return null;
                                            },
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            onChanged: (value) {
                                              // _newAssessment.airportAndRoute = value;
                                              int existingIndex = dataCandidate.assessmentFlightDetails1.flightDetails.indexWhere((element) => element.startsWith(item));
                                              if (value.isNotEmpty) {
                                                setState(() {
                                                  if (existingIndex != -1) {
                                                    dataCandidate.assessmentFlightDetails1.flightDetails[existingIndex] = "$item:$value";
                                                  } else {
                                                    dataCandidate.assessmentFlightDetails1.flightDetails.add("$item:$value");
                                                    assessmentFlightDetails1Count++;
                                                  }
                                                });
                                              } else {
                                                setState(() {
                                                  dataCandidate.assessmentFlightDetails1.flightDetails.removeAt(existingIndex);
                                                  assessmentFlightDetails1Count--;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                        : CheckboxListTile(
                                            dense: true,
                                            value: assessmentFlightDetails1[item],
                                            onChanged: (newValue) {
                                              setState(() {
                                                assessmentFlightDetails1[item] = newValue!;

                                                if (newValue) {
                                                  if (!dataCandidate.assessmentFlightDetails1.flightDetails.contains(item)) {
                                                    dataCandidate.assessmentFlightDetails1.flightDetails.add(item);
                                                    assessmentFlightDetails1Count++;
                                                  }
                                                } else {
                                                  dataCandidate.assessmentFlightDetails1.flightDetails.remove(item);
                                                  assessmentFlightDetails1Count--;
                                                }

                                                if (assessmentFlightDetails1Count == 0) {
                                                  setState(() {
                                                    assessmentFlightDetails1Error = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    assessmentFlightDetails1Error = false;
                                                  });
                                                }
                                              });
                                            },
                                            title: Text(
                                              item,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            controlAffinity: ListTileControlAffinity.leading,
                                          ),
                                  ),
                                )
                                .toList(),
                          ),

                          // flight crew 2
                          _flightCrew2Enabled
                              ? Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 16.0),
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
                                              'Flight Crew 2',
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
                                    DropdownButtonFormField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Training or Checking Details',
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: NewAssessment.keySessionDetailsTraining,
                                          child: Text(NewAssessment.keySessionDetailsTraining),
                                        ),
                                        DropdownMenuItem(
                                          value: NewAssessment.keySessionDetailsCheck,
                                          child: Text(NewAssessment.keySessionDetailsCheck),
                                        ),
                                        DropdownMenuItem(
                                          value: NewAssessment.keySessionDetailsRetraining,
                                          child: Text(NewAssessment.keySessionDetailsRetraining),
                                        )
                                      ],
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value == null) {
                                          return "Select one of the options available";
                                        }
                                        return null;
                                      },
                                      value: dataCandidate.sessionDetails2,
                                      onChanged: (value) {
                                        setState(() {
                                          dataCandidate.sessionDetails2 = value.toString();
                                        });
                                      },
                                    ),
                                    assessmentFlightDetails2Error
                                        ? const Padding(
                                            padding: EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
                                            child: Text(
                                              "Select at least one option",
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          )
                                        : const SizedBox(),
                                    Column(
                                      children: assessmentFlightDetails2.keys
                                          .map<Widget>(
                                            (item) => ListTileTheme(
                                              contentPadding: const EdgeInsets.all(0),
                                              child: item.split("/").length > 1
                                                  ? ExpansionTile(
                                                      controlAffinity: ListTileControlAffinity.leading,
                                                      tilePadding: const EdgeInsets.only(left: 9),
                                                      title: Padding(
                                                        padding: const EdgeInsets.only(left: 8),
                                                        child: Text(
                                                          item,
                                                          style: const TextStyle(fontSize: 14),
                                                        ),
                                                      ),
                                                      children: assessmentFlightDetailsWhichCanBeSelectedAgainS2[item]!
                                                          .keys
                                                          .map<Widget>(
                                                            (subItem) => CheckboxListTile(
                                                              contentPadding: const EdgeInsets.only(left: 20),
                                                              dense: true,
                                                              title: Text(
                                                                subItem,
                                                                style: const TextStyle(fontSize: 14),
                                                              ),
                                                              controlAffinity: ListTileControlAffinity.leading,
                                                              value: assessmentFlightDetailsWhichCanBeSelectedAgainS2[item]![subItem],
                                                              onChanged: (newValue) {
                                                                setState(() {
                                                                  assessmentFlightDetailsWhichCanBeSelectedAgainS2[item]![subItem] = newValue!;

                                                                  if (newValue == true) {
                                                                    assessmentFlightDetailsWhichCanBeSelectedAgainS2[item]!.forEach((key, value) {
                                                                      if (key != subItem) {
                                                                        assessmentFlightDetailsWhichCanBeSelectedAgainS2[item]![key] = false;
                                                                      }
                                                                    });
                                                                  } else {
                                                                    assessmentFlightDetailsWhichCanBeSelectedAgainS2[item]![subItem] = false;
                                                                    dataCandidate.assessmentFlightDetails2.flightDetails.remove("$item:$subItem");
                                                                  }

                                                                  if (!dataCandidate.assessmentFlightDetails2.flightDetails.contains("$item:$subItem")) {
                                                                    dataCandidate.assessmentFlightDetails2.flightDetails.add("$item:$subItem");
                                                                    assessmentFlightDetails2Count++;
                                                                  } else {
                                                                    dataCandidate.assessmentFlightDetails2.flightDetails.remove("$item:$subItem");
                                                                    assessmentFlightDetails2Count--;
                                                                  }

                                                                  if (assessmentFlightDetails2Count == 0) {
                                                                    setState(() {
                                                                      assessmentFlightDetails2Error = true;
                                                                    });
                                                                  } else {
                                                                    setState(() {
                                                                      assessmentFlightDetails2Error = false;
                                                                    });
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                          )
                                                          .toList(),
                                                    )
                                                  : item == "Recurrent …." || item == "Other ...."
                                                  ? ExpansionTile(
                                                controlAffinity: ListTileControlAffinity.leading,
                                                tilePadding: const EdgeInsets.only(left: 9),
                                                title: Padding(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 50, bottom: 16.0, top: 5),
                                                    child: TextFormField(
                                                      decoration: const InputDecoration(
                                                        border: OutlineInputBorder(),
                                                        labelText: 'Input',
                                                      ),
                                                      textInputAction: TextInputAction.next,
                                                      validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Please enter the data';
                                                        }
                                                        return null;
                                                      },
                                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                                      onChanged: (value) {
                                                        // _newAssessment.airportAndRoute = value;
                                                        int existingIndex = dataCandidate.assessmentFlightDetails2.flightDetails.indexWhere((element) => element.startsWith(item));
                                                        if (value.isNotEmpty) {
                                                          setState(() {
                                                            if (existingIndex != -1) {
                                                              dataCandidate.assessmentFlightDetails2.flightDetails[existingIndex] = "$item:$value";
                                                            } else {
                                                              dataCandidate.assessmentFlightDetails2.flightDetails.add("$item:$value");
                                                              assessmentFlightDetails2Count++;
                                                            }
                                                          });
                                                        } else {
                                                          setState(() {
                                                            dataCandidate.assessmentFlightDetails2.flightDetails.removeAt(existingIndex);
                                                            assessmentFlightDetails2Count--;
                                                          });
                                                        }
                                                        log("YOSUAHALOHO S2: ${dataCandidate.assessmentFlightDetails2.flightDetails}");
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )
                                              : CheckboxListTile(
                                                      dense: true,
                                                      value: assessmentFlightDetails2[item],
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          assessmentFlightDetails2[item] = newValue!;

                                                          if (newValue) {
                                                            if (!dataCandidate.assessmentFlightDetails2.flightDetails.contains(item)) {
                                                              dataCandidate.assessmentFlightDetails2.flightDetails.add(item);
                                                              assessmentFlightDetails2Count++;
                                                            }
                                                          } else {
                                                            dataCandidate.assessmentFlightDetails2.flightDetails.remove(item);
                                                            assessmentFlightDetails2Count--;
                                                          }

                                                          if (assessmentFlightDetails2Count == 0) {
                                                            setState(() {
                                                              assessmentFlightDetails2Error = true;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              assessmentFlightDetails2Error = false;
                                                            });
                                                          }
                                                        });
                                                      },
                                                      title: Text(
                                                        item,
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                      controlAffinity: ListTileControlAffinity.leading,
                                                    ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                )
                              : const SizedBox(),

                          ElevatedButton(
                            onPressed: () {
                              if (assessmentFlightDetails1Count == 0) {
                                assessmentFlightDetails1Error = true;
                              }
                              if (assessmentFlightDetails2Count == 0 && _flightCrew2Enabled) {
                                assessmentFlightDetails2Error = true;
                              }
                              if (_formKey.currentState!.validate() && !assessmentFlightDetails1Error && !assessmentFlightDetails2Error) {
                                log("From newAssessmentFlightDetails $dataCandidate");
                                Navigator.pushNamed(context, NamedRoute.newAssessmentVariables, arguments: dataCandidate);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TsOneColor.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 48,
                              child: const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Next",
                                  style: TextStyle(color: TsOneColor.onPrimary),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
