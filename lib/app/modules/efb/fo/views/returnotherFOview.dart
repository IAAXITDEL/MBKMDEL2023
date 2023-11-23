import 'dart:typed_data';
import 'dart:ui';
//fdfffff
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:path/path.dart' as Path;

import '../../../../../presentation/theme.dart';
import '../../../../routes/app_pages.dart';

class ReturnOtherFOView extends StatefulWidget {
  final String documentId;
  final String deviceId;
  final String deviceName2;
  final String deviceName3;
  final String OccOnDuty;

  ReturnOtherFOView({
    required this.documentId,
    required this.deviceId,
    required this.OccOnDuty,
    required this.deviceName2,
    required this.deviceName3,
  });

  @override
  _ReturnOtherFOViewState createState() => _ReturnOtherFOViewState();
}

class _ReturnOtherFOViewState extends State<ReturnOtherFOView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _idController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String deviceId2 = "";
  String deviceId3 = "";
  String deviceName2 = "";
  String deviceName3 = "";
  String OccOnDuty = "";
  bool agree = false;
  DocumentSnapshot? selectedUser;
  Stream<QuerySnapshot>? usersStream;
  Uint8List? signatureImage;
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();

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

    _idController.addListener(() {
      // Listen to changes in the text field and filter users accordingly
      final searchText = _idController.text.trim();
      if (searchText.isNotEmpty) {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: searchText)
            .where(FieldPath.documentId, isLessThanOrEqualTo: searchText + '\uf8ff')
            .snapshots();
      } else {
        usersStream = null;
      }
      setState(() {});
    });
  }

  Future<void> _fetchUserData(String id) async {
    final documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(id).get();

    if (documentSnapshot.exists) {
      setState(() {
        selectedUser = documentSnapshot;
      });
    } else {
      setState(() {
        selectedUser = null;
      });
      // Show a snackbar with the "No Data In Database" message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Data In Database')),
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
          'Return',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Agar Column rata kiri
                  children: [
                    Text(
                      'Note:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight, // Ganti menjadi Alignment.centerLeft untuk membuat rata kiri
                            child: Text(
                              'You must be in one place with the next FO to confirm the return. If you are in a different place, whatever the FO contains, you automatically agree with its statement.',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: Text(
                  'Please select another crew',
                  style: tsOneTextTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextField(
              //         controller: _idController,
              //         decoration: InputDecoration(
              //           labelText: 'Enter ID Number',
              //         ),
              //       ),
              //     ),
              //     ElevatedButton(
              //       onPressed: () async {
              //         // Trigger barcode scanning
              //         String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode('#FF0000', 'Cancel', true, ScanMode.BARCODE);

              //         if (barcodeScanResult != '-1') {
              //           // Update the text field with the scanned result
              //           setState(() {
              //             _idController.text = barcodeScanResult;
              //             _fetchUserData(barcodeScanResult);
              //           });
              //           // Fetch user data for the scanned ID
              //         }
              //       },
              //       child: Icon(Icons.qr_code_2),
              //     ),
              //   ],
              // ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TsOneColor.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onPressed: () async {
                  String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode('#FF0000', 'Cancel', true, ScanMode.QR);

                  if (barcodeScanResult != '-1') {
                    setState(() {
                      _idController.text = barcodeScanResult;
                      _fetchUserData(barcodeScanResult);
                    });
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      color: TsOneColor.secondary,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Scan QR Crew",
                      style: TextStyle(color: TsOneColor.secondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // if (usersStream != null)
              //   StreamBuilder<QuerySnapshot>(
              //     stream: usersStream,
              //     builder: (context, snapshot) {
              //       if (!snapshot.hasData) {
              //         return CircularProgressIndicator();
              //       }
              //
              //       final users = snapshot.data!.docs;
              //
              //       return ListView.builder(
              //         shrinkWrap: true,
              //         itemCount: users.length,
              //         itemBuilder: (context, index) {
              //           final user = users[index];
              //
              //           return ListTile(
              //             title: Text(user.id), // Display the document ID
              //             onTap: () {
              //               _idController.text = user.id;
              //               _fetchUserData(user.id);
              //               setState(() {
              //                 usersStream = null;
              //               });
              //             },
              //           );
              //         },
              //       );
              //     },
              //   ),
              const SizedBox(height: 20.0),

              if (selectedUser != null)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Crew Info",
                    style: tsOneTextTheme.headlineMedium,
                  ),
                ),
              if (selectedUser != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Card(
                        color: tsOneColorScheme.secondary,
                        surfaceTintColor: TsOneColor.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 8.0),
                              CircleAvatar(
                                backgroundImage: selectedUser!['PHOTOURL'] != null
                                    ? NetworkImage(selectedUser!['PHOTOURL'] as String)
                                    : AssetImage('assets/default_profile_image.png') as ImageProvider,
                                radius: 25.0,
                              ),
                              SizedBox(width: 12.0),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      child: Text(
                                        '${selectedUser!['NAME']}',
                                        style: tsOneTextTheme.titleMedium,
                                      ),
                                    ),
                                    Text(
                                      '${selectedUser!['ID NO']}',
                                      style: tsOneTextTheme.labelMedium,
                                    ),
                                    Text(
                                      '${selectedUser!['RANK']}',
                                      style: tsOneTextTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 15.0),
              if (selectedUser != null)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15.0),
              if (selectedUser != null)
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
              if (selectedUser != null)
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
              if (selectedUser != null)
                Stack(
                  children: [
                    Container(
                      height: 380,
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
                        key: _signaturePadKey,
                        backgroundColor: Colors.white,
                        onDrawEnd: () async {
                          final signatureImageData = await _signaturePadKey.currentState!.toImage();
                          final byteData = await signatureImageData.toByteData(format: ImageByteFormat.png);
                          if (byteData != null) {
                            setState(() {
                              signatureImage = byteData.buffer.asUint8List();
                            });
                          }
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
                          _signaturePadKey.currentState?.clear();
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              if (selectedUser != null)
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: agree,
                          onChanged: (value) {
                            setState(() {
                              agree = value!;
                            });
                          },
                        ),
                        Text(
                          'I agree with all the statements above.',
                          style: tsOneTextTheme.labelSmall,
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final signatureData = signatureImage;
                        if (signatureData == null && !agree) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Please provide signature & consent"),
                              duration: const Duration(milliseconds: 1000),
                              action: SnackBarAction(
                                label: 'Close',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                },
                              ),
                            ),
                          );
                        } else if (signatureData == null) {
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
                        } else if (agree && signatureData == null) {
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
                        } else if (!agree) {
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
                        } else if (_signaturePadKey.currentState?.clear == null) {
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
                        } else if (signatureData != null && agree) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  'Confirmation',
                                  style: tsOneTextTheme.headlineLarge,
                                ),
                                content: const Text('Are you sure you want to save this signature?'),
                                actions: [
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
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              final idNumber = _idController.text.trim();
                                              if (idNumber.isNotEmpty) {
                                                User? user = _auth.currentUser;
                                                QuerySnapshot userQuery =
                                                    await _firestore.collection('users').where('EMAIL', isEqualTo: user?.email).get();
                                                String userUid = userQuery.docs.first.id;
                                                final image = await _signaturePadKey.currentState?.toImage(pixelRatio: 3.0);
                                                final ByteData? byteData = await image?.toByteData(format: ImageByteFormat.png);
                                                final Uint8List? uint8List = byteData?.buffer.asUint8List();
                                                final Reference storageReference =
                                                    FirebaseStorage.instance.ref().child('signatures/${DateTime.now()}.png');
                                                final UploadTask uploadTask = storageReference.putData(uint8List!);

                                                await uploadTask.whenComplete(() async {
                                                  String signatureUrl = await storageReference.getDownloadURL();
                                                  await _fetchUserData(idNumber);

                                                  FirebaseFirestore.instance.collection('pilot-device-1').doc(widget.deviceId).update({
                                                    'statusDevice': 'waiting-handover-to-other-crew',
                                                    'handover-to-crew': idNumber,
                                                    'signature_url': signatureUrl,
                                                    'document_id': widget.deviceId,
                                                  });
                                                });

                                                Navigator.pop(context); // Close the ReturnOtherPilotView
                                              } else {
                                                // Handle invalid input, show a message, or prevent submission
                                              }
                                            } catch (error) {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text('Error'),
                                                    content: const Text('An error occurred while saving the signature.'),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
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
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: TsOneColor.greenColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          )),
                      child: const Text('Submit', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  // Function to clear the signature
  void _clearSignature() {
    _signaturePadKey.currentState?.clear();
  }
}

Future<void> _showQuickAlert(BuildContext context) async {
  await QuickAlert.show(
    context: context,
    type: QuickAlertType.success,
    text: 'You have Returned To Other Crew! Thankss Capt!',
  );
  Get.offAllNamed(Routes.NAVOCC);
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
