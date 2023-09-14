import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReturnOtherPilotView extends StatefulWidget {
  final String documentId;
  final String deviceName; // Tambahkan parameter deviceName
  final String deviceId; // Tambahkan parameter deviceName
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
  final TextEditingController _idController = TextEditingController();
  String deviceId = "";
  String deviceName = "";
  String OccOnDuty = "";

  @override
  void initState() {
    super.initState();
    // Ambil deviceUid, deviceName, dan OCC On Duty dari Firestore menggunakan widget.deviceId
    FirebaseFirestore.instance
        .collection('pilot-device-1')
        .doc(widget.deviceId) // Gunakan widget.deviceId
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          deviceId = documentSnapshot['device_uid'];
          deviceName = documentSnapshot['device_name'];
          OccOnDuty = documentSnapshot['occ-on-duty'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Return Other Pilot'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Device Name: $deviceName',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Device UID: $deviceId',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Device ID: ${widget.deviceId}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'OCC On Duty: $OccOnDuty',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Enter ID Number',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final idNumber = _idController.text.trim();
                if (idNumber.isNotEmpty) {
                  // Update status untuk dokumen yang ada
                  FirebaseFirestore.instance
                      .collection('pilot-device-1')
                      .doc(widget.deviceId) // Use widget.deviceId to identify the document
                      .update({
                    'status-device-1': 'handover-to-other-crew',
                    'handover-to-crew': idNumber,
                  });

                  // Tambahkan dokumen baru dengan nomor ID yang diberikan, serta deviceName dan deviceUid
                  FirebaseFirestore.instance.collection('pilot-device-1').add({
                    'user_uid': idNumber,
                    'device_uid': deviceId,
                    'device_name': deviceName,
                    'occ-on-duty': OccOnDuty,
                    'status-device-1': 'waiting-confirmation-other-pilot',
                    'timestamp': FieldValue.serverTimestamp(), // Tambahkan timestamp
                  });

                  // Kembali ke halaman sebelumnya
                  Navigator.pop(context);
                } else {
                  // Tangani input yang tidak valid, tampilkan pesan, atau mencegah pengiriman
                }
              },
              child: Text('Confirm'),
            ),

          ],
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
