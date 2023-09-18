import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'package:ts_one/app/modules/efb/pilot/controllers/requestdevice_controller.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
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

  Future<void> _showConfirmationDialog() async {
    bool deviceInUse = await _bookingService.isDeviceInUse(selectedDevice!.uid);

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
                if (deviceInUse)
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
            if (!deviceInUse)
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
    if (selectedDevice != null) {

      // Create the booking entry with necessary information
      _bookingService.requestDevice(
        selectedDevice!.uid,
        selectedDevice!.deviceno,
          'waiting-confirmation-1',
      );

      setState(() {
        selectedDevice = null;
        deviceNoController.clear();
      });

      Navigator.pop(context); // Close the confirmation dialog
    }
  }



  @override
  Widget build(BuildContext context) {
    bool isDeviceNotFound =
        deviceNoController.text.isNotEmpty &&
            getMatchingDevices(deviceNoController.text).isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Device',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                        labelText: 'Device No',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
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

              if (isDeviceNotFound) // Show message if device is not found
                 const EmptyScreenEFB(),
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
              if (selectedDevice != null) // Show attributes if a device is selected
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text("DEVICE INFO",
                          style: tsOneTextTheme.headlineLarge,
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          children: [
                            Expanded(
                                flex: 6,
                                child: Text("Device Number")),
                            Expanded(
                                flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child: Text('${selectedDevice!.deviceno}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 6,
                                child: Text("iOS Version")),
                            Expanded(
                                flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child:  Text('${selectedDevice!.iosver}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 6,
                                child: Text("Flysmart Version")),
                            Expanded(
                                flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child:  Text('${selectedDevice!.flysmart}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 6,
                                child: Text("DoCu Version")),
                            Expanded(
                                flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child:  Text('${selectedDevice!.docuversion}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 6,
                                child: Text("Lido Version")),
                            Expanded(
                                flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child:   Text('${selectedDevice!.lidoversion}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 6,
                                child: Text("HUB")),
                            Expanded(
                                flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child:   Text('${selectedDevice!.hub}'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 6,
                                child: Text("Condition")),
                            Expanded(
                                flex: 1, child: Text(":")),
                            Expanded(
                              flex: 6,
                              child:   Text('${selectedDevice!.condition}'),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (selectedDevice != null ) {
                    _showConfirmationDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TsOneColor.greenColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Submit', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension IterableExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}


