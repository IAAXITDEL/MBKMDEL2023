import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/app/routes/app_pages.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../presentation/theme.dart';

class ConfirmRequestFOView extends GetView {
  final String dataId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ConfirmRequestFOView({Key? key, required this.dataId}) : super(key: key);

  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'You have succesfully Confirm The Request',
    ).then((value) {
      Get.offAllNamed(Routes.NAVOCC);
    });
  }

  void confirmInUse(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmation',
            style: tsOneTextTheme.headlineLarge,
          ),
          content: Text('Are you sure you want to confirm the usage?'),
          actions: <Widget>[
            Row(
              children: [
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
                        // Get the user's ID
                        QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user.email).get();
                        String userUid = userQuery.docs.first.id;

                        DocumentReference pilotDeviceRef = FirebaseFirestore.instance.collection("pilot-device-1").doc(dataId);

                        try {
                          await pilotDeviceRef.update({
                            'statusDevice': 'in-use-fo',
                            'occ-on-duty': userUid, // Store the user's ID as occ-on-duty
                          });

                          _showQuickAlert(context);
                        } catch (error) {
                          print('Error updating data: $error');
                        }
                      }
                      _showQuickAlert(context);
                      // Navigator.of(context).pop(); // Close the dialog
                      // Navigator.of(context).pop(); // Close the dialog
                      // Navigator.of(context).pop(); // Close the dialog
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust the padding here
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
                    future: FirebaseFirestore.instance.collection("Device").doc(deviceUid2).get(),
                    builder: (context, deviceSnapshot) {
                      if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (deviceSnapshot.hasError) {
                        return Center(child: Text('Error: ${deviceSnapshot.error}'));
                      }

                      if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                        return Center(child: Text('Device data 2 not found'));
                      }

                      final deviceData2 = deviceSnapshot.data!.data() as Map<String, dynamic>;

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

                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 60.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "REQUEST INFO",
                                    style: tsOneTextTheme.titleLarge,
                                  ),
                                  SizedBox(height: 30.0),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "CREW INFO",
                                      style: tsOneTextTheme.titleLarge,
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "ID NO",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${userData['ID NO'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "Name",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${userData['NAME'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
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
                                            "Rank",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${userData['RANK'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
                                        ),
                                      ),
                                    ],
                                  ),

                                  //DEVICE INFO 1
                                  SizedBox(height: 10.0),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "DEVICE INFO 1",
                                      style: tsOneTextTheme.titleLarge,
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "Device No",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${data['device_name2'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
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
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData2['iosver'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
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
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData2['flysmart'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
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
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData2['docuversion'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
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
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData2['lidoversion'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "HUB",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData2['hub'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "Condition",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData2['condition'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
                                        ),
                                      ),
                                    ],
                                  ),

                                  //DEVICE INFO 2
                                  SizedBox(height: 10.0),
                                  SizedBox(height: 10.0),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "DEVICE INFO 2",
                                      style: tsOneTextTheme.titleLarge,
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "Device No",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${data['device_name3'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
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
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData3['iosver'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
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
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData3['flysmart'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
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
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData3['docuversion'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
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
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData3['lidoversion'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "HUB",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData3['hub'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "Condition",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          '${deviceData3['condition'] ?? 'No Data'}',
                                          style: tsOneTextTheme.labelMedium,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 18.0),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "CONFIRMATION",
                                      style: tsOneTextTheme.titleLarge,
                                    ),
                                  ),
                                  SizedBox(height: 70.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      confirmInUse(context); // Pass the context to the function
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: TsOneColor.greenColor,
                                      minimumSize: const Size(double.infinity, 50),
                                    ),
                                    child: const Text(
                                      'Confirm',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
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
        child: Expanded(
          child: ElevatedButton(
            onPressed: () {
              confirmInUse(context); // Pass the context to the function
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
