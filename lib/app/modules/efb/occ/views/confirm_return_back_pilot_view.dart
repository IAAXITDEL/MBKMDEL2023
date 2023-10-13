import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:path/path.dart' as Path;
import 'package:image/image.dart' as img;


import '../../../../../presentation/theme.dart';

class ConfirmReturnBackPilotView extends GetView {
  final String dataId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isImageUploading = false;

  ConfirmReturnBackPilotView({Key? key, required this.dataId}) : super(key: key);

  GlobalKey<SfSignaturePadState> signatureKey = GlobalKey();

  Future<void> _uploadImageAndShowDialog(XFile pickedFile, BuildContext context) async {
    final Uint8List imageBytes = await pickedFile.readAsBytes();

    // Load the image using image package
    img.Image? image = img.decodeImage(imageBytes);

    // Compress the image to reduce size and resize the resolution
    image = img.copyResize(image!, width: 800);

    // Encode the compressed image to Uint8List
    final Uint8List compressedImageBytes = Uint8List.fromList(img.encodePng(image));

    final Reference storageReference =
    FirebaseStorage.instance.ref().child('camera_images/${Path.basename(dataId)}.png');

    try {
      // Upload the compressed image
      await storageReference.putData(compressedImageBytes);

      // Get the download URL after upload completes
      String cameraImageUrl = await storageReference.getDownloadURL();

      // Show confirmation dialog only after getting the image URL
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to submit this data?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text('Submit'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  confirmInUse(context, cameraImageUrl);
                  _showQuickAlert(context); // Call the function to submit data
                },
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'Your data has been saved! Thank You',
    );
    Navigator.of(context).pop();
  }

