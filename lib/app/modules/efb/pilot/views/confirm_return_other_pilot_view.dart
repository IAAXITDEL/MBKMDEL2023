import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // For camera feature
import 'package:firebase_storage/firebase_storage.dart'; // For uploading images to Firebase Storage
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
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
  final ImagePicker _imagePicker = ImagePicker(); // ImagePicker instance

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

  // Function to show a success message using QuickAlert
  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'You have successfully added a device',
    );
    Navigator.of(context).pop();
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Return'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to confirm the return of this device?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                // Call the function to update status and upload image
                updateStatusToInUsePilot(widget.deviceId);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop();
              },
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
        title: Text('Confirmation'),
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
                future: FirebaseFirestore.instance.collection("users").doc(data['user_uid']).get(),
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
                    future: FirebaseFirestore.instance.collection("users").doc(data['handover-from']).get(),
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
                        future: FirebaseFirestore.instance.collection("Device").doc(data['device_uid']).get(),
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
                                        flex: 6, child: Text("ID NO", style: tsOneTextTheme.labelMedium,)),
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
                                        flex: 6, child: Text("Name", style: tsOneTextTheme.labelMedium,)),
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
                                        flex: 6, child: Text("RANK", style: tsOneTextTheme.labelMedium,)),
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
                                SizedBox(height: 5.0),
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
                                SizedBox(height: 20.0),
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
                                SizedBox(height: 5.0),
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
                                SizedBox(height: 20.0),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "PROOF",
                                    style: tsOneTextTheme.titleLarge,
                                  ),
                                ),
                                Text('If something doesn''t match, please inform us!'),


                                SizedBox(height: 20.0),

                                TextField(
                                  controller: remarksController,
                                  decoration: InputDecoration(
                                    labelText: 'Remarks',
                                    border: OutlineInputBorder(), // Add a border
                                    hintText: 'Enter your remarks here', // Optional hint text
                                    contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12), // Adjust vertical padding
                                  ),
                                  maxLines: null, // Allows multiple lines of text
                                ),


                                SizedBox(height: 20.0),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "PICK AN IMAGE",
                                    style: tsOneTextTheme.titleLarge,
                                  ),
                                ),
                                Text('If something doesn''t match, please take pictures of the damage!'),
                                SizedBox(height: 5.0),

                                // Button to open the image picker
                                // Button to open the image picker
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt, // Use the camera icon
                                        color: Colors.red, // Set the icon color
                                      ),
                                      SizedBox(width: 8), // Add some space between the icon and text
                                      Text(
                                        'Camera',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 7.0),
                                // Display the selected image
                                _buildSelectedImage(),


                                SizedBox(height: 50.0),
                                ElevatedButton(
                                  onPressed: () {
                                    // Call the function to update status and upload image
                                    _showConfirmationDialog();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TsOneColor.greenColor,
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                  child: const Text('Confirm', style: TextStyle(color: Colors.white),),
                                ),
                                SizedBox(height: 20.0),
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
    );
  }
}
