import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/modules/efb/occ/views/history/history_all_device_view.dart';

import '../../../../../../presentation/theme.dart';
import '../../../occ/views/history/handover_attachment1.dart';

class DetailHistoryDeviceView extends GetView {
  final String dataId;
  final String userName;
  final String deviceno;

  const DetailHistoryDeviceView({
    Key? key,
    required this.dataId,
    required this.userName,
    required this.deviceno,
  }) : super(key: key);

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No Data';

    DateTime dateTime = timestamp.toDate();
    // Format the date and time as desired, e.g., 'dd/MM/yyyy HH:mm:ss'
    String formattedDateTime =
        '${dateTime.day}/${dateTime.month}/${dateTime.year}'
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
          future: FirebaseFirestore.instance
              .collection("pilot-device-1")
              .doc(dataId)
              .get(),
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
            final deviceUid = data['device_uid'];
            final status = data['statusDevice'];
            final handoverTo = data['handover-to-crew'];
            final occOnDuty = data['occ-on-duty'];
            final occAccepted = data['occ-accepted-device'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(userUid)
                  .get(),
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

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;

                //handover from
                return FutureBuilder<DocumentSnapshot>(
                  future: handoverTo != null
                      ? FirebaseFirestore.instance
                          .collection("users")
                          .doc(handoverTo)
                          .get()
                      : Future.value(null),
                  builder: (context, handoverToSnapshot) {
                    if (handoverToSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (handoverToSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${handoverToSnapshot.error}'));
                    }

                    final handoverTouserData = handoverToSnapshot.data?.data()
                        as Map<String, dynamic>?;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("Device")
                          .doc(deviceUid)
                          .get(),
                      builder: (context, deviceSnapshot) {
                        if (deviceSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (deviceSnapshot.hasError) {
                          return Center(
                              child: Text('Error: ${deviceSnapshot.error}'));
                        }

                        if (!deviceSnapshot.hasData ||
                            !deviceSnapshot.data!.exists) {
                          return Center(child: Text('Device data not found'));
                        }

                        final deviceData =
                            deviceSnapshot.data!.data() as Map<String, dynamic>;

                        //occ on duty from
                        return FutureBuilder<DocumentSnapshot>(
                          future: occOnDuty != null
                              ? FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(occOnDuty)
                                  .get()
                              : Future.value(null),
                          builder: (context, occOnDutySnapshot) {
                            if (occOnDutySnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (occOnDutySnapshot.hasError) {
                              return Center(
                                  child: Text(
                                      'Error: ${occOnDutySnapshot.error}'));
                            }

                            final occOnDutyuserData = occOnDutySnapshot.data
                                ?.data() as Map<String, dynamic>?;

                            //occ accepted from
                            return FutureBuilder<DocumentSnapshot>(
                              future: occAccepted != null
                                  ? FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(occAccepted)
                                      .get()
                                  : Future.value(null),
                              builder: (context, occAcceptedSnapshot) {
                                if (occAcceptedSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                if (occAcceptedSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error: ${occAcceptedSnapshot.error}'));
                                }

                                final occAccepteduserData =
                                    occAcceptedSnapshot.data?.data()
                                        as Map<String, dynamic>?;

                                // generateLogPdfDevice1(
                                //   userName: userData['NAME'],
                                //   userRank: userData['RANK'],
                                //   userID: userData['ID NO'].toString(),
                                //   occAccept: occAccepteduserData?['NAME'],
                                //   occGiven: occOnDutyuserData?['NAME'],
                                //   deviceNo: data['device_name'],
                                //   iosVer: deviceData['iosver'],
                                //   flySmart: deviceData['flysmart'],
                                //   lido: deviceData['lidoversion'],
                                //   docunet: deviceData['docuversion'],
                                //   deviceCondition: deviceData['condition'],
                                //   ttdUser: data['signature_url'],
                                //   loan: data['timestamp'],
                                //   statusdevice: data['statusDevice'],
                                //   handoverName: handoverTouserData != null
                                //       ? handoverTouserData['NAME']
                                //       : 'Not Found',
                                //   handoverID: handoverTouserData != null
                                //       ? handoverTouserData['ID NO']
                                //       : 'Not Found',
                                // );

                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 7),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 6,
                                                      child: Text("Loan Date")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        _formatTimestamp(
                                                            data['timestamp'])),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                "CREW INFO",
                                                style: tsOneTextTheme
                                                    .headlineLarge,
                                              ),
                                              SizedBox(height: 7.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 6,
                                                      child: Text("ID NO")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        '${userData['ID NO'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 6,
                                                      child: Text("Name")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        '${userData['NAME'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 6,
                                                      child: Text("Rank")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        '${userData['RANK'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                "DEVICE INFO",
                                                style: tsOneTextTheme
                                                    .headlineLarge,
                                              ),
                                              SizedBox(height: 7.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 6,
                                                      child: Text("Device ID")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        '${data['device_name'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 6,
                                                      child:
                                                          Text("iOS Version")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        '${deviceData['iosver'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 6,
                                                      child: Text(
                                                          "FlySmart Version")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        '${deviceData['flysmart'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 6,
                                                      child:
                                                          Text("Docu Version")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        '${deviceData['docuversion'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 6,
                                                      child:
                                                          Text("Lido Version")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        '${deviceData['lidoversion'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 6,
                                                      child: Text("HUB")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        '${deviceData['hub'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 6,
                                                      child: Text("Condition")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        '${deviceData['condition'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(height: 10.0),
                                              Text(
                                                "PROOF INFO",
                                                style: tsOneTextTheme
                                                    .headlineLarge,
                                              ),
                                              SizedBox(height: 7.0),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text("Remarks :"),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text(
                                                            '${data['remarks'] ?? '-'}'),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),

                                              SizedBox(height: 5.0),
                                              // Row(
                                              //   children: [
                                              //     Expanded(flex: 6, child: Text("Image Proof")),
                                              //     Expanded(flex: 1, child: Text(":")),
                                              //     Expanded(
                                              //       flex: 6,
                                              //       child: Column(
                                              //         children: [
                                              //           if (data['prove_image_url'] != null)
                                              //             Image.network(
                                              //               data['prove_image_url'],
                                              //               width: 100, // Adjust the width as needed
                                              //               height: 100, // Adjust the height as needed
                                              //             ),
                                              //           if (data['prove_image_url'] == null)
                                              //             Text(
                                              //               'There is no data',
                                              //               style: TextStyle(color: Colors.black), // Adjust the style as needed
                                              //             ),
                                              //           SizedBox(height: 5),  // Add some spacing between the image or text and the other content
                                              //         ],
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),

                                              SizedBox(height: 10),
                                              // Conditionally display the fields based on the status
                                              if (status == 'Done')
                                                Text(
                                                  "OCC ON DUTY",
                                                  style: tsOneTextTheme
                                                      .headlineLarge,
                                                ),
                                              SizedBox(height: 7.0),
                                              if (status == 'Done')
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 6,
                                                        child: Text(
                                                            "OCC That Gives")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text(":")),
                                                    Expanded(
                                                      flex: 6,
                                                      child: Text(
                                                          '${occOnDutyuserData?['NAME'] ?? 'No Data'}'),
                                                    ),
                                                  ],
                                                ),
                                              SizedBox(height: 5.0),
                                              if (status == 'Done')
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 6,
                                                        child: Text(
                                                            "OCC Who Received")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text(":")),
                                                    Expanded(
                                                      flex: 6,
                                                      child: Text(
                                                          '${occAccepteduserData?['NAME'] ?? 'No Data'}'),
                                                    ),
                                                  ],
                                                ),

                                              SizedBox(height: 5.0),
                                              if (status == 'Done')
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 6,
                                                        child: Text(
                                                            "Image Proof")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text(":")),
                                                    Expanded(
                                                      flex: 6,
                                                      child: Column(
                                                        children: [
                                                          if (data[
                                                                  'prove_back_to_base'] ==
                                                              null)
                                                            Text(
                                                              'There is no data',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          SizedBox(height: 5),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              // Show the picture in a dialog when the button is pressed
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    content:
                                                                        Container(
                                                                      width:
                                                                          400, // Adjust the width as needed
                                                                      height:
                                                                          400, // Adjust the height as needed
                                                                      child: Image
                                                                          .network(
                                                                        data['prove_back_to_base'] ??
                                                                            '',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Text(
                                                                'See Picture'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                              // Conditionally display the fields based on the status
                                              if (status ==
                                                  'handover-to-other-crew')
                                                Text(
                                                  "GIVEN TO",
                                                  style: tsOneTextTheme
                                                      .headlineLarge,
                                                ),
                                              SizedBox(height: 7.0),
                                              if (status ==
                                                  'handover-to-other-crew')
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 6,
                                                        child: Text("ID NO")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text(":")),
                                                    Expanded(
                                                      flex: 6,
                                                      child: handoverTouserData !=
                                                              null
                                                          ? Text(
                                                              '${handoverTouserData['ID NO'] ?? 'Not Found'}')
                                                          : Text('Not Found'),
                                                    ),
                                                  ],
                                                ),
                                              SizedBox(height: 5.0),
                                              if (status ==
                                                  'handover-to-other-crew')
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 6,
                                                        child: Text("NAME")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text(":")),
                                                    Expanded(
                                                      flex: 6,
                                                      child: handoverTouserData !=
                                                              null
                                                          ? Text(
                                                              '${handoverTouserData['NAME'] ?? 'Not Found'}')
                                                          : Text('Not Found'),
                                                    ),
                                                  ],
                                                ),
                                              SizedBox(height: 5.0),
                                              if (status ==
                                                  'handover-to-other-crew')
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 6,
                                                        child: Text("RANK")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text(":")),
                                                    Expanded(
                                                      flex: 6,
                                                      child: handoverTouserData !=
                                                              null
                                                          ? Text(
                                                              '${handoverTouserData['RANK'] ?? 'Not Found'}')
                                                          : Text('Not Found'),
                                                    ),
                                                  ],
                                                ),

                                              SizedBox(height: 70.0),
                                              ElevatedButton(
                                                onPressed: () {
                                                  generateLogPdfDevice1(
                                                    userName: userData['NAME'],
                                                    userRank: userData['RANK'],
                                                    userID: userData['ID NO']
                                                        .toString(),
                                                    occAccept:
                                                        occAccepteduserData?[
                                                            'NAME'],
                                                    occGiven:
                                                        occOnDutyuserData?[
                                                            'NAME'],
                                                    deviceNo:
                                                        data['device_name'],
                                                    iosVer:
                                                        deviceData['iosver'],
                                                    flySmart:
                                                        deviceData['flysmart'],
                                                    lido: deviceData[
                                                        'lidoversion'],
                                                    docunet: deviceData[
                                                        'docuversion'],
                                                    deviceCondition:
                                                        deviceData['condition'],
                                                    ttdUser:
                                                        data['signature_url'],
                                                    loan: data['timestamp'],
                                                    statusdevice:
                                                        data['statusDevice'],
                                                    handoverName:
                                                        handoverTouserData !=
                                                                null
                                                            ? handoverTouserData[
                                                                'NAME']
                                                            : 'Not Found',
                                                    handoverID:
                                                        handoverTouserData !=
                                                                null
                                                            ? handoverTouserData[
                                                                'ID NO']
                                                            : 'Not Found',
                                                  );

                                                  //generateLogPdfDevice1();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      TsOneColor.greenColor,
                                                  minimumSize: const Size(
                                                      double.infinity, 50),
                                                ),
                                                child: const Text(
                                                  'Download PDF',
                                                  style: TextStyle(
                                                      color: Colors.white),
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
        ),
      ),
    );
  }
}
