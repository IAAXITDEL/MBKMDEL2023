import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // For camera feature
import 'package:firebase_storage/firebase_storage.dart'; // For uploading images to Firebase Storage
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'dart:io'; // For handling selected image file

import '../../../../../presentation/theme.dart';
import '../../../../routes/app_pages.dart';
import 'confirm_signature_other_fo.dart';

class ConfirmReturnOtherFOView extends StatefulWidget {
  final String deviceName2;
  final String deviceName3;
  final String deviceId;

  ConfirmReturnOtherFOView({
    required this.deviceName2,
    required this.deviceName3,
    required this.deviceId,
  });

  @override
  _ConfirmReturnOtherFOViewState createState() => _ConfirmReturnOtherFOViewState();
}

class _ConfirmReturnOtherFOViewState extends State<ConfirmReturnOtherFOView> {
  final TextEditingController remarksController = TextEditingController();
  File? selectedImage; // File to store the selected image
  final ImagePicker _imagePicker = ImagePicker(); // ImagePicker instance
  String deviceId2 = "";
  String deviceId3 = "";
  String deviceName2 = "";
  String deviceName3 = "";
  String OccOnDuty = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Fetch deviceUid, deviceName, and OCC On Duty from Firestore using widget.deviceId
    FirebaseFirestore.instance.collection('pilot-device-1').doc(widget.deviceId).get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          deviceId2 = documentSnapshot['device_uid2'];
          deviceId3 = documentSnapshot['device_uid3'];
          deviceName2 = documentSnapshot['device_name2'];
          deviceName3 = documentSnapshot['device_name3'];
          OccOnDuty = documentSnapshot['occ-on-duty'];
        });
      }
    });
  }

  // Function to update status in Firestore and upload image to Firebase Storage

  // Function to open the image picker
  Future<void> _pickImage() async {
    final pickedImageCamera = await _imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImageCamera != null) {
      setState(() {
        selectedImage = File(pickedImageCamera.path);
      });
    }
  }

  // Function to show a success message using QuickAlert
  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'You have successfully added a device',
    );
    Get.offAllNamed(Routes.NAVOCC);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmationn'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust the padding here
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("pilot-device-1").doc(widget.deviceId).get(),
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

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection("users").doc(data['handover-to-crew']).get(),
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
                    future: FirebaseFirestore.instance.collection("users").doc(data['user_uid']).get(),
                    builder: (context, otheruserSnapshot) {
                      if (otheruserSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (otheruserSnapshot.hasError) {
                        return Center(child: Text('Error: ${otheruserSnapshot.error}'));
                      }

                      if (!otheruserSnapshot.hasData || !otheruserSnapshot.data!.exists) {
                        return Center(child: Text('Other Crew data not found'));
                      }

                      final otheruserData = otheruserSnapshot.data!.data() as Map<String, dynamic>;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection("Device").doc(data['device_uid2']).get(),
                        builder: (context, device2Snapshot) {
                          if (device2Snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (device2Snapshot.hasError) {
                            return Center(child: Text('Error: ${device2Snapshot.error}'));
                          }

                          if (!device2Snapshot.hasData || !device2Snapshot.data!.exists) {
                            return Center(child: Text('Device data 2 not found'));
                          }

                          final deviceData2 = device2Snapshot.data!.data() as Map<String, dynamic>;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection("Device").doc(data['device_uid3']).get(),
                            builder: (context, device3Snapshot) {
                              if (device3Snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (device3Snapshot.hasError) {
                                return Center(child: Text('Error: ${device3Snapshot.error}'));
                              }

                              if (!device3Snapshot.hasData || !device3Snapshot.data!.exists) {
                                return Center(child: Text('Device data not found'));
                              }

                              final deviceData3 = device3Snapshot.data!.data() as Map<String, dynamic>;

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10.0),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "HANDOVER FROM",
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
                                            '${otheruserData['ID NO'] ?? 'No Data'}',
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
                                              "Name",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(flex: 1, child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${otheruserData['NAME'] ?? 'No Data'}',
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
                                              "RANK",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(flex: 1, child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${otheruserData['RANK'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.0),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "HANDOVER TO",
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
                                    SizedBox(height: 5.0),
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
                                    SizedBox(height: 20.0),
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
                                    SizedBox(height: 5.0),
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
                                    SizedBox(height: 5.0),
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
                                    SizedBox(height: 20.0),
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
                                    SizedBox(height: 5.0),
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
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
        child: Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmSignatureReturnOtherFOView(
                    deviceName2: deviceName2,
                    deviceName3: deviceName3,
                    deviceId: widget.deviceId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: TsOneColor.greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                )),
            child: const Text('Next', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

Future<String> getHubFromDeviceName(String deviceName2, String deviceName3) async {
  String hub = "Unknown Hub"; // Default value

  try {
    // Fetch the 'hub' field from the 'Device' collection based on deviceName
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Device').where('deviceno', whereIn: [deviceName2, deviceName3]).get();

    if (querySnapshot.docs.isNotEmpty) {
      hub = querySnapshot.docs.first['hub'];
    }
  } catch (e) {
    print("Error getting hub from Device: $e");
  }

  return hub;
}