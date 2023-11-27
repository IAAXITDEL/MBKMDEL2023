import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/app/routes/app_pages.dart';

import '../../../../../presentation/theme.dart';

class PilotUnRequestDeviceView extends GetView {
  final String deviceId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PilotUnRequestDeviceView({Key? key, required this.deviceId, required String deviceName}) : super(key: key);

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

  //QuickAlert Success
  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'Succesfully rejected the device',
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
                        QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user.email).get();
                        String userUid = userQuery.docs.first.id;

                        DocumentReference pilotDeviceRef = FirebaseFirestore.instance.collection("pilot-device-1").doc(deviceId);

                        try {
                          await pilotDeviceRef.delete(); // Delete the document
                          print('Data deleted successfully!');
                        } catch (error) {
                          print('Error deleting data: $error');
                        }
                      }
                      _showQuickAlert(context);
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
        title: Text('Reject', style: tsOneTextTheme.headlineLarge),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
              final deviceUid = data['device_uid'];

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
                    future: FirebaseFirestore.instance.collection("Device").doc(deviceUid).get(),
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
                                      'EFB Details',
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
                                    '${data['device_name'] ?? 'No Data'}',
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
                                    '${deviceData['value']['iosver'] ?? 'No Data'}',
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
                                    '${deviceData['value']['flysmart'] ?? 'No Data'}',
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
                                    '${deviceData['value']['docuversion'] ?? 'No Data'}',
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
                                    '${deviceData['value']['lidoversion'] ?? 'No Data'}',
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
                                    '${deviceData['value']['hub'] ?? 'No Data'}',
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
                                    '${deviceData['value']['condition'] ?? 'No Data'}',
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15.0),
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
                                      'Device Condition',
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
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                Expanded(
                                    flex: 7,
                                    child: Text(
                                      "Condition Category",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                Expanded(
                                    child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                Expanded(
                                  flex: 7,
                                  child: Text(
                                    '${data['initial-condition-category'] ?? 'No Data'}',
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6.0),
                            Row(
                              children: [
                                Expanded(
                                    flex: 7,
                                    child: Text(
                                      "Condition Remarks",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                Expanded(
                                    child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                Expanded(
                                  flex: 7,
                                  child: Text(
                                    '${data['initial-condition-remarks'] ?? 'No Data'}',
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
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
        child: ElevatedButton(
          onPressed: () {
            confirmRejected(context);
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
