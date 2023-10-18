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

class ConfirmReturnBackPilotView extends StatefulWidget {
  final String dataId;
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();
  Uint8List? signatureImage;

  ConfirmReturnBackPilotView({Key? key, required this.dataId}) : super(key: key);

  @override
  _ConfirmReturnBackPilotViewState createState() => _ConfirmReturnBackPilotViewState();
}

class _ConfirmReturnBackPilotViewState extends State<ConfirmReturnBackPilotView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isImageUploading = false;

  bool agree = false;
  var isChecked = false.obs;

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

  GlobalKey<SfSignaturePadState> signatureKey = GlobalKey();

  Future<void> _uploadImageAndShowDialog(XFile pickedFile, BuildContext context) async {
    final int targetFileSizeInBytes = 2 * 1024 * 1024; // Target ukuran file 2MB

    // Baca file gambar
    final Uint8List imageData = await pickedFile.readAsBytes();

    double compressionRatio = 1.0;

    // Reduce the image dimensions iteratively until the file size is below the target
    while (imageData.length > targetFileSizeInBytes && compressionRatio > 0) {
      final img.Image? originalImage = img.decodeImage(imageData);
      final img.Image compressedImage = img.copyResize(originalImage!,
          width: (originalImage.width * compressionRatio).toInt(), height: (originalImage.height * compressionRatio).toInt());

      final compressedImageData = img.encodePng(compressedImage);

      compressionRatio -= 0.1;

      // Update imageData for the next iteration
      imageData.clear();
      imageData.addAll(compressedImageData);
    }

    final Reference storageReference = FirebaseStorage.instance.ref().child('camera_images/${Path.basename(widget.dataId)}.png');

    try {
      // Upload gambar yang sudah terkompresi
      await storageReference.putData(imageData);

      // Dapatkan URL unduhan setelah proses unggah selesai
      String cameraImageUrl = await storageReference.getDownloadURL();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Confirmation',
              style: tsOneTextTheme.headlineLarge,
            ),
            content: SingleChildScrollView(
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
                      child: Text('No', style: TextStyle(color: TsOneColor.secondaryContainer)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Spacer(flex: 1),
                  Expanded(
                    flex: 5,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
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
      text: 'Your data has been saved. Thank You',
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

      final Reference storageReference = FirebaseStorage.instance.ref().child('signatures/${Path.basename(widget.dataId)}.png');

      final UploadTask uploadTask = storageReference.putData(uint8List!);

      await uploadTask.whenComplete(() async {
        String signatureURL = await storageReference.getDownloadURL();

        DocumentReference pilotDeviceRef = FirebaseFirestore.instance.collection("pilot-device-1").doc(widget.dataId);

        try {
          await pilotDeviceRef.update({
            'statusDevice': 'Done',
            'occ-accepted-device': userUid,
            'signature_url_occ': signatureURL,
            'prove_back_to_base': cameraImageUrl,
          });

          print('Data updated successfully!');

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Confirmation',
                  style: tsOneTextTheme.headlineLarge,
                ),
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
                      Navigator.of(context).pop();
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
          future: FirebaseFirestore.instance.collection("pilot-device-1").doc(widget.dataId).get(),
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

                              final deviceData3 = deviceSnapshot.data!.data() as Map<String, dynamic>;

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
                                          ),
                                          SizedBox(height: 15.0),
                                          Row(
                                            children: [
                                              Expanded(flex: 6, child: Text("ID NO")),
                                              Expanded(flex: 1, child: Text(":")),
                                              Expanded(
                                                flex: 6,
                                                child: Text('${userData['ID NO'] ?? 'No Data'}'),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(flex: 6, child: Text("Name")),
                                              Expanded(flex: 1, child: Text(":")),
                                              Expanded(
                                                flex: 6,
                                                child: Text('${userData['NAME'] ?? 'No Data'}'),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(flex: 6, child: Text("Rank")),
                                              Expanded(flex: 1, child: Text(":")),
                                              Expanded(
                                                flex: 6,
                                                child: Text('${userData['RANK'] ?? 'No Data'}'),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
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
                                            child: Text("Device 2", style: tsOneTextTheme.displaySmall),
                                          ),
                                          SizedBox(height: 7.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "Device No",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "IOS Version",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "FlySmart Version",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "Docunet Version",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "Lido mPilot Version",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "HUB",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "Condition",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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

                                          //DEVICE INFO 2
                                          SizedBox(height: 15.0),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Device 3", style: tsOneTextTheme.displaySmall),
                                          ),
                                          SizedBox(height: 7.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "Device No",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "IOS Version",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "FlySmart Version",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "Docunet Version",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "Lido mPilot Version",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          SizedBox(height: 5.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "HUB",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    "Condition",
                                                    style: tsOneTextTheme.bodySmall,
                                                  )),
                                              Expanded(
                                                  flex: 1,
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

                                          SizedBox(height: 20.0),
                                          const Padding(
                                            padding: EdgeInsets.only(bottom: 20.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Divider(
                                                    color: TsOneColor.primary,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(
                                                    'Please sign in the section provided.',
                                                    style: TextStyle(color: TsOneColor.primary),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Divider(
                                                    color: TsOneColor.primary,
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
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minHeight: 40,
                                              minWidth: 400,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: tsOneColorScheme.primary,
                                                borderRadius: BorderRadius.only(
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
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(10.0),
                                                    topRight: Radius.circular(10.0),
                                                    bottomLeft: Radius.circular(25.0),
                                                    bottomRight: Radius.circular(25.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      blurRadius: 5,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: SfSignaturePad(
                                                  key: signatureKey,
                                                  backgroundColor: Colors.white,
                                                  onDrawEnd: () async {
                                                    final signatureImageData = await widget._signaturePadKey.currentState!.toImage();
                                                    final byteData = await signatureImageData.toByteData(format: ImageByteFormat.png);
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
                                          SizedBox(height: 10),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Obx(() {
                                                    return Checkbox(
                                                      value: isChecked.value,
                                                      onChanged: (value) {
                                                        isChecked.value = value!;
                                                      },
                                                    );
                                                  }),
                                                  Text('I agree with all of the results', style: TextStyle(fontWeight: FontWeight.w300)),
                                                ],
                                              ),
                                              SizedBox(height: 15),
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    final signatureData = await signatureKey.currentState!.toImage();
                                                    if (!isChecked.value) {
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
                                                    } else if (widget._signaturePadKey.currentState?.clear != null) {
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
                                                                  return Container();
                                                                }
                                                              },
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        print('No image selected');
                                                      }
                                                    }

                                                    // else if (signatureData != null && agree) {
                                                    //   showDialog(
                                                    //     context: context,
                                                    //     builder: (context) {
                                                    //       return AlertDialog(
                                                    //         title: Text(
                                                    //           'Confirm',
                                                    //           style: tsOneTextTheme.headlineLarge,
                                                    //         ),
                                                    //         content: const Text('Are you sure you want to save this signature?'),
                                                    //         actions: [
                                                    //           Row(
                                                    //             children: [
                                                    //               Expanded(
                                                    //                 flex: 5,
                                                    //                 child: TextButton(
                                                    //                   child: Text('No', style: TextStyle(color: TsOneColor.secondaryContainer)),
                                                    //                   onPressed: () {
                                                    //                     Navigator.of(context).pop();
                                                    //                   },
                                                    //                 ),
                                                    //               ),
                                                    //               Spacer(flex: 1),
                                                    //               Expanded(
                                                    //                 flex: 5,
                                                    //                 child: ElevatedButton(
                                                    //                   onPressed: () {
                                                    //                     try {
                                                    //                       final newDocumentId = addToPilotDeviceCollection(
                                                    //                         signatureData,
                                                    //                         widget.deviceId,
                                                    //                       );
                                                    //                     } catch (error) {
                                                    //                       showDialog(
                                                    //                         context: context,
                                                    //                         builder: (context) {
                                                    //                           return AlertDialog(
                                                    //                             title: const Text('Error'),
                                                    //                             content: const Text('An error occurred while saving the signature.'),
                                                    //                             actions: [
                                                    //                               ElevatedButton(
                                                    //                                 onPressed: () {
                                                    //                                   Navigator.pop(context);
                                                    //                                 },
                                                    //                                 child: const Text('OK'),
                                                    //                               ),
                                                    //                             ],
                                                    //                           );
                                                    //                         },
                                                    //                       );
                                                    //                     }
                                                    //                     _showQuickAlert(context);
                                                    //                   },
                                                    //                   child: const Text('Yes', style: TextStyle(color: TsOneColor.onPrimary)),
                                                    //                   style: ElevatedButton.styleFrom(
                                                    //                     backgroundColor: TsOneColor.greenColor,
                                                    //                     shape: RoundedRectangleBorder(
                                                    //                       borderRadius: BorderRadius.circular(20.0),
                                                    //                     ),
                                                    //                   ),
                                                    //                 ),
                                                    //               ),
                                                    //             ],
                                                    //           ),
                                                    //         ],
                                                    //       );
                                                    //     },
                                                    //   );
                                                    // }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor: TsOneColor.greenColor,
                                                      minimumSize: const Size(double.infinity, 50),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(4),
                                                      )),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.camera_alt_outlined,
                                                        size: 24,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text('Take a picture for approval', style: TextStyle(color: Colors.white)),
                                                    ],
                                                  )),
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

                                          SizedBox(height: 15.0),
                                          // ElevatedButton(
                                          //   onPressed: () async {
                                          //     final ImagePicker _picker = ImagePicker();
                                          //     XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                                          //
                                          //     if (pickedFile != null) {
                                          //       showDialog(
                                          //         context: context,
                                          //         barrierDismissible: false,
                                          //         builder: (BuildContext context) {
                                          //           return FutureBuilder<void>(
                                          //             future: _uploadImageAndShowDialog(pickedFile, context),
                                          //             builder: (context, snapshot) {
                                          //               if (snapshot.connectionState == ConnectionState.waiting) {
                                          //                 return AlertDialog(
                                          //                   content: Column(
                                          //                     mainAxisSize: MainAxisSize.min,
                                          //                     children: [
                                          //                       CircularProgressIndicator(),
                                          //                       SizedBox(height: 10.0),
                                          //                       Text("This might take a second..."),
                                          //                     ],
                                          //                   ),
                                          //                 );
                                          //               } else {
                                          //                 return Container(); // Placeholder, you can customize this based on your requirements
                                          //               }
                                          //             },
                                          //           );
                                          //         },
                                          //       );
                                          //     } else {
                                          //       print('No image selected.');
                                          //     }
                                          //   },
                                          //   style: ElevatedButton.styleFrom(
                                          //     backgroundColor: TsOneColor.greenColor,
                                          //     minimumSize: const Size(double.infinity, 50),
                                          //   ),
                                          //   child: const Text('Take Picture To Approve', style: TextStyle(color: Colors.white)),
                                          // ),
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
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "ID NO",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 1,
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
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "Name",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 1,
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
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "Rank",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 1,
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
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "Device No",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 1,
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
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "IOS Version",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData['iosver'] ?? 'No Data'}',
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "FlySmart Version",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData['flysmart'] ?? 'No Data'}',
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "Docunet Version",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData['docuversion'] ?? 'No Data'}',
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "Lido mPilot Version",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData['lidoversion'] ?? 'No Data'}',
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "HUB",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData['hub'] ?? 'No Data'}',
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            "Condition",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                      Expanded(
                                          flex: 6,
                                          child: Text(
                                            '${deviceData['condition'] ?? 'No Data'}',
                                            style: tsOneTextTheme.bodySmall,
                                          )),
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
                                      color: Colors.red, // Mengatur warna teks menjadi merah
                                      fontStyle: FontStyle.italic, // Mengatur teks menjadi italic
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
