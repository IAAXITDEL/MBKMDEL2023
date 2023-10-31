import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../../../presentation/theme.dart';
import '../../../../routes/app_pages.dart';

class FOUnReturnDeviceView extends GetView {
  final String deviceId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FOUnReturnDeviceView({Key? key, required this.deviceId}) : super(key: key);

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

  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'You have successfully rejected the device.',
    ).then((value) {
      Get.offAllNamed(Routes.NAVOCC);
    });
  }

  void confirmRejected(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation', style: tsOneTextTheme.headlineLarge),
          content: const Text('Are you sure you want to reject the usage?'),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextButton(
                    child: const Text('No', style: TextStyle(color: TsOneColor.secondaryContainer)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 5,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: TsOneColor.greenColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text('Yes', style: TextStyle(color: TsOneColor.onPrimary)),
                    onPressed: () async {
                      User? user = _auth.currentUser;

                      if (user != null) {
                        // Get the user's ID
                        QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user.email).get();
                        String userUid = userQuery.docs.first.id;

                        DocumentReference pilotDeviceRef = FirebaseFirestore.instance.collection("pilot-device-1").doc(deviceId);

                        try {
                          await pilotDeviceRef.update({
                            'statusDevice': 'in-use-pilot',
                          });
                          _showQuickAlert(context);
                          print('Data updated successfully!');
                        } catch (error) {
                          print('Error updating data: $error');
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Reject Return',
          style: tsOneTextTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("pilot-device-1").doc(deviceId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('Data not found'));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              final userUid = data['user_uid'];
              final deviceUid2 = data['device_uid2'];
              final deviceUid3 = data['device_uid3'];

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

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection("Device").doc(deviceUid2).get(),
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
                        future: FirebaseFirestore.instance.collection("Device").doc(deviceUid3).get(),
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

                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Expanded(flex: 7, child: Text("ID NO")),
                                    const Expanded( child: Text(":")),
                                    Expanded(
                                      flex: 6,
                                      child: Text('${userData['ID NO'] ?? 'No Data'}'),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Expanded(flex: 7, child: Text("Name")),
                                    const Expanded( child: Text(":")),
                                    Expanded(
                                      flex: 6,
                                      child: Text('${userData['NAME'] ?? 'No Data'}'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    const Expanded(flex: 7, child: Text("Rank")),
                                    const Expanded( child: Text(":")),
                                    Expanded(
                                      flex: 6,
                                      child: Text('${userData['RANK'] ?? 'No Data'}'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
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
                                const SizedBox(height: 5.0),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Device 2", style: tsOneTextTheme.displaySmall),
                                ),
                                const SizedBox(height: 5.0),
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
                                        '${data['device_name2'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
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
                                        '${deviceData2['iosver'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "FlySmart Version",
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
                                        '${deviceData2['flysmart'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
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
                                        '${deviceData2['docuversion'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
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
                                        '${deviceData2['lidoversion'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
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
                                        '${deviceData2['hub'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
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
                                        '${deviceData2['condition'] ?? 'No Data'}',
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
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Device No",
                                          style: tsOneTextTheme.bodySmall,
                                        )),
                                    const Expanded( child: Text(":")),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        '${data['device_name3'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
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
                                        '${deviceData3['iosver'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "FlySmart Version",
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
                                        '${deviceData3['flysmart'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
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
                                        '${deviceData3['docuversion'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
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
                                        '${deviceData3['lidoversion'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
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
                                        '${deviceData3['hub'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
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
                                        '${deviceData3['condition'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 70.0),
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
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
        child: ElevatedButton(
          onPressed: () {
            confirmRejected(context); // Pass the context to the function
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: TsOneColor.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              )),
          child: const Text('Reject', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
