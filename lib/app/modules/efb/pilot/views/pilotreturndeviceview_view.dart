import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/app/modules/efb/feedback/PilotFeedback.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilotsignature_view.dart';
import 'package:ts_one/app/modules/efb/pilot/views/return_other_pilot_view.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class PilotreturndeviceviewView extends StatefulWidget {
  final String deviceName;
  final String deviceId;
  final String OccOnDuty;

  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();
  Uint8List? signatureImage;

  PilotreturndeviceviewView({required this.deviceName, required this.deviceId, required this.OccOnDuty});

  @override
  _PilotreturndeviceviewViewState createState() => _PilotreturndeviceviewViewState();
}

Future<String> getDocumentIdForDevice(String deviceId) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('pilot-device-1').where('document_id', isEqualTo: deviceId).get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs[0].id;
  } else {
    return 'N/A';
  }
}

class _PilotreturndeviceviewViewState extends State<PilotreturndeviceviewView> {
  bool isReturnToOCC = false;
  bool isReturnToOtherPilot = false;

  String getMonthText(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'Desember'
    ];
    return months[month - 1]; // Index 0-11 for Januari-Desember
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No Data';

    DateTime dateTime = timestamp.toDate();
    String formattedDateTime = '${dateTime.day} ${getMonthText(dateTime.month)} ${dateTime.year}'
        ' ; '
        '${dateTime.hour}:${dateTime.minute}';
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Device In Use',
          style: tsOneTextTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              FutureBuilder(
                future: Future.wait([
                  FirebaseFirestore.instance.collection('Device').where('deviceno', isEqualTo: widget.deviceName).get(),
                  FirebaseFirestore.instance.collection('pilot-device-1').where('device_name', isEqualTo: widget.deviceName).get(),
                ]),
                builder: (context, snapshotList) {
                  if (snapshotList.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshotList.hasError) {
                    return Center(
                      child: Text('Error: ${snapshotList.error.toString()}'),
                    );
                  } else {
                    final deviceSnapshot = snapshotList.data![0];
                    final pilotDeviceSnapshot = snapshotList.data![1];

                      return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection("Device").doc(widget.deviceName).get(),
                      builder: (context, deviceSnapshot) {
                      if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                      }

                      if (deviceSnapshot.hasError) {
                      return Center(child: Text('Error: ${deviceSnapshot.error}'));
                      }

                      if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                      return const Center(child: Text('Device data not found'));
                      }

                      final deviceData = deviceSnapshot.data!.data() as Map<String, dynamic>;

                    // Handle data from 'pilot-device-1' collection
                    final pilotDeviceData = pilotDeviceSnapshot.docs.isNotEmpty ? pilotDeviceSnapshot.docs.first.data() : <String, dynamic>{};
                    final occOnDuty = pilotDeviceData['occ-on-duty'] as String? ?? 'N/A';

                    final userUid = pilotDeviceData['user_uid'];
                    final feedbackId = pilotDeviceData['feedbackId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection("users").doc(userUid).get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (userSnapshot.hasError) {
                          return Center(child: Text('Error: ${userSnapshot.error}'));
                        }

                        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                          return const Center(child: Text('User data not found'));
                        }

                        final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(_formatTimestamp(pilotDeviceData['timestamp']), style: tsOneTextTheme.labelSmall),
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      const Expanded(flex: 6, child: Text("ID NO")),
                                      const Expanded(child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text('${userData['ID NO'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      const Expanded(flex: 6, child: Text("Name")),
                                      const Expanded(child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text('${userData['NAME'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      const Expanded(flex: 6, child: Text("Rank")),
                                      const Expanded(child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text('${userData['RANK'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
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
                                            'Device Details',
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
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Device 1", style: tsOneTextTheme.displaySmall),
                                  ),
                                  const SizedBox(height: 7.0),
                                  Row(
                                    children: [
                                      const Expanded(flex: 5, child: Text("Device No")),
                                      const Expanded(child: Text(":")),
                                      Expanded(flex: 5, child: Text(
                                        '${deviceData['value']['deviceno'] ?? 'No Data'}',

                                      ),),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(flex: 5, child: Text("IOS Version")),
                                      const Expanded(child: Text(":")),
                                      Expanded(flex: 5, child: Text(
                                        '${deviceData['value']['iosver'] ?? 'No Data'}',

                                      ),),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(flex: 5, child: Text("Flysmart Ver")),
                                      const Expanded(child: Text(":")),
                                      Expanded(flex: 5, child: Text(
                                        '${deviceData['value']['flysmart'] ?? 'No Data'}',

                                      ),),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(flex: 5, child: Text("Docunet Version")),
                                      const Expanded(child: Text(":")),
                                      Expanded(flex: 5, child: Text(
                                        '${deviceData['value']['docuversion'] ?? 'No Data'}',
                                      ),),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(flex: 5, child: Text("Lido mPilot Version")),
                                      const Expanded(child: Text(":")),
                                      Expanded(flex: 5, child: Text(
                                        '${deviceData['value']['lidoversion'] ?? 'No Data'}',

                                      ),),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(flex: 5, child: Text("HUB")),
                                      const Expanded(child: Text(":")),
                                      Expanded(flex: 5, child: Text(
                                        '${deviceData['value']['hub'] ?? 'No Data'}',

                                      ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(flex: 5, child: Text("Condition")),
                                      const Expanded(child: Text(":")),
                                      Expanded(flex: 5, child: Text(
                                        '${deviceData['value']['condition'] ?? 'No Data'}',

                                      ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
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
                                        'Feedback Form',
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
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey), // Warna dan ketebalan border dapat disesuaikan
                                  borderRadius: const BorderRadius.all(Radius.circular(10)), // Untuk sudut yang lebih berbulu
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Column(
                                    children: [
                                      // Center(
                                      //   child: Align(
                                      //     alignment: Alignment.centerLeft,
                                      //     child: Text(
                                      //       "Fill out this form after you complete the flight",
                                      //       style: tsOneTextTheme.headlineSmall?.copyWith(color: Colors.black), // Mengubah warna teks menjadi hijau
                                      //     ),
                                      //   ),
                                      // ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Fill out this form after you complete the flight",
                                            style: tsOneTextTheme.headlineSmall?.copyWith(color: Colors.black),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Text(
                                            "(Optional)",
                                            style: tsOneTextTheme.labelSmall?.copyWith(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 5),
                                      if (feedbackId == null)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                String documentId = await getDocumentIdForDevice(widget.deviceId);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PilotFeedBack(
                                                      documentId: documentId,
                                                      deviceId: widget.deviceId,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text("FeedBack"),
                                            )
                                          ],
                                        ),
                                      if (feedbackId != null)
                                        const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [Text("Your feedback has been recorded")],
                                        )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // if (feedbackId == null)
                              //   Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       ElevatedButton(
                              //           onPressed: () async {
                              //             String documentId = await getDocumentIdForDevice(widget.deviceId);
                              //             Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                 builder: (context) => PilotFeedBack(
                              //                   documentId: documentId,
                              //                   deviceId: widget.deviceId,
                              //                 ),
                              //               ),
                              //             );
                              //           },
                              //           child: const Text("FeedBack"))
                              //     ],
                              //   ),
                              // if (feedbackId != null)
                              //   const Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [Text("Your feedback has been recorded")],
                              //   )
                            ],
                          ),
                        );
                      },
                    );
                      },
                      );
                  }
                },
              ),
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
                        'Return Device',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Choose who you want to return it to :', style: TextStyle(color: TsOneColor.primary, fontWeight: FontWeight.w500))
                    ],
                  )
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: isReturnToOCC,
                          onChanged: (value) {
                            setState(() {
                              isReturnToOCC = value!;
                              isReturnToOtherPilot = !value;
                            });
                          },
                        ),
                        const Text('Return To OCC'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: isReturnToOtherPilot,
                          onChanged: (value) {
                            setState(() {
                              isReturnToOtherPilot = value!;
                              isReturnToOCC = !value;
                            });
                          },
                        ),
                        const Text('Return To Other Pilot'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
        child: ElevatedButton(
          onPressed: () async {
            if (isReturnToOCC) {
              String documentId = await getDocumentIdForDevice(widget.deviceId);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignaturePadPage(
                    documentId: documentId,
                    deviceId: widget.deviceId,
                  ),
                ),
              );
            } else if (isReturnToOtherPilot) {
              String documentId = await getDocumentIdForDevice(widget.deviceId);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReturnOtherPilotView(
                    documentId: documentId,
                    deviceId: widget.deviceId,
                    deviceName: widget.deviceName,
                    OccOnDuty: widget.OccOnDuty,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
    );
  }
}
