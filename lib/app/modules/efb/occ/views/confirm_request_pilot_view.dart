import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../presentation/theme.dart';

class ConfirmRequestPilotView extends GetView {
  final String dataId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ConfirmRequestPilotView({Key? key, required this.dataId}) : super(key: key);

  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'You have succesfully Confirm The Request',
    );
    Navigator.of(context).pop();

  }


  void confirmInUse(BuildContext context) async {

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Are you sure you want to confirm the usage?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Confirm'),
                onPressed: () async {
                  User? user = _auth.currentUser;

                  if (user != null) {
                    // Get the user's ID
                    QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user.email).get();
                    String userUid = userQuery.docs.first.id;

                    DocumentReference pilotDeviceRef = FirebaseFirestore.instance
                        .collection("pilot-device-1")
                        .doc(dataId);

                    try {
                      await pilotDeviceRef.update({
                        'statusDevice': 'in-use-pilot',
                        'occ-on-duty': userUid, // Store the user's ID as occ-on-duty
                      });

                      _showQuickAlert(context);
                    } catch (error) {
                      print('Error updating data: $error');
                    }
                  }
                  _showQuickAlert(context);
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close the dialog
                },
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
        title: Text('Need Confirm'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust the padding here
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

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("Device")
                        .doc(deviceUid)
                        .get(),
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

                      final deviceData =
                      deviceSnapshot.data!.data() as Map<String, dynamic>;

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.0),
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
                                Expanded(flex: 6, child: Text("ID NO", style: tsOneTextTheme.labelMedium,)),
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
                                Expanded(flex: 6, child: Text("Name", style: tsOneTextTheme.labelMedium,)),
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
                                Expanded(flex: 6, child: Text("Rank", style: tsOneTextTheme.labelMedium,)),
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
                            SizedBox(height: 10.0),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "DEVICE INFO",
                                style: tsOneTextTheme.titleLarge,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6, child: Text("Device ID", style: tsOneTextTheme.labelMedium,)),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    '${data['device_name'] ?? 'No Data'}',
                                    style: tsOneTextTheme.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6, child: Text("iOS Version", style: tsOneTextTheme.labelMedium,)),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    '${deviceData['iosver'] ?? 'No Data'}',
                                    style: tsOneTextTheme.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6, child: Text("FlySmart Version", style: tsOneTextTheme.labelMedium,)),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    '${deviceData['flysmart'] ?? 'No Data'}',
                                    style: tsOneTextTheme.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6, child: Text("Docu Version", style: tsOneTextTheme.labelMedium,)),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    '${deviceData['docuversion'] ?? 'No Data'}',
                                    style: tsOneTextTheme.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6, child: Text("Lido Version", style: tsOneTextTheme.labelMedium,)),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    '${deviceData['lidoversion'] ?? 'No Data'}',
                                    style: tsOneTextTheme.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6, child: Text("HUB", style: tsOneTextTheme.labelMedium,)),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    '${deviceData['hub'] ?? 'No Data'}',
                                    style: tsOneTextTheme.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6, child: Text("Condition", style: tsOneTextTheme.labelMedium,)),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    '${deviceData['condition'] ?? 'No Data'}',
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
                              child: const Text('Submit', style: TextStyle(color: Colors.white),),
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
    );
  }
}
