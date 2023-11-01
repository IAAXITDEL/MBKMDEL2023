import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

import 'package:ts_one/app/modules/efb/pilot/views/main_view_pilot.dart';

import '../../../../../presentation/theme.dart';
import '../../../../routes/app_pages.dart';

class FOSignaturePadPage extends StatefulWidget {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();
  Uint8List? signatureImage;
  final String deviceId;

  FOSignaturePadPage({required String documentId, required this.deviceId});

  @override
  _FOSignaturePadPageState createState() => _FOSignaturePadPageState();
}

class _FOSignaturePadPageState extends State<FOSignaturePadPage> {
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
              const SizedBox(
                height: 15,
              ),
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
                      const Text('I agree with all of the results', style: TextStyle(fontWeight: FontWeight.w300)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final signatureData = widget.signatureImage;
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
                                            // Simpan tanda tangan ke koleksi pilot-device-1
                                            final newDocumentId = await addToPilotDeviceCollection(
                                              signatureData,
                                              widget.deviceId,
                                            );
                                            _showQuickAlert(context);

                                            // Tampilkan pesan sukses
                                          } catch (error) {
                                            // Handle error jika diperlukan
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text('Error'),
                                                  content: const Text('An error occurred while saving the signature.'),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context); // Tutup dialog error
                                                      },
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
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
                ],
              ),
              // Teks untuk menampilkan deviceId
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menyimpan tanda tangan ke dokumen pilot-device-1
  // Fungsi untuk menyimpan tanda tangan ke dokumen pilot-device-1
  // Fungsi untuk menyimpan tanda tangan ke dokumen pilot-device-1
  Future<void> addToPilotDeviceCollection(Uint8List signatureData, String deviceId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      // Mendefinisikan data tambahan yang akan ditambahkan ke dokumen
      Map<String, dynamic> additionalData = {
        'signature_url': await uploadSignatureToFirestore(signatureData),
        'statusDevice': 'need-confirmation-occ', // Update the status here
        'document_id': deviceId, // Associate the signature with the deviceId
        'handover-to-crew': '-', // Associate the signature with the deviceId
        // Tambahkan field lain jika diperlukan
      };

      try {
        // Update dokumen yang ada di koleksi pilot-device-1 dengan field baru
        await FirebaseFirestore.instance
            .collection('pilot-device-1')
            .doc(deviceId) // Gunakan deviceId untuk mengidentifikasi dokumen yang akan diperbarui
            .update(additionalData);

        // Kembalikan tanpa perlu mengembalikan ID dokumen
        return;
      } catch (e) {
        // Handle error jika diperlukan
        print("Error updating document in Firestore: $e");
        rethrow;
      }
    }

    throw Exception("User not authenticated");
  }

  // Fungsi untuk mengunggah tanda tangan ke Firebase Firestore
  Future<String> uploadSignatureToFirestore(Uint8List signatureData) async {
    try {
      final Reference storageRef = FirebaseStorage.instance.ref().child('signatures/${DateTime.now()}.png');
      final UploadTask uploadTask = storageRef.putData(signatureData);
      await uploadTask.whenComplete(() {});
      final String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Handle error jika diperlukan
      print("Error uploading signature: $e");
      rethrow;
    }
  }
}

Future<void> _showQuickAlert(BuildContext context) async {
  await QuickAlert.show(
    context: context,
    type: QuickAlertType.success,
    text: 'You have returned to OCC!\nPlease kindly wait until OCC confirms the device.',
  ).then((value) {
    Get.offAllNamed(Routes.NAVOCC);
  });
}