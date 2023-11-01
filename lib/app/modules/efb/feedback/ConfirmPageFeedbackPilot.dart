import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../../presentation/theme.dart';

class ConfirmPageFeedbackPilot extends StatefulWidget {
  final String documentId;
  final String deviceId;
  final String? Q1;
  final String? Q2;
  final String? Q3;
  final String? Q4;
  final String? Q5;
  final String? Q6;
  final TextEditingController? oneSectorController;
  final TextEditingController? twoSectorController;
  final TextEditingController? threeSectorController;
  final TextEditingController? fourSectorController;
  final TextEditingController? fiveSectorController;
  final TextEditingController? sixSectorController;

  ConfirmPageFeedbackPilot({
    required this.documentId,
    required this.deviceId,
    this.Q1,
    this.Q2,
    this.Q3,
    this.Q4,
    this.Q5,
    this.Q6,
    this.oneSectorController,
    this.twoSectorController,
    this.threeSectorController,
    this.fourSectorController,
    this.fiveSectorController,
    this.sixSectorController,
  });

  @override
  _ConfirmPageFeedbackPilotState createState() =>
      _ConfirmPageFeedbackPilotState();
}

class _ConfirmPageFeedbackPilotState extends State<ConfirmPageFeedbackPilot> {
  String? Q1; // To store the "Yes" or "No" value
  String? Q2; // To store the "Yes" or "No" value
  String? Q3;
  String? Q4;
  String? Q5;
  String? Q6;
  String? Q7; // To store the "Yes" or "No" value
  String? Q8; // To store the "Yes" or "No" value
  String? Q9;
  String? Q10;
  String? Q11;
  String? Q12;
  String? Q13;
  String? Q14;
  String? Q15;
  String? Q16;
  TextEditingController? ifHighController = TextEditingController();
  TextEditingController? addionalComentController = TextEditingController();

  void submitFeedback(BuildContext context) async {
    String? ifHigh = ifHighController?.text;
    String? additionalComment = addionalComentController?.text;
    String? oneSector = widget.oneSectorController?.text;
    String? twoSector = widget.twoSectorController?.text;
    String? threeSector = widget.threeSectorController?.text;
    String? fourSector = widget.fourSectorController?.text;
    String? fiveSector = widget.fiveSectorController?.text;
    String? sixSector = widget.sixSectorController?.text;

    final CollectionReference feedbackCollection =
        FirebaseFirestore.instance.collection('feedback-device');

    // Membuat dokumen baru dalam koleksi feedback-device
    DocumentReference feedbackDoc = await feedbackCollection.add({
      'timestamp': FieldValue.serverTimestamp(),
      'handover-id': widget.deviceId,
      'q1': widget.Q1,
      'q2': widget.Q2,
      'q3': widget.Q3,
      'q4': widget.Q4,
      'q5': widget.Q5,
      'q6': widget.Q6,
      '1-sector': oneSector,
      '2-sector': twoSector,
      '3-sector': threeSector,
      '4-sector': fourSector,
      '5-sector': fiveSector,
      '6-sector': sixSector,
      'additionalComment': additionalComment,
      'ifHigh': ifHigh,
      'q7': Q7,
      'q8': Q8,
      'q9': Q9,
      'q10': Q10,
      'q11': Q11,
      'q12': Q12,
      'q13': Q13,
      'q14': Q14,
      'q15': Q15,
      'q16': Q16,
    });

    String feedbackId = feedbackDoc.id;

    // Update feedbackId pada dokumen pilot-device-1
    final DocumentReference pilotDeviceRef = FirebaseFirestore.instance
        .collection('pilot-device-1')
        .doc(widget.documentId);
    await pilotDeviceRef.update({
      'feedbackId': feedbackId,
    });

    // Call the _showQuickAlert function
    _showQuickAlert(context);
  }

