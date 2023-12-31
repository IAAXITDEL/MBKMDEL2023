import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import 'package:ts_one/util/util.dart';
import '../../../../../presentation/theme.dart';
import '../controllers/analytics_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:ts_one/data/users/users.dart';
import 'package:animations/animations.dart';
import 'package:ts_one/presentation/shared_components/legend_widget.dart';

DateTime? selectedStartDate;
DateTime? selectedEndDate;
String selectedHub = 'ALL';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({Key? key}) : super(key: key);

  Future<void> exportToExcel(List<Map<String, dynamic>> data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Main Data'];
    // Menentukan judul kolom
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value = 'Handover Date';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value = 'Crew ID';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2)).value = 'Crew Name';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 2)).value = 'RANK';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 2)).value = 'HUB';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 2)).value = 'Device 1';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 2)).value = 'Device 2';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 2)).value = 'Device 3';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 2)).value = 'Status';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 2)).value = 'Return';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 2)).value = 'Not return';
    final titleCellStyle = CellStyle(
      backgroundColorHex: '#FFFF00', // Warna latar belakang kuning
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    // Merge & center cell untuk judul Device
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 0));
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = titleCellStyle;
    final deviceTitleCellHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
    deviceTitleCellHeader.value = 'Acknowledgment & Return Process';

    final centerAlignmentHeader = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
    );
    deviceTitleCellHeader.cellStyle = centerAlignmentHeader;

    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 1), CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 1));
    final deviceTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 1));
    deviceTitleCell.value = 'Device Used';
    final centerAlignment = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
    );
    deviceTitleCell.cellStyle = centerAlignment;

    for (var i = 0; i < data.length; i++) {
      final device = data[i];
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(device['user_uid']).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        // Ubah Firestore Timestamp ke DateTime
        final timestamp = (device['timestamp'] as Timestamp).toDate();
        final formattedTimestamp = DateFormat('dd-MM-yyyy HH:mm:ss').format(timestamp);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 3)).value = formattedTimestamp;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 3)).value = userData['ID NO'];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 3)).value = userData['NAME'];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 3)).value = userData['RANK'];
      }
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 3)).value = device['field_hub'] ?? '-';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 3)).value = device['device_name'] ?? '-';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 3)).value = device['device_name2'] ?? '-';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 3)).value = device['device_name3'] ?? '-';

      String statusDeviceAlias = device['statusDevice'];
      if (statusDeviceAlias == 'Done') {
        statusDeviceAlias = 'Return back to OCC';
        // Tambahkan angka 1 ke kolom Return (kolom ke-9)
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 3)).value = 1;
        // Tambahkan angka 0 ke kolom Not Return (kolom ke-10)
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: i + 3)).value = 0;
      } else if (statusDeviceAlias == 'handover-to-other-crew') {
        statusDeviceAlias = 'Handover to other Crew';
        // Tambahkan angka 1 ke kolom Return (kolom ke-9)
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 3)).value = 1;
        // Tambahkan angka 0 ke kolom Not Return (kolom ke-10)
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: i + 3)).value = 0;
      } else if (statusDeviceAlias == 'in-use-pilot') {
        statusDeviceAlias = 'Not Return';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 3)).value = 0;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: i + 3)).value = 1;
      } else {
        // Jika tidak ada status yang cocok, tambahkan angka 0 ke kedua kolom
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 3)).value = 0;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: i + 3)).value = 0;
      }
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 3)).value = statusDeviceAlias;
    }

    // Simpan data
    final excelBytes = excel.encode();
    final output = await getTemporaryDirectory();
    final excelFile = File('${output.path}/device-data.xlsx');
    await excelFile.writeAsBytes(excelBytes!);

    await OpenFile.open(excelFile.path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }

  Future<List<Map<String, dynamic>>?> fetchDataFromFirebase() async {
    Query query = FirebaseFirestore.instance
        .collection('pilot-device-1')
        .where('statusDevice', whereIn: ['in-use-pilot', 'Done', 'handover-to-other-crew'])
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate)
        .where('timestamp', isLessThanOrEqualTo: selectedEndDate);

    if (selectedHub != 'ALL') {
      query = query.where('field_hub', isEqualTo: selectedHub);
    }

    QuerySnapshot querySnapshot = await query.get();

    List<Map<String, dynamic>> data = [];
    querySnapshot.docs.forEach((doc) {
      data.add(doc.data() as Map<String, dynamic>);
    });

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: tsOneTextTheme.headlineLarge,
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.table_chart_rounded),
            tooltip: "Export to Sheet",
            onPressed: () async {
              if (selectedStartDate != null && selectedEndDate != null) {
                List<Map<String, dynamic>>? data = await fetchDataFromFirebase();

                // Export data to Excel
                await exportToExcel(data!);
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
        // scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Column(
            children: [
              RedTitleText(text: "EFB Handover Monthly"),
              RedTitleText(text: "Report"),
              AnalyticsHub(),
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

class _AnalyticsHubState extends State<AnalyticsHub> with TickerProviderStateMixin {
  late int deviceCounts_InUse_AllHubs;
  late TabController tabController;
  late Map<String, int> totalDeviceCounts = {};
  late String selectedOption;
  int currentTabIndex = 0;
  static String keyHubCGK = "CGK";
  static String keyHubSUB = "SUB";
  static String keyHubDPS = "DPS";
  static String keyHubKNO = "KNO";

  void _selectStartingDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? currentDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
      currentDate: currentDate,
    );
    if (pickedStartDate != null && pickedStartDate != selectedStartDate) {
      setState(() {
        selectedStartDate = pickedStartDate;
      });
    }
  }

  void _selectEndingDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? pickedEndDate = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? currentDate,
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
    AnalyticsController().countDevicesHub().then((result) {
      setState(() {
        totalDeviceCounts = result;
        deviceCounts_InUse_AllHubs = result['CGK'] ?? 0;
      });
    });
  }

  @override
  void dispose() {
    // tabController?.dispose();
    super.dispose();
  }

  List<String> hubOptions = ['ALL', keyHubCGK, keyHubSUB, keyHubDPS, keyHubKNO];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Column(
        children: [
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
                        selectedStartDate != null ? Util.convertDateTimeDisplay(selectedStartDate.toString(), "dd MMM yyyy") : "Select Date",
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
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
                        selectedEndDate != null ? Util.convertDateTimeDisplay(selectedEndDate.toString(), "dd MMM yyyy") : "Select Date",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '  HUB',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                labelStyle: TextStyle(fontSize: 12, color: Colors.black),
              ),
              child: DropdownButton<String>(
                value: selectedHub,
                icon: Icon(Icons.arrow_drop_down, size: 24),
                iconSize: 24,
                items: hubOptions.map((String hub) {
                  return DropdownMenuItem<String>(
                    value: hub,
                    child: Text(hub),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedHub = newValue ?? 'ALL';
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
                "Currently showing analytics from ${Util.convertDateTimeDisplay(selectedStartDate.toString(), "dd MMM yyyy")} to ${Util.convertDateTimeDisplay(selectedEndDate.toString(), "dd MMM yyyy")} in HUB ${selectedHub}"),
          ),
          countDevicesInUse('CGK'),
          percentageDevicesInUse('CGK'),
          percentageDevices23InUse('CGK'),
          percentageDevices23InUsed('CGK'),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
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
                    'Available Devices',
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
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
            child: LegendsListWidget(
              legends: [
                Legend('CGK', Color.fromARGB(255, 255, 243, 226)),
                Legend('KNO', Color.fromARGB(255, 255, 229, 202)),
                Legend('DPS', Color.fromARGB(250, 250, 152, 132)),
                Legend('SUB', Color.fromARGB(231, 231, 70, 70)),
              ],
            ),
          ),
          PieChartWidget(totalDeviceCounts),
        ],
      ),
    );
  }

  Widget countDevicesInUse(String? hub) {
    if (hub != null) {
      return FutureBuilder(
        future: AnalyticsController().countDevicesHub_InUse_AllHubs(),
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
                          child: Center(child: BlackTitleText(text: "${deviceCounts_InUse_AllHubs}", size: 14.0)),
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
                            if (snapshot.connectionState == ConnectionState.waiting) {
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
                                  child: BlackTitleText(text: "${snapshot.data}", size: 14.0),
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
        future: AnalyticsController().countDevicesHub_InUse_AllHubs(),
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
                            AnalyticsController().calculatePercentageDeviceName(),
                            AnalyticsController().countDeviceName(),
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final double percentage = snapshot.data?[0] as double;
                              final int deviceNameCount = snapshot.data?[1] as int;
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
                                    text: "${percentage.toStringAsFixed(2)}%($deviceNameCount)",
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
                          future:
                              Future.wait([AnalyticsController().calculatePercentageDeviceNameDone(), AnalyticsController().countDeviceNameDone()]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final double percentage = snapshot.data?[0] as double;
                              final int deviceNameCountDone = snapshot.data?[1] as int;
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
                                    text: "${percentage.toStringAsFixed(2)}%($deviceNameCountDone)",
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
        future: AnalyticsController().countDevicesHub_InUse_AllHubs(),
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
                        Text("Device 2 & 3", style: tsOneTextTheme.bodySmall),
                        FutureBuilder(
                          future:
                              Future.wait([AnalyticsController().calculatePercentageDeviceName2and3(), AnalyticsController().countDeviceName2and3()]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final double percentage = snapshot.data?[0] as double;
                              final int deviceNameCount23 = snapshot.data?[1] as int;
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
                                    text: "${percentage.toStringAsFixed(2)}%($deviceNameCount23)",
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
                        Text("Device 2 & 3", style: tsOneTextTheme.bodySmall),
                        FutureBuilder(
                          future: Future.wait(
                              [AnalyticsController().calculatePercentageDeviceName2and3Done(), AnalyticsController().countDeviceName2and3Done()]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final double percentages = snapshot.data?[0] as double;
                              final int deviceNameCount2and3 = snapshot.data?[1] as int;
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
                                    text: "${percentages.toStringAsFixed(2)}%($deviceNameCount2and3) ",
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

  Widget percentageDevices23InUsed(String? hub) {
    if (hub != null) {
      return FutureBuilder(
        future: AnalyticsController().countDevicesHub_InUse_AllHubs(),
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
                        Text("Unfinished Process", style: tsOneTextTheme.bodySmall),
                        FutureBuilder(
                          future: Future.wait([
                            AnalyticsController().calculatePercentageNotReturn(),
                            AnalyticsController().countNotReturn(),
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final int deviceNotReturn = snapshot.data?[1] as int;
                              return Center(
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: tsOneColorScheme.primary,
                                    primary: Colors.white,
                                    padding: EdgeInsets.all(16),
                                    minimumSize: Size(200, 50),
                                  ),
                                  child: Text("$deviceNotReturn", style: TextStyle(color: Colors.white)),
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

  Future<int> countDevicesDone(String hub) async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot doneSnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', whereIn: ['Done', 'handover-to-other-crew'])
        // .where('field_hub', isEqualTo: hub)
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final int deviceCountDone = doneSnapshot.docs.length;
    final QuerySnapshot inUseSnapshot =
        await firestore.collection('pilot-device-1').where('statusDevice', isEqualTo: 'in-use-pilot').where('field_hub', isEqualTo: hub).get();

    final int inUseCount = inUseSnapshot.docs.length;
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

// Pie Chart Available Devices
class PieChartWidget extends StatefulWidget {
  final Map<String, int> deviceCounts;

  PieChartWidget(this.deviceCounts);
  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: AnalyticsController().countDevicesInUse(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Display a loading indicator while fetching data.
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final deviceCountInUse = snapshot.data;
          return AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: _getChartSections(deviceCountInUse),
                borderData: FlBorderData(show: false),
                startDegreeOffset: 180,
              ),
            ),
          );
        }
      },
    );
  }

//Color myColor = Color.fromARGB(255, 255, 0, 0); // Membuat warna merah (RGB: 255, 0, 0)

  List<PieChartSectionData> _getChartSections(int? deviceCountInUse) {
    final List<Color> colors = [
      Color.fromARGB(255, 234, 153, 39),
      Color.fromARGB(255, 255, 229, 202),
      Color.fromARGB(250, 250, 152, 132),
      Color.fromARGB(231, 231, 70, 70),
    ];

    final otherSections = List.generate(widget.deviceCounts.length, (i) {
      final hub = widget.deviceCounts.keys.toList()[i];
      final count = widget.deviceCounts[hub] ?? 0;

      return PieChartSectionData(
        title: '$count', // Update the title
        value: count.toDouble(),
        color: colors[i % colors.length],
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontFamily: 'Poppins',
        ),
      );
    });
    return otherSections;
  }
}
