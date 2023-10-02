import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ts_one/app/modules/efb/occ/model/device.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import 'dart:io';

import 'package:ts_one/presentation/theme.dart';

class ShowDevice extends StatelessWidget {
  final Device device;

  const ShowDevice({super.key, required this.device});

    Future<void> _createQR() async {
      final pdf = pw.Document();

      // Load the background image
      final Uint8List image = (await rootBundle.load('assets/images/template_EFB_Device_No.jpg')).buffer.asUint8List();

      // Define the page dimensions
      const PdfPageFormat pageFormat = PdfPageFormat(612.0, 792.0); // 8.5 x 11 inches

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          build: (context) {
            return [
              pw.Container(
                width: pageFormat.width,
                height: pageFormat.height,
                child: pw.Stack(
                  children: [
                    pw.Image(
                      pw.MemoryImage(image),  // Set background image
                      width: pageFormat.width,
                      height: pageFormat.height,
                      fit: pw.BoxFit.fill,
                    ),
                    pw.Center(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 20),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: device.deviceno,
                              width: 150,
                              height: 150,
                            ),
                            pw.SizedBox(width: 50),
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  device.deviceno,
                                  style: const pw.TextStyle(
                                    fontSize: 50,
                                    color: PdfColors.white,  // Set text color
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      final pdfBytes = await pdf.save();

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/device_info.pdf");
      await file.writeAsBytes(pdfBytes);

      OpenFile.open(file.path);
    }

  @override
  Widget build(BuildContext context) {
    final String deviceNo = device.deviceno;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Detail Device',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 20, bottom: 70, right: 20, left: 20),
          child: Container(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: RedTitleText(text: 'Device Info'),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(flex: 6, child: const Text('Device Number')),
                    Expanded(flex: 1, child: const Text(':')),
                    Expanded(flex: 4, child: Text('${device.deviceno}')),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(flex: 6, child: const Text('IOS Version')),
                    Expanded(flex: 1, child: const Text(':')),
                    Expanded(flex: 4, child: Text('${device.iosver}')),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(flex: 6, child: const Text('FlySmart Version')),
                    Expanded(flex: 1, child: const Text(':')),
                    Expanded(flex: 4, child: Text('${device.flysmart}')),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(flex: 6, child: const Text('Lido Version')),
                    Expanded(flex: 1, child: const Text(':')),
                    Expanded(flex: 4, child: Text('${device.lidoversion}')),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(flex: 6, child: const Text('Docu Version')),
                    Expanded(flex: 1, child: const Text(':')),
                    Expanded(flex: 4, child: Text('${device.docuversion}')),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(flex: 6, child: const Text('Device Condition')),
                    Expanded(flex: 1, child: const Text(':')),
                    Expanded(flex: 4, child: Text('${device.condition}')),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                const SizedBox(height: 30),
                Container(
                  child: Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: TsOneColor.surface,
                          borderRadius: BorderRadius.circular(4.0),
                          boxShadow: const [
                            BoxShadow(
                                color: TsOneColor.secondaryContainer,
                                blurRadius: 10,
                                spreadRadius: -5,
                                offset: Offset(1, 1),
                                blurStyle: BlurStyle.normal)
                          ]),
                      child: Column(
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Align(
                            //   alignment: Alignment.centerLeft,
                            //   child: RedTitleText(text: 'Show QR Code'),
                            // ),
                            SizedBox(height: 30),
                            Center(
                              child: QrImageView(
                                data: deviceNo,
                                version: QrVersions.auto,
                                size: 250.0,
                              ),
                            ),
                            SizedBox(height: 30),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ElevatedButton(
                                onPressed: _createQR,
                                child: const Text('Eksport QR Code'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(15),
                                  backgroundColor: tsOneColorScheme.primary,
                                  foregroundColor: Colors.white,
                                  surfaceTintColor: tsOneColorScheme.onPrimary,
                                  minimumSize: const Size.fromHeight(40),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
