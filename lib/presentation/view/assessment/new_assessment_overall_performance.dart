
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/assessments/assessment_variables.dart';
import 'package:ts_one/data/assessments/new_assessment.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view_model/assessment_viewmodel.dart';

class NewAssessmentOverallPerformance extends StatefulWidget {
  const NewAssessmentOverallPerformance({
    super.key,
    required this.dataCandidate,
  });

  final NewAssessment dataCandidate;

  @override
  State<NewAssessmentOverallPerformance> createState() => _NewAssessmentOverallPerformanceState();
}

class _NewAssessmentOverallPerformanceState extends State<NewAssessmentOverallPerformance> {
  late AssessmentViewModel viewModel;
  late NewAssessment _newAssessment;
  String selectedInstructorRecommendation1 = "None";
  String selectedInstructorRecommendation2 = "None";

  @override
  void initState() {
    viewModel = Provider.of<AssessmentViewModel>(context, listen: false);
    _newAssessment = widget.dataCandidate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Overall Performance",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Flight Crew 1
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintMaxLines: 1,
                      label: Text(
                        "Overall Performance",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      )),
                  value: _newAssessment.overallPerformance1.round(),
                  items: AssessmentVariables.markerList
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _newAssessment.overallPerformance1 = value as double;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintMaxLines: 1,
                      label: Text(
                        "Instructor's Recommendation",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      )),
                  value: selectedInstructorRecommendation1,
                  items: AssessmentVariables.instructorRecommendation
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _newAssessment.instructorRecommendation1 = value as String;
                      selectedInstructorRecommendation1 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context,
                        NamedRoute.newAssessmentInstructorNotes,
                        arguments: _newAssessment.idNo1
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf56464),
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
                        "See other instructor notes",
                        style: TextStyle(color: TsOneColor.secondary),
                      ),
                    ),
                  ),
                ),
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 20,
                minLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Notes / Comment / Recommendations",
                  hintStyle: TextStyle(fontSize: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _newAssessment.notes1 = value;
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    _newAssessment.notes1 = value;
                  });
                },
              ),

              // flight crew 2
              const Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintMaxLines: 1,
                      label: Text(
                        "Overall Performance",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      )),
                  value: _newAssessment.overallPerformance2.round(),
                  items: AssessmentVariables.markerList
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _newAssessment.overallPerformance2 = value as double;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintMaxLines: 1,
                      label: Text(
                        "Instructor's Recommendation",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      )),
                  value: selectedInstructorRecommendation2,
                  items: AssessmentVariables.instructorRecommendation
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _newAssessment.instructorRecommendation2 = value as String;
                      selectedInstructorRecommendation2 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context,
                        NamedRoute.newAssessmentInstructorNotes,
                        arguments: _newAssessment.idNo2
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf56464),
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
                        "See other instructor notes",
                        style: TextStyle(color: TsOneColor.secondary),
                      ),
                    ),
                  ),
                ),
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Notes / Comment / Recommendations",
                  hintStyle: TextStyle(fontSize: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _newAssessment.notes2 = value;
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    _newAssessment.notes2 = "$value\n";
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context,
                        NamedRoute.newAssessmentDeclaration,
                        arguments: _newAssessment
                    );
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
                        style: TextStyle(color: TsOneColor.secondary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
