import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../presentation/theme.dart';

class DetailHistoryFOView extends GetView {
  final String dataId;
  final String userName;
  final String deviceno2;
  final String deviceno3;

  const DetailHistoryFOView({
    Key? key,
    required this.dataId,
    required this.userName,
    required this.deviceno2,
    required this.deviceno3,
  }) : super(key: key);

  @override
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No Data';

    DateTime dateTime = timestamp.toDate();
    // Format the date and time as desired, e.g., 'dd/MM/yyyy HH:mm:ss'
    String formattedDateTime = '${dateTime.day}/${dateTime.month}/${dateTime.year}'
        ' at '
        '${dateTime.hour}:${dateTime.minute}';
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DETAIL'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection("pilot-device-1").doc(dataId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Data not found'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final userUid = data['user_uid'];
            final deviceUid2 = data['device_uid2'];
            final deviceUid3 = data['device_uid3'];
            final status = data['statusDevice'];
            final handoverTo = data['handover-to-crew'];
            final occOnDuty = data['occ-on-duty'];
            final occAccepted = data['occ-accepted-device'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("users").doc(userUid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Center(child: Text('User data not found'));
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                //handover from
                return FutureBuilder<DocumentSnapshot>(
                  future: handoverTo != null ? FirebaseFirestore.instance.collection("users").doc(handoverTo).get() : Future.value(null),
                  builder: (context, handoverToSnapshot) {
                    if (handoverToSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (handoverToSnapshot.hasError) {
                      return Center(child: Text('Error: ${handoverToSnapshot.error}'));
                    }

                    final handoverTouserData = handoverToSnapshot.data?.data() as Map<String, dynamic>?;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection("Device").doc(deviceUid2).get(),
                      builder: (context, deviceUid2Snapshot) {
                        if (deviceUid2Snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (deviceUid2Snapshot.hasError) {
                          return Center(child: Text('Error: ${deviceUid2Snapshot.error}'));
                        }

                        if (!deviceUid2Snapshot.hasData || !deviceUid2Snapshot.data!.exists) {
                          return Center(child: Text('Device data not found'));
                        }

                        final deviceData2 = deviceUid2Snapshot.data!.data() as Map<String, dynamic>;

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection("Device").doc(deviceUid3).get(),
                          builder: (context, deviceUid3Snapshot) {
                            if (deviceUid3Snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (deviceUid3Snapshot.hasError) {
                              return Center(child: Text('Error: ${deviceUid3Snapshot.error}'));
                            }

                            if (!deviceUid3Snapshot.hasData || !deviceUid3Snapshot.data!.exists) {
                              return Center(child: Text('Device data 3 not found'));
                            }

                            final deviceData3 = deviceUid3Snapshot.data!.data() as Map<String, dynamic>;

                            //occ on duty from
                            return FutureBuilder<DocumentSnapshot>(
                              future: occOnDuty != null ? FirebaseFirestore.instance.collection("users").doc(occOnDuty).get() : Future.value(null),
                              builder: (context, occOnDutySnapshot) {
                                if (occOnDutySnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                if (occOnDutySnapshot.hasError) {
                                  return Center(child: Text('Error: ${occOnDutySnapshot.error}'));
                                }

                                final occOnDutyuserData = occOnDutySnapshot.data?.data() as Map<String, dynamic>?;

                                //occ accepted from
                                return FutureBuilder<DocumentSnapshot>(
                                  future: occAccepted != null
                                      ? FirebaseFirestore.instance.collection("users").doc(occAccepted).get()
                                      : Future.value(null),
                                  builder: (context, occAcceptedSnapshot) {
                                    if (occAcceptedSnapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }

                                    if (occAcceptedSnapshot.hasError) {
                                      return Center(child: Text('Error: ${occAcceptedSnapshot.error}'));
                                    }

                                    final occAccepteduserData = occAcceptedSnapshot.data?.data() as Map<String, dynamic>?;

                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 7),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Loan Date")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text(_formatTimestamp(data['timestamp'])),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10.0),
                                                  Text(
                                                    "CREW INFO",
                                                    style: tsOneTextTheme.headlineLarge,
                                                  ),
                                                  SizedBox(height: 7.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("ID NO")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${userData['ID NO'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Name")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${userData['NAME'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Rank")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${userData['RANK'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10.0),
                                                  Text(
                                                    "DEVICE INFO 1",
                                                    style: tsOneTextTheme.headlineLarge,
                                                  ),
                                                  SizedBox(height: 7.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Device No")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${data['device_nam2'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("IOS Version")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData2['iosver'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("FlySmart Version")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData2['flysmart'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Docunet Version")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData2['docuversion'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Lido mPilot Version")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData2['lidoversion'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("HUB")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData2['hub'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Condition")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData2['condition'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),

                                                  Text(
                                                    "DEVICE INFO 2",
                                                    style: tsOneTextTheme.headlineLarge,
                                                  ),
                                                  SizedBox(height: 7.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Device No")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${data['device_name3'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("IOS Version")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData3['iosver'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("FlySmart Version")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData3['flysmart'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Docunet Version")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData3['docuversion'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Lido mPilot Version")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData3['lidoversion'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("HUB")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData3['hub'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Condition")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${deviceData3['condition'] ?? 'No Data'}'),
                                                      ),
                                                    ],
                                                  ),

                                                  SizedBox(height: 10.0),
                                                  Text(
                                                    "PROOF INFO",
                                                    style: tsOneTextTheme.headlineLarge,
                                                  ),
                                                  SizedBox(height: 7.0),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("Remarks :"),
                                                      SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 6,
                                                            child: Text('${data['remarks'] ?? '-'}'),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),

                                                  SizedBox(height: 5.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Image Proof")),
                                                      Expanded( child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Column(
                                                          children: [
                                                            if (data['prove_image_url'] != null)
                                                              Image.network(
                                                                data['prove_image_url'],
                                                                width: 100, // Adjust the width as needed
                                                                height: 100, // Adjust the height as needed
                                                              ),
                                                            if (data['prove_image_url'] == null)
                                                              Text(
                                                                'There is no data',
                                                                style: TextStyle(color: Colors.black), // Adjust the style as needed
                                                              ),
                                                            SizedBox(height: 5), // Add some spacing between the image or text and the other content
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  SizedBox(height: 10),
                                                  // Conditionally display the fields based on the status
                                                  if (status == 'Done')
                                                    Text(
                                                      "OCC ON DUTY",
                                                      style: tsOneTextTheme.headlineLarge,
                                                    ),
                                                  SizedBox(height: 7.0),
                                                  if (status == 'Done')
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("OCC That Gives")),
                                                        Expanded( child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${occOnDutyuserData?['NAME'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                  SizedBox(height: 5.0),
                                                  if (status == 'Done')
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("OCC Who Received")),
                                                        Expanded( child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${occAccepteduserData?['NAME'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),

                                                  SizedBox(height: 5.0),
                                                  if (status == 'Done')
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Image Proof")),
                                                        Expanded( child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Column(
                                                            children: [
                                                              if (data['prove_back_to_base'] == null)
                                                                Text(
                                                                  'There is no data',
                                                                  style: TextStyle(color: Colors.black),
                                                                ),
                                                              SizedBox(height: 5),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  // Show the picture in a dialog when the button is pressed
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) {
                                                                      return AlertDialog(
                                                                        content: Container(
                                                                          width: 400, // Adjust the width as needed
                                                                          height: 400, // Adjust the height as needed
                                                                          child: Image.network(
                                                                            data['prove_back_to_base'] ?? '',
                                                                            fit: BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                                child: Text('See Picture'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  // Conditionally display the fields based on the status
                                                  if (status == 'handover-to-other-crew')
                                                    Text(
                                                      "GIVEN TO",
                                                      style: tsOneTextTheme.headlineLarge,
                                                    ),
                                                  SizedBox(height: 7.0),
                                                  if (status == 'handover-to-other-crew')
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("ID NO")),
                                                        Expanded( child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: handoverTouserData != null
                                                              ? Text('${handoverTouserData['ID NO'] ?? 'Not Found'}')
                                                              : Text('Not Found'),
                                                        ),
                                                      ],
                                                    ),
                                                  SizedBox(height: 5.0),
                                                  if (status == 'handover-to-other-crew')
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("NAME")),
                                                        Expanded( child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: handoverTouserData != null
                                                              ? Text('${handoverTouserData['NAME'] ?? 'Not Found'}')
                                                              : Text('Not Found'),
                                                        ),
                                                      ],
                                                    ),
                                                  SizedBox(height: 5.0),
                                                  if (status == 'handover-to-other-crew')
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("RANK")),
                                                        Expanded( child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: handoverTouserData != null
                                                              ? Text('${handoverTouserData['RANK'] ?? 'Not Found'}')
                                                              : Text('Not Found'),
                                                        ),
                                                      ],
                                                    ),

                                                  SizedBox(height: 70.0),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      // confirmInUse(context);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: TsOneColor.greenColor,
                                                      minimumSize: const Size(double.infinity, 50),
                                                    ),
                                                    child: const Text(
                                                      'Download PDF',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
