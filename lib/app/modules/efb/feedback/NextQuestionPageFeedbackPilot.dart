import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/app/modules/efb/feedback/ConfirmPageFeedbackPilot.dart';

import '../../../../presentation/theme.dart';

class NextQuestionPageFeedbackPilot extends StatefulWidget {
  final String documentId;
  final String deviceId;
  final String? Q1;
  final String? Q2;
  final String? Q3;
  final String? Q4;
  final String? Q5;
  final String? Q6;

  NextQuestionPageFeedbackPilot({
    required this.documentId,
    required this.deviceId,
    this.Q1,
    this.Q2,
    this.Q3,
    this.Q4,
    this.Q5,
    this.Q6,
  });

  @override
  _NextQuestionPageFeedbackPilotState createState() => _NextQuestionPageFeedbackPilotState();
}

class _NextQuestionPageFeedbackPilotState extends State<NextQuestionPageFeedbackPilot> {
  TextEditingController? oneSectorController = TextEditingController();
  TextEditingController? twoSectorController = TextEditingController();
  TextEditingController? threeSectorController = TextEditingController();
  TextEditingController? fourSectorController = TextEditingController();
  TextEditingController? fiveSectorController = TextEditingController();
  TextEditingController? sixSectorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BATTERY LEVEL AFTER ENGINE SHUTDOWN (with or without charging)'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: oneSectorController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  labelText: 'First Sector',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: twoSectorController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  labelText: 'Second Sector',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: threeSectorController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  labelText: 'Third Sector',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: fourSectorController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  labelText: 'Fourth Sector',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: fiveSectorController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  labelText: 'Fifth Sector',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: sixSectorController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  labelText: 'Sixth Sector',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ConfirmPageFeedbackPilot(
                  documentId: widget.documentId,
                  deviceId: widget.deviceId,
                  Q1: widget.Q1,
                  Q2: widget.Q2,
                  Q3: widget.Q3,
                  Q4: widget.Q4,
                  Q5: widget.Q5,
                  Q6: widget.Q6,
                  oneSectorController: oneSectorController,
                  twoSectorController: twoSectorController,
                  threeSectorController: threeSectorController,
                  fourSectorController: fourSectorController,
                  fiveSectorController: fiveSectorController,
                  sixSectorController: sixSectorController,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: TsOneColor.greenColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              )),
          child: const Text('Next', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
