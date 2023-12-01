import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

import 'package:ts_one/app/modules/efb/pilot/views/main_view_pilot.dart';
import 'package:ts_one/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../../../../../presentation/theme.dart';

class SignaturePadPage extends StatefulWidget {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();
  Uint8List? signatureImage;
  final String deviceId;
  final TextEditingController remarksController = TextEditingController();
  // final TextEditingController remarksHandoverController = TextEditingController();

  SignaturePadPage({required String documentId, required this.deviceId});

  @override
  _SignaturePadPageState createState() => _SignaturePadPageState();
}

class _SignaturePadPageState extends State<SignaturePadPage> {
  bool agree = false;

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
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
                              'You must be in one place with the OCC to confirm the return. If you are in a different place, whatever the OCC contains, you automatically agree with its statement.',
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
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enter your remarks",
                  style: tsOneTextTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: widget.remarksController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Fill if returned via FO',
                ),
              ),
              const SizedBox(height: 10),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ConstrainedBox(
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
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Stack(
                  children: [
                    Container(
                      height: 300,
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
                        key: widget._signaturePadKey,
                        backgroundColor: Colors.white,
                        onDrawEnd: () async {
                          final signatureImageData = await widget._signaturePadKey.currentState!.toImage();
                          final byteData = await signatureImageData.toByteData(format: ImageByteFormat.png);
                          if (byteData != null) {
                            setState(() {
                              widget.signatureImage = byteData.buffer.asUint8List();
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
                          widget._signaturePadKey.currentState?.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
                      final signatureData = widget.signatureImage;
                      final remarks = widget.remarksController.text;
                      // final remarksHandover = widget.remarksHandoverController.text;

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
                      } else if (widget._signaturePadKey.currentState?.clear == null) {
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
                                        onPressed: () {
                                          try {
                                            final newDocumentId = addToPilotDeviceCollection(signatureData, widget.deviceId, remarks
                                                // remarksHandover,
                                                );
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
                                          _showQuickAlert(context, remarks);
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
                      ),
                    ),
                    child: const Text('Submit', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addToPilotDeviceCollection(Uint8List signatureData, String deviceId, String remarks) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      Map<String, dynamic> additionalData = {
        'signature_url': await uploadSignatureToFirestore(signatureData),
        'statusDevice': 'need-confirmation-occ',
        'document_id': deviceId,
        // 'handover-to-crew': 'remarksHandover',
        // 'remarks-handover': '-',
        'remarks-handover': remarks,
        // 'remarks': remarks,
      };

      try {
        await FirebaseFirestore.instance.collection('pilot-device-1').doc(deviceId).update(additionalData);

        return;
      } catch (e) {
        print("Error updating document in Firestore: $e");
        rethrow;
      }
    }

    throw Exception("User not authenticated");
  }

  Future<String> uploadSignatureToFirestore(Uint8List signatureData) async {
    try {
      final Reference storageRef = FirebaseStorage.instance.ref().child('signatures/${DateTime.now()}.png');
      final UploadTask uploadTask = storageRef.putData(signatureData);
      await uploadTask.whenComplete(() {});
      final String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading signature: $e");
      rethrow;
    }
  }

  Future<void> _showQuickAlert(BuildContext context, String remarks) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'You have returned to OCC!\nPlease kindly wait until OCC confirms the device.\nRemarks: $remarks',
    ).then((value) {
      Get.offAllNamed(Routes.NAVOCC);
    });
  }
}
