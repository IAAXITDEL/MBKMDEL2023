import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../presentation/theme.dart';
import 'NextQuestionPageFeedbackPilot.dart';

class PilotFeedBack extends StatefulWidget {
  final String documentId;
  final String deviceId;

  PilotFeedBack({required this.documentId, required this.deviceId});

  @override
  _PilotFeedBackState createState() => _PilotFeedBackState();
}

class _PilotFeedBackState extends State<PilotFeedBack> {
  TextEditingController remarksController = TextEditingController();
  String? Q1; // To store the "Yes" or "No" value
  String? Q2; // To store the "Yes" or "No" value
  String? Q3;
  String? Q4;
  String? Q5;
  String? Q6;

  void submitFeedback(BuildContext context) async {
    String? remarks = remarksController.text;

    final CollectionReference feedbackCollection = FirebaseFirestore.instance.collection('feedback-device');

    final DocumentReference feedbackDoc = await feedbackCollection.add({
      'handover-id': widget.deviceId,
      'remarks': remarks,
      'q1': Q1,
      'q2' : Q2,
      'q3': Q3,
      'q4': Q4,
      'q5': Q5,
      'q6': Q6,
    });

    String feedbackId = feedbackDoc.id;

    final DocumentReference pilotDeviceRef = FirebaseFirestore.instance.collection('pilot-device-1').doc(widget.documentId);
    await pilotDeviceRef.update({
      'feedbackId': feedbackId,
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Batery Integrity",
                    style: tsOneTextTheme.titleMedium,
                  ),
                ),
                SizedBox(height: 5,),
                Text('Do you Charge the device during your duty?', style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                      title: Text('Yes'),
                      value: 'Yes',
                      groupValue: Q1,
                      onChanged: (value) {
                        setState(() {
                          Q1 = value;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    RadioListTile<String?>(
                      title: Text('No'),
                      value: 'No',
                      groupValue: Q1,
                      onChanged: (value) {
                        setState(() {
                          Q1 = value;
                        });
                      },
                      activeColor: Colors.red,
                    )

                ],
                  ),
                ),
                Text('Do you find any risk or concern on the cabling?', style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                      title: Text('Yes'),
                      value: 'Yes',
                      groupValue: Q2,
                      onChanged: (value) {
                        setState(() {
                          Q2 = value;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    RadioListTile<String?>(
                      title: Text('No'),
                      value: 'No',
                      groupValue: Q2,
                      onChanged: (value) {
                        setState(() {
                          Q2 = value;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                  ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "If charging the device is REQUIRED.",
                    style: tsOneTextTheme.titleMedium,
                  ),
                ),
                SizedBox(height: 5,),
                Text('Flight Phase', style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Cruise'),
                        value: 'Cruise',
                        groupValue: Q3,
                        onChanged: (value) {
                          setState(() {
                            Q3 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('Transit'),
                        value: 'Transit',
                        groupValue: Q3,
                        onChanged: (value) {
                          setState(() {
                            Q3 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10), // Spasi tambahan antara teks dan radio buttons
                Text('Charging duration', style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('0-20 Minutes'),
                        value: '0-20 Minutes',
                        groupValue: Q4,
                        onChanged: (value) {
                          setState(() {
                            Q4 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('21-40 Minutes'),
                        value: '21-40 Minutes',
                        groupValue: Q4,
                        onChanged: (value) {
                          setState(() {
                            Q4 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('41 - 60 Minutes'),
                        value: '41 - 60 Minutes',
                        groupValue: Q4,
                        onChanged: (value) {
                          setState(() {
                            Q4 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('61 - 80 Minutes'),
                        value: '61 - 80 Minutes',
                        groupValue: Q4,
                        onChanged: (value) {
                          setState(() {
                            Q4 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('81 - 100 Minutes'),
                        value: '81 - 100 Minutes',
                        groupValue: Q4,
                        onChanged: (value) {
                          setState(() {
                            Q4 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('101 - 120 Minutes'),
                        value: '101 - 120 Minutes',
                        groupValue: Q4,
                        onChanged: (value) {
                          setState(() {
                            Q4 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "If charging the device is NOT REQUIRED.",
                    style: tsOneTextTheme.titleMedium,
                  ),
                ),
                SizedBox(height: 5,),
                Text('Did you utilize ALL EFB software during your duty?', style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Yes'),
                        value: 'Yes',
                        groupValue: Q5,
                        onChanged: (value) {
                          setState(() {
                            Q5 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('No'),
                        value: 'No',
                        groupValue: Q5,
                        onChanged: (value) {
                          setState(() {
                            Q5 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10), // Spasi tambahan antara teks dan radio buttons
                Text('Which software did you utilize the most?', style: tsOneTextTheme.labelLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Mengatur jarak antara radio buttons
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: Text('Flysmart'),
                        value: 'Flysmart',
                        groupValue: Q6,
                        onChanged: (value) {
                          setState(() {
                            Q6 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('Lido'),
                        value: 'Lido',
                        groupValue: Q6,
                        onChanged: (value) {
                          setState(() {
                            Q6 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile<String?>(
                        title: Text('Docunet'),
                        value: 'Docunet',
                        groupValue: Q6,
                        onChanged: (value) {
                          setState(() {
                            Q6 = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                    ],
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NextQuestionPageFeedbackPilot(
                    documentId: widget.documentId,
                    deviceId: widget.deviceId,
                    Q1: Q1,
                    Q2: Q2,
                    Q3: Q3,
                    Q4: Q4,
                    Q5: Q5,
                    Q6: Q6,
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
