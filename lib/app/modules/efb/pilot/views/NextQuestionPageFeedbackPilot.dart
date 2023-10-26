import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/app/modules/efb/pilot/views/ConfirmPageFeedbackPilot.dart';

import '../../../../../presentation/theme.dart';

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
        title: Text('Next Question Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: oneSectorController,
                  decoration: InputDecoration(labelText: 'Enter remarks'),
                ),
                TextField(
                  controller: twoSectorController,
                  decoration: InputDecoration(labelText: 'Enter remarks'),
                ),
                TextField(
                  controller: threeSectorController,
                  decoration: InputDecoration(labelText: 'Enter remarks'),
                ),
                TextField(
                  controller: fourSectorController,
                  decoration: InputDecoration(labelText: 'Enter remarks'),
                ),
                TextField(
                  controller: fiveSectorController,
                  decoration: InputDecoration(labelText: 'Enter remarks'),
                ),
                TextField(
                  controller: sixSectorController,
                  decoration: InputDecoration(labelText: 'Enter remarks'),
                ),

              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
        child: Expanded(
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
      ),
    );
  }
}
