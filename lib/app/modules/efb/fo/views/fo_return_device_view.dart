import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/app/modules/efb/fo/views/returnotherFOview.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilotsignature_view.dart';
import 'package:ts_one/app/modules/efb/pilot/views/return_other_pilot_view.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import 'package:ts_one/presentation/theme.dart';

import '../../feedback/PilotFeedback.dart';
import 'fo_signature_view.dart';

class FOreturndeviceviewView extends StatefulWidget {
  final String deviceName2;
  final String deviceName3;
  final String deviceId;
  final String OccOnDuty;

  FOreturndeviceviewView({required this.deviceName2, required this.deviceName3, required this.deviceId, required this.OccOnDuty});

  @override
  _FOreturndeviceviewViewState createState() => _FOreturndeviceviewViewState();
}

Future<String> getDocumentIdForDevice(String deviceId) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('pilot-device-1').where('document_id', isEqualTo: deviceId).get();

  if (querySnapshot.docs.isNotEmpty) {
    // Mengambil document_id dari dokumen pertama yang sesuai
    return querySnapshot.docs[0].id;
  } else {
    // Mengembalikan nilai default jika tidak ditemukan data yang sesuai
    return 'N/A';
  }
}

class _FOreturndeviceviewViewState extends State<FOreturndeviceviewView> {
  bool isReturnToOCC = false;
  bool isReturnToOtherPilot = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Device In Use',
          style: tsOneTextTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              FutureBuilder(
                future: Future.wait([
                  FirebaseFirestore.instance.collection('Device').where('deviceno', isEqualTo: widget.deviceName2).get(),
                  FirebaseFirestore.instance.collection('Device').where('deviceno', isEqualTo: widget.deviceName3).get(),
                ]),
                builder: (context, snapshotList) {
                  if (snapshotList.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshotList.hasError) {
                    return Center(
                      child: Text('Error: ${snapshotList.error.toString()}'),
                    );
                  } else {
                    final deviceSnapshot2 = snapshotList.data![0]; // Use index 0 for deviceSnapshot2
                    final deviceSnapshot3 = snapshotList.data![1]; // Use index 1 for deviceSnapshot3
                    final pilotDeviceSnapshot = snapshotList.data![1];
                    final deviceData2 = deviceSnapshot2.docs.isNotEmpty ? deviceSnapshot2.docs.first.data() : <String, dynamic>{};
                    final deviceData3 = deviceSnapshot3.docs.isNotEmpty ? deviceSnapshot3.docs.first.data() : <String, dynamic>{};

                    print(deviceData2);

                    print(deviceData3);

                    // Handle null values gracefully
                    final deviceno2 = deviceData2['deviceno'] as String? ?? 'N/A';
                    final iosver2 = deviceData2['iosver'] as String? ?? 'N/A';
                    final flysmart2 = deviceData2['flysmart'] as String? ?? 'N/A';
                    final lidoversion2 = deviceData2['lidoversion'] as String? ?? 'N/A';
                    final docuversion2 = deviceData2['docuversion'] as String? ?? 'N/A';
                    final condition2 = deviceData2['condition'] as String? ?? 'N/A';
                    final hub2 = deviceData2['hub'] as String? ?? 'N/A';

                    // Handle null values gracefully
                    final deviceno3 = deviceData3['deviceno'] as String? ?? 'N/A';
                    final iosver3 = deviceData3['iosver'] as String? ?? 'N/A';
                    final flysmart3 = deviceData3['flysmart'] as String? ?? 'N/A';
                    final lidoversion3 = deviceData3['lidoversion'] as String? ?? 'N/A';
                    final docuversion3 = deviceData3['docuversion'] as String? ?? 'N/A';
                    final condition3 = deviceData3['condition'] as String? ?? 'N/A';
                    final hub3 = deviceData3['hub'] as String? ?? 'N/A';

                    // Handle data from 'pilot-device-1' collection
                    final pilotDeviceData = pilotDeviceSnapshot.docs.isNotEmpty ? pilotDeviceSnapshot.docs.first.data() : <String, dynamic>{};
                    final occOnDuty = pilotDeviceData['occ-on-duty'] as String? ?? 'N/A';

                    return Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Device 2", style: tsOneTextTheme.displaySmall),
                            ),
                            SizedBox(height: 7),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Device No",
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
                                    deviceno2,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "IOS Version",
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
                                    iosver2,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Flysmart Ver",
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
                                    flysmart2,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Docunet Version",
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
                                    docuversion2,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Lido mPilot Version",
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
                                    lidoversion2,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Hub",
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
                                    hub2,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Condition",
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
                                    condition2,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.0),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Device 3", style: tsOneTextTheme.displaySmall),
                            ),
                            SizedBox(height: 7),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Device No",
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
                                    deviceno3,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "IOS Version",
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
                                    iosver3,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Flysmart Ver",
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
                                    flysmart3,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Docunet Version",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                Expanded(
                                    
                                    child: Text(
                                      ":",
                                      style: tsOneTextTheme.bodySmall,
                                    )),
                                Expanded(
                                  flex: 6,
                                  child: Text(docuversion3),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Lido mPilot Version",
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
                                    lidoversion3,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
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
                                    hub3,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Condition",
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
                                    condition3,
                                    style: tsOneTextTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'RETURN',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        String documentId = await getDocumentIdForDevice(widget.deviceId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PilotFeedBack(
                              documentId: documentId,
                              deviceId: widget.deviceId,
                            ),
                          ),
                        );
                      },
                      child: Text("FeedBack"))
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Choose who you want to return it to :', style: TextStyle(color: TsOneColor.primary, fontWeight: FontWeight.w500))
                    ],
                  )
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
        child: ElevatedButton(
          onPressed: () async {
            if (isReturnToOCC) {
              String documentId = await getDocumentIdForDevice(widget.deviceId);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FOSignaturePadPage(
                    documentId: documentId,
                    deviceId: widget.deviceId,
                  ),
                ),
              );
            } else if (isReturnToOtherPilot) {
              String documentId = await getDocumentIdForDevice(widget.deviceId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReturnOtherFOView(
                    documentId: documentId,
                    deviceId: widget.deviceId,
                    OccOnDuty: widget.OccOnDuty,
                    deviceName2: widget.deviceName2,
                    deviceName3: widget.deviceName3,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: TsOneColor.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              )),
          child: const Text('Next', style: TextStyle(color: TsOneColor.secondary)),
        ),
      ),
    );
  }
}