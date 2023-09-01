import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:googleapis/apigeeregistry/v1.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/presentation/view_model/assessment_results_viewmodel.dart';
import 'package:ts_one/util/util.dart';

class NewAssessmentInstructorNotes extends StatefulWidget {
  const NewAssessmentInstructorNotes({Key? key, required this.examineeId}) : super(key: key);

  final int examineeId;

  @override
  State<NewAssessmentInstructorNotes> createState() => _NewAssessmentInstructorNotesState();
}

class _NewAssessmentInstructorNotesState extends State<NewAssessmentInstructorNotes> {
  late AssessmentResultsViewModel viewModel;


  Map<String, DateTime> instructorNotes = {};

  @override
  void initState() {
    viewModel = Provider.of<AssessmentResultsViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllInstructorNotes();
    });

    super.initState();
  }

  void getAllInstructorNotes() async {
    instructorNotes = await viewModel.getInstructorNotes(widget.examineeId);
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentResultsViewModel>(
      builder: (_, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Other Instructor Notes"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child:
              viewModel.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : instructorNotes.isEmpty
              ? const Center(
                  child: Text("No Instructor Notes"),
                )
              :
            ListView.builder(
                itemCount: instructorNotes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Util.convertDateTimeDisplay(instructorNotes.values.elementAt(index).toString()),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 10,
                        controller: TextEditingController(
                          text: instructorNotes.keys.elementAt(index),
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Notes / Comment / Recommendations",
                          hintStyle: TextStyle(fontSize: 12),
                        ),
                        enabled: false,
                      ),
                      const SizedBox(
                        height: 16,
                      )
                    ],
                  );
                }
            ),
          ),
        );
      }
    );
  }
}
