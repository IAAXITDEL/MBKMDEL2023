import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import '../../../../../presentation/theme.dart';
import '../controllers/analytics_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animations/animations.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({Key? key}) : super(key: key);

  Future<Map<String, int>> countDevicesHub() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot =
        await firestore.collection('Device').get();

    final Map<String, int> deviceCountByHub = {
      'CGK': 0,
      'KNO': 0,
      'DPS': 0,
      'SUB': 0,
    };

    querySnapshot.docs.forEach((doc) {
      final hub = doc['hub'] as String;

      if (deviceCountByHub.containsKey(hub)) {
        deviceCountByHub[hub] = (deviceCountByHub[hub] ?? 0) + 1;
      }
    });

    return deviceCountByHub;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Analytics Device',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              RedTitleText(text: "EFB Handover Monthly Report"),
              AnalyticsHub()
            ],
          ),
        ),
      ),
    );
  }
}

class AnalyticsHub extends StatefulWidget {
  const AnalyticsHub({Key? key}) : super(key: key);

  @override
  State<AnalyticsHub> createState() => _AnalyticsHubState();
}

class _AnalyticsHubState extends State<AnalyticsHub>
    with TickerProviderStateMixin {
  final List<Tab> tabs = [
    Tab(text: "CGK"),
    Tab(text: "KNO"),
    Tab(text: "DPS"),
    Tab(text: "SUB"),
  ];
  late int deviceCounts_InUse_AllHubs;
  late TabController tabController;
  late Map<String, int> totalDeviceCounts = {};
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    countDevicesHub('CGK').then((result) {
      setState(() {
        totalDeviceCounts = result;
        // Initialize deviceCounts_InUse_AllHubs with the initial count
        deviceCounts_InUse_AllHubs = result['CGK'] ?? 0;
      });
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          countDevicesInUse(tabs[currentTabIndex].text),
          percentageDevicesInUse(tabs[currentTabIndex].text),
          percentageDevices23InUse(tabs[currentTabIndex].text),
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Flexible(
              child: TabBarView(
                controller: tabController,
                children: tabs.map((Tab tab) {
                  return ListView(
                    children: [
                      // Menampilkan jumlah total perangkat
                      SizedBox(height: 10),
                      PieChartWidget(
                          totalDeviceCounts, currentTabIndex, tabController),
                      TabBar(tabs: tabs, controller: tabController),
                      count(tabs[currentTabIndex]
                          .text), // Menampilkan jumlah perangkat yang sedang digunakan
                      SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget count(String? hub) {
    if (hub != null) {
      return FutureBuilder(
        future: Future.wait([countDevicesHub(hub), countDevicesHub_InUse(hub)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final deviceCounts =
                (snapshot.data as List<Map<String, int>>?)?.first;
            final deviceCounts_InUse =
                (snapshot.data as List? ?? [])[1] as Map<String, int>;
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Text("Total", style: tsOneTextTheme.bodySmall),
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: tsOneColorScheme.primary,
                                width: 1.0,
                              )),
                          child: Center(
                            child: BlackTitleText(
                                text: "${deviceCounts?[hub] ?? 'N/A'}"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Text("In Use", style: tsOneTextTheme.bodySmall),
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: tsOneColorScheme.primary,
                                width: 1.0,
                              )),
                          child: Center(
                              child: BlackTitleText(
                                  text: "${deviceCounts_InUse[hub]}")),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    } else {
      return Text('Tab tidak valid');
    }
  }

  Widget countDevicesInUse(String? hub) {
    if (hub != null) {
      return FutureBuilder(
        future: countDevicesHub_InUse_AllHubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final deviceCounts_InUse_AllHubs = snapshot.data as int;
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Text("IAA", style: tsOneTextTheme.bodySmall),
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: tsOneColorScheme.primary,
                                width: 1.0,
                              )),
                          child: Center(child: BlackTitleText(text: "Overall")),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Text("Acknowledgment", style: tsOneTextTheme.bodySmall),
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: tsOneColorScheme.primary,
                                width: 1.0,
                              )),
                          child: Center(
                              child: BlackTitleText(
                                  text: "${deviceCounts_InUse_AllHubs}")),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Text("Return", style: tsOneTextTheme.bodySmall),
                        FutureBuilder(
                          future: countDevicesDone(
                              tabs[currentTabIndex]?.text ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Container(
                                margin: EdgeInsets.all(16.0),
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: tsOneColorScheme.primary,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child:
                                      BlackTitleText(text: "${snapshot.data}"),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    } else {
      return Text('Tab tidak valid');
    }
  }

  Widget percentageDevicesInUse(String? hub) {
    if (hub != null) {
      return FutureBuilder(
        future: countDevicesHub_InUse_AllHubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // final deviceCounts_InUse_AllHubs = snapshot.data as int;
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: tsOneColorScheme.primary,
                                width: 1.0,
                              )),
                          child:
                              Center(child: BlackTitleText(text: "Device 1")),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: Future.wait([
                            calculatePercentageDeviceName(),
                            countDeviceName(),
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final double percentage =
                                  snapshot.data?[0] as double;
                              final int deviceNameCount =
                                  snapshot.data?[1] as int;
                              return Container(
                                margin: EdgeInsets.all(16.0),
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: tsOneColorScheme.primary,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: BlackTitleText(
                                    text:
                                        "${percentage.toStringAsFixed(2)}% ($deviceNameCount)",
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        // Text("Persentase device name2 dan 3",
                        //     style: tsOneTextTheme.bodySmall),
                        FutureBuilder(
                          future: Future.wait([
                            calculatePercentageDeviceNameDone(),
                            countDeviceNameDone()
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final double percentage =
                                  snapshot.data?[0] as double;
                              final int deviceNameCountDone =
                                  snapshot.data?[1] as int;
                              return Container(
                                margin: EdgeInsets.all(16.0),
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: tsOneColorScheme.primary,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: BlackTitleText(
                                    text:
                                        "${percentage.toStringAsFixed(2)}% ($deviceNameCountDone)",
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    } else {
      return Text('Tab tidak valid');
    }
  }

  Widget percentageDevices23InUse(String? hub) {
    if (hub != null) {
      return FutureBuilder(
        future: countDevicesHub_InUse_AllHubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // final deviceCounts_InUse_AllHubs = snapshot.data as int;
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: tsOneColorScheme.primary,
                                width: 1.0,
                              )),
                          child:
                              Center(child: BlackTitleText(text: "Device 2&3")),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: Future.wait([
                            calculatePercentageDeviceName2and3(),
                            countDeviceName2and3()
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final double percentage =
                                  snapshot.data?[0] as double;
                              final int deviceNameCount23 =
                                  snapshot.data?[1] as int;
                              return Container(
                                margin: EdgeInsets.all(16.0),
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: tsOneColorScheme.primary,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: BlackTitleText(
                                    text:
                                        "${percentage.toStringAsFixed(2)}% ($deviceNameCount23)",
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: Future.wait([
                            calculatePercentageDeviceName2and3Done(),
                            countDeviceName2and3Done()
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final double percentages =
                                  snapshot.data?[0] as double;
                              final int deviceNameCount2and3 =
                                  snapshot.data?[1] as int;
                              return Container(
                                margin: EdgeInsets.all(16.0),
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: tsOneColorScheme.primary,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: BlackTitleText(
                                    text:
                                        "${percentages.toStringAsFixed(2)}% ($deviceNameCount2and3) ",
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    } else {
      return Text('Tab tidak valid');
    }
  }

  Future<Map<String, int>> countDevicesHub(String hub) async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot =
        await firestore.collection('Device').get();

    final Map<String, int> deviceCountByHub = {
      'CGK': 0,
      'KNO': 0,
      'DPS': 0,
      'SUB': 0,
    };
    querySnapshot.docs.forEach((doc) {
      final hubValue = doc['hub'] as String;
      if (deviceCountByHub.containsKey(hubValue)) {
        deviceCountByHub[hubValue] = (deviceCountByHub[hubValue] ?? 0) + 1;
      }
    });

    return deviceCountByHub;
  }

//--------Kalkulasi Persentase Device 1----------
  Future<double> calculatePercentageDeviceName() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        // .where('statusDevice', isEqualTo: 'in-use-pilot')
        .where('statusDevice',
            whereIn: ['Done', 'in-use-pilot', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalRecords = documents.length;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name' tidak null dan tidak '-'.
      if (data['device_name'] != null && data['device_name'] != '') {
        totalDeviceName++;
      }
    }
    if (totalRecords > 0) {
      // Hitung persentase 'DeviceName' berdasarkan jumlahnya terhadap total in-use-pilot.
      double percentageDeviceName = (totalDeviceName / totalRecords) * 100;

      // Mengembalikan persentase 'DeviceName' sebagai hasil.
      return percentageDeviceName;
    } else {
      return 0.0; // Jika tidak ada data, persentasenya adalah 0.
    }
  }

  Future<int> countDeviceName() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice',
            whereIn: ['Done', 'in-use-pilot', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name' tidak null dan tidak '-'.
      if (data['device_name'] != null && data['device_name'] != '') {
        totalDeviceName++;
      }
    }

    // Mengembalikan jumlah perangkat dengan nama 'device_name'.
    return totalDeviceName;
  }

//-----------Kalkulasi pesentase device 2 dan device 3
  Future<double> calculatePercentageDeviceName2and3() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        // .where('statusDevice', isEqualTo: 'in-use-pilot')
        .where('statusDevice',
            whereIn: ['Done', 'in-use-pilot', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalRecords = documents.length;
    int totalDeviceName2and3 = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name2' atau 'device_name3' tidak null dan tidak '-'.
      if ((data['device_name2'] != null && data['device_name2'] != '-') ||
          (data['device_name3'] != null && data['device_name3'] != '-')) {
        totalDeviceName2and3++;
      }
    }

    if (totalRecords > 0) {
      // Hitung persentase 'DeviceName2and3' berdasarkan jumlahnya terhadap total in-use-pilot.
      double percentageDeviceName2and3 =
          (totalDeviceName2and3 / totalRecords) * 100;

      // Mengembalikan persentase 'DeviceName2and3' sebagai hasil.
      return percentageDeviceName2and3;
    } else {
      return 0.0; // Jika tidak ada data, persentasenya adalah 0.
    }
  }

  Future<int> countDeviceName2and3() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice',
            whereIn: ['Done', 'in-use-pilot', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalDeviceName2and3 = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name' tidak null dan tidak '-'.
      if ((data['device_name2'] != null && data['device_name2'] != '-') ||
          (data['device_name3'] != null && data['device_name3'] != '-')) {
        totalDeviceName2and3++;
      }
    }

    // Mengembalikan jumlah perangkat dengan nama 'device_name'.
    return totalDeviceName2and3;
  }

//--------Kalkulasi persentase device 1 yang kembali---------
  Future<double> calculatePercentageDeviceNameDone() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice',
            whereIn: ['Done', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalRecords = documents.length;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name' tidak null dan tidak '-'.
      if (data['device_name'] != null && data['device_name'] != '') {
        totalDeviceName++;
      }
    }

    if (totalRecords > 0) {
      // Hitung persentase 'DeviceName' berdasarkan jumlahnya terhadap total in-use-pilot.
      double percentageDeviceName = (totalDeviceName / totalRecords) * 100;

      // Mengembalikan persentase 'DeviceName' sebagai hasil.
      return percentageDeviceName;
    } else {
      return 0.0; // Jika tidak ada data, persentasenya adalah 0.
    }
  }

  Future<int> countDeviceNameDone() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice',
            whereIn: ['Done', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name' tidak null dan tidak '-'.
      if (data['device_name'] != null && data['device_name'] != '') {
        totalDeviceName++;
      }
    }

    // Mengembalikan jumlah perangkat dengan nama 'device_name'.
    return totalDeviceName;
  }

//--------Kalkulasi persentase device 2 dan device 3   yang kembali---------
  Future<double> calculatePercentageDeviceName2and3Done() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice',
            whereIn: ['Done', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalRecords = documents.length;
    int totalDeviceName2and3 = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name2' atau 'device_name3' tidak null dan tidak '-'.
      if ((data['device_name2'] != null && data['device_name2'] != '-') ||
          (data['device_name3'] != null && data['device_name3'] != '-')) {
        totalDeviceName2and3++;
      }
    }

    if (totalRecords > 0) {
      // Hitung persentase 'DeviceName2and3' berdasarkan jumlahnya terhadap total in-use-pilot.
      double percentageDeviceName2and3 =
          (totalDeviceName2and3 / totalRecords) * 100;

      // Mengembalikan persentase 'DeviceName2and3' sebagai hasil.
      return percentageDeviceName2and3;
    } else {
      return 0.0; // Jika tidak ada data, persentasenya adalah 0.
    }
  }

  Future<int> countDeviceName2and3Done() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice',
            whereIn: ['Done', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalDeviceName2and3 = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name' tidak null dan tidak '-'.
      if ((data['device_name2'] != null && data['device_name2'] != '-') ||
          (data['device_name3'] != null && data['device_name3'] != '-')) {
        totalDeviceName2and3++;
      }
    }

    // Mengembalikan jumlah perangkat dengan nama 'device_name'.
    return totalDeviceName2and3;
  }

  Future<Map<String, int>> countDevicesHub_InUse(String hub) async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice', isEqualTo: 'in-use-pilot')
        .where('field_hub', isEqualTo: hub)
        .get();

    final int deviceCount_InUse = querySnapshot.docs.length;

    final Map<String, int> deviceCountByHub_InUse = {
      hub: deviceCount_InUse,
    };

    return deviceCountByHub_InUse;
  }

  Future<int> countDevicesHub_InUse_AllHubs() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice',
            whereIn: ['in-use-pilot', 'Done', 'handover-to-other-crew']).get();

    final int deviceCount_InUse_AllHubs = querySnapshot.docs.length;

    return deviceCount_InUse_AllHubs;
  }

  Future<int> countDevicesDone(String hub) async {
    final firestore = FirebaseFirestore.instance;

    // Query for devices with 'Done' status
    final QuerySnapshot doneSnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice', whereIn: ['Done', 'handover-to-other-crew'])
        // .where('field_hub', isEqualTo: hub)
        .get();

    final int deviceCountDone = doneSnapshot.docs.length;

    // Query for devices with 'in-use-pilot' status
    final QuerySnapshot inUseSnapshot = await firestore
        .collection('pilot-device-1')
        .where('statusDevice', isEqualTo: 'in-use-pilot')
        .where('field_hub', isEqualTo: hub)
        .get();

    final int inUseCount = inUseSnapshot.docs.length;
    // Check if there's a decrease in 'in-use-pilot' devices count
    if (inUseCount < deviceCounts_InUse_AllHubs) {
      deviceCounts_InUse_AllHubs = inUseCount;
    }
    return deviceCountDone;
  }

  void _handleTabChange(int newIndex) {
    setState(() {
      currentTabIndex = newIndex;
    });
  }
}

// Pie Chart
class PieChartWidget extends StatefulWidget {
  final Map<String, int> deviceCounts;
  final int currentTabIndex;
  final TabController tabController;

  PieChartWidget(this.deviceCounts, this.currentTabIndex, this.tabController);

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      setState(() {
        touchedIndex = widget.tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback:
                (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null) {
                return;
              }
              setState(() {
                if (pieTouchResponse.touchedSection != null) {
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                } else {
                  touchedIndex = -1;
                }
              });

              if (touchedIndex != -1 &&
                  touchedIndex != widget.currentTabIndex) {
                widget.tabController
                    .animateTo(touchedIndex); // Switch to the corresponding tab
              }
            },
          ),
          sectionsSpace: 2,
          centerSpaceRadius: 30,
          sections: _getChartSections(),
          borderData: FlBorderData(show: false),
          startDegreeOffset: 180,
        ),
      ),
    );
  }

  List<PieChartSectionData> _getChartSections() {
    final List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
    ];

    final List<String> hubs = widget.deviceCounts.keys.toList();
    return List.generate(widget.deviceCounts.length, (i) {
      final int count = widget.deviceCounts[hubs[i]] ?? 0;
      final double percentage =
          (count / widget.deviceCounts.values.reduce((a, b) => a + b)) * 100;

      final bool isExploded = touchedIndex == i;

      return PieChartSectionData(
        title: '${hubs[i]}\n${percentage.toStringAsFixed(2)}%',
        value: count.toDouble(),
        color: colors[i % colors.length],
        radius: isExploded ? 110 : 90,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontFamily: 'Poppins',
        ),
      );
    });
  }
}
