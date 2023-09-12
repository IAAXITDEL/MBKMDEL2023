import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilotsignature_view.dart';

class PilotreturndeviceviewView extends StatefulWidget {
  final String deviceName;
  final String deviceId;
  PilotreturndeviceviewView({required this.deviceName, required this.deviceId});


  @override
  _PilotreturndeviceviewViewState createState() =>
      _PilotreturndeviceviewViewState();
}

Future<String> getDocumentIdForDevice(String deviceName) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('pilot-device-1')
      .where('device_name', isEqualTo: deviceName)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    // Mengambil document_id dari dokumen pertama yang sesuai
    return querySnapshot.docs[0].id;
  } else {
    // Mengembalikan nilai default jika tidak ditemukan data yang sesuai
    return 'N/A';
  }
}


class _PilotreturndeviceviewViewState extends State<PilotreturndeviceviewView> {
  bool isReturnToOCC = false;
  bool isReturnToOtherPilot = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Used'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: Future.wait([
              FirebaseFirestore.instance
                  .collection('Device')
                  .where('deviceno', isEqualTo: widget.deviceName)
                  .get(),
              FirebaseFirestore.instance
                  .collection('pilot-device-1')
                  .where('device_name', isEqualTo: widget.deviceName)
                  .get(),
            ]),
            builder: (context, snapshotList) {
              if (snapshotList.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshotList.hasError) {
                return Center(
                  child: Text('Error: ${snapshotList.error.toString()}'),
                );
              } else {

                final deviceSnapshot = snapshotList.data![0];
                final pilotDeviceSnapshot = snapshotList.data![1];
                final deviceData = deviceSnapshot.docs.isNotEmpty
                    ? deviceSnapshot.docs.first.data()
                    : <String, dynamic>{};

                // Handle null values gracefully
                final deviceno = deviceData['deviceno'] as String? ?? 'N/A';
                final iosver = deviceData['iosver'] as String? ?? 'N/A';
                final flysmart = deviceData['flysmart'] as String? ?? 'N/A';
                final lidoversion =
                    deviceData['lidoversion'] as String? ?? 'N/A';
                final docuversion =
                    deviceData['docuversion'] as String? ?? 'N/A';
                final condition = deviceData['condition'] as String? ?? 'N/A';

                // Handle data from 'pilot-device-1' collection
                final pilotDeviceData = pilotDeviceSnapshot.docs.isNotEmpty
                    ? pilotDeviceSnapshot.docs.first.data()
                    : <String, dynamic>{};
                final occOnDuty = pilotDeviceData['occ-on-duty'] as String? ?? 'N/A';

                Widget buildInfoRow(String label, String value) {
                  return Row(
                    children: [
                      Text(label),
                      const SizedBox(width: 8), // Spasi antara label dan nilai
                      const Text(':'),
                      const SizedBox(width: 8), // Spasi antara ":" dan nilai
                      Text(value),
                    ],
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Card(
                        color: Colors.grey[200], // Warna abu-abu
                        child: ListTile(
                          title: const Text('Device Info', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildInfoRow("Device Number", deviceno),
                              buildInfoRow("iOS Version", iosver),
                              buildInfoRow("FlySmart", flysmart),
                              buildInfoRow("Lido Version", lidoversion),
                              buildInfoRow("Docu Version", docuversion),
                              buildInfoRow("Condition", condition),
                              buildInfoRow("OCC On Duty", occOnDuty),
                              // Display other f  ields as needed
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 15,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text('Return Device',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    )
                  ],
                ),
                Row(
                  children: const [
                    Text('Choose who you want to return it to',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Radio(
                      value: true,
                      groupValue: isReturnToOCC,
                      onChanged: (value) {
                        setState(() {
                          isReturnToOCC = value!;
                          isReturnToOtherPilot = !value;
                        });
                      },
                    ),
                    const Text('Return To OCC'),
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      value: true,
                      groupValue: isReturnToOtherPilot,
                      onChanged: (value) {
                        setState(() {
                          isReturnToOtherPilot = value!;
                          isReturnToOCC = !value;
                        });
                      },
                    ),
                    const Text('Return To Other Pilot'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              // Handle the next button click based on radio button selection
              if (isReturnToOCC) {
                //Navigate to a new page for "Return To OCC"
                // Mendapatkan document_id dari koleksi pilot-device-1 yang sesuai
                String documentId = await getDocumentIdForDevice(widget.deviceName);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignaturePadPage(documentId: documentId),
                  ),
                );
              } else if (isReturnToOtherPilot) {
                // Navigate to a new page for "Return To Other Pilot"
                // ...
              }
            },
            child: const Text('Next'),
          ),

        ],
      ),
    );
  }
}
