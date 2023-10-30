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

class HomeCptsccView extends GetView<HomeCptsccController> {
  const HomeCptsccView({Key? key}) : super(key: key);

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
    return Scaffold(
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STATS',
                      style: tsOneTextTheme.displayMedium,
                    ),

                    // DOWNLOAD EXCEL
                    TextButton(
                      onPressed: () async {
                        var dir = await getApplicationDocumentsDirectory();
                        var file = File('${dir.path}/stats_data.xlsx');

                        // Check if the Excel file already exists
                        if (!await file.exists()) {
                          // Create an Excel workbook
                          final excel = Excel.createExcel();
                          final sheet = excel['Sheet1'];

                          // Define column titles and cell styles
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value = 'Category';
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value = 'Count';

                          final titleCellStyle = CellStyle(
                            backgroundColorHex: '#FFFF00', // Yellow background color
                            horizontalAlign: HorizontalAlign.Center,
                            verticalAlign: VerticalAlign.Center,
                          );

                          // Set cell style for column titles
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).cellStyle = titleCellStyle;
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).cellStyle = titleCellStyle;

                          // Merge and center cells for the "Acknowledgment & Return Process" title
                          sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0));
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = titleCellStyle;
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Acknowledgment & Return Process';

                          // Gather your data
                          List<List<dynamic>> data = [
                            ['Category', 'Count'],
                            ['Trainings', controller.trainingCount.value],
                            ['Instructors', controller.instructorCount.value],
                            ['Pilots', controller.pilotCount.value],
                            ['Ongoing Trainings', controller.ongoingTrainingCount.value],
                            ['Completed Trainings', controller.completedTrainingCount.value],
                            ['Trainees', controller.traineeCount.value],
                          ];

                          // Add data to the sheet
                          for (final row in data) {
                            sheet.appendRow(row);
                          }

                          // Save the Excel file
                          await file.writeAsBytes(excel.encode() ?? Uint8List(0));
                        }

                        // Delay for 2 seconds (adjust as needed)
                        await Future.delayed(Duration(seconds: 2));

                        // Open the saved Excel file
                        OpenFile.open(file.path);
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.black,
                        backgroundColor: Colors.green,
                        minimumSize: Size(0, 30),
                        padding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                      child: Text(
                        'Download',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ),

                Column(
                  children: [
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

                    SizedBox(height: 25),

                    //PIE CHART
                    Column(
                      children: [
                        Text(
                          'Instructor vs. Pilot',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: 15),

                        Container(
                          height: 150,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      value: controller.instructorCount.value.toDouble(),
                                      color: const Color(0xff3366cc),
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
                                      color: const Color(0xffff9900),
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
                                      color: const Color(0xff3366cc),
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
    );
  }
}
