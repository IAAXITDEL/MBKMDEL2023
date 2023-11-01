import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'package:ts_one/app/modules/efb/pilot/controllers/requestdevice_controller.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:ts_one/app/routes/app_pages.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import 'package:ts_one/presentation/theme.dart';

import '../../../../../util/empty_screen_efb.dart';
import '../../occ/model/device.dart';

class PilotrequestdeviceView extends StatefulWidget {
  const PilotrequestdeviceView({super.key});

  @override
  _PilotrequestdeviceView createState() => _PilotrequestdeviceView();
}

class _PilotrequestdeviceView extends State<PilotrequestdeviceView> {
  final RequestdeviceController _bookingService = RequestdeviceController();
  late List<Device> devices = [];
  Device? selectedDevice;
  TextEditingController OccOnDutyController = TextEditingController();
  TextEditingController deviceNoController = TextEditingController();

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

  //QuickAlert Success
  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'Succesfully Requested The Device',
    ).then((value) {
      Get.offAllNamed(Routes.NAVOCC);
    });
  }

  //QuickAlert Info
  Future<void> _showInfo(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      text: 'The device is already in use',
      textColor: tsOneColorScheme.primary,
    ).then((value) {
      Navigator.of(context).pop();
    });
  }

  Future<void> _showConfirmationDialog() async {
    bool deviceInUse = await _bookingService.isDeviceInUse(selectedDevice!.uid);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Request',
            style: tsOneTextTheme.headlineLarge,
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to request this device?'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextButton(
                    child: const Text('No',
                        style: TextStyle(color: TsOneColor.secondaryContainer)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 5,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: TsOneColor.greenColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text('Yes',
                        style: TextStyle(color: TsOneColor.onPrimary)),
                    onPressed: () {
                      if (!deviceInUse) _saveBooking();
                      if (!deviceInUse) _showQuickAlert(context);

                      if (deviceInUse) _showInfo(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBooking() async {
    if (selectedDevice != null) {
      String fieldHub = selectedDevice!.hub;
      _bookingService.requestDevice(
        selectedDevice!.uid,
        selectedDevice!.deviceno,
        'waiting-confirmation-1',
        fieldHub,
      );

      setState(() {
        selectedDevice = null;
        deviceNoController.clear();
      });
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
    bool isDeviceNotFound = deviceNoController.text.isNotEmpty &&
        getMatchingDevices(deviceNoController.text).isEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Request Device',
          style: tsOneTextTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Device 1", style: tsOneTextTheme.displaySmall),
              ),
              const SizedBox(width: 7.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: deviceNoController,
                      onChanged: (input) {
                        setState(() {
                          selectedDevice = null;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        labelText: 'Device No',
                        labelStyle: tsOneTextTheme.labelMedium,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      String qrCode = await FlutterBarcodeScanner.scanBarcode(
                        '#ff6666', // Warna overlay saat pemindaian
                        'Cancel', // Label tombol batal
                        true, // Memungkinkan pemindaian di latar belakang
                        ScanMode.QR, // Mode pemindaian QR code
                      );

                      if (qrCode != '-1') {
                        setState(() {
                          deviceNoController.text = qrCode;
                          selectedDevice =
                              getMatchingDevices(qrCode).firstOrNull;
                        });
                      }
                    },
                    child: const Icon(Icons.qr_code_2),
                  ),
                ],
              ),
              if (isDeviceNotFound) const EmptyScreenEFB(),
              if (deviceNoController.text.isNotEmpty)
                Column(
                  children: getMatchingDevices(deviceNoController.text)
                      .map(
                        (device) => ListTile(
                          title: Text(device.deviceno),
                          onTap: () {
                            setState(() {
                              selectedDevice = device;
                              deviceNoController.text = device.deviceno;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 16.0),
              if (selectedDevice != null)
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: tsOneColorScheme.onSecondary,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const RedTitleText(text: 'Device Details'),
                        const SizedBox(height: 5.0),
                        Row(
                          children: [
                            const Expanded(
                                flex: 7, child: Text("Device Number")),
                            const Expanded(flex: 2, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice!.deviceno}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(flex: 7, child: Text("IOS Version")),
                            const Expanded(flex: 2, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice!.iosver}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(
                                flex: 7, child: Text("FlySmart Version")),
                            const Expanded(flex: 2, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice!.flysmart}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(
                                flex: 7, child: Text("Docunet Version")),
                            const Expanded(flex: 2, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice!.docuversion}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(
                                flex: 7, child: Text("Lido mPilot Version")),
                            const Expanded(flex: 2, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice!.lidoversion}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(flex: 7, child: Text("HUB")),
                            const Expanded(flex: 2, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice!.hub}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(flex: 7, child: Text("Condition")),
                            const Expanded(flex: 2, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice!.condition}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
        child: ElevatedButton(
          onPressed: () {
            if (selectedDevice != null) {
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
    );
  }
}

extension IterableExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
