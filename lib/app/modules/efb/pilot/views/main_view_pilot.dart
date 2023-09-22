import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilot_un_request_device_view.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilot_un_return_device_view.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilotrequestdevice_view.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilotreturndeviceview_view.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import '../../../../../presentation/theme.dart';
import '../../../../../util/util.dart';
import '../../occ/model/device.dart';
import '../controllers/homepilot_controller.dart';
import '../controllers/requestdevice_controller.dart';
import 'confirm_return_other_pilot_view.dart';

class HomePilotView extends GetView<HomePilotController> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomePilotController());
    final requestDeviceController = RequestdeviceController();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi, ${controller.titleToGreet!}",
                    style: tsOneTextTheme.headlineLarge,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Good ${controller.timeToGreet}',
                  style: tsOneTextTheme.labelMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.calendar_month_outlined,
                        color: TsOneColor.onSecondary,
                        size: 32,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Util.convertDateTimeDisplay(
                              DateTime.now().toString(), "EEEE"),
                          style: tsOneTextTheme.labelSmall,
                        ),
                        Text(
                          Util.convertDateTimeDisplay(
                              DateTime.now().toString(), "dd MMMM yyyy"),
                          style: tsOneTextTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder<QuerySnapshot>(
                future: requestDeviceController.getPilotDevices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    QuerySnapshot? pilotDevicesSnapshot = snapshot.data;

                    if (pilotDevicesSnapshot != null &&
                        pilotDevicesSnapshot.docs.isNotEmpty) {
                      // Filter the data for 'in-use-pilot' and 'waiting-confirmation-1'
                      final inUsePilotDocs = pilotDevicesSnapshot.docs
                          .where((doc) => doc['statusDevice'] == 'in-use-pilot')
                          .toList();
                      final waitingConfirmationDocs = pilotDevicesSnapshot.docs
                          .where((doc) =>
                              doc['statusDevice'] == 'waiting-confirmation-1')
                          .toList();
                      final needConfirmationOccDocs = pilotDevicesSnapshot.docs
                          .where((doc) =>
                              doc['statusDevice'] == 'need-confirmation-occ')
                          .toList();
                      final needConfirmationPilotDocs = pilotDevicesSnapshot
                          .docs
                          .where((doc) =>
                              doc['statusDevice'] ==
                              'waiting-confirmation-other-pilot')
                          .toList();
                      return Column(
                        children: [
                          // Display 'in-use-pilot' data
                          if (inUsePilotDocs.isNotEmpty) ...[
                            Align(
                                alignment: Alignment.centerLeft,
                                child: RedTitleText(text: "In Use Pilot")
                                // Text(
                                //   "In Use Pilot",
                                //   style: tsOneTextTheme.titleLarge,
                                // ),
                                ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: inUsePilotDocs.map((doc) {
                                // Your existing code for displaying 'in-use-pilot' data
                                String deviceName = doc['device_name'];
                                String OccOnDuty = doc['occ-on-duty'];
                                String deviceId = doc.id;

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PilotreturndeviceviewView(
                                            deviceName: deviceName,
                                            deviceId: deviceId,
                                            OccOnDuty: OccOnDuty,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                        EdgeInsets.all(18.0),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors
                                            .white, // Warna latar belakang putih
                                      ),
                                      overlayColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors.yellow.withOpacity(
                                            0.2), // Warna kuning dengan opacity saat ditekan
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      // Menggunakan Row untuk mengatur item rata kiri
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Mengatur item rata kiri
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start, // Mengatur teks ke kiri
                                          children: [
                                            Text(
                                              deviceName,
                                              style: tsOneTextTheme.titleSmall,
                                            ),
                                            SizedBox(height: 5.0),
                                            Text(
                                              'ID: $deviceId',
                                              style: tsOneTextTheme.labelMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 10),
                          ],

                          // Display 'waiting-confirmation-1' data
                          if (waitingConfirmationDocs.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Waiting Confirmation",
                                style: tsOneTextTheme.titleLarge,
                              ),
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: waitingConfirmationDocs.map((doc) {
                                String deviceName = doc['device_name'];
                                String deviceId = doc.id;

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PilotUnRequestDeviceView(
                                            deviceName: deviceName,
                                            deviceId: deviceId,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                        const EdgeInsets.all(18.0),
                                      ),
                                      overlayColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors.yellow.withOpacity(
                                            0.2), // Yellow with opacity when pressed
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors
                                            .white, // Set the default background color to white
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Mengatur item rata kiri
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start, // Mengatur teks ke kiri
                                          children: [
                                            Text(
                                              deviceName,
                                              style: tsOneTextTheme.titleSmall,
                                            ),
                                            const SizedBox(height: 5.0),
                                            Text(
                                              'ID: $deviceId',
                                              style: tsOneTextTheme.labelMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 10),
                          ],

                          // Display 'waiting-confirmation-other-pilot' data
                          if (needConfirmationPilotDocs.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Need Your Confirmation",
                                style: tsOneTextTheme.titleLarge,
                              ),
                            ),
                            SizedBox(height: 15),
                            Column(
                              children: needConfirmationPilotDocs.map((doc) {
                                String deviceName = doc['device_name'];
                                String deviceId = doc.id;

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ConfirmReturnOtherPilotView(
                                            deviceName: deviceName,
                                            deviceId: deviceId,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                        const EdgeInsets.all(18.0),
                                      ),
                                      overlayColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors.yellow.withOpacity(
                                            0.2), // Yellow with opacity when pressed
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors
                                            .white, // Set the default background color to white
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Mengatur item rata kiri
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start, // Mengatur teks ke kiri
                                          children: [
                                            Text(
                                              deviceName,
                                              style: tsOneTextTheme.titleSmall,
                                            ),
                                            const SizedBox(height: 5.0),
                                            Text(
                                              'ID: $deviceId',
                                              style: tsOneTextTheme.labelMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 10),
                          ],

                          if (needConfirmationOccDocs.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Waiting OCC To Confirm",
                                style: tsOneTextTheme.titleLarge,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: needConfirmationOccDocs.map((doc) {
                                String deviceName = doc['device_name'];
                                String deviceId = doc.id;

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PilotUnReturnDeviceView(
                                            deviceName: deviceName,
                                            deviceId: deviceId,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                        EdgeInsets.all(18.0),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors
                                            .white, // Warna latar belakang putih
                                      ),
                                      overlayColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors.yellow.withOpacity(
                                            0.2), // Warna kuning dengan opacity saat ditekan
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Mengatur item rata kiri
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start, // Mengatur teks ke kiri
                                          children: [
                                            Text(
                                              deviceName,
                                              style: tsOneTextTheme.titleSmall,
                                            ),
                                            SizedBox(height: 5.0),
                                            Text(
                                              'ID: $deviceId',
                                              style: tsOneTextTheme.labelMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      );
                    } else {
                      // Data not found, show "Request Device" button
                      return Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: TsOneColor.primary,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PilotrequestdeviceView(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  //Icons.qr_code_scanner_rounded,
                                  color: TsOneColor.onPrimary,
                                  size: 30,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Request Device",
                                  style: TextStyle(color: TsOneColor.onPrimary),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: BlackTitleText(text: "Need Confirmation"),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            "There is no data that needs confirmation",
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: BlackTitleText(text: 'Device Used')),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            "There is no device you are using",
                          ),
                        ],
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
