  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:ts_one/app/modules/efb/pilot/views/pilotrequestdevice_view.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilotreturndeviceview_view.dart';
  import '../../../../../presentation/theme.dart';
  import '../../../../../util/util.dart';
  import '../controllers/homepilot_controller.dart';
  import '../controllers/requestdevice_controller.dart';

  class HomePilotView extends GetView<HomePilotController> {
  const HomePilotView({super.key});

    @override
    Widget build(BuildContext context) {
      final controller = Get.put(HomePilotController());
      final requestDeviceController = RequestdeviceController();

      return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hi, ${controller.titleToGreet}",
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
                const SizedBox(height: 20),
                FutureBuilder<QuerySnapshot>(
                  future: requestDeviceController.getPilotDevices(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      QuerySnapshot? pilotDevicesSnapshot = snapshot.data;

                      if (pilotDevicesSnapshot != null && pilotDevicesSnapshot.docs.isNotEmpty) {
                        // Data "in-use-pilot" sudah ada, maka tombol "Request Device" disembunyikan
                        return Column(
                          children: [
                            Text(
                              "Need Confirmation",
                              style: tsOneTextTheme.headlineLarge,
                              textAlign: TextAlign.left,
                            ),
                            const Text(
                              "There is no data that needs confirmation",
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "Device Used",
                              style: tsOneTextTheme.headlineLarge,
                              textAlign: TextAlign.left,
                            ),
                            const Text(
                              "(You have to returned the device so that you can request another device!)",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 8.0,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: pilotDevicesSnapshot.docs.map((doc) {
                                String deviceName = doc['device_name'];
                                String deviceId = doc.id;

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PilotreturndeviceviewView(
                                            deviceName: deviceName,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                        const EdgeInsets.all(18.0),
                                      ),
                                      side: MaterialStateProperty.all<BorderSide>(
                                        const BorderSide(
                                          color: Colors.yellow, // Warna border line kuning
                                          width: 2.0,
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                        Colors.white, // Warna latar belakang putih
                                      ),
                                      overlayColor: MaterialStateProperty.all<Color>(
                                        Colors.yellow.withOpacity(0.2), // Warna kuning dengan opacity saat ditekan
                                      ),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                      ),
                                    ),

                                    child: Row( // Menggunakan Row untuk mengatur item rata kiri
                                      crossAxisAlignment: CrossAxisAlignment.start, // Mengatur item rata kiri
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start, // Mengatur teks ke kiri
                                          children: [
                                            Text(
                                              deviceName,
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            Text(
                                              'ID: $deviceId',
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                                color: Colors.black,
                                              ),
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
                        );
                      } else {
                        // Data "in-use-pilot" belum ada, maka tampilkan tombol "Request Device"
                        return Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PilotrequestdeviceView(),
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  const EdgeInsets.symmetric(vertical: 15, horizontal: 90),
                                ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white,
                                ),
                              ),
                              child: const Text(
                                "Request Device",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "Need Confirmation",
                              style: tsOneTextTheme.headlineLarge,
                              textAlign: TextAlign.left,
                            ),
                            const Text(
                              "There is no data that needs confirmation",
                            ),
                            Text(
                              "Device Used",
                              style: tsOneTextTheme.headlineLarge,
                              textAlign: TextAlign.left,
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

