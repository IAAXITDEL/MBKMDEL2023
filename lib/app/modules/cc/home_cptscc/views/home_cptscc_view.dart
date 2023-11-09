import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ts_one/app/modules/cc/home_cptscc/controllers/home_cptscc_controller.dart';
import '../../../../../presentation/theme.dart';
import '../../../../../util/util.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

DateTime? selectedStartDate;
DateTime? selectedEndDate;
String selectedSubject = 'ALL';

class HomeCptsccView extends GetView<HomeCptsccController> {
  HomeCptsccView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  // Function to create a Card widget with specified content
  Widget buildCard(String imagePath, String count, String title) {
    return Card(
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 48,
            height: 63,
          ),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.red),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    var fromC = TextEditingController();
    var toC = TextEditingController();

    var nameC = TextEditingController();

    Future<bool> onWillPop() async {
      controller.resetDate();
      return true;
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, ${controller.titleToGreet}!",
                    style: tsOneTextTheme.headlineLarge,
                  ),
                  Text(
                    'Good ${controller.timeToGreet}',
                    style: tsOneTextTheme.labelMedium,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
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
                              DateTime.now().toString(),
                              "EEEE",
                            ),
                            style: tsOneTextTheme.labelSmall,
                          ),
                          Text(
                            Util.convertDateTimeDisplay(
                              DateTime.now().toString(),
                              "dd MMMM yyyy",
                            ),
                            style: tsOneTextTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 35),

                  Column(
                    children: [
                      Center(
                        child: Text(
                          'STATS',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black, // Color of the line
                        thickness: 3,       // Thickness of the line
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  // DOWNLOAD EXCEL
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // TextButton(
                      //   onPressed: () async {
                      //     var dir = await getApplicationDocumentsDirectory();
                      //     var file = File('${dir.path}/stats_data.xlsx');
                      //
                      //     // Check if the Excel file already exists
                      //     if (!await file.exists()) {
                      //       // Create an Excel workbook
                      //       final excel = Excel.createExcel();
                      //       final sheet = excel['Sheet1'];
                      //
                      //       // Define column titles and cell styles
                      //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value = 'Category';
                      //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value = 'Count';
                      //
                      //       final titleCellStyle = CellStyle(
                      //         backgroundColorHex: '#FFFF00', // Yellow background color
                      //         horizontalAlign: HorizontalAlign.Center,
                      //         verticalAlign: VerticalAlign.Center,
                      //       );
                      //
                      //       // Set cell style for column titles
                      //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).cellStyle = titleCellStyle;
                      //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).cellStyle = titleCellStyle;
                      //
                      //       // Merge and center cells for the "Acknowledgment & Return Process" title
                      //       sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0));
                      //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = titleCellStyle;
                      //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Acknowledgment & Return Process';
                      //
                      //       // Gather your data
                      //       List<List<dynamic>> data = [
                      //         ['Category', 'Count'],
                      //         ['Trainings', controller.trainingCount.value],
                      //         ['Instructors', controller.instructorCount.value],
                      //         ['Pilots', controller.pilotCount.value],
                      //         ['Ongoing Trainings', controller.ongoingTrainingCount.value],
                      //         ['Completed Trainings', controller.completedTrainingCount.value],
                      //         ['Trainees', controller.traineeCount.value],
                      //       ];
                      //
                      //       // Add data to the sheet
                      //       for (final row in data) {
                      //         sheet.appendRow(row);
                      //       }
                      //
                      //       // Save the Excel file
                      //       await file.writeAsBytes(excel.encode() ?? Uint8List(0));
                      //     }
                      //
                      //     // Delay for 2 seconds (adjust as needed)
                      //     await Future.delayed(Duration(seconds: 2));
                      //
                      //     // Open the saved Excel file
                      //     OpenFile.open(file.path);
                      //   },
                      //   style: TextButton.styleFrom(
                      //     primary: Colors.black,
                      //     backgroundColor: Colors.green,
                      //     minimumSize: Size(0, 30),
                      //     padding: EdgeInsets.symmetric(horizontal: 15),
                      //   ),
                      //   child: Text(
                      //     'Download',
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 12,
                      //     ),
                      //   ),
                      // )
                    ],
                  ),

                  SizedBox(height: 15),

                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 100,
                            child: Divider(
                              color: Colors.red,
                              thickness: 1,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                'Trainings',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 100,
                            child: Divider(
                              color: Colors.red,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          //SUBJECT TRAININGS
                          Expanded(
                            child: Container(
                              height: 140,
                              child: buildCard(
                                'assets/images/G1.png',
                                '${controller.trainingCount.value}',
                                'Trainings',
                              ),
                            ),
                          ),

                          //ONGOING TRAININGS
                          Expanded(
                            child: Container(
                              height: 140,
                              child: buildCard(
                                'assets/images/G1.png',
                                '${controller.ongoingTrainingCount.value}',
                                'Ongoing Trainings',
                              ),
                            ),
                          ),

                          //COMPLETED TRAININGS
                          Expanded(
                            child: Container(
                              height: 140,
                              child: buildCard(
                                'assets/images/G2.png',
                                '${controller.completedTrainingCount.value}',
                                'Completed Trainings',
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      //PILOTS VS INSTRUCTORS PIE CHART
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 80, // Atur lebar garis kiri sesuai kebutuhan
                                child: Divider(
                                  color: Colors.red,
                                  thickness: 1,
                                ),
                              ),
                              Expanded(
                                flex: 1, // Atur flex ke 3 untuk teks
                                child: Center(
                                  child: Text(
                                    'Instructor vs. Pilot',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Atur lebar garis kanan sesuai kebutuhan
                                child: Divider(
                                  color: Colors.red,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),

                          Container(
                            height: 150,
                            child: Stack(
                              children: [
                                PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: controller.instructorCount.value.toDouble(),
                                        color: const Color(0xffF24C3D),
                                        title: controller.instructorCount.value.toString(),
                                        radius: 45,
                                        titleStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white, // Ubah warna teks menjadi putih
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: controller.pilotCount.value.toDouble(),
                                        color: const Color(0xff35A29F),
                                        title: controller.pilotCount.value.toString(),
                                        radius: 45,
                                        titleStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white, // Ubah warna teks menjadi putih
                                        ),
                                      ),
                                    ],
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 30,
                                  ),
                                ),
                                Positioned(
                                  top: 90, // Sesuaikan posisi teks
                                  left: 250,
                                  right: 20,
                                  child: Center(
                                    child: Text('Instructors',
                                      style: TextStyle(
                                        fontSize: 12, // Perbesar angka
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xffF24C3D),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 40, // Sesuaikan posisi teks
                                  left: -190,
                                  right: 0,
                                  child: Center(
                                    child: Text('Pilots',
                                      style: TextStyle(
                                        fontSize: 12, // Perbesar angka
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff35A29F),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      //FILTERS

                      //ABSENT VS ATTENDANCE PIE CHART
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 100, // Atur lebar garis kiri sesuai kebutuhan
                                child: Divider(
                                  color: Colors.red,
                                  thickness: 1,
                                ),
                              ),
                              Expanded(
                                flex: 1, // Atur flex ke 3 untuk teks
                                child: Center(
                                  child: Text(
                                    'Attendance',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Atur lebar garis kanan sesuai kebutuhan
                                child: Divider(
                                  color: Colors.red,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),

                          //FILTER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.filter_list),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadiusDirectional.only(
                                            topEnd: Radius.circular(25),
                                            topStart: Radius.circular(25),
                                          ),
                                        ),
                                        builder: (context) => SingleChildScrollView(
                                          padding: EdgeInsetsDirectional.only(
                                            start: 20,
                                            end: 20,
                                            bottom: 30,
                                            top: 8,
                                          ),
                                          child: Wrap(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: MediaQuery.of(context)
                                                        .viewInsets
                                                        .bottom),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      'Filter',
                                                      style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Date',
                                                          style: tsOneTextTheme.labelLarge,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10),
                                                    Form(
                                                      key: _formKey,
                                                      child: Container(
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 3,
                                                              child: TextFormField(
                                                                controller: fromC,
                                                                obscureText: false,
                                                                readOnly: true,
                                                                validator: (value) {
                                                                  if (value == null ||
                                                                      value.isEmpty) {
                                                                    // Validation Logic
                                                                    return 'Please enter the From Date';
                                                                  }
                                                                  return null;
                                                                },
                                                                decoration: InputDecoration(
                                                                    contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical: 0,
                                                                        horizontal: 10),
                                                                    prefixIcon: const Icon(
                                                                      Icons.calendar_month,
                                                                      color:
                                                                      TsOneColor.primary,
                                                                    ),
                                                                    enabledBorder:
                                                                    const OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color: TsOneColor
                                                                            .primary,
                                                                      ),
                                                                    ),
                                                                    border: const OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: TsOneColor
                                                                                .secondaryContainer)),
                                                                    focusedBorder:
                                                                    const OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color: Colors.green,
                                                                      ),
                                                                    ),
                                                                    labelText: "From Date"),
                                                                onTap: () async {
                                                                  DateTime? pickedDate =
                                                                  await showDatePicker(
                                                                      context: context,
                                                                      initialDate:
                                                                      DateTime.now(),
                                                                      firstDate:
                                                                      DateTime(1945),
                                                                      lastDate:
                                                                      DateTime(2300));
                                                                  if (pickedDate != null) {
                                                                    String formattedDate =
                                                                    DateFormat(
                                                                        'dd-MM-yyyy')
                                                                        .format(
                                                                        pickedDate);
                                                                    fromC.text =
                                                                        formattedDate;
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            Expanded(
                                                                flex: 1,
                                                                child: Icon(Icons
                                                                    .compare_arrows_rounded)),
                                                            Expanded(
                                                              flex: 3,
                                                              child: TextFormField(
                                                                controller: toC,
                                                                obscureText: false,
                                                                readOnly: true,
                                                                validator: (value) {
                                                                  if (value == null ||
                                                                      value.isEmpty) {
                                                                    // Validation Logic
                                                                    return 'Please enter the To Date';
                                                                  }
                                                                  return null;
                                                                },
                                                                decoration: InputDecoration(
                                                                    contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical: 0,
                                                                        horizontal: 10),
                                                                    prefixIcon: const Icon(
                                                                      Icons.calendar_month,
                                                                      color:
                                                                      TsOneColor.primary,
                                                                    ),
                                                                    enabledBorder:
                                                                    const OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color: TsOneColor
                                                                            .primary,
                                                                      ),
                                                                    ),
                                                                    border: const OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: TsOneColor
                                                                                .secondaryContainer)),
                                                                    focusedBorder:
                                                                    const OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color: Colors.green,
                                                                      ),
                                                                    ),
                                                                    labelText: "To Date"),
                                                                onTap: () async {
                                                                  DateTime? pickedDate =
                                                                  await showDatePicker(
                                                                      context: context,
                                                                      initialDate:
                                                                      DateTime.now(),
                                                                      firstDate:
                                                                      DateTime(1945),
                                                                      lastDate:
                                                                      DateTime(2300));
                                                                  if (pickedDate != null) {
                                                                    String formattedDate =
                                                                    DateFormat(
                                                                        'dd-MM-yyyy')
                                                                        .format(
                                                                        pickedDate);
                                                                    toC.text = formattedDate;
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Align(
                                                      alignment: Alignment.bottomCenter,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              fromC.clear();
                                                              toC.clear();
                                                              controller.resetDate();
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal: 40,
                                                                  vertical: 10),
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                    10.0),
                                                                color: Colors.white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.grey
                                                                        .withOpacity(0.3),
                                                                    spreadRadius: 2,
                                                                    blurRadius: 3,
                                                                    offset:
                                                                    const Offset(0, 2),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Text(
                                                                "Reset",
                                                                style: tsOneTextTheme
                                                                    .headlineMedium,
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              DateTime from =
                                                              DateFormat('dd-MM-yyyy')
                                                                  .parse(fromC.text);
                                                              DateTime to =
                                                              DateFormat('dd-MM-yyyy')
                                                                  .parse(toC.text);

                                                              if (_formKey.currentState !=
                                                                  null &&
                                                                  _formKey.currentState!
                                                                      .validate() !=
                                                                      0) {
                                                                if (from.isBefore(to)) {
                                                                  controller.from.value =
                                                                      from;
                                                                  controller.to.value = to;
                                                                  Navigator.of(context).pop();
                                                                } else {}
                                                              }
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal: 40,
                                                                  vertical: 10),
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                    10.0),
                                                                color: TsOneColor.primary,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.grey
                                                                        .withOpacity(0.3),
                                                                    spreadRadius: 2,
                                                                    blurRadius: 3,
                                                                    offset:
                                                                    const Offset(0, 2),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Text(
                                                                "Apply",
                                                                style: tsOneTextTheme
                                                                    .headlineMedium,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ));
                                  }),
                            ],
                          ),

                          Container(
                            height: 150,
                            child: Stack(
                              children: [
                                PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: (controller.absentCount.value / (controller.absentCount.value + controller.presentCount.value)),
                                        color: const Color(0xFF116D6E),
                                        title: '${((controller.absentCount.value / (controller.absentCount.value + controller.presentCount.value))*100).toStringAsFixed(1)}%',
                                        radius: 45,
                                        titleStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: (controller.presentCount.value / (controller.absentCount.value + controller.presentCount.value)),
                                        color: const Color(0xffFFB000),
                                        title: '${((controller.presentCount.value / (controller.absentCount.value + controller.presentCount.value))*100).toStringAsFixed(1)}%',
                                        radius: 45,
                                        titleStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 30,
                                  ),
                                ),

                                Positioned(
                                  top: 120, // Sesuaikan posisi teks
                                  left: 220,
                                  right: 45,
                                  child: Center(
                                    child: Text('Absent',
                                      style: TextStyle(
                                        fontSize: 12, // Perbesar angka
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff116D6E),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10, // Sesuaikan posisi teks
                                  left: -190,
                                  right: -20,
                                  child: Center(
                                    child: Text('Present',
                                      style: TextStyle(
                                        fontSize: 12, // Perbesar angka
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xffff9900),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
