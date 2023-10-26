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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Detail Device',
          style: tsOneTextTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: <Widget>[
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(flex: 6, child: const Text('Device Number')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 6, child: Text('${widget.device.deviceno}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 6, child: const Text('IOS Version')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 6, child: Text('${widget.device.iosver}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 6, child: const Text('FlySmart Version')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 6, child: Text('${widget.device.flysmart}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 6, child: const Text('Lido mPilot Version')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 6, child: Text('${widget.device.lidoversion}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 6, child: const Text('Docunet Version')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 6, child: Text('${widget.device.docuversion}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 6, child: const Text('Hub')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 6, child: Text('${widget.device.hub}')),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(flex: 6, child: const Text('Device Condition')),
                          Expanded(flex: 1, child: const Text(':')),
                          Expanded(flex: 6, child: Text('${widget.device.condition}')),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
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
                        'QR - Wallpaper',
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
              SizedBox(
                height: 10,
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
        child: Expanded(
          child: ElevatedButton(
            onPressed: () {
              _captureAndSave();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: TsOneColor.greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                )),
            child: const Text('Download Image', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
