import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:path/path.dart' as Path;
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../presentation/theme.dart';

class ConfirmReturnBackPilotView extends GetView {
  final String dataId;

  ConfirmReturnBackPilotView({Key? key, required this.dataId})
      : super(key: key);

  TextEditingController occAcceptedTheDeviceController =
  TextEditingController();

  GlobalKey<SfSignaturePadState> signatureKey = GlobalKey();

  void confirmInUse(BuildContext context) async {
    final String occAcceptedTheDevice =
        occAcceptedTheDeviceController.text;

    if (occAcceptedTheDevice.isNotEmpty) {
      final signatureKey = this.signatureKey.currentState!;
      final image = await signatureKey.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      final Uint8List? uint8List = byteData?.buffer.asUint8List();

      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('signatures/${Path.basename(dataId)}.png');

      final UploadTask uploadTask = storageReference.putData(uint8List!);

      await uploadTask.whenComplete(() async {
        String signatureURL = await storageReference.getDownloadURL();

        DocumentReference pilotDeviceRef = FirebaseFirestore.instance
            .collection("pilot-device-1")
            .doc(dataId);

        try {
          await pilotDeviceRef.update({
            'status-device-1': 'Done',
            'occ-on-duty': occAcceptedTheDevice,
            'signature_url_occ': signatureURL,
          });

          print('Data updated successfully!');
          Navigator.of(context).pop(); // Close the dialog
          Navigator.of(context).pop();
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

            final data = snapshot.data!.data()
            as Map<String, dynamic>;

            final userUid = data['user_uid'];
            final deviceUid = data['device_uid'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(userUid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${userSnapshot.error}'));
                }

                if (!userSnapshot.hasData ||
                    !userSnapshot.data!.exists) {
                  return Center(child: Text('User data not found'));
                }

                final userData = userSnapshot.data!.data()
                as Map<String, dynamic>;

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("Device")
                      .doc(deviceUid)
                      .get(),
                  builder: (context, deviceSnapshot) {
                    if (deviceSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator());
                    }

                    if (deviceSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${deviceSnapshot.error}'));
                    }

                    if (!deviceSnapshot.hasData ||
                        !deviceSnapshot.data!.exists) {
                      return Center(child: Text('Device data not found'));
                    }

                    final deviceData =
                    deviceSnapshot.data!.data()
                    as Map<String, dynamic>;

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  RedTitleText(text: "CREW INFO",),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("ID NO")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${userData['ID NO'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Name")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${userData['NAME'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Rank")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${userData['RANK'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  Text("DEVICE INFO",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Device ID")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${data['device_name'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("iOS Version")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${deviceData['iosver'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("FlySmart Version")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${deviceData['flysmart'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Docu Version")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${deviceData['docuversion'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Lido Version")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${deviceData['lidoversion'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Condition")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${deviceData['condition'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  Text("CONFIRMATION",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Occ on Duty")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: TextField(
                                          controller:
                                          occAcceptedTheDeviceController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Occ on Duty',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Tambahkan widget SignaturePad di sini
                                  SizedBox(height: 20.0),
                                  Text("SIGNATURE",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 5.0),
                                  Container(
                                    width: double.infinity,
                                    height: 200.0,
                                    child: SfSignaturePad(
                                      key: signatureKey,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),

                                  SizedBox(height: 10.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      confirmInUse(context);
                                    },
                                    child: Text('Confirm'),
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
          },
        ),
      ),
    );
  }
}
