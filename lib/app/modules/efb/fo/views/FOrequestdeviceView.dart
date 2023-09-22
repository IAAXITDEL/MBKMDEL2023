import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/app/modules/efb/fo/controllers/FOrequestdevice_controller.dart';

import 'package:ts_one/app/modules/efb/pilot/controllers/requestdevice_controller.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import 'package:ts_one/presentation/theme.dart';

import '../../../../../util/empty_screen_efb.dart';
import '../../occ/model/device.dart';

class FOrequestdeviceView extends StatefulWidget {
  const FOrequestdeviceView({super.key});

  @override
  _FOrequestdeviceView createState() => _FOrequestdeviceView();
}

class _FOrequestdeviceView extends State<FOrequestdeviceView> {
  final FORequestdeviceController _bookingService = FORequestdeviceController() ;
  late List<Device> devices = [];
  Device? selectedDevice2;
  Device? selectedDevice3;
  TextEditingController OccOnDutyController = TextEditingController();
  TextEditingController deviceNoController2 = TextEditingController();
  TextEditingController deviceNoController3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  void fetchDevices() async {
    devices = await _bookingService.getDevices();
    setState(() {});
  }

  List<Device> getMatchingDevices(String input) {
    return devices
        .where((device) =>
        device.deviceno.toLowerCase().contains(input.toLowerCase()))
        .toList();
  }



