import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../../../../routes/app_pages.dart';

class ReturnOtherPilotView extends StatefulWidget {
  final String documentId;
  final String deviceName;
  final String deviceId;
  final String OccOnDuty;

  ReturnOtherPilotView({
    required this.documentId,
    required this.deviceName,
    required this.deviceId,
    required this.OccOnDuty,
  });

  @override
  _ReturnOtherPilotViewState createState() => _ReturnOtherPilotViewState();
}

class _ReturnOtherPilotViewState extends State<ReturnOtherPilotView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _idController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String deviceId = "";
  String deviceName = "";
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
          deviceId = documentSnapshot['device_uid'];
          deviceName = documentSnapshot['device_name'];
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
              //         enabled: true,
              //         //readOnly: true,  // Make the text field non-editable
              //         decoration: InputDecoration(
              //           labelText: 'Enter ID Number',
              //         ),
              //       ),
              //     ),
              //     ElevatedButton(
              //       onPressed: () async {
              //         // Trigger barcode scanning
              //         String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode('#FF0000', 'Cancel', true, ScanMode.QR);

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
              // SizedBox(height: 16.0),
              // if (usersStream == null && selectedUser == null)
              //   Center(
              //     child: Text('Please select the user'),
              //   ),
              //SizedBox(height: 16.0),
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
              const SizedBox(height: 16.0),
              if (selectedUser != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: tsOneColorScheme.onSecondary,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Crew Info",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //         flex: 6,
                        //         child: Text(
                        //           "ID NO",
                        //           style: tsOneTextTheme.bodySmall,
                        //         )),
                        //     Expanded(
                        //
                        //         child: Text(
                        //           ":",
                        //           style: tsOneTextTheme.bodySmall,
                        //         )),
                        //     Expanded(
                        //       flex: 6,
                        //       child: Text(
                        //         '${selectedUser!['ID NO']}',
                        //         style: tsOneTextTheme.bodySmall,
                        //       ),
                        //     ),
                        //   ],
                        // ),
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
                                '${selectedUser!['NAME']}',
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
                                '${selectedUser!['RANK']}',
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
                                '${selectedUser!['HUB']}',
                                style: tsOneTextTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20.0),
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
                        const Text('I agree with all the statements above.', style: TextStyle(fontWeight: FontWeight.w300)),
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

                                                _showQuickAlert(context);
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
}

Future<void> _showQuickAlert(BuildContext context) async {
  await QuickAlert.show(
    context: context,
    type: QuickAlertType.success,
    text: 'You have Returned To Other Crew! Thankss Capt!',
  );
  Get.offAllNamed(Routes.NAVOCC);
}

Future<String> getHubFromDeviceName(String deviceName) async {
  String hub = "Unknown Hub"; // Default value

  try {
    // Fetch the 'hub' field from the 'Device' collection based on deviceName
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Device').where('deviceno', isEqualTo: deviceName).get();

    if (querySnapshot.docs.isNotEmpty) {
      hub = querySnapshot.docs.first['hub'];
    }
  } catch (e) {
    print("Error getting hub from Device: $e");
  }

  return hub;
}
