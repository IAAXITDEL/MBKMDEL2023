import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilot_un_request_device_view.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilot_un_return_device_view.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilot_unreturn_to_other_crew.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilotrequestdevice_view.dart';
import 'package:ts_one/app/modules/efb/pilot/views/pilotreturndeviceview_view.dart';
import 'package:ts_one/app/routes/app_pages.dart';
import 'package:ts_one/app/routes/app_pages.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import '../../../../../presentation/theme.dart';
import '../../../../../util/util.dart';
import '../../occ/model/device.dart';
import '../controllers/homepilot_controller.dart';
import '../controllers/requestdevice_controller.dart';
import 'confirm_return_other_pilot_view.dart';

class HomePilotView extends GetView<HomePilotController> {
  Future<void> _handleRefresh() async {
    return await Future.delayed(Duration(milliseconds: 500)).then((value) {
      Get.offAllNamed(Routes.NAVOCC);
    });
  }

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomePilotController());
    final requestDeviceController = RequestdeviceController();

    String getMonthText(int month) {
      const List<String> months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'Desember'
      ];
      return months[month - 1]; // Index 0-11 for Januari-Desember
    }

    String _formatTimestamp(Timestamp? timestamp) {
      if (timestamp == null) return 'No Data';

      DateTime dateTime = timestamp.toDate();
      String formattedDateTime =
          '${dateTime.day} ${getMonthText(dateTime.month)} ${dateTime.year}';
      return formattedDateTime;
    }

    return Scaffold(
        body: LiquidPullToRefresh(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      showChildOpacityTransition: false,
      child: ListView(children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                              'waiting-handover-to-other-crew')
                          .toList();
                      return Column(
                        children: [
                          // Display 'in-use-pilot' data
                          if (inUsePilotDocs.isNotEmpty) ...[
                            const Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  BlackTitleText(text: "Waiting Confirmation"),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Text(
                              "There is no data that wait for confirmation",
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: BlackTitleText(
                                  text: "Need Your Confirmation"),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Text(
                              "There is no data that needs confirmation",
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: BlackTitleText(text: "In Use Pilot")),
                            const SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: inUsePilotDocs.map((doc) {
                                // Your existing code for displaying 'in-use-pilot' data
                                String deviceName = doc['device_name'];
                                String OccOnDuty = doc['occ-on-duty'];
                                String userId = doc['user_uid'];
                                String deviceId = doc.id;

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: double
                                        .infinity, // Set lebar kartu ke seluruh lebar tampilan
                                    child: Card(
                                      color: tsOneColorScheme
                                          .primary, // Mengatur warna latar belakang kartu menjadi merah
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: InkWell(
                                        onTap: () {
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
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Device 1',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    'CAPT ID',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    'Date',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              const Column(
                                                children: [
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(deviceName,
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                  Text(userId,
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                  Text(
                                                      _formatTimestamp(
                                                          doc['timestamp']),
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                ],
                                              )),
                                              const Icon(
                                                Icons.chevron_right,
                                                color: TsOneColor.secondary,
                                                size: 48,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Display 'waiting-confirmation-1' data
                          if (waitingConfirmationDocs.isNotEmpty) ...[
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: BlackTitleText(
                                    text: "Waiting OCC To Confirm")),
                            const SizedBox(height: 10),
                            Column(
                              children: waitingConfirmationDocs.map((doc) {
                                String deviceName = doc['device_name'];
                                String userId = doc['user_uid'];
                                String deviceId = doc.id;

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: double
                                        .infinity, // Set lebar kartu ke seluruh lebar tampilan
                                    child: Card(
                                      color: tsOneColorScheme
                                          .primary, // Mengatur warna latar belakang kartu menjadi merah
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: InkWell(
                                        onTap: () {
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
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Device 1',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    'CAPT ID',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    'Date',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              const Column(
                                                children: [
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(deviceName,
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                  Text(userId,
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                  Text(
                                                      _formatTimestamp(
                                                          doc['timestamp']),
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                ],
                                              )),
                                              const Icon(
                                                Icons.chevron_right,
                                                color: TsOneColor.secondary,
                                                size: 48,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: BlackTitleText(
                                  text: "Need Your Confirmation"),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Text(
                              "There is no data that needs confirmation",
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: BlackTitleText(text: "In Use"),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Text(
                              "There is no data that In Use",
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                          ],

                          // Display 'waiting-confirmation-other-pilot' data
                          if (needConfirmationPilotDocs.isNotEmpty) ...[
                            const Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  BlackTitleText(text: "Waiting Confirmation"),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Text(
                              "There is no data that wait for confirmation",
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: BlackTitleText(
                                  text: "Waiting For Confirmation!"),
                            ),
                            const SizedBox(height: 15),
                            Column(
                              children: needConfirmationPilotDocs.map((doc) {
                                String deviceName = doc['device_name'];
                                String userId = doc['user_uid'];
                                String deviceId = doc.id;

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: double
                                        .infinity, // Set lebar kartu ke seluruh lebar tampilan
                                    child: Card(
                                      color: tsOneColorScheme
                                          .primary, // Mengatur warna latar belakang kartu menjadi merah
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PilotUnReturnToOtherCrewView(
                                                deviceName: deviceName,
                                                deviceId: deviceId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Device 1',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    'CAPT ID',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    'Date',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              const Column(
                                                children: [
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(deviceName,
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                  Text(userId,
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                  Text(
                                                      _formatTimestamp(
                                                          doc['timestamp']),
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                ],
                                              )),
                                              const Icon(
                                                Icons.chevron_right,
                                                color: TsOneColor.secondary,
                                                size: 48,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: BlackTitleText(text: "In Use"),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Text(
                              "There is no data In Use",
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            const SizedBox(height: 10),
                          ],

                          if (needConfirmationOccDocs.isNotEmpty) ...[
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: BlackTitleText(
                                  text: "Waiting For OCC To Confirm"),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: needConfirmationOccDocs.map((doc) {
                                String deviceName = doc['device_name'];
                                String userId = doc['user_uid'];
                                String deviceId = doc.id;

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: double
                                        .infinity, // Set lebar kartu ke seluruh lebar tampilan
                                    child: Card(
                                      color: tsOneColorScheme
                                          .primary, // Mengatur warna latar belakang kartu menjadi merah
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: InkWell(
                                        onTap: () {
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
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Device 1',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    'CAPT ID',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    'Date',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              const Column(
                                                children: [
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                  Text(
                                                    ':',
                                                    style: TextStyle(
                                                        color: TsOneColor
                                                            .secondary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(deviceName,
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                  Text(userId,
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                  Text(
                                                      _formatTimestamp(
                                                          doc['timestamp']),
                                                      style: const TextStyle(
                                                          color: TsOneColor
                                                              .secondary)),
                                                ],
                                              )),
                                              const Icon(
                                                Icons.chevron_right,
                                                color: TsOneColor.secondary,
                                                size: 48,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: BlackTitleText(
                                  text: "Need Your Confirmation"),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Text(
                              "There is no data that needs confirmation",
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: BlackTitleText(text: "In Use"),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Text(
                              "There is no data that In Use",
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                          ],
                        ],
                      );
                    } else {
                      // Data not found, show "Request Device" button
                      // Data not found, show "Request Device" button
                      return Column(
                        children: [
                          //Untuk Handover
                          FutureBuilder<QuerySnapshot>(
                            future: requestDeviceController
                                .getPilotDevicesHandover(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                QuerySnapshot? pilotDevicesSnapshot =
                                    snapshot.data;
                                if (pilotDevicesSnapshot != null &&
                                    pilotDevicesSnapshot.docs.isNotEmpty) {
                                  // Filter the data for 'in-use-pilot' and 'waiting-confirmation-1'
                                  final inConfirmationPilotDocs =
                                      pilotDevicesSnapshot.docs
                                          .where((doc) =>
                                              doc['statusDevice'] ==
                                              'waiting-handover-to-other-crew')
                                          .toList();

                                  return Column(
                                    children: [
                                      // Display 'in-use-pilot' data
                                      if (inConfirmationPilotDocs
                                          .isNotEmpty) ...[
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: BlackTitleText(
                                              text: "Confirm From Other Crew"),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),

                                        //IN USE PILOT HERE
                                        Column(
                                          children: inConfirmationPilotDocs
                                              .map((doc) {
                                            // Your existing code for displaying 'in-use-pilot' data
                                            String deviceName =
                                                doc['device_name'];
                                            String userId = doc['user_uid'];
                                            String deviceId = doc.id;

                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: double
                                                    .infinity, // Set lebar kartu ke seluruh lebar tampilan
                                                child: Card(
                                                  color: tsOneColorScheme
                                                      .primary, // Mengatur warna latar belakang kartu menjadi merah
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ConfirmReturnOtherPilotView(
                                                            deviceName:
                                                                deviceName,
                                                            deviceId: deviceId,
                                                          ),
                                                        ),
                                                      );
                                                      print(deviceName);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Device 1",
                                                                style: TextStyle(
                                                                    color: TsOneColor
                                                                        .secondary),
                                                              ),
                                                              Text(
                                                                'CAPT ID',
                                                                style: TextStyle(
                                                                    color: TsOneColor
                                                                        .secondary),
                                                              ),
                                                              Text(
                                                                'Date',
                                                                style: TextStyle(
                                                                    color: TsOneColor
                                                                        .secondary),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          const Column(
                                                            children: [
                                                              Text(
                                                                ':',
                                                                style: TextStyle(
                                                                    color: TsOneColor
                                                                        .secondary),
                                                              ),
                                                              Text(
                                                                ':',
                                                                style: TextStyle(
                                                                    color: TsOneColor
                                                                        .secondary),
                                                              ),
                                                              Text(
                                                                ':',
                                                                style: TextStyle(
                                                                    color: TsOneColor
                                                                        .secondary),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Expanded(
                                                              child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(deviceName,
                                                                  style: const TextStyle(
                                                                      color: TsOneColor
                                                                          .secondary)),
                                                              Text(userId,
                                                                  style: const TextStyle(
                                                                      color: TsOneColor
                                                                          .secondary)),
                                                              Text(
                                                                  _formatTimestamp(doc[
                                                                      'timestamp']),
                                                                  style: const TextStyle(
                                                                      color: TsOneColor
                                                                          .secondary)),
                                                            ],
                                                          )),
                                                          const Icon(
                                                            Icons.chevron_right,
                                                            color: TsOneColor
                                                                .secondary,
                                                            size: 48,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 10),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: BlackTitleText(
                                              text: "Waiting Confirmation"),
                                        ),
                                        const SizedBox(
                                          height: 15.0,
                                        ),
                                        const Text(
                                          "There is no data that need to confirm",
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        const Align(
                                            alignment: Alignment.centerLeft,
                                            child:
                                                BlackTitleText(text: 'In Use')),
                                        const SizedBox(
                                          height: 15.0,
                                        ),
                                        const Text(
                                          "There is data In Use ",
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
                                            minimumSize:
                                                const Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            )),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PilotrequestdeviceView(),
                                            ),
                                          );
                                        },
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                              style: TextStyle(
                                                  color: TsOneColor.onPrimary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: BlackTitleText(
                                            text: "Waiting Confirmation"),
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      const Text(
                                        "There is no data that need to confirm",
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: BlackTitleText(
                                            text: "Need Confirmation"),
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      const Text(
                                        "There is no data that wait for confirmation",
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      const Align(
                                          alignment: Alignment.centerLeft,
                                          child:
                                              BlackTitleText(text: 'In Use')),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      const Text(
                                        "There is data In Use ",
                                      ),
                                    ],
                                  );
                                }
                              }
                            },
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
      ]),
    ));
  }
}