  Future<void> _showConfirmationDialog() async {
    bool deviceInUse2 = await _bookingService.isDeviceInUse(selectedDevice2!.uid, selectedDevice3!.uid);
    bool deviceInUse3 = await _bookingService.isDeviceInUse(selectedDevice3!.uid, selectedDevice2!.uid);

    if (selectedDevice2!.deviceno == selectedDevice3!.deviceno) {
      // Show an error message or handle it accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Device numbers cannot be the same.')),
      );
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Booking',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (deviceInUse2)
                  const Text(
                    'Device is already in use.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Poppins',
                    ),
                  ),
                const Text(
                  'Are you sure you want to book this device?',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            if (!deviceInUse2 && !deviceInUse3)
              TextButton(
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                onPressed: () {
                  _saveBooking();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _saveBooking() async {
    if (selectedDevice2 != null && selectedDevice3 != null) {
      String fieldHub2 = selectedDevice2!.hub;
      String fieldHub3 = selectedDevice3!.hub;
      // Create the booking entry with necessary information
      _bookingService.requestDevice(
        selectedDevice2!.uid,
        selectedDevice2!.deviceno,
        selectedDevice3!.uid,
        selectedDevice3!.deviceno,
        'waiting-confirmation-1',
        fieldHub2,
        fieldHub3,
      );

      setState(() {
        selectedDevice2 = null;
        selectedDevice3 = null;
        deviceNoController2.clear();
        deviceNoController3.clear();
      });

      Navigator.pop(context); // Close the confirmation dialog
    }
  }

  Future<Widget> getUserPhoto(String userUid) async {
    final userSnapshot =
    await FirebaseFirestore.instance.collection("users").doc(userUid).get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final photoUrl = userData['PHOTOURL'] as String?;

      if (photoUrl != null) {
        return CircleAvatar(
          backgroundImage: NetworkImage(photoUrl),
          radius: 20.0,
        );
      }
    }

    return const CircleAvatar(
      backgroundImage: AssetImage('assets/images/placeholder_person.png'),
      radius: 20.0,
    );
  }

  Future<String> getUserName(String userUid) async {
    final userSnapshot =
    await FirebaseFirestore.instance.collection("users").doc(userUid).get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final userName = userData['NAME'] as String?;

      if (userName != null) {
        return userName;
      }
    }
    return 'No Name';
  }

  @override
  Widget build(BuildContext context) {
    bool isDeviceNotFound = deviceNoController2.text.isNotEmpty && getMatchingDevices(deviceNoController2.text).isEmpty
        && deviceNoController3.text.isNotEmpty && getMatchingDevices(deviceNoController3.text).isEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Request Device',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: deviceNoController2,
                      onChanged: (input) {
                        setState(() {
                          selectedDevice2 = null;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        labelText: 'Device No',
                        labelStyle: tsOneTextTheme.labelMedium,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      String qrCode =
                      await FlutterBarcodeScanner.scanBarcode(
                        '#ff6666', // Warna overlay saat pemindaian
                        'Cancel', // Label tombol batal
                        true, // Memungkinkan pemindaian di latar belakang
                        ScanMode.QR, // Mode pemindaian QR code
                      );

                      if (qrCode != '-1') {
                        setState(() {
                          deviceNoController2.text = qrCode;
                          selectedDevice2 = getMatchingDevices(qrCode).firstOrNull;
                        });
                      }
                    },
                    child: const Icon(Icons.qr_code_2),
                  ),
                ],
              ),
              if (isDeviceNotFound) // Show message if device is not found
                const EmptyScreenEFB(),
              if (deviceNoController2.text.isNotEmpty)
                Column(
                  children: getMatchingDevices(deviceNoController2.text)
                      .map(
                        (device) => ListTile(
                      title: Text(device.deviceno),
                      onTap: () {
                        setState(() {
                          selectedDevice2 = device;
                          deviceNoController2.text = device.deviceno;
                        });
                      },
                    ),
                  )
                      .toList(),
                ),
              const SizedBox(height: 16.0),
              if (selectedDevice2 != null) // Show attributes if a device is selected
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: tsOneColorScheme.onSecondary,
                      )),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RedTitleText(text: 'Request Details'),
                        SizedBox(height: 5.0),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("Device Number")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice2!.deviceno}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("IOS Version")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice2!.iosver}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("Flysmart Version")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice2!.flysmart}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("DoCu Version")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice2!.docuversion}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 7, child: Text("Lido mPilot Version")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice2!.lidoversion}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("HUB")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice2!.hub}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("Condition")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice2!.condition}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
              // ElevatedButton(
              //   onPressed: () {
              //     if (selectedDevice != null) {
              //       _showConfirmationDialog();
              //     }
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: TsOneColor.greenColor,
              //     minimumSize: const Size(double.infinity, 50),
              //   ),
              //   child: const Text(
              //     'Submit',
              //     style: TextStyle(color: Colors.white),
              //   ),
              // ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: deviceNoController3,
                      onChanged: (input) {
                        setState(() {
                          selectedDevice3 = null;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        labelText: 'Device No',
                        labelStyle: tsOneTextTheme.labelMedium,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      String qrCode =
                      await FlutterBarcodeScanner.scanBarcode(
                        '#ff6666', // Warna overlay saat pemindaian
                        'Cancel', // Label tombol batal
                        true, // Memungkinkan pemindaian di latar belakang
                        ScanMode.QR, // Mode pemindaian QR code
                      );

                      if (qrCode != '-1') {
                        setState(() {
                          deviceNoController3.text = qrCode;
                          selectedDevice3 = getMatchingDevices(qrCode).firstOrNull;
                        });
                      }
                    },
                    child: const Icon(Icons.qr_code_2),
                  ),
                ],
              ),
              if (isDeviceNotFound) // Show message if device is not found
                const EmptyScreenEFB(),
              if (deviceNoController3.text.isNotEmpty)
                Column(
                  children: getMatchingDevices(deviceNoController3.text)
                      .map(
                        (device) => ListTile(
                      title: Text(device.deviceno),
                      onTap: () {
                        setState(() {
                          selectedDevice3 = device;
                          deviceNoController3.text = device.deviceno;
                        });
                      },
                    ),
                  )
                      .toList(),
                ),
              const SizedBox(height: 16.0),
              if (selectedDevice3 != null) // Show attributes if a device is selected
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: tsOneColorScheme.onSecondary,
                      )),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RedTitleText(text: 'Request Details'),
                        SizedBox(height: 5.0),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("Device Number")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice3!.deviceno}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("IOS Version")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice3!.iosver}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("Flysmart Version")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice3!.flysmart}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("DoCu Version")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice3!.docuversion}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 7, child: Text("Lido mPilot Version")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice3!.lidoversion}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("HUB")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice3!.hub}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(flex: 7, child: Text("Condition")),
                            Expanded(flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice3!.condition}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
              // ElevatedButton(
              //   onPressed: () {
              //     if (selectedDevice != null) {
              //       _showConfirmationDialog();
              //     }
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: TsOneColor.greenColor,
              //     minimumSize: const Size(double.infinity, 50),
              //   ),
              //   child: const Text(
              //     'Submit',
              //     style: TextStyle(color: Colors.white),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (selectedDevice2 != null && selectedDevice3 != null) {
                _showConfirmationDialog();
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: TsOneColor.greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                )),
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

extension IterableExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
