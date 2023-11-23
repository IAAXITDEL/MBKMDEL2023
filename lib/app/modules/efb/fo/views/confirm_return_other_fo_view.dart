import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // For camera feature
import 'package:firebase_storage/firebase_storage.dart'; // For uploading images to Firebase Storage
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'dart:io';
import '../../../../../presentation/theme.dart'; //
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
    ).then((value) {
      Get.offAllNamed(Routes.NAVOCC);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Confirmation', style: tsOneTextTheme.headlineLarge),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("pilot-device-1").doc(widget.deviceId).get(),
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

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection("users").doc(data['handover-to-crew']).get(),
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
                    future: FirebaseFirestore.instance.collection("users").doc(data['user_uid']).get(),
                    builder: (context, otheruserSnapshot) {
                      if (otheruserSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (otheruserSnapshot.hasError) {
                        return Center(child: Text('Error: ${otheruserSnapshot.error}'));
                      }

                      if (!otheruserSnapshot.hasData || !otheruserSnapshot.data!.exists) {
                        return const Center(child: Text('Other Crew data not found'));
                      }

                      final otheruserData = otheruserSnapshot.data!.data() as Map<String, dynamic>;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection("Device").doc(data['device_uid2']).get(),
                        builder: (context, device2Snapshot) {
                          if (device2Snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (device2Snapshot.hasError) {
                            return Center(child: Text('Error: ${device2Snapshot.error}'));
                          }

                          if (!device2Snapshot.hasData || !device2Snapshot.data!.exists) {
                            return const Center(child: Text('Device data 2 not found'));
                          }

                          final deviceData2 = device2Snapshot.data!.data() as Map<String, dynamic>;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection("Device").doc(data['device_uid3']).get(),
                            builder: (context, device3Snapshot) {
                              if (device3Snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (device3Snapshot.hasError) {
                                return Center(child: Text('Error: ${device3Snapshot.error}'));
                              }

                              if (!device3Snapshot.hasData || !device3Snapshot.data!.exists) {
                                return const Center(child: Text('Device data not found'));
                              }

                              final deviceData3 = device3Snapshot.data!.data() as Map<String, dynamic>;

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10.0),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Handover From",
                                        style: tsOneTextTheme.headlineMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 6,
                                            child: Text(
                                              "ID NO",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${otheruserData['ID NO'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              "Name",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${otheruserData['NAME'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              "RANK",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${otheruserData['RANK'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16.0),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Handover To",
                                        style: tsOneTextTheme.headlineMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 6,
                                            child: Text(
                                              "ID NO",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${userData['ID NO'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              "Name",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${userData['NAME'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              "Rank",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${userData['RANK'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
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
                                      child: Text(
                                        "Device 2",
                                        style: tsOneTextTheme.headlineMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 6,
                                            child: Text(
                                              "Device No",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${data['device_name2'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData2['value']['iosver'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData2['value']['flysmart'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData2['value']['docuversion'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData2['value']['lidoversion'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData2['value']['hub'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // const SizedBox(height: 5.0),
                                    // Row(
                                    //   children: [
                                    //     Expanded(
                                    //         flex: 6,
                                    //         child: Text(
                                    //           "Condition",
                                    //           style: tsOneTextTheme.labelMedium,
                                    //         )),
                                    //     const Expanded(child: Text(":")),
                                    //     Expanded(
                                    //       flex: 6,
                                    //       child: Text(
                                    //         '${deviceData2['value']['condition'] ?? 'No Data'}',
                                    //         style: tsOneTextTheme.labelMedium,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    const SizedBox(height: 20.0),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Device 3",
                                        style: tsOneTextTheme.headlineMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 6,
                                            child: Text(
                                              "Device No",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${data['device_name3'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData3['value']['iosver'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData3['value']['flysmart'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData3['value']['docuversion'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData3['value']['lidoversion'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        const Expanded(child: Text(":")),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData3['value']['hub'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Device Condition 2",
                                        style: tsOneTextTheme.headlineMedium,
                                      ),
                                    ),
                                    SizedBox(height: 7,),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 7,
                                            child: Text(
                                              "Condition Category",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                            child: Text(
                                              ":",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                          flex: 7,
                                          child: Text(
                                            '${data['initial-condition-category2'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                            child: Text(
                                              ":",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                          flex: 7,
                                          child: Text(
                                            '${data['initial-condition-remarks2'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Device Condition 3",
                                        style: tsOneTextTheme.headlineMedium,
                                      ),
                                    ),
                                    SizedBox(height: 7,),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 7,
                                            child: Text(
                                              "Condition Category",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                            child: Text(
                                              ":",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                          flex: 7,
                                          child: Text(
                                            '${data['initial-condition-category3'] ?? 'No Data'}',
                                            style: tsOneTextTheme.labelMedium,
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
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                            child: Text(
                                              ":",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                          flex: 7,
                                          child: Text(
                                            '${data['initial-condition-remarks3'] ?? 'No Data'}',
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
