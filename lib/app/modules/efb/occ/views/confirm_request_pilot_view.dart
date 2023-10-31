import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/app/routes/app_pages.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
//sssssss
import '../../../../../presentation/theme.dart';
import '../../../../routes/app_pages.dart';

class ConfirmRequestPilotView extends GetView {
  final String dataId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ConfirmRequestPilotView({Key? key, required this.dataId}) : super(key: key);

  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'You have successfully confirmed the request',
    ).then((value) {
      Get.offAllNamed(Routes.NAVOCC);
    });
  }

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

  void confirmInUseCrew(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmation',
            style: tsOneTextTheme.headlineLarge,
          ),
          content: const Text('Are you sure you want to approve the usage of this device? '),
          actions: <Widget>[
            Row(children: [
              Expanded(
                flex: 5,
                child: TextButton(
                  child: Text('No', style: TextStyle(color: TsOneColor.secondaryContainer)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Spacer(flex: 1),
              Expanded(
                flex: 5,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: TsOneColor.greenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text('Yes', style: TextStyle(color: TsOneColor.onPrimary)),
                  onPressed: () async {
                    User? user = _auth.currentUser;

                    if (user != null) {
                      QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user.email).get();
                      String userUid = userQuery.docs.first.id;

                      DocumentReference pilotDeviceRef = FirebaseFirestore.instance.collection("pilot-device-1").doc(dataId);

                      try {
                        await pilotDeviceRef.update({
                          'statusDevice': 'in-use-pilot',
                          'occ-on-duty': userUid,
                        });
                        _showQuickAlert(context);
                        print("Data Updated!");
                      } catch (error) {
                        print('Error updating data: $error');
                      }
                    }
                  },
                ),
              )
            ]),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Confirmation Request',
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

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection("Device").doc(deviceUid).get(),
                  builder: (context, deviceSnapshot) {
                    if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (deviceSnapshot.hasError) {
                      return Center(child: Text('Error: ${deviceSnapshot.error}'));
                    }

                    //IF DEVICE_NAME NOT FOUND OR NULL VALUE
                    if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                      final deviceUid2 = data['device_uid2'];
                      final deviceUid3 = data['device_uid3'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection("Device").doc(deviceUid2).get(),
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

                          final deviceData2 = deviceSnapshot.data!.data() as Map<String, dynamic>;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection("Device").doc(deviceUid3).get(),
                            builder: (context, deviceSnapshot) {
                              if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (deviceSnapshot.hasError) {
                                return Center(child: Text('Error: ${deviceSnapshot.error}'));
                              }

                              if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                                return const Center(child: Text('Device data not found'));
                              }

                              final deviceData3 = deviceSnapshot.data!.data() as Map<String, dynamic>;

                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
                                      ),
                                      const SizedBox(height: 15.0),
                                      Row(
                                        children: [
                                          Expanded(flex: 7, child: Text("ID NO")),
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
                                          Expanded(flex: 7, child: Text("Name")),
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
                                          Expanded(flex: 7, child: Text("Rank")),
                                          Expanded(flex: 1, child: Text(":")),
                                          Expanded(
                                            flex: 6,
                                            child: Text('${userData['RANK'] ?? 'No Data'}'),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15.0),

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
                                      SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Device No",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${data['device_name2'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "IOS Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData2['iosver'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "FlySmart Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData2['flysmart'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Docunet Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData2['docuversion'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Lido mPilot Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData2['lidoversion'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Hub",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData2['hub'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Condition",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData2['condition'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),

                                      //Device 3
                                      SizedBox(height: 20.0),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Device 3", style: tsOneTextTheme.displaySmall),
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Device No",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${data['device_name3'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "IOS Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData3['iosver'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "FlySmart Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData3['flysmart'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Docunet Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData3['docuversion'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Lido mPilot Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData3['lidoversion'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Hub",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData3['hub'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Condition",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData3['condition'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }

                    final deviceData = deviceSnapshot.data!.data() as Map<String, dynamic>;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
                          ),
                          SizedBox(height: 15.0),
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
                          SizedBox(
                            height: 5.0,
                          ),
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
                          SizedBox(height: 5.0),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Device 1", style: tsOneTextTheme.displaySmall),
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 7,
                                  child: Text(
                                    "Device No",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    ":",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                flex: 7,
                                child: Text(
                                  '${data['device_name'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "IOS Version",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    ":",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['iosver'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "FlySmart Version",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    ":",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['flysmart'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "Docunet Version",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    ":",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['docuversion'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "Lido mPilot Version",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    ":",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['lidoversion'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "Hub",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    ":",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['hub'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "Condition",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    ":",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['condition'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
        child: Expanded(
          child: ElevatedButton(
            onPressed: () {
              confirmInUseCrew(context); // Pass the context to the function
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: TsOneColor.greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                )),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
