import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/modules/efb/occ/views/history/history_all_device_view.dart';

import '../../../../../../presentation/theme.dart';
import 'handover_attachment1.dart';

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

  String getMonthText(int month) {
    const List<String> months = [
      'Januar7',
      'Februar7',
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
        title: Text(
          'Device Usage History',
          style: tsOneTextTheme.headlineLarge,
        ),
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
            final deviceUid = data['device_uid'];
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
                      future: FirebaseFirestore.instance.collection("Device").doc(deviceUid).get(),
                      builder: (context, deviceSnapshot) {
                        if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (deviceSnapshot.hasError) {
                          return Center(child: Text('Error: ${deviceSnapshot.error}'));
                        }

                        if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                          return Center(child: Text('Device data not found'));
                        }

                        final deviceData = deviceSnapshot.data!.data() as Map<String, dynamic>;

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
                              future:
                              occAccepted != null ? FirebaseFirestore.instance.collection("users").doc(occAccepted).get() : Future.value(null),
                              builder: (context, occAcceptedSnapshot) {
                                if (occAcceptedSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                if (occAcceptedSnapshot.hasError) {
                                  return Center(child: Text('Error: ${occAcceptedSnapshot.error}'));
                                }

                                final occAccepteduserData = occAcceptedSnapshot.data?.data() as Map<String, dynamic>?;

                                return SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              //show date
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
                                              ),
                                              SizedBox(height: 15.0),

                                              //show crew info
                                              // Text(
                                              //   "CREW INFO",
                                              //   style: tsOneTextTheme.headlineLarge,
                                              // ),
                                              Row(
                                                children: [
                                                  Expanded(flex: 6, child: Text("ID NO")),
                                                  Expanded(flex: 1, child: Text(":")),
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
                                                  Expanded(flex: 1, child: Text(":")),
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
                                                  Expanded(flex: 1, child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text('${userData['RANK'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 15.0),

                                              //device info
                                              Text(
                                                "Device Info",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: tsOneColorScheme.onBackground,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                              SizedBox(height: 7.0),
                                              Row(
                                                children: [
                                                  Expanded(flex: 6, child: Text("Device No")),
                                                  Expanded(flex: 1, child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text('${data['device_name'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(flex: 6, child: Text("IOS Version")),
                                                  Expanded(flex: 1, child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text('${deviceData['iosver'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(flex: 6, child: Text("FlySmart Version")),
                                                  Expanded(flex: 1, child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text('${deviceData['flysmart'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(flex: 6, child: Text("Docunet Version")),
                                                  Expanded(flex: 1, child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text('${deviceData['docuversion'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(flex: 6, child: Text("Lido mPilot Version")),
                                                  Expanded(flex: 1, child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text('${deviceData['lidoversion'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(flex: 6, child: Text("HUB")),
                                                  Expanded(flex: 1, child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text('${deviceData['hub'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Expanded(flex: 6, child: Text("Condition")),
                                                  Expanded(flex: 1, child: Text(":")),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text('${deviceData['condition'] ?? 'No Data'}'),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(height: 15),
                                              if (status == 'Done')
                                                Text(
                                                  "Return Documentation",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: tsOneColorScheme.onBackground,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              // if (status == 'Done') SizedBox(height: 7.0),
                                              // if (status == 'Done')
                                              // Row(
                                              //   children: [
                                              //     Expanded(flex: 6, child: Text("Remarks")),
                                              //     Expanded(flex: 1, child: Text(":")),
                                              //     Expanded(
                                              //       flex: 6,
                                              //       child: Text('${data['remarks'] ?? '-'}'),
                                              //     ),
                                              //   ],
                                              // ),

                                              SizedBox(height: 5.0),
                                              if (status == 'Done')
                                                Row(
                                                  children: [
                                                    Expanded(flex: 6, child: Text("Proof Back To Base")),
                                                    Expanded(flex: 1, child: Text(":")),
                                                    Expanded(
                                                      flex: 6,
                                                      child: Column(
                                                        children: [
                                                          if (status == 'Done' && data['prove_back_to_base'] == null ||
                                                              data['prove_back_to_base'].isEmpty)
                                                            Text(
                                                              'There is no image',
                                                              style: TextStyle(color: Colors.black),
                                                            ),
                                                          if (data['prove_back_to_base'] != null && data['prove_back_to_base'].isNotEmpty)
                                                            GestureDetector(
                                                              onTap: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      content: Container(
                                                                        width: 400,
                                                                        height: 400,
                                                                        child: Image.network(
                                                                          data['prove_back_to_base'] ?? 'No Image',
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Align(
                                                                alignment: Alignment.centerLeft,
                                                                child: Text(
                                                                  'See Picture',
                                                                  style: TextStyle(
                                                                    color: TsOneColor.primary,
                                                                    fontWeight: FontWeight.bold,
                                                                    decoration: TextDecoration.underline,
                                                                    decorationColor: TsOneColor.primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                              if (status == 'handover-to-other-crew')
                                                Text(
                                                  "Proof Info",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    color: tsOneColorScheme.onBackground,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              SizedBox(height: 7.0),
                                              if (status == 'handover-to-other-crew')
                                                Row(
                                                  children: [
                                                    Expanded(flex: 6, child: Text("Remarks")),
                                                    Expanded(flex: 1, child: Text(":")),
                                                    Expanded(
                                                      flex: 6,
                                                      child:
                                                      handoverTouserData != null ? Text('${data['remarks'] ?? 'Not Found'}') : Text('Not Found'),
                                                    ),
                                                  ],
                                                ),
                                              SizedBox(height: 7.0),
                                              if (status == 'handover-to-other-crew')
                                                Row(
                                                  children: [
                                                    Expanded(flex: 6, child: Text("Proof of Remarks")),
                                                    Expanded(flex: 1, child: Text(":")),
                                                    Expanded(
                                                      flex: 6,
                                                      child: Column(
                                                        children: [
                                                          if (status == 'handover-to-other-crew' && data['prove_image_url'] == null ||
                                                              data['prove_image_url'].isEmpty)
                                                            Text(
                                                              'There is no image',
                                                              style: TextStyle(color: Colors.black),
                                                            ),
                                                          if (data['prove_image_url'] != null && data['prove_image_url'].isNotEmpty)
                                                            GestureDetector(
                                                              onTap: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      content: Container(
                                                                        width: 400,
                                                                        height: 400,
                                                                        child: Image.network(
                                                                          data['prove_image_url'] ?? 'No Data',
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Align(
                                                                alignment: Alignment.centerLeft,
                                                                child: Text(
                                                                  'See Picture',
                                                                  style: TextStyle(
                                                                    color: TsOneColor.primary,
                                                                    fontWeight: FontWeight.bold,
                                                                    decoration: TextDecoration.underline,
                                                                    decorationColor: TsOneColor.primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                              SizedBox(height: 15),

                                              if (status == 'handover-to-other-crew')
                                                Text(
                                                  "Given To",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    color: tsOneColorScheme.onBackground,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              SizedBox(height: 7.0),
                                              if (status == 'handover-to-other-crew')
                                                Row(
                                                  children: [
                                                    Expanded(flex: 6, child: Text("ID NO")),
                                                    Expanded(flex: 1, child: Text(":")),
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
                                                    Expanded(flex: 1, child: Text(":")),
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
                                                    Expanded(flex: 1, child: Text(":")),
                                                    Expanded(
                                                      flex: 6,
                                                      child: handoverTouserData != null
                                                          ? Text('${handoverTouserData['RANK'] ?? 'Not Found'}')
                                                          : Text('Not Found'),
                                                    ),
                                                  ],
                                                ),

                                              SizedBox(height: 10),
                                              if (status == 'Done')
                                                Text(
                                                  "OCC On Duty",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: tsOneColorScheme.onBackground,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              SizedBox(height: 7.0),
                                              if (status == 'Done')
                                                Row(
                                                  children: [
                                                    Expanded(flex: 6, child: Text("OCC (Given)")),
                                                    Expanded(flex: 1, child: Text(":")),
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
                                                    Expanded(flex: 6, child: Text("OCC (Received)")),
                                                    Expanded(flex: 1, child: Text(":")),
                                                    Expanded(
                                                      flex: 6,
                                                      child: Text('${occAccepteduserData?['NAME'] ?? 'No Data'}'),
                                                    ),
                                                  ],
                                                ),

                                              SizedBox(height: 80.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible: false,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                content: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    CircularProgressIndicator(),
                                                                    SizedBox(height: 20),
                                                                    Text('Please Wait...'),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          );

                                                          generateLogPdfDevice1(
                                                            userName: userData['NAME'],
                                                            userRank: userData['RANK'],
                                                            userID: userData['ID NO'].toString(),
                                                            occAccept: occAccepteduserData?['NAME'],
                                                            occGiven: occOnDutyuserData?['NAME'],
                                                            deviceNo: data['device_name'],
                                                            iosVer: deviceData['iosver'],
                                                            flySmart: deviceData['flysmart'],
                                                            lido: deviceData[' lidoversion'],
                                                            docunet: deviceData['docuversion'],
                                                            deviceCondition: deviceData['condition'],
                                                            ttdUser: data['signature_url'],
                                                            ttdOCC: data['signature_url_occ'],
                                                            loan: data['timestamp'],
                                                            statusdevice: data['statusDevice'],
                                                            ttdOtherCrew: data != null ? data['signature_url_other_user'] : 'Not Found',
                                                            handoverName: handoverTouserData != null ? handoverTouserData['NAME'] : 'Not Found',
                                                            handoverID: data['handover-to-crew'],
                                                          ).then((_) {
                                                            Navigator.pop(context);
                                                          }).catchError((error) {
                                                            print('Error generating PDF: $error');
                                                            Navigator.pop(context);
                                                          });
                                                          //generateLogPdfDevice1();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: TsOneColor.greenColor,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(4.0),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets.all(15),
                                                          child: Text(
                                                            'Download History',
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        )),
                                                  ),
                                                ],
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