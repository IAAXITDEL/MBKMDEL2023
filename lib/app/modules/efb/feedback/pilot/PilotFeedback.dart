import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/app/modules/efb/feedback/pilot/NextQuestionPageFeedbackPilot.dart';

import '../../../../../presentation/theme.dart';

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
      'q2': Q2,
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
        title: const Text('Feedback Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey), // Warna dan ketebalan border dapat disesuaikan
                    borderRadius: const BorderRadius.all(Radius.circular(10)), // Untuk sudut yang lebih berbulu
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Battery Integrity",
                              style: tsOneTextTheme.titleMedium?.copyWith(color: Colors.red), // Mengubah warna teks menjadi hijau
                            ),
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                        ), // Divider akan menambahkan garis horizontal di bawah teks
                        const SizedBox(height: 5),
                        Text('Do you charge the device during your duty?', style: tsOneTextTheme.labelMedium),
                        Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text('Yes', style: tsOneTextTheme.labelMedium),
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
                              title: Text('No', style: tsOneTextTheme.labelMedium),
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
                        Text('Do you find any risk or concern on the cabling?', style: tsOneTextTheme.labelMedium),
                        Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text('Yes', style: tsOneTextTheme.labelMedium),
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
                              title: Text('No', style: tsOneTextTheme.labelMedium),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey), // Atur warna dan tipe garis sesuai kebutuhan Anda
                    borderRadius: const BorderRadius.all(Radius.circular(10)), // Atur sudut border sesuai kebutuhan Anda
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Agar teks tetap di kiri
                      children: [
                        Center(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "If charging the device is REQUIRED.",
                              style: tsOneTextTheme.titleSmall?.copyWith(color: Colors.red), // Mengubah warna teks menjadi hijau
                            ),
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                        ), // Divider akan menambahkan garis horizontal di bawah teks
                        const SizedBox(height: 5),
                        Text('Flight Phase', style: tsOneTextTheme.labelMedium),
                        Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text('Cruise', style: tsOneTextTheme.labelMedium),
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
                              title: Text('Transit', style: tsOneTextTheme.labelMedium),
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
                        const SizedBox(height: 10),
                        Text('Charging duration', style: tsOneTextTheme.labelMedium),
                        Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text('0-20 Minutes', style: tsOneTextTheme.labelMedium),
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
                              title: Text('21-40 Minutes', style: tsOneTextTheme.labelMedium),
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
                              title: Text('41 - 60 Minutes', style: tsOneTextTheme.labelMedium),
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
                              title: Text('61 - 80 Minutes', style: tsOneTextTheme.labelMedium),
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
                              title: Text('81 - 100 Minutes', style: tsOneTextTheme.labelMedium),
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
                              title: Text('101 - 120 Minutes', style: tsOneTextTheme.labelMedium),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey), // Atur warna dan tipe garis sesuai kebutuhan Anda
                    borderRadius: const BorderRadius.all(Radius.circular(10)), // Atur sudut border sesuai kebutuhan Anda
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Agar teks tetap di kiri
                      children: [
                        Center(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "If charging the device is NOT REQUIRED.",
                              style: tsOneTextTheme.titleMedium?.copyWith(color: Colors.red), // Mengubah warna teks menjadi hijau
                            ),
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('Did you utilize ALL EFB software during your duty?', style: tsOneTextTheme.labelMedium),
                        Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text('Yes', style: tsOneTextTheme.labelMedium),
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
                              title: Text('No', style: tsOneTextTheme.labelMedium),
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

                        const SizedBox(height: 10), // Spasi tambahan antara teks dan radio buttons
                        Text('Which software did you utilize the most?', style: tsOneTextTheme.labelMedium),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0), // Mengatur jarak antara radio buttons
                          child: Column(
                            children: [
                              RadioListTile<String?>(
                                title: Text('Flysmart', style: tsOneTextTheme.labelMedium),
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
                                title: Text('Lido', style: tsOneTextTheme.labelMedium),
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
                                title: Text('Docunet', style: tsOneTextTheme.labelMedium),
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
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
    );
  }
}
