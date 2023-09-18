import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:path/path.dart' as Path;

import '../../../../../presentation/theme.dart';

class ConfirmReturnBackPilotView extends GetView {
  final String dataId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  ConfirmReturnBackPilotView({Key? key, required this.dataId})
      : super(key: key);


  GlobalKey<SfSignaturePadState> signatureKey = GlobalKey();

  // Function to show a success message using QuickAlert
  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'Your data has been saved! Thank You',
    );
    Navigator.of(context).pop();
  }

  void confirmInUse(BuildContext context) async {
    User? user = _auth.currentUser;

    if (user != null) {
      QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user.email).get();
      String userUid = userQuery.docs.first.id;

      final signatureKey = this.signatureKey.currentState!;
      final image = await signatureKey.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
      await image.toByteData(format: ImageByteFormat.png);
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
            'occ-accepted-device': userUid,
            'signature_url_occ': signatureURL,

          });

          print('Data updated successfully!');
          Navigator.of(context).pop(); // Close the dialog
          Navigator.of(context).pop();

          // Show a confirmation dialog
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
                                  Text(
                                    "CREW INFO",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 7.0),
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
                                  SizedBox(height: 5.0),
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
                                  SizedBox(height: 5.0),
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
                                  Text(
                                    "DEVICE INFO",
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
                                  SizedBox(height: 5.0),
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
                                  SizedBox(height: 5.0),
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
                                  SizedBox(height: 5.0),
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
                                  SizedBox(height: 5.0),
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
                                  SizedBox(height: 5.0),
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
                                  Text(
                                    "CONFIRMATION",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 5.0),


                                  // Tambahkan widget SignaturePad di sini
                                  SizedBox(height: 20.0),
                                  Text(
                                    "SIGNATURE",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 8.0),
                                  Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 400.0,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey
                                                  .withOpacity(0.3), // Warna bayangan
                                              spreadRadius:
                                              5, // Radius penyebaran bayangan
                                              blurRadius:
                                              7, // Radius blur bayangan
                                              offset: Offset(
                                                  0, 3), // Offset bayangan (x, y)
                                            ),
                                          ],
                                        ),
                                        child: SfSignaturePad(
                                          key: signatureKey,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 10.0), // Spasi antara SignaturePad dan tombol
                                      ElevatedButton(
                                        onPressed: () {
                                          // Clear signature saat tombol ditekan
                                          signatureKey.currentState?.clear();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          TsOneColor.primary, // Warna tombol
                                          minimumSize: const Size(
                                              double.infinity, 50),
                                        ),
                                        child: const Text('Clear Signature',
                                            style:
                                            TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 20.0),

                                  ElevatedButton(
                                    onPressed: () {
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
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Submit'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(); // Close the confirmation dialog
                                                  Navigator.of(context).pop(); // Close the confirmation dialog
                                                  Navigator.of(context).pop(); // Close the confirmation dialog
                                                  confirmInUse(context);
                                                  _showQuickAlert(context);// Call the function to submit data
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: TsOneColor.greenColor,
                                      minimumSize: const Size(double.infinity, 50),
                                    ),
                                    child: const Text('Submit', style: TextStyle(color: Colors.white)),
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
