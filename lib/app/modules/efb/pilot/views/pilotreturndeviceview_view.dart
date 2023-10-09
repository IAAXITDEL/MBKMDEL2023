import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilotsignature_view.dart';
import 'package:ts_one/app/modules/efb/pilot/views/return_other_pilot_view.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import 'package:ts_one/presentation/theme.dart';

class PilotreturndeviceviewView extends StatefulWidget {
  final String deviceName;
  final String deviceId;
  final String OccOnDuty;

  PilotreturndeviceviewView({required this.deviceName, required this.deviceId, required this.OccOnDuty});

  @override
  _PilotreturndeviceviewViewState createState() => _PilotreturndeviceviewViewState();
}

Future<String> getDocumentIdForDevice(String deviceId) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('pilot-device-1').where('document_id', isEqualTo: deviceId).get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs[0].id;
  } else {
    return 'N/A';
  }
}

class _PilotreturndeviceviewViewState extends State<PilotreturndeviceviewView> {
  bool isReturnToOCC = false;
  bool isReturnToOtherPilot = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Device Used',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              Row(
                children: const [
                  RedTitleText(
                    text: 'DEVICE INFO',
                  )
                ],
              ),
              FutureBuilder(
                future: Future.wait([
                  FirebaseFirestore.instance.collection('Device').where('deviceno', isEqualTo: widget.deviceName).get(),
                  FirebaseFirestore.instance.collection('pilot-device-1').where('device_name', isEqualTo: widget.deviceName).get(),
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
                    final deviceData = deviceSnapshot.docs.isNotEmpty ? deviceSnapshot.docs.first.data() : <String, dynamic>{};

                    // Handle null values gracefully
                    final deviceno = deviceData['deviceno'] as String? ?? 'N/A';
                    final iosver = deviceData['iosver'] as String? ?? 'N/A';
                    final flysmart = deviceData['flysmart'] as String? ?? 'N/A';
                    final lidoversion = deviceData['lidoversion'] as String? ?? 'N/A';
                    final docuversion = deviceData['docuversion'] as String? ?? 'N/A';
                    final condition = deviceData['condition'] as String? ?? 'N/A';
                    final hub = deviceData['hub'] as String? ?? 'N/A';

                    // Handle data from 'pilot-device-1' collection
                    final pilotDeviceData = pilotDeviceSnapshot.docs.isNotEmpty ? pilotDeviceSnapshot.docs.first.data() : <String, dynamic>{};
                    final occOnDuty = pilotDeviceData['occ-on-duty'] as String? ?? 'N/A';

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(flex: 5, child: Text("Device No")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(flex: 5, child: Text(deviceno)),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 5, child: Text("iOS Version")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(flex: 5, child: Text(iosver)),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 5, child: Text("Flysmart Ver")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(flex: 5, child: Text(flysmart)),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 5, child: Text("Docu Version")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(flex: 5, child: Text(docuversion)),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 5, child: Text("Lido Version")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(flex: 5, child: Text(lidoversion)),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 5, child: Text("HUB")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(flex: 5, child: Text(hub)),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 5, child: Text("Condition")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(flex: 5, child: Text(condition)),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 5, child: Text("OCC On Duty")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(flex: 5, child: Text(occOnDuty)),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                color: Colors.black,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: const [
                  RedTitleText(
                    text: 'RETURN DEVICE',
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Choose who you want to return it to :',
                          style: tsOneTextTheme.labelMedium,
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
              // ElevatedButton(
              //   onPressed: () async {
              //     if (isReturnToOCC) {
              //       String documentId = await getDocumentIdForDevice(widget.deviceId);

              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => SignaturePadPage(
              //             documentId: documentId,
              //             deviceId: widget.deviceId,
              //           ),
              //         ),
              //       );
              //     } else if (isReturnToOtherPilot) {
              //       String documentId = await getDocumentIdForDevice(widget.deviceId);

              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => ReturnOtherPilotView(
              //             documentId: documentId,
              //             deviceId: widget.deviceId,
              //             deviceName: widget.deviceName,
              //             OccOnDuty: widget.OccOnDuty,
              //           ),
              //         ),
              //       );
              //     }
              //   },
              //   style: ElevatedButton.styleFrom(
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              //     backgroundColor: TsOneColor.greenColor,
              //   ),
              //   child: SizedBox(
              //     width: MediaQuery.of(context).size.width,
              //     height: 48,
              //     child: const Align(
              //       alignment: Alignment.center,
              //       child: Text(
              //         "Next",
              //         style: TextStyle(color: TsOneColor.secondary),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () async {
            if (isReturnToOCC) {
              String documentId = await getDocumentIdForDevice(widget.deviceId);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignaturePadPage(
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
                  builder: (context) => ReturnOtherPilotView(
                    documentId: documentId,
                    deviceId: widget.deviceId,
                    deviceName: widget.deviceName,
                    OccOnDuty: widget.OccOnDuty,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: TsOneColor.greenColor,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 48,
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                "Next",
                style: TextStyle(color: TsOneColor.secondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
