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
import '../../../../routes/app_pages.dart';

class ConfirmReturnBackPilotView extends GetView {
  final String dataId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isImageUploading = false;
  bool agree = false;

  ConfirmReturnBackPilotView({Key? key, required this.dataId}) : super(key: key);

  //GlobalKey<SfSignaturePadState> signatureKey = GlobalKey();
  final GlobalKey<SfSignaturePadState> signatureKey = GlobalKey<SfSignaturePadState>();
  Uint8List? signatureImage;

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

  Future<void> _uploadImageAndShowDialog(XFile pickedFile, BuildContext context) async {
    final Uint8List imageBytes = await pickedFile.readAsBytes();

    // Load the image using the image package
    img.Image? originalImage = img.decodeImage(imageBytes);

    // Define maximum dimensions
    int maxWidth = 1024;
    int maxHeight = 1024;

    // Resize the image while maintaining its aspect ratio
    img.Image resizedImage = img.copyResize(originalImage!, width: maxWidth, height: maxHeight);

    // Encode the resized image to Uint8List with JPEG format and adjustable quality
    Uint8List compressedImageBytes = img.encodeJpg(resizedImage, quality: 75); // Adjust quality as needed

    final Reference storageReference = FirebaseStorage.instance.ref().child('camera_images/${Path.basename(dataId)} at ${DateTime.now()}.jpg');

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
            title: Text(
              'Confirmation',
              style: tsOneTextTheme.headlineLarge,
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to submit this data?'),
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
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const Spacer(flex: 1),
                  Expanded(
                    flex: 5,
                    child: ElevatedButton(
                      onPressed: () async {
                        confirmInUse(context, cameraImageUrl);
                        _showQuickAlert(context);
                      },
                      child: const Text('Yes', style: TextStyle(color: TsOneColor.onPrimary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TsOneColor.greenColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ],
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
    ).then((value) {
      Get.offAllNamed(Routes.NAVOCC);
    });
  }

  void confirmInUse(BuildContext context, String cameraImageUrl) async {
    User? user = _auth.currentUser;

    if (user != null) {
      QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user.email).get();
      String userUid = userQuery.docs.first.id;

      final signatureKey = this.signatureKey.currentState!;
      final image = await signatureKey.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      final Uint8List? uint8List = byteData?.buffer.asUint8List();

      final Reference storageReference = FirebaseStorage.instance.ref().child('signatures/${Path.basename(dataId)}.png');

      final UploadTask uploadTask = storageReference.putData(uint8List!);

      await uploadTask.whenComplete(() async {
        String signatureURL = await storageReference.getDownloadURL();

        DocumentReference pilotDeviceRef = FirebaseFirestore.instance.collection("pilot-device-1").doc(dataId);

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
                title: Text(
                  'Confirmation',
                  style: tsOneTextTheme.headlineLarge,
                ),
                content: const SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Data has been successfully updated.'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
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
        backgroundColor: Colors.white,
        title: Text(
          'Confirmation Return',
          style: tsOneTextTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection("pilot-device-1").doc(dataId).get(),
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
                      final deviceUid2 = data['device_uid2'];
                      final deviceUid3 = data['device_uid3'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection("Device").doc(deviceUid2).get(),
                        builder: (context, deviceSnapshot) {
                          if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (deviceSnapshot.hasError) {
                            return Center(child: Text('Error: ${deviceSnapshot.error}'));
                          }

                          if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                            return const Center(child: Text('Device data 2 not found'));
                          }

                          final deviceData2 = deviceSnapshot.data!.data() as Map<String, dynamic>;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection("Device").doc(deviceUid3).get(),
                            builder: (context, deviceSnapshot) {
                              if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (deviceSnapshot.hasError) {
                                return Center(child: Text('Error: ${deviceSnapshot.error}'));
                              }

                              if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                                return const Center(child: Text('Device data 2 not found'));
                              }

                              final deviceData3 = deviceSnapshot.data!.data() as Map<String, dynamic>;

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          // SizedBox(height: 10.0),
                                          // Align(
                                          //   alignment: Alignment.centerLeft,
                                          //   child: Text(
                                          //     "CREW INFO",
                                          //     style: tsOneTextTheme.titleLarge,
                                          //   ),
                                          // ),
                                          // SizedBox(height: 5.0),
                                          const SizedBox(height: 10.0),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
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
                                          // Padding(
                                          //   padding: EdgeInsets.symmetric(vertical: 20),
                                          //   child: Divider(
                                          //     color: TsOneColor.secondaryContainer,
                                          //   ),
                                          // ),
                                          // Align(
                                          //   alignment: Alignment.centerLeft,
                                          //   child: Text(
                                          //     "Device 2",
                                          //     style: tsOneTextTheme.titleLarge,
                                          //   ),
                                          // ),
                                          // SizedBox(height: 5.0),
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
                                          const SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "Device ID",
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
                                                    "iOS Version",
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
                                                  '${deviceData2['value']['iosver'] ?? 'No Data'}',
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
                                                  '${deviceData2['value']['flysmart'] ?? 'No Data'}',
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
                                                    "Docu Version",
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
                                                  '${deviceData2['value']['docuversion'] ?? 'No Data'}',
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
                                                    "Lido Version",
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
                                                  '${deviceData2['value']['lidoversion'] ?? 'No Data'}',
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
                                                  '${deviceData2['value']['hub'] ?? 'No Data'}',
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
                                                  '${deviceData2['value']['condition'] ?? 'No Data'}',
                                                  style: tsOneTextTheme.bodySmall,
                                                ),
                                              ),
                                            ],
                                          ),

                                          //DEVICE INFO 2
                                          const SizedBox(height: 10.0),
                                          // Align(
                                          //   alignment: Alignment.centerLeft,
                                          //   child: Text(
                                          //     "Device 3",
                                          //     style: tsOneTextTheme.titleLarge,
                                          //   ),
                                          // ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Device 3",
                                              style: tsOneTextTheme.headlineMedium,
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "Device ID",
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
                                                    "iOS Version",
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
                                                  '${deviceData3['value']['iosver'] ?? 'No Data'}',
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
                                                  '${deviceData3['value']['flysmart'] ?? 'No Data'}',
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
                                                    "Docu Version",
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
                                                  '${deviceData3['value']['docuversion'] ?? 'No Data'}',
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
                                                    "Lido Version",
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
                                                  '${deviceData3['value']['lidoversion'] ?? 'No Data'}',
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
                                                  '${deviceData3['value']['hub'] ?? 'No Data'}',
                                                  style: tsOneTextTheme.bodySmall,
                                                ),
                                              ),
                                            ],
                                          ),
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
                                                  '${deviceData3['value']['condition'] ?? 'No Data'}',
                                                  style: tsOneTextTheme.bodySmall,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Padding(
                                          //   padding: EdgeInsets.symmetric(vertical: 20),
                                          //   child: Divider(
                                          //     color: TsOneColor.secondaryContainer,
                                          //   ),
                                          // ),
                                          // Text(
                                          //   "SIGNATURE",
                                          //   style: tsOneTextTheme.headlineLarge,
                                          // ),

                                          // Text(
                                          //   'Please sign in the section provided.',
                                          //   style: TextStyle(
                                          //     color: Colors.red, // Mengatur warna teks menjadi merah
                                          //     fontStyle: FontStyle.italic, // Mengatur teks menjadi italic
                                          //   ),
                                          // ),

                                          // SizedBox(height: 7.0),
                                          const SizedBox(height: 20.0),
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
                                                    'Please sign in the provided section',
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
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Signature",
                                              style: tsOneTextTheme.headlineMedium,
                                            ),
                                          ),
                                          const SizedBox(height: 15.0),

                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minHeight: 40,
                                              minWidth: 400,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: tsOneColorScheme.primary,
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(25.0),
                                                  topRight: Radius.circular(25.0),
                                                ),
                                              ),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text("Draw", style: TextStyle(color: tsOneColorScheme.secondary, fontWeight: FontWeight.w600)),
                                              ),
                                            ),
                                          ),
                                          Stack(
                                            children: [
                                              Container(
                                                height: 480,
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(10.0),
                                                    topRight: Radius.circular(10.0),
                                                    bottomLeft: Radius.circular(25.0),
                                                    bottomRight: Radius.circular(25.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      blurRadius: 5,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: SfSignaturePad(
                                                  key: signatureKey,
                                                  backgroundColor: Colors.white,
                                                  onDrawEnd: () async {
                                                    final signatureImageData = await signatureKey.currentState!.toImage();
                                                    final byteData = await signatureImageData.toByteData(format: ImageByteFormat.png);
                                                    // if (byteData != null) {
                                                    //   setState(() {
                                                    //     widget.signatureImage = byteData.buffer.asUint8List();
                                                    //   });
                                                    // }
                                                  },
                                                ),
                                              ),
                                              Container(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline_outlined,
                                                    size: 32,
                                                    color: TsOneColor.primary,
                                                  ),
                                                  onPressed: () {
                                                    signatureKey.currentState?.clear();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            children: [
                                              StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Checkbox(
                                                    value: agree,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        agree = value!;
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                              Text(
                                                'I agree with all the statements above.',
                                                style: tsOneTextTheme.labelSmall,
                                              )
                                            ],
                                          ),

                                          // Column(
                                          //   children: [
                                          //     Container(
                                          //       width: double.infinity,
                                          //       height: 400.0,
                                          //       decoration: BoxDecoration(
                                          //         boxShadow: [
                                          //           BoxShadow(
                                          //             color: Colors.grey.withOpacity(0.3),
                                          //             spreadRadius: 5,
                                          //             blurRadius: 7,
                                          //             offset: Offset(0, 3),
                                          //           ),
                                          //         ],
                                          //       ),
                                          //       child: SfSignaturePad(
                                          //         key: signatureKey,
                                          //         backgroundColor: Colors.white,
                                          //       ),
                                          //     ),
                                          //     SizedBox(height: 10.0),
                                          //     ElevatedButton(
                                          //       onPressed: () {
                                          //         signatureKey.currentState?.clear();
                                          //       },
                                          //       style: ElevatedButton.styleFrom(
                                          //         backgroundColor: TsOneColor.primary,
                                          //         minimumSize: const Size(double.infinity, 50),
                                          //       ),
                                          //       child: const Text('Clear Signature', style: TextStyle(color: Colors.white)),
                                          //     ),
                                          //   ],
                                          // ),

                                          const SizedBox(height: 20.0),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // final ImagePicker _picker = ImagePicker();
                                              // XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                                              final signatureData = await signatureKey.currentState!.toImage();

                                              if (!agree) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text("Please checklist consent"),
                                                    duration: const Duration(milliseconds: 1000),
                                                    action: SnackBarAction(
                                                      label: 'Close',
                                                      onPressed: () {
                                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                      },
                                                    ),
                                                  ),
                                                );
                                              } else if (signatureKey.currentState?.clear == null || signatureData == null) {
                                                //widget._signaturePadKey.currentState!.clear();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text("Please provide signature"),
                                                    duration: const Duration(milliseconds: 1000),
                                                    action: SnackBarAction(
                                                      label: 'Close',
                                                      onPressed: () {
                                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                      },
                                                    ),
                                                  ),
                                                );
                                              } else {
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
                                                            return const AlertDialog(
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
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: TsOneColor.greenColor,
                                              minimumSize: const Size(double.infinity, 50),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                            child: const Text('Take Picture To Approve', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
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
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SizedBox(height: 5),
                                // Text(
                                //   "CREW INFO",
                                //   style: tsOneTextTheme.headlineLarge,
                                // ),
                                // SizedBox(height: 7.0),
                                const SizedBox(height: 10.0),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
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
                                        )),
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
                                        )),
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
                                        )),
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
                                Text(
                                  "Device 1",
                                  style: tsOneTextTheme.headlineMedium,
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Device ID",
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
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "iOS Version",
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
                                        )),
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
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Docu Version",
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
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Lido Version",
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
                                        )),
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
                                        )),
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
                                        )),
                                  ],
                                ),
                                // Padding(
                                //   padding: EdgeInsets.symmetric(vertical: 20),
                                //   child: Divider(
                                //     color: TsOneColor.secondaryContainer,
                                //   ),
                                // ),
                                // Text(
                                //   "SIGNATURE",
                                //   style: tsOneTextTheme.headlineLarge,
                                // ),
                                // Text(
                                //   'Please sign in the section provided.',
                                //   style: TextStyle(
                                //     color: Colors.red, // Mengatur warna teks menjadi merah
                                //     fontStyle: FontStyle.italic, // Mengatur teks menjadi italic
                                //   ),
                                // ),
                                // SizedBox(height: 7.0),
                                const SizedBox(height: 20.0),
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
                                          'Please sign in the provided section',
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
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Signature",
                                    style: tsOneTextTheme.headlineMedium,
                                  ),
                                ),
                                const SizedBox(height: 15.0),

                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 40,
                                    minWidth: 400,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: tsOneColorScheme.primary,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(25.0),
                                        topRight: Radius.circular(25.0),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text("Draw", style: TextStyle(color: tsOneColorScheme.secondary, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      height: 480,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                          bottomLeft: Radius.circular(25.0),
                                          bottomRight: Radius.circular(25.0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: SfSignaturePad(
                                        key: signatureKey,
                                        backgroundColor: Colors.white,
                                        onDrawEnd: () async {
                                          final signatureImageData = await signatureKey.currentState!.toImage();
                                          final byteData = await signatureImageData.toByteData(format: ImageByteFormat.png);
                                          // if (byteData != null) {
                                          //   setState(() {
                                          //     widget.signatureImage = byteData.buffer.asUint8List();
                                          //   });
                                          // }
                                        },
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_outlined,
                                          size: 32,
                                          color: TsOneColor.primary,
                                        ),
                                        onPressed: () {
                                          signatureKey.currentState?.clear();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    StatefulBuilder(
                                      builder: (context, setState) {
                                        return Checkbox(
                                          value: agree,
                                          onChanged: (value) {
                                            setState(() {
                                              agree = value!;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                    Text(
                                      'I agree with all the statements above.',
                                      style: tsOneTextTheme.labelSmall,
                                    )
                                  ],
                                ),

                                // Column(
                                //   children: [
                                //     Container(
                                //       width: double.infinity,
                                //       height: 400.0,
                                //       decoration: BoxDecoration(
                                //         boxShadow: [
                                //           BoxShadow(
                                //             color: Colors.grey.withOpacity(0.3),
                                //             spreadRadius: 5,
                                //             blurRadius: 7,
                                //             offset: Offset(0, 3),
                                //           ),
                                //         ],
                                //       ),
                                //       child: SfSignaturePad(
                                //         key: signatureKey,
                                //         backgroundColor: Colors.white,
                                //       ),
                                //     ),
                                //     SizedBox(height: 10.0),
                                //     ElevatedButton(
                                //       onPressed: () {
                                //         signatureKey.currentState?.clear();
                                //       },
                                //       style: ElevatedButton.styleFrom(
                                //         backgroundColor: TsOneColor.primary,
                                //         minimumSize: const Size(double.infinity, 50),
                                //       ),
                                //       child: const Text('Clear Signature', style: TextStyle(color: Colors.white)),
                                //     ),
                                //   ],
                                // ),
                                const SizedBox(height: 20.0),
                                ElevatedButton(
                                  onPressed: () async {
                                    // final ImagePicker _picker = ImagePicker();
                                    // XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                                    final signatureData = await signatureKey.currentState!.toImage();

                                    if (!agree) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text("Please checklist consent"),
                                          duration: const Duration(milliseconds: 1000),
                                          action: SnackBarAction(
                                            label: 'Close',
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            },
                                          ),
                                        ),
                                      );
                                    } else if (signatureKey.currentState?.clear == null || signatureData == null) {
                                      //widget._signaturePadKey.currentState!.clear();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text("Please provide signature"),
                                          duration: const Duration(milliseconds: 1000),
                                          action: SnackBarAction(
                                            label: 'Close',
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            },
                                          ),
                                        ),
                                      );
                                    } else {
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
                                                  return const AlertDialog(
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
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TsOneColor.greenColor,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: const Text('Take Picture To Approve', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(height: 20.0),
                              ],
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
