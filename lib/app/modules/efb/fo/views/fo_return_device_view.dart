import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/app/modules/efb/feedback/fo/FOFeedback.dart';
import 'package:ts_one/app/modules/efb/fo/views/returnotherFOview.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilotsignature_view.dart';
import 'package:ts_one/app/modules/efb/pilot/views/return_other_pilot_view.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import 'package:ts_one/presentation/theme.dart';
import 'fo_signature_view.dart';

class FOreturndeviceviewView extends StatefulWidget {
  final String deviceName2;
  final String deviceName3;
  final String deviceId;
  final String OccOnDuty;

  FOreturndeviceviewView({required this.deviceName2, required this.deviceName3, required this.deviceId, required this.OccOnDuty});

  @override
  _FOreturndeviceviewViewState createState() => _FOreturndeviceviewViewState();
}

Future<String> getDocumentIdForDevice(String deviceId) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('pilot-device-1').where('document_id', isEqualTo: deviceId).get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs[0].id;
  } else {
    return 'N/A';
  }
}

class _FOreturndeviceviewViewState extends State<FOreturndeviceviewView> {
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
                  FirebaseFirestore.instance.collection('Device').where('deviceno', isEqualTo: widget.deviceName2).get(),
                  FirebaseFirestore.instance.collection('Device').where('deviceno', isEqualTo: widget.deviceName3).get(),
                  FirebaseFirestore.instance.collection('pilot-device-1').where('device_name2', isEqualTo: widget.deviceName2).get(),
                ]),
                builder: (context, snapshotList) {
                  // if (snapshotList.connectionState == ConnectionState.waiting) {
                  //   return CircularProgressIndicator();
                  // } else
                  if (snapshotList.hasError) {
                    return Center(
                      child: Text('Error: ${snapshotList.error.toString()}'),
                    );
                  } else {
                    final deviceSnapshot2 = snapshotList.data![0]; // Use index 0 for deviceSnapshot2
                    final deviceSnapshot3 = snapshotList.data![1]; // Use index 1 for deviceSnapshot3
                    final pilotDeviceSnapshot = snapshotList.data![2];
                    final deviceData2 = deviceSnapshot2.docs.isNotEmpty ? deviceSnapshot2.docs.first.data() : <String, dynamic>{};
                    final deviceData3 = deviceSnapshot3.docs.isNotEmpty ? deviceSnapshot3.docs.first.data() : <String, dynamic>{};
                    final pilotData = pilotDeviceSnapshot.docs.isNotEmpty ? pilotDeviceSnapshot.docs.first.data() : <String, dynamic>{};

                    // Handle data from 'pilot-device-1' collection
                    final occOnDuty = pilotData['occ-on-duty'] as String? ?? 'N/A';
                    final userUid = pilotData['user_uid'];
                    final feedbackFOId = pilotData['feedbackId'];
                    print(feedbackFOId);

                        return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection("Device").doc(widget.deviceName2).get(),
                        builder: (context, deviceUid2Snapshot) {
                        if (deviceUid2Snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                        }

                        if (deviceUid2Snapshot.hasError) {
                        return Center(child: Text('Error: ${deviceUid2Snapshot.error}'));
                        }

                        if (!deviceUid2Snapshot.hasData || !deviceUid2Snapshot.data!.exists) {
                        return const Center(child: Text('Device data 2 not found'));
                        }

                        final deviceData2 = deviceUid2Snapshot.data!.data() as Map<String, dynamic>;

                        return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection("Device").doc(widget.deviceName3).get(),
                        builder: (context, deviceUid3Snapshot) {
                        if (deviceUid3Snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                        }

                        if (deviceUid3Snapshot.hasError) {
                        return Center(child: Text('Error: ${deviceUid3Snapshot.error}'));
                        }

                        if (!deviceUid3Snapshot.hasData || !deviceUid3Snapshot.data!.exists) {
                        return const Center(child: Text('Device data 3 not found'));
                        }

                        final deviceData3 = deviceUid3Snapshot.data!.data() as Map<String, dynamic>;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection("users").doc(userUid).get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          //return Center(child: CircularProgressIndicator());
                        }

                        if (userSnapshot.hasError) {
                          return Center(child: Text('Error: ${userSnapshot.error}'));
                        }

                        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                          return const Center(child: Text('User data not found'));
                        }

                        final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(_formatTimestamp(pilotData['timestamp']), style: tsOneTextTheme.labelSmall),
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
                                  child: Text("Device 2", style: tsOneTextTheme.displaySmall),
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Device No",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData2['value']['deviceno'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "IOS Version",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData2['value']['iosver'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Flysmart Ver",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData2['value']['flysmart'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Docunet Version",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData2['value']['docuversion'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Lido mPilot Version",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData2['value']['lidoversion'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Hub",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData2['value']['hub'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Condition",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData2['value']['condition'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15.0),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Device 3", style: tsOneTextTheme.displaySmall),
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Device No",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData3['value']['deviceno'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "IOS Version",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData3['value']['iosver'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Flysmart Ver",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData3['value']['flysmart'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Docunet Version",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData3['value']['docuversion'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Lido mPilot Version",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData3['value']['lidoversion'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "HUB",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData3['value']['hub'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Condition",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    Expanded(
                                        child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${deviceData3['value']['condition'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
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
                                        if (feedbackFOId == null)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  String documentId = await getDocumentIdForDevice(widget.deviceId);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => FOFeedBack(
                                                        documentId: documentId,
                                                        deviceId: widget.deviceId,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  children: [Text("Feedback")],
                                                ),
                                              )
                                            ],
                                          ),
                                        if (feedbackFOId != null)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [Text("Your feedback has been recorded")],
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ],
                        );
                      },
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
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     ElevatedButton(
              //       onPressed: () async {
              //         String documentId = await getDocumentIdForDevice(widget.deviceId);
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => PilotFeedBack(
              //               documentId: documentId,
              //               deviceId: widget.deviceId,
              //             ),
              //           ),
              //         );
              //       },
              //       child: const Text("FeedBack"),
              //     )
              //   ],
              // ),
              const Column(
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
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
                  builder: (context) => FOSignaturePadPage(
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
                  builder: (context) => ReturnOtherFOView(
                    documentId: documentId,
                    deviceId: widget.deviceId,
                    OccOnDuty: widget.OccOnDuty,
                    deviceName2: widget.deviceName2,
                    deviceName3: widget.deviceName3,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: TsOneColor.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              )),
          child: const Text('Next', style: TextStyle(color: TsOneColor.secondary)),
        ),
      ),
    );
  }
}
