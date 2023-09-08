import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ts_one/app/modules/efb/pilot/controllers/requestdevice_controller.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../occ/model/device.dart';

class PilotrequestdeviceView extends StatefulWidget {
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
          title: Text(
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
                  Text(
                    'Device is already in use.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Poppins',
                    ),
                  ),
                Text(
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
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            if (!deviceInUse)
              TextButton(
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _saveBooking();
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _saveBooking() async {
    if (selectedDevice != null && OccOnDutyController.text.isNotEmpty) {

      // Create the booking entry with necessary information
      _bookingService.requestDevice(
        selectedDevice!.uid,
        selectedDevice!.deviceno,
        OccOnDutyController.text,
          'in-use-pilot',
      );

      setState(() {
        selectedDevice = null;
        OccOnDutyController.clear();
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
        title: Text(
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
          padding: EdgeInsets.all(16.0),
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
                  SizedBox(width: 16.0),
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
                    child: Icon(Icons.qr_code_2),
                  ),
                ],
              ),

              if (isDeviceNotFound) // Show message if device is not found
                Text(
                  'Device not found',
                  style: TextStyle(color: Colors.red),
                ),
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
              SizedBox(height: 16.0),
              if (selectedDevice != null) // Show attributes if a device is selected
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Device No: ${selectedDevice!.deviceno}'),
                    Text('iOS Version: ${selectedDevice!.iosver}'),
                    Text('Fly Smart Version: ${selectedDevice!.flysmart}'),
                    Text('Docu Version: ${selectedDevice!.docuversion}'),
                    Text('Lido Version: ${selectedDevice!.lidoversion}'),
                    Text('Condition: ${selectedDevice!.condition}'),
                  ],
                ),
              SizedBox(height: 16.0),
              TextField(
                controller: OccOnDutyController,
                decoration: InputDecoration(
                  labelText: 'OCC On Duty',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (selectedDevice != null &&
                      OccOnDutyController.text.isNotEmpty) {
                    _showConfirmationDialog();
                  }
                },
                child: Text('Confirmation'),
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
