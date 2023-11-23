import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // For camera feature
import 'package:firebase_storage/firebase_storage.dart'; // For uploading images to Firebase Storage
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilot_confirm_signature_other_crew.dart';
import 'package:ts_one/app/routes/app_pages.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import 'dart:io'; // For handling selected image file

import '../../../../../presentation/theme.dart';

class ConfirmReturnOtherPilotView extends StatefulWidget {
  final String deviceName;
  final String deviceId;

  ConfirmReturnOtherPilotView({
    required this.deviceName,
    required this.deviceId,
  });

  @override
  _ConfirmReturnOtherPilotViewState createState() => _ConfirmReturnOtherPilotViewState();
}

class _ConfirmReturnOtherPilotViewState extends State<ConfirmReturnOtherPilotView> {
  final TextEditingController remarksController = TextEditingController();
  File? selectedImage; // File to store the selected image
  final ImagePicker _imagePicker = ImagePicker();
  String deviceName = "";

  // Function to update status in Firestore and upload image to Firebase Storage
  void updateStatusToInUsePilot(String deviceId) async {
    final remarks = remarksController.text;

    // Upload the selected image to Firebase Storage (if an image is selected)
    String imageUrl = '';
    if (selectedImage != null) {
      final storageRef = FirebaseStorage.instance.ref().child('images/$deviceId.jpg');
      await storageRef.putFile(selectedImage!);
      imageUrl = await storageRef.getDownloadURL();
    }

    // Update Firestore
    await FirebaseFirestore.instance.collection('pilot-device-1').doc(widget.deviceId).update({
      'statusDevice': 'in-use-pilot',
      'handover-to-crew': '-',
      'remarks': remarks,
      'prove_image_url': imageUrl,
    });

    // Return to the previous page
    _showQuickAlert(context);
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

  String getMonthText(int month) {
    const List<String> months = [
      'Januari',
      'Februari',
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

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation Return'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to confirm the return of this device?'),
              ],
            ),
          ),
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
                      updateStatusToInUsePilot(widget.deviceId);
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

  Widget _buildSelectedImage() {
    if (selectedImage == null) {
      return Container();
    } else {
      return Image.file(
        selectedImage!,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Confirmation',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Adjust the padding here
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
                        return const Center(child: Text('Other Crew From data not found'));
                      }

                      final otheruserData = otheruserSnapshot.data!.data() as Map<String, dynamic>;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection("Device").doc(data['device_uid']).get(),
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
                                    const Expanded(flex: 6, child: Text("ID NO")),
                                    const Expanded(child: Text(":")),
                                    Expanded(
                                      flex: 6,
                                      child: Text('${otheruserData['ID NO'] ?? 'No Data'}'),
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
                                      child: Text('${otheruserData['NAME'] ?? 'No Data'}'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    const Expanded(flex: 6, child: Text("RANK")),
                                    const Expanded(child: Text(":")),
                                    Expanded(
                                      flex: 6,
                                      child: Text('${otheruserData['RANK'] ?? 'No Data'}'),
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
                                        '${userData['ID NO'] ?? 'No Data'}',
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
                                          "Name",
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
                                        '${userData['NAME'] ?? 'No Data'}',
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
                                          "Rank",
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
                                        '${userData['RANK'] ?? 'No Data'}',
                                        style: tsOneTextTheme.bodySmall,
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
                                    "Device 1",
                                    style: tsOneTextTheme.headlineMedium,
                                  ),
                                ),
                                const SizedBox(height: 7.0),
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
                                const SizedBox(height: 5.0),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmSignatureReturnOtherPilotView(
                  deviceName: deviceName,
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
