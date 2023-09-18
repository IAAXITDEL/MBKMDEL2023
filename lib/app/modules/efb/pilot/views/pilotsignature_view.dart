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

import '../../../../../presentation/theme.dart';

class SignaturePadPage extends StatefulWidget {
  final GlobalKey<SfSignaturePadState> _signaturePadKey =
  GlobalKey<SfSignaturePadState>();
  Uint8List? signatureImage;
  final String deviceId;

  SignaturePadPage({required String documentId, required this.deviceId});

  @override
  _SignaturePadPageState createState() => _SignaturePadPageState();
}

class _SignaturePadPageState extends State<SignaturePadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Borrower Signature'),
              Container(
                decoration: BoxDecoration(border: Border.all(width: 1)),
                child: SfSignaturePad(
                  key: widget._signaturePadKey,
                  backgroundColor: Colors.white,
                  // This callback is called when the user finishes drawing the signature
                  onDrawEnd: () async {
                    final signatureImageData =
                    await widget._signaturePadKey.currentState!.toImage();
                    final byteData = await signatureImageData.toByteData(
                        format: ImageByteFormat.png);
                    if (byteData != null) {
                      setState(() {
                        widget.signatureImage = byteData.buffer.asUint8List();
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 15,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  widget._signaturePadKey.currentState?.clear();
                },
                child: const Text('Clear Signature'),
              ),
              SizedBox(height: 15,),
              // Teks untuk menampilkan deviceId
              Text(
                'Device ID: ${widget.deviceId}',
                style: TextStyle(fontSize: 18),
              ),
              ElevatedButton(
                onPressed: () async {
                  final signatureData = widget.signatureImage;
                  if (signatureData != null) {
                    // Tampilkan dialog konfirmasi
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Confirmation'),
                          content: const Text(
                              'Are you sure you want to save this signature?'),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context); // Tutup dialog konfirmasi
                                _showQuickAlert(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                try {
                                  // Simpan tanda tangan ke koleksi pilot-device-1
                                  final newDocumentId =
                                  await addToPilotDeviceCollection(
                                      signatureData, widget.deviceId,);
                                  // Tampilkan pesan sukses
                                } catch (error) {
                                  // Handle error jika diperlukan
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Error'),
                                        content: const Text(
                                            'An error occurred while saving the signature.'),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context); // Tutup dialog error
                                            },
                                            child:
                                            const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: const Text(
                                  'Yes'), // Tombol konfirmasi "Yes"
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                    context); // Tutup dialog konfirmasi
                              },
                              child: const Text(
                                  'No'), // Tombol konfirmasi "No"
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
                ),
                child: const Text('Confirm', style: TextStyle(color: Colors.white)),
              ),
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
        'status-device-1': 'need-confirmation-occ', // Update the status here
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
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('signatures/${DateTime.now()}.png');
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
    text: 'You have return to OCC! Please kindly wait after the OCC Confirm the Device okay?',
  );
  Navigator.of(context).pop();
}

