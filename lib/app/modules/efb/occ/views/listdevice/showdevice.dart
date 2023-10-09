import 'dart:typed_data';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ts_one/app/modules/efb/occ/model/device.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:ts_one/presentation/theme.dart';

import '../../../../../../presentation/shared_components/TitleText.dart';

class ShowDevice extends StatefulWidget {
  final Device device;

  const ShowDevice({super.key, required this.device});

  @override
  State<ShowDevice> createState() => _ShowDeviceState();
}

class _ShowDeviceState extends State<ShowDevice> {
  ByteData? imageData;
  final GlobalKey _captureKey = GlobalKey();
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  // Function Show QR Code in page
  // Future<void> _createQR() async {
  //   final pdf = pw.Document();

  //   final Uint8List image = (await rootBundle.load('assets/images/template_EFB_Device_No.jpg')).buffer.asUint8List();
  //   const PdfPageFormat pageFormat = PdfPageFormat(1280, 720);

  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: pageFormat,
  //       build: (context) {
  //         return pw.Container(
  //           width: pageFormat.width,
  //           height: pageFormat.height,
  //           child: pw.Stack(
  //             children: [
  //               pw.Image(
  //                 pw.MemoryImage(image),
  //                 width: pageFormat.width,
  //                 height: pageFormat.height,
  //                 fit: pw.BoxFit.fill,
  //               ),
  //               pw.Center(
  //                 child: pw.Padding(
  //                   padding: const pw.EdgeInsets.symmetric(vertical: 20),
  //                   child: pw.Column(
  //                     mainAxisAlignment: pw.MainAxisAlignment.center,
  //                     crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                     children: [
  //                       pw.Text(
  //                         "EFB - IPAD",
  //                         style: pw.TextStyle(
  //                           color: PdfColors.white,
  //                           fontSize: 36,
  //                           fontWeight: pw.FontWeight.bold,
  //                         ),
  //                       ),
  //                       pw.SizedBox(width: 25),
  //                       pw.Text(
  //                         widget.device.deviceno,
  //                         style: const pw.TextStyle(
  //                           fontSize: 50,
  //                           color: PdfColors.white, // Set text color
  //                         ),
  //                       ),
  //                       pw.BarcodeWidget(
  //                         barcode: pw.Barcode.qrCode(),
  //                         data: widget.device.deviceno,
  //                         width: 150,
  //                         height: 150,
  //                       ),
  //                       pw.SizedBox(width: 25),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );

  //   final pdfBytes = await pdf.save();

  //   final output = await getTemporaryDirectory();
  //   final file = File("${output.path}/walpaper_device_${widget.device.deviceno}.pdf");
  //   await file.writeAsBytes(pdfBytes);

  //   OpenFile.open(file.path);
  // }

  Future<void> loadImage() async {
    final ByteData data = await rootBundle.load('assets/images/Wallpaper_EFB_Device.png');
    if (mounted) {
      setState(() {
        imageData = data;
      });
    }
  }

  Future<void> _captureAndSave() async {
    screenshotController
        .capture(
      delay: Duration(milliseconds: 100),
      pixelRatio: 3,
    )
        .then((capturedImage) async {
      if (capturedImage != null) {
        final buffer = capturedImage.buffer?.asUint8List();

        if (buffer != null) {
          final result = await ImageGallerySaver.saveImage(Uint8List.fromList(buffer), quality: 80);

          if (result['isSuccess']) {
            print("The image has been successfully saved in the gallery.");
          } else {
            print("Failed to save image to gallery.");
          }

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Image.memory(buffer),
            ),
          );
          await Future.delayed(Duration(seconds: 1));
          Navigator.of(context).pop();

          Fluttertoast.showToast(
            msg: 'Successfully saved in the gallery',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          Future.delayed(Duration(seconds: 1), () {
            Fluttertoast.cancel(); // Tutup toast
          });
        } else {
          print("Buffer is null");
        }
      } else {
        print("Captured image is null");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String deviceNo = widget.device.deviceno;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Detail Device',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: RedTitleText(text: 'Device Info'),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(flex: 5, child: const Text('Device Number')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 5, child: Text('${widget.device.deviceno}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 5, child: const Text('IOS Version')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 5, child: Text('${widget.device.iosver}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 5, child: const Text('FlySmart Version')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 5, child: Text('${widget.device.flysmart}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 5, child: const Text('Lido Version')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 5, child: Text('${widget.device.lidoversion}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 5, child: const Text('Docu Version')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 5, child: Text('${widget.device.docuversion}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 5, child: const Text('Hub')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 5, child: Text('${widget.device.hub}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 5, child: const Text('Device Condition')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 5, child: Text('${widget.device.condition}')),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),

                      // Qr Code without background image
                      // Container(
                      //   child: Expanded(
                      //     child: DecoratedBox(
                      //       decoration: BoxDecoration(color: TsOneColor.surface, borderRadius: BorderRadius.circular(4.0), boxShadow: const [
                      //         BoxShadow(
                      //             color: TsOneColor.secondaryContainer,
                      //             blurRadius: 10,
                      //             spreadRadius: -5,
                      //             offset: Offset(1, 1),
                      //             blurStyle: BlurStyle.normal)
                      //       ]),
                      //       child: Column(
                      //           //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //           children: [
                      //             // Align(
                      //             //   alignment: Alignment.centerLeft,
                      //             //   child: RedTitleText(text: 'Show QR Code'),
                      //             // ),
                      //             SizedBox(height: 30),
                      //             Center(
                      //               child: QrImageView(
                      //                 data: deviceNo,
                      //                 version: QrVersions.auto,
                      //                 size: 250.0,
                      //               ),
                      //             ),
                      //             SizedBox(height: 30),
                      //             Padding(
                      //               padding: const EdgeInsets.symmetric(horizontal: 20),
                      //               child: ElevatedButton(
                      //                 onPressed: _createQR,
                      //                 child: const Text('Eksport QR Code'),
                      //                 style: ElevatedButton.styleFrom(
                      //                   padding: EdgeInsets.all(15),
                      //                   backgroundColor: tsOneColorScheme.primary,
                      //                   foregroundColor: Colors.white,
                      //                   surfaceTintColor: tsOneColorScheme.onPrimary,
                      //                   minimumSize: const Size.fromHeight(40),
                      //                 ),
                      //               ),
                      //             ),
                      //           ]),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                color: Colors.black,
              ),
              SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: RedTitleText(text: 'QR - Wallpaper'),
              ),
              SizedBox(
                height: 15,
              ),
              Screenshot(
                controller: screenshotController,
                child: RepaintBoundary(
                  key: _captureKey,
                  child: Stack(
                    children: [
                      if (imageData != null) Image.memory(Uint8List.sublistView(imageData!.buffer.asUint8List())),
                      if (imageData == null) CircularProgressIndicator(),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Text(
                                'EFB - IPAD',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: tsOneColorScheme.secondary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                '${widget.device.deviceno}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: tsOneColorScheme.secondary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 5.0),
                              QrImageView(
                                data: deviceNo,
                                version: QrVersions.auto,
                                size: 70.0,
                                foregroundColor: tsOneColorScheme.secondary,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _captureAndSave();
                },
                child: Text('Capture Wallpaper'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
