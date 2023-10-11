import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import 'package:ts_one/util/util.dart';
import '../../../../../presentation/theme.dart';
import '../controllers/analytics_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animations/animations.dart';

DateTime? selectedStartDate;
DateTime? selectedEndDate;

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

  Future<void> exportToExcel(List<Map<String, dynamic>> data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Main Data'];

    // Menentukan judul kolom
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value =
        'ID';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value =
        'NAME';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1)).value =
        'RANK';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1)).value =
        'Hub';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 1)).value =
        'Device 1';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 1)).value =
        'Device 2';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 1)).value =
        'Device 3';

    // Merge & center cell untuk judul Device
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0));
    final deviceTitleCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0));
    deviceTitleCell.value = 'Device yang sedang digunakan';

    final centerAlignment = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
    );
    deviceTitleCell.cellStyle = centerAlignment;

    for (var i = 0; i < data.length; i++) {
      final device = data[i];
      // Membaca data pengguna dari Firestore
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(device['user_uid'])
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 2))
            .value = userData['ID NO'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 2))
            .value = userData['NAME'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 2))
            .value = userData['RANK'];
      }
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 2))
          .value = device['field_hub'];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 2))
          .value = device['device_name'];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 2))
          .value = device['device_name2'];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 2))
          .value = device['device_name3'];
    }

    // Simpan data
    final excelBytes = excel.encode();
    final output = await getTemporaryDirectory();
    final excelFile = File('${output.path}/device-data.xlsx');
    await excelFile.writeAsBytes(excelBytes!);

    await OpenFile.open(excelFile.path,
        type:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }

  Future<List<Map<String, dynamic>>> fetchDataFromFirebase() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('pilot-device-1')
        .where('statusDevice', isEqualTo: 'in-use-pilot')
        // Filter by date range using selectedStartDate and selectedEndDate
        .where('timestamp',
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
        .get();

    List<Map<String, dynamic>> data = [];
    querySnapshot.docs.forEach((doc) {
      data.add(doc.data() as Map<String, dynamic>);
    });

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: tsOneTextTheme.headlineLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.table_chart_rounded),
            tooltip: "Export to Sheet",
            onPressed: () async {
              if (selectedStartDate != null && selectedEndDate != null) {
                List<Map<String, dynamic>> data = await fetchDataFromFirebase();

                // Export data to Excel
                await exportToExcel(data);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select both start and end dates.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              RedTitleText(text: "EFB Handover Monthly Report"),
              AnalyticsHub(),
              RedTitleText(text: "Device Distribution"),
              // Pass the deviceCounts data here
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
  late int deviceCounts_InUse_AllHubs;
  late TabController tabController;
  late Map<String, int> totalDeviceCounts = {};

  late String selectedOption;
  int currentTabIndex = 0;

  // Define variabel untuk menyimpan teks "start date" dan "end date"
  void _selectStartingDate(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    );
    if (pickedStartDate != null && pickedStartDate != selectedStartDate) {
      setState(() {
        selectedStartDate = pickedStartDate;
      });
    }
  }

  void _selectEndingDate(BuildContext context) async {
    final DateTime? pickedEndDate = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    );
    if (pickedEndDate != null && pickedEndDate != selectedEndDate) {
      setState(() {
        selectedEndDate = pickedEndDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();
    tabController = TabController(length: 1, vsync: this);
    countDevicesHub('CGK').then((result) {
      setState(() {
        totalDeviceCounts = result;
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
      length: 1,
      child: Column(
        children: [
          // Add Start Date Selector
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedStartDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          selectedStartDate = selectedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        selectedStartDate != null
                            ? Util.convertDateTimeDisplay(
                                selectedStartDate.toString(), "dd MMM yyyy")
                            : "Select Date",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Add End Date Selector
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedEndDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          selectedEndDate = selectedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        selectedEndDate != null
                            ? Util.convertDateTimeDisplay(
                                selectedEndDate.toString(), "dd MMM yyyy")
                            : "Select Date",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
                "Currently showing analytics from ${Util.convertDateTimeDisplay(selectedStartDate.toString(), "dd MMM yyyy")} to ${Util.convertDateTimeDisplay(selectedEndDate.toString(), "dd MMM yyyy")}"),
          ),
          countDevicesInUse('CGK'),
          percentageDevicesInUse('CGK'),
          percentageDevices23InUse('CGK'),
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView(
              children: [
                // Widgets for the content of the single "tab"
                SizedBox(height: 10),
                PieChartWidget(totalDeviceCounts),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
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
                        Text("Acknowledgment", style: tsOneTextTheme.bodySmall),
                        Container(
                          margin: EdgeInsets.all(6.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: tsOneColorScheme.primary,
                                width: 1.0,
                              )),
                          child: Center(
                              child: BlackTitleText(
                                  text: "${deviceCounts_InUse_AllHubs}",
                                  size: 14.0)),
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
                          future: countDevicesDone('CGK'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Container(
                                margin: EdgeInsets.all(6.0),
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
                                      text: "${snapshot.data}", size: 14.0),
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
                        Text("Device 1", style: tsOneTextTheme.bodySmall),
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
                                margin: EdgeInsets.all(6.0),
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
                                        "${percentage.toStringAsFixed(2)}%($deviceNameCount)",
                                    size: 14.0,
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
                        Text("Device 1", style: tsOneTextTheme.bodySmall),
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
                                margin: EdgeInsets.all(6.0),
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
                                        "${percentage.toStringAsFixed(2)}%($deviceNameCountDone)",
                                    size: 14.0,
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
                        Text("Device 1 & 2", style: tsOneTextTheme.bodySmall),
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
                                margin: EdgeInsets.all(6.0),
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
                                        "${percentage.toStringAsFixed(2)}%($deviceNameCount23)",
                                    size: 14.0,
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
                        Text("Device 1 & 2", style: tsOneTextTheme.bodySmall),
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
                                margin: EdgeInsets.all(6.0),
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
                                        "${percentages.toStringAsFixed(2)}%($deviceNameCount2and3) ",
                                    size: 14.0,
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

//count
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
        .where('timestamp',
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice',
            whereIn: ['Done', 'in-use-pilot', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalRecords = documents.length;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name' tidak null dan tidak ''.
      if (data['device_name'] != null && data['device_name'] != '-') {
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
        .where('timestamp',
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice',
            whereIn: ['Done', 'in-use-pilot', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name' tidak null dan tidak '-'.
      if (data['device_name'] != null && data['device_name'] != '-') {
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
        .where('timestamp',
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
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
        .where('timestamp',
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
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
        .where('timestamp',
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice',
            whereIn: ['Done', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalRecords = documents.length;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name' tidak null dan tidak '-'.
      if (data['device_name'] != null && data['device_name'] != '-') {
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
        .where('timestamp',
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice',
            whereIn: ['Done', 'handover-to-other-crew']).get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      // Periksa apakah field 'device_name' tidak null dan tidak '-'.
      if (data['device_name'] != null && data['device_name'] != '-') {
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
        .where('timestamp',
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
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
        .where('timestamp',
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
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
        // .where('timestamp', isGreaterThanOrEqualTo: startDate)
        // .where('timestamp', isLessThanOrEqualTo: endDate)
        .where('timestamp',
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
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
        .where('timestamp',
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
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

  PieChartWidget(this.deviceCounts);

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1; // Tambahkan variabel touchedIndex di sini
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
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

      final bool isTouched = i == touchedIndex;

      return PieChartSectionData(
        title: isTouched
            ? ''
            : '${hubs[i]}\n${percentage.toStringAsFixed(2)}% ($count)',
        value: count.toDouble(),
        color: isTouched ? Colors.grey : colors[i % colors.length],
        radius: isTouched ? 70 : 90,
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
