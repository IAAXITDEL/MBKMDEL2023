import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ts_one/data/assessments/assessment_flight_details.dart';
import 'package:ts_one/data/assessments/new_assessment.dart';
import 'package:ts_one/presentation/shared_components/dropdown_button_form_component.dart';
import 'package:ts_one/presentation/theme.dart';
import '../../../data/assessments/assessment_variables.dart';
import '../../routes.dart';

class NewAssessmentVariablesSecond extends StatefulWidget {
  const NewAssessmentVariablesSecond(
      {super.key, required this.dataAssessmentFlightDetails, required this.dataCandidate, required this.dataAssessmentVariables});

  final AssessmentFlightDetails dataAssessmentFlightDetails;
  final NewAssessment dataCandidate;
  final Map<AssessmentVariables, Map<String, String>> dataAssessmentVariables;

  @override
  State<NewAssessmentVariablesSecond> createState() => _NewAssessmentVariablesSecondState();
}

class _NewAssessmentVariablesSecondState extends State<NewAssessmentVariablesSecond> {
  late List<String> assessmentCategories;

  @override
  void initState() {
    assessmentCategories = ["Aircraft System/Procedures", "Abnormal/Emer.Proc"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log("flightDetails: ${widget.dataAssessmentFlightDetails.toString()}");
    log("dataCandidate: ${widget.dataCandidate.toString()}");
    log("dataAssessmentVariables: ${widget.dataAssessmentVariables}");

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Assessment"),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              NamedRoute.newAssessmentHumanFactorVariables,
            );
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: TsOneColor.primary,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: _expansionTilesForNewManualVariables(assessmentCategories),
          ),
        ),
      ),
    );
  }

  List<Widget> _expansionTilesForNewManualVariables(List<String> assessmentCategories) {
    List<Widget> expansionTilesVariables = [];

    for (var category in assessmentCategories) {
      expansionTilesVariables.add(
        ExpansionTile(
          title: Text(category),
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
          shape: RoundedRectangleBorder(side: BorderSide(color: TsOneColor.primary.withOpacity(0.15)), borderRadius: BorderRadius.circular(5.0)),
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(5.0),
                ),
                color: TsOneColor.secondary,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  children: [
                    Column(
                      children: [
                        TextField(
                          onChanged: (value) {},
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'New Assessment',
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                                flex: 1,
                                child: DropdownButtonFormComponent(
                                  label: "PF",
                                  isDisabled: false,
                                  value: null,
                                  onValueChanged: (newValue) {},
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              flex: 1,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: DropdownButtonFormComponent(
                                    label: "PM",
                                    isDisabled: false,
                                    value: null,
                                    onValueChanged: (newValue) {},
                                  )),
                            )
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          child: const Center(
                            child: Icon(Icons.add),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );

      expansionTilesVariables.add(const SizedBox(
        height: 15,
      ));
    }

    return expansionTilesVariables;
  }
}