  void confirmInUse(BuildContext context, String cameraImageUrl) async {
    User? user = _auth.currentUser;

    if (user != null) {
      QuerySnapshot userQuery =
      await _firestore.collection('users').where('EMAIL', isEqualTo: user.email).get();
      String userUid = userQuery.docs.first.id;

      final signatureKey = this.signatureKey.currentState!;
      final image = await signatureKey.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      final Uint8List? uint8List = byteData?.buffer.asUint8List();

      final Reference storageReference = FirebaseStorage.instance.ref().child('signatures/${Path.basename(dataId)}.png');

      final UploadTask uploadTask = storageReference.putData(uint8List!);

      await uploadTask.whenComplete(() async {
        String signatureURL = await storageReference.getDownloadURL();

        DocumentReference pilotDeviceRef =
        FirebaseFirestore.instance.collection("pilot-device-1").doc(dataId);

        try {
          await pilotDeviceRef.update({
            'statusDevice': 'Done',
            'occ-accepted-device': userUid,
            'signature_url_occ': signatureURL,
            'prove_back_to_base': cameraImageUrl,
          });

          print('Data updated successfully!');
          Navigator.of(context).pop(); // Close the dialog
          Navigator.of(context).pop();

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirmation'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Data has been successfully updated.'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        } catch (error) {
          print('Error updating data: $error');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Need Confirm'),
        centerTitle: true,
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

                    if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                      final deviceUid2 = data['device_uid2'];
                      final deviceUid3 = data['device_uid3'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("Device")
                            .doc(deviceUid2)
                            .get(),
                        builder: (context, deviceSnapshot) {
                          if (deviceSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (deviceSnapshot.hasError) {
                            return Center(
                                child: Text('Error: ${deviceSnapshot.error}'));
                          }

                          if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                            return Center(child: Text('Device data 2 not found'));
                          }

                          final deviceData2 = deviceSnapshot.data!.data() as Map<
                              String,
                              dynamic>;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection("Device")
                                .doc(deviceUid3)
                                .get(),
                            builder: (context, deviceSnapshot) {
                              if (deviceSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (deviceSnapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${deviceSnapshot.error}'));
                              }

                              if (!deviceSnapshot.hasData ||
                                  !deviceSnapshot.data!.exists) {
                                return Center(child: Text('Device data 2 not found'));
                              }

                              final deviceData3 = deviceSnapshot.data!.data() as Map<
                                  String,
                                  dynamic>;

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
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
                                                Expanded(flex: 6, child: Text("ID NO", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                                Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    '${userData['ID NO'] ?? 'No Data'}',
                                                    style: tsOneTextTheme.bodySmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5.0),
                                            Row(
                                              children: [
                                                Expanded(flex: 6, child: Text("Name", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                                Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    '${userData['NAME'] ?? 'No Data'}',
                                                    style: tsOneTextTheme.bodySmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5.0),
                                            Row(
                                              children: [
                                                Expanded(flex: 6, child: Text("Rank", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                                Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    '${userData['RANK'] ?? 'No Data'}',
                                                    style: tsOneTextTheme.bodySmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 20),
                                              child: Divider(
                                                color: TsOneColor.secondaryContainer,
                                              ),
                                            ),
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
                                                    flex: 6, child: Text("Device ID", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":" , style: tsOneTextTheme.bodySmall,)),
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
                                                    flex: 6, child: Text("iOS Version", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
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
                                                    flex: 6, child: Text("FlySmart Version", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
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
                                                    flex: 6, child: Text("Docu Version", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
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
                                                    flex: 6, child: Text("Lido Version", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
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
                                                    flex: 6, child: Text("HUB", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
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
                                                    flex: 6, child: Text("Condition", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                                Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    '${deviceData2['condition'] ?? 'No Data'}',
                                                    style: tsOneTextTheme.bodySmall,
                                                  ),
                                                ),
                                              ],
                                            ),


                                            //DEVICE INFO 2
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
                                                    flex: 6, child: Text("Device ID", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
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
                                                    flex: 6, child: Text("iOS Version", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
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
                                                    flex: 6, child: Text("FlySmart Version", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
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
                                                    flex: 6, child: Text("Docu Version", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
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
                                                    flex: 6, child: Text("Lido Version", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
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
                                                    flex: 6, child: Text("HUB", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                                Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    '${deviceData3['hub'] ?? 'No Data'}',
                                                    style: tsOneTextTheme.bodySmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    flex: 6, child: Text("Condition", style: tsOneTextTheme.bodySmall,)),
                                                Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                                Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    '${deviceData3['condition'] ?? 'No Data'}',
                                                    style: tsOneTextTheme.bodySmall,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 20),
                                              child: Divider(
                                                color: TsOneColor.secondaryContainer,
                                              ),
                                            ),
                                            Text(
                                              "SIGNATURE",
                                              style: tsOneTextTheme.headlineLarge,
                                            ),

                                            Text(
                                              'Please sign in the section provided.',
                                              style: TextStyle(
                                                color: Colors.red,  // Mengatur warna teks menjadi merah
                                                fontStyle: FontStyle.italic,  // Mengatur teks menjadi italic
                                              ),
                                            ),

                                            SizedBox(height: 7.0),
                                            Column(
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  height: 400.0,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.3),
                                                        spreadRadius: 5,
                                                        blurRadius: 7,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: SfSignaturePad(
                                                    key: signatureKey,
                                                    backgroundColor: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 10.0),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    signatureKey.currentState?.clear();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: TsOneColor.primary,
                                                    minimumSize: const Size(double.infinity, 50),
                                                  ),
                                                  child: const Text('Clear Signature', style: TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 20.0),
                                            ElevatedButton(
                                              onPressed: () async {
                                                final ImagePicker _picker = ImagePicker();
                                                XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

                                                if (pickedFile != null) {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext context) {
                                                      return FutureBuilder<void>(
                                                        future: _uploadImageAndShowDialog(pickedFile, context),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return AlertDialog(
                                                              content: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  CircularProgressIndicator(),
                                                                  SizedBox(height: 10.0),
                                                                  Text("This might take a second..."),
                                                                ],
                                                              ),
                                                            );
                                                          } else {
                                                            return Container(); // Placeholder, you can customize this based on your requirements
                                                          }
                                                        },
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  print('No image selected.');
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: TsOneColor.greenColor,
                                                minimumSize: const Size(double.infinity, 50),
                                              ),
                                              child: const Text('Take Picture To Approve', style: TextStyle(color: Colors.white)),
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
                    }

                    final deviceData = deviceSnapshot.data!.data() as Map<String, dynamic>;

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text(
                                    "CREW INFO",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 7.0),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("ID NO",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 6, child: Text('${userData['ID NO'] ?? 'No Data'}',style: tsOneTextTheme.bodySmall,)),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("Name",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 6, child: Text('${userData['NAME'] ?? 'No Data'}',style: tsOneTextTheme.bodySmall, )),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("Rank", style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 6, child: Text('${userData['RANK'] ?? 'No Data'}',style: tsOneTextTheme.bodySmall,)),
                                    ],
                                  ),

                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Divider(
                                      color: TsOneColor.secondaryContainer,
                                    ),
                                  ),
                                  Text(
                                    "DEVICE INFO",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("Device ID",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 6, child: Text('${data['device_name'] ?? 'No Data'}',style: tsOneTextTheme.bodySmall,)),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("iOS Version",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 6, child: Text('${deviceData['iosver'] ?? 'No Data'}',style: tsOneTextTheme.bodySmall,)),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("FlySmart Version",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 6, child: Text('${deviceData['flysmart'] ?? 'No Data'}',style: tsOneTextTheme.bodySmall,)),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("Docu Version",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 6, child: Text('${deviceData['docuversion'] ?? 'No Data'}',style: tsOneTextTheme.bodySmall,)),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("Lido Version",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 6, child: Text('${deviceData['lidoversion'] ?? 'No Data'}',style: tsOneTextTheme.bodySmall,)),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("HUB",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 6, child: Text('${deviceData['hub'] ?? 'No Data'}',style: tsOneTextTheme.bodySmall,)),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("Condition",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                                      Expanded(flex: 6, child: Text('${deviceData['condition'] ?? 'No Data'}',style: tsOneTextTheme.bodySmall,)),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Divider(
                                      color: TsOneColor.secondaryContainer,
                                    ),
                                  ),
                                  Text(
                                    "SIGNATURE",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  Text(
                                      'Please sign in the section provided.',
                                      style: TextStyle(
                                        color: Colors.red,  // Mengatur warna teks menjadi merah
                                        fontStyle: FontStyle.italic,  // Mengatur teks menjadi italic
                                      ),
                                    ),

                                  SizedBox(height: 7.0),
                                  Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 400.0,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.3),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: SfSignaturePad(
                                          key: signatureKey,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      ElevatedButton(
                                        onPressed: () {
                                          signatureKey.currentState?.clear();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: TsOneColor.primary,
                                          minimumSize: const Size(double.infinity, 50),
                                        ),
                                        child: const Text('Clear Signature', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.0),
                                ElevatedButton(
                                  onPressed: () async {
                                    final ImagePicker _picker = ImagePicker();
                                    XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

                                    if (pickedFile != null) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return FutureBuilder<void>(
                                            future: _uploadImageAndShowDialog(pickedFile, context),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return AlertDialog(
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      CircularProgressIndicator(),
                                                      SizedBox(height: 10.0),
                                                      Text("This might take a second..."),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return Container(); // Placeholder, you can customize this based on your requirements
                                              }
                                            },
                                          );
                                        },
                                      );
                                    } else {
                                      print('No image selected.');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TsOneColor.greenColor,
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                  child: const Text('Take Picture To Approve', style: TextStyle(color: Colors.white)),
                                ),

                                  SizedBox(height: 20.0),
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
        ),
      ),
    );
  }
}