  // Function to show a success message using QuickAlert
  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'You have successfully added a device',
    );
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "BRACKET (RAM-MOUNT) INTEGRITY",
                    style: tsOneTextTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('Strong Mechanical Integrity During Flight',
                    style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Yes'),
                        value: 'Yes',
                        groupValue: Q7,
                        onChanged: (value) {
                          setState(() {
                            Q7 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('No'),
                        value: 'No',
                        groupValue: Q7,
                        onChanged: (value) {
                          setState(() {
                            Q7 = value;
                          });
                        },
                        activeColor: Colors.red,
                      )
                    ],
                  ),
                ),
                Text('Easy to use ', style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Yes'),
                        value: 'Yes',
                        groupValue: Q8,
                        onChanged: (value) {
                          setState(() {
                            Q8 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('No'),
                        value: 'No',
                        groupValue: Q8,
                        onChanged: (value) {
                          setState(() {
                            Q8 = value;
                          });
                        },
                        activeColor: Colors.red,
                      )
                    ],
                  ),
                ),
                Text('Easy to detached during emergency, if required',
                    style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Yes'),
                        value: 'Yes',
                        groupValue: Q9,
                        onChanged: (value) {
                          setState(() {
                            Q9 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('No'),
                        value: 'No',
                        groupValue: Q9,
                        onChanged: (value) {
                          setState(() {
                            Q9 = value;
                          });
                        },
                        activeColor: Colors.red,
                      )
                    ],
                  ),
                ),
                Text('Obstruct emergency egress',
                    style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Yes'),
                        value: 'Yes',
                        groupValue: Q10,
                        onChanged: (value) {
                          setState(() {
                            Q10 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('No'),
                        value: 'No',
                        groupValue: Q10,
                        onChanged: (value) {
                          setState(() {
                            Q10 = value;
                          });
                        },
                        activeColor: Colors.red,
                      )
                    ],
                  ),
                ),
                Text('Bracket position obstruct your vision',
                    style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Yes'),
                        value: 'Yes',
                        groupValue: Q11,
                        onChanged: (value) {
                          setState(() {
                            Q11 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('No'),
                        value: 'No',
                        groupValue: Q11,
                        onChanged: (value) {
                          setState(() {
                            Q11 = value;
                          });
                        },
                        activeColor: Colors.red,
                      )
                    ],
                  ),
                ),
                Text('If Yes, How severe did it obstruct your vision?',
                    style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Low'),
                        value: 'Low',
                        groupValue: Q12,
                        onChanged: (value) {
                          setState(() {
                            Q12 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('High'),
                        value: 'High',
                        groupValue: Q12,
                        onChanged: (value) {
                          setState(() {
                            Q12 = value;
                          });
                        },
                        activeColor: Colors.red,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                    "If high please write down your concern in the comment box below"),
                TextFormField(
                  controller: ifHighController,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    labelText: 'Write Here',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "EFB SOFTWARE INTEGRITY",
                    style: tsOneTextTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('Airbus Flysmart (Performance)',
                    style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Yes'),
                        value: 'Yes',
                        groupValue: Q13,
                        onChanged: (value) {
                          setState(() {
                            Q13 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('No'),
                        value: 'No',
                        groupValue: Q13,
                        onChanged: (value) {
                          setState(() {
                            Q13 = value;
                          });
                        },
                        activeColor: Colors.red,
                      )
                    ],
                  ),
                ),
                Text('Lido (Navigation)', style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Yes'),
                        value: 'Yes',
                        groupValue: Q14,
                        onChanged: (value) {
                          setState(() {
                            Q14 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('No'),
                        value: 'No',
                        groupValue: Q14,
                        onChanged: (value) {
                          setState(() {
                            Q14 = value;
                          });
                        },
                        activeColor: Colors.red,
                      )
                    ],
                  ),
                ),
                Text('Vistair Docunet (Library Document)',
                    style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Yes'),
                        value: 'Yes',
                        groupValue: Q15,
                        onChanged: (value) {
                          setState(() {
                            Q15 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('No'),
                        value: 'No',
                        groupValue: Q15,
                        onChanged: (value) {
                          setState(() {
                            Q15 = value;
                          });
                        },
                        activeColor: Colors.red,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text("Additional comment on all observation"),
                TextFormField(
                  controller: addionalComentController,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    labelText: 'Write Here',
                    border: OutlineInputBorder(),
                  ),
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
              submitFeedback(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: TsOneColor.greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                )),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
