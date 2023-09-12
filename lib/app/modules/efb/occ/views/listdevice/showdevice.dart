import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ts_one/app/modules/efb/occ/model/device.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';


class ShowDevice extends StatelessWidget {
  final Device device;

  const ShowDevice({super.key, required this.device});


  Future<void> _createQR() async {

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 20), // Add vertical padding
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(), // Create a QR code barcode
                    data: device.deviceno, // Use deviceno as QR code data
                    width: 150,
                    height: 150,
                  ),
                  pw.SizedBox(width: 50), // Add horizontal spacing
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(device.deviceno,
                        style: const pw.TextStyle(fontSize: 50,),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/device_info.pdf");
    await file.writeAsBytes(pdfBytes.toList());

    OpenFile.open(file.path);
  }


  @override
  Widget build(BuildContext context) {
    final String deviceNo = device.deviceno;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Device Number: ${device.deviceno}"),
            Text("iOS Version: ${device.iosver}"),
            Text("FlySmart: ${device.flysmart}"),
            Text("Lido Version: ${device.lidoversion}"),
            Text("Docu Version: ${device.docuversion}"),
            Text("Condition: ${device.condition}"),
            const SizedBox(height: 20),
            QrImageView(
              data: deviceNo,
              version: QrVersions.auto,
              size: 200.0,
            ),
            ElevatedButton(
              onPressed: _createQR,
              child: const Text('Export QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}
