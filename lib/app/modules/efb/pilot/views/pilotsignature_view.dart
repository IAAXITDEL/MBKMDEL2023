import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

import 'package:ts_one/app/modules/efb/pilot/views/main_view_pilot.dart';

class SignaturePadPage extends StatefulWidget {
  final String documentId;
  final GlobalKey<SfSignaturePadState> _signaturePadKey =
  GlobalKey<SfSignaturePadState>();
  Uint8List? signatureImage;

  SignaturePadPage({super.key, required this.documentId});

  @override
  _SignaturePadPageState createState() => _SignaturePadPageState();
}

class _SignaturePadPageState extends State<SignaturePadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature Pad'),
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
              ElevatedButton(
                onPressed: () {
                  widget._signaturePadKey.currentState?.clear();
                },
                child: const Text('Clear Signature'),
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
                          title: const Text('Konfirmasi'),
                          content: const Text('Apakah Anda yakin ingin menyimpan tanda tangan ini?'),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                MaterialPageRoute(
                                  builder: (context) => HomePilotView(),
                                ); // Tutup dialog konfirmasi

                                try {
                                  // Simpan tanda tangan ke koleksi pilot-device-1
                                  await addToPilotDeviceCollection(
                                      widget.documentId, signatureData);

                                  // Tampilkan pesan sukses
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Sukses'),
                                        content: const Text('Tanda tangan berhasil disimpan.'),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context); // Tutup dialog sukses
                                              Navigator.pop(context); // Kembali ke halaman sebelumnya (pilot)
                                              Navigator.pop(context); // Kembali ke halaman sebelumnya (pilot)
                                              Navigator.pop(context); // Kembali ke halaman sebelumnya (pilot)
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } catch (error) {
                                  // Handle error jika diperlukan
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Error'),
                                        content: const Text(
                                            'Terjadi kesalahan saat menyimpan tanda tangan.'),
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
                              child: const Text('Ya'), // Tombol konfirmasi "Ya"
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Tutup dialog konfirmasi
                              },
                              child: const Text('Tidak'), // Tombol konfirmasi "Tidak"
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Simpan Tanda Tangan'),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menyimpan tanda tangan ke dokumen pilot-device-1
  Future<void> addToPilotDeviceCollection(String documentId, Uint8List signatureData) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      // Mendefinisikan data tambahan yang akan ditambahkan ke dokumen
      Map<String, dynamic> additionalData = {
        'signature_url': await uploadSignatureToFirestore(signatureData),
        'status-device-1': 'need-confirmation-occ', // Update the status here
        // Tambahkan field lain jika diperlukan
      };

      // Mendapatkan referensi dokumen berdasarkan documentId
      DocumentReference docRef =
      FirebaseFirestore.instance.collection('pilot-device-1').doc(documentId);

      // Melakukan update dokumen dengan data tambahan
      await docRef.update(additionalData);
    }
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
