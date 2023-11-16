import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ts_one/app/modules/cc/home_cptscc/controllers/home_cptscc_controller.dart';
import 'package:ts_one/util/empty_screen.dart';
import '../../../../../presentation/theme.dart';
import '../../../../../util/error_screen.dart';
import '../../../../../util/loading_screen.dart';
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

  List<String> subjectTrainingOptions = [
    'ALL',
    'SEP',
    'BASIC INDOC',
    'RGT',
    ' RVSM',
    'D'
  ];

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
                        thickness: 3, // Thickness of the line
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //SUBJECT TRAININGS
                         Expanded(child:  Card(
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10),
                             side: BorderSide(color: TsOneColor.secondary, width: 1),
                           ),
                           color: TsOneColor.surface,
                           surfaceTintColor: Colors.white,
                           shadowColor: Colors.white,
                           elevation: 5,
                           child: InkWell(
                             onTap: () {},
                             splashColor: TsOneColor.primary,
                             child: Center(
                               child: Container(
                                 padding: const EdgeInsets.symmetric(
                                     vertical: 10, horizontal: 10),
                                 child: Column(
                                   children: [
                                     Image.asset(
                                       "assets/images/trainings_logo.png",
                                       fit: BoxFit.fitWidth,
                                     ),
                                     Obx(() => Text('${controller.trainingCount.value}', style: tsOneTextTheme.headlineMedium,),),
                                     Text( 'Trainings\n', style: TextStyle(color: TsOneColor.redColor),)
                                   ],
                                 ),
                               ),
                             ),
                           ),
                         )),

                          //ONGOING TRAININGS
                          Expanded(child:  Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: TsOneColor.secondary, width: 1),
                            ),
                            color: TsOneColor.surface,
                            surfaceTintColor: Colors.white,
                            shadowColor: Colors.white,
                            elevation: 5,
                            child: InkWell(
                              onTap: () {},
                              splashColor: TsOneColor.primary,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "assets/images/on_going_training_logo.png",
                                        fit: BoxFit.fitWidth,
                                      ),
                                      Obx(() => Text('${controller.ongoingTrainingCount.value}', style: tsOneTextTheme.headlineMedium,),),
                                      Text( 'Ongoing Trainings', style: TextStyle(color: TsOneColor.redColor), textAlign: TextAlign.center,)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),

                          //COMPLETED TRAININGS
                          Expanded(child:  Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: TsOneColor.secondary, width: 1),
                            ),
                            color: TsOneColor.surface,
                            surfaceTintColor: Colors.white,
                            shadowColor: Colors.white,
                            elevation: 5,
                            child: InkWell(
                              onTap: () {},
                              splashColor: TsOneColor.primary,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "assets/images/completed_training_logo.png",
                                        fit: BoxFit.fitWidth,
                                      ),
                                     Obx(() =>  Text('${controller.completedTrainingCount.value}', style: tsOneTextTheme.headlineMedium,),),
                                      Text( 'Completed Trainings', style: TextStyle(color: TsOneColor.redColor), textAlign: TextAlign.center,)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),

                      SizedBox(height: 40),

                      //PILOTS VS INSTRUCTORS PIE CHART

                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width:
                                    80, // Atur lebar garis kiri sesuai kebutuhan
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
                                width:
                                    80, // Atur lebar garis kanan sesuai kebutuhan
                                child: Divider(
                                  color: Colors.red,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                         Obx((){
                           return  Container(
                             height: 150,
                             child: Stack(
                               children: [
                                 PieChart(
                                   PieChartData(
                                     sections: [
                                       PieChartSectionData(
                                         value: controller.instructorCount.value
                                             .toDouble(),
                                         color: const Color(0xffF24C3D),
                                         title: controller.instructorCount.value
                                             .toString(),
                                         radius: 45,
                                         titleStyle: TextStyle(
                                           fontSize: 16,
                                           fontWeight: FontWeight.bold,
                                           color: Colors
                                               .white, // Ubah warna teks menjadi putih
                                         ),
                                       ),
                                       PieChartSectionData(
                                         value: controller.pilotCount.value
                                             .toDouble(),
                                         color: const Color(0xff35A29F),
                                         title: controller.pilotCount.value
                                             .toString(),
                                         radius: 45,
                                         titleStyle: TextStyle(
                                           fontSize: 16,
                                           fontWeight: FontWeight.bold,
                                           color: Colors
                                               .white, // Ubah warna teks menjadi putih
                                         ),
                                       ),
                                     ],
                                     sectionsSpace: 3,
                                     centerSpaceRadius: 30,
                                   ),
                                 ),

                                 //DESCRIPTION
                                 Positioned(
                                   top: 102,
                                   left: 0,
                                   right: -300,
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         'Desc:',
                                         style: TextStyle(
                                           fontSize: 12,
                                           fontWeight: FontWeight.bold,
                                           color: Colors.black,
                                         ),
                                       ),
                                       Row(
                                         children: [
                                           Container(
                                             width: 10,
                                             height: 10,
                                             decoration: BoxDecoration(
                                               color: const Color(0xffF24C3D),
                                               shape: BoxShape.rectangle,
                                             ),
                                           ),
                                           SizedBox(width: 5),
                                           Text(
                                             'Instructors',
                                             style: TextStyle(
                                               fontSize: 12,
                                               fontWeight: FontWeight.bold,
                                               color: const Color(0xffF24C3D),
                                             ),
                                           ),
                                         ],
                                       ),
                                       Row(
                                         children: [
                                           Container(
                                             width: 10,
                                             height: 10,
                                             decoration: BoxDecoration(
                                               color: const Color(0xff35A29F),
                                               shape: BoxShape.rectangle,
                                             ),
                                           ),
                                           SizedBox(width: 5),
                                           Text(
                                             'Pilots',
                                             style: TextStyle(
                                               fontSize: 12,
                                               fontWeight: FontWeight.bold,
                                               color: const Color(0xff35A29F),
                                             ),
                                           ),
                                         ],
                                       ),
                                     ],
                                   ),
                                 ),
                               ],
                             ),
                           );
                         }),
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
                                width:
                                    100, // Atur lebar garis kiri sesuai kebutuhan
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
                                width:
                                    100, // Atur lebar garis kanan sesuai kebutuhan
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
                                      borderRadius:
                                          BorderRadiusDirectional.only(
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
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold, color: Colors.red),
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Please pick date range',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
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
                                                            // validator: (value) {
                                                            //   if (value ==
                                                            //           null ||
                                                            //       value
                                                            //           .isEmpty) {
                                                            //     // Validation Logic
                                                            //     return 'Please enter the From Date';
                                                            //   }
                                                            //   return null;
                                                            // },
                                                            decoration:
                                                                InputDecoration(
                                                                    contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                        vertical:
                                                                            0,
                                                                        horizontal:
                                                                            10),
                                                                    prefixIcon:
                                                                        const Icon(
                                                                      Icons
                                                                          .calendar_month,
                                                                      color: TsOneColor
                                                                          .primary,
                                                                    ),
                                                                    enabledBorder:
                                                                        const OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
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
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                    labelText:
                                                                        "From Date"),
                                                            onTap: () async {
                                                              DateTime? pickedDate = await showDatePicker(
                                                                  context:
                                                                      context,
                                                                  initialDate:
                                                                      DateTime
                                                                          .now(),
                                                                  firstDate:
                                                                      DateTime(
                                                                          1945),
                                                                  lastDate:
                                                                      DateTime(
                                                                          2300));
                                                              if (pickedDate !=
                                                                  null) {
                                                                String
                                                                    formattedDate =
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
                                                            // validator: (value) {
                                                            //   if (value ==
                                                            //           null ||
                                                            //       value
                                                            //           .isEmpty) {
                                                            //     // Validation Logic
                                                            //     return 'Please enter the To Date';
                                                            //   }
                                                            //   return null;
                                                            // },
                                                            decoration:
                                                                InputDecoration(
                                                                    contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                        vertical:
                                                                            0,
                                                                        horizontal:
                                                                            10),
                                                                    prefixIcon:
                                                                        const Icon(
                                                                      Icons
                                                                          .calendar_month,
                                                                      color: TsOneColor
                                                                          .primary,
                                                                    ),
                                                                    enabledBorder:
                                                                        const OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
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
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                    labelText:
                                                                        "To Date"),
                                                            onTap: () async {
                                                              DateTime? pickedDate = await showDatePicker(
                                                                  context:
                                                                      context,
                                                                  initialDate:
                                                                      DateTime
                                                                          .now(),
                                                                  firstDate:
                                                                      DateTime(
                                                                          1945),
                                                                  lastDate:
                                                                      DateTime(
                                                                          2300));
                                                              if (pickedDate !=
                                                                  null) {
                                                                String
                                                                    formattedDate =
                                                                    DateFormat(
                                                                            'dd-MM-yyyy')
                                                                        .format(
                                                                            pickedDate);
                                                                toC.text =
                                                                    formattedDate;
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                // Adding the filter dropdown inside the pop-up
                                                SizedBox(height: 40),

                                                //DROPDOWN
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Please choose the training subject',
                                                      // style: tsOneTextTheme
                                                      //     .labelLarge,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                //OLD
                                                // Padding(
                                                //   padding: const EdgeInsets.all(3.0),
                                                //   child: InputDecorator(
                                                //     decoration: InputDecoration(
                                                //       // labelText: 'TRAINING SUBJECT',
                                                //       border: const OutlineInputBorder(
                                                //         borderSide: BorderSide(color: TsOneColor.greenColor),
                                                //       ),
                                                //       contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                //       labelStyle: const TextStyle(fontSize: 12, color: Colors.black),
                                                //     ),
                                                //     child: FutureBuilder<List<String>>(
                                                //       future: controller.getTrainingSubjects(),
                                                //       builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                                                //         if (snapshot.connectionState == ConnectionState.waiting) {
                                                //           return CircularProgressIndicator(); // Show a loading indicator while fetching data
                                                //         }
                                                //
                                                //         if (snapshot.hasError) {
                                                //           return Text('Error: ${snapshot.error}');
                                                //         }
                                                //
                                                //         List<String> subjects = snapshot.data ?? [];
                                                //
                                                //         return DropdownButton<String>(
                                                //           value: controller.selectedSubject(),
                                                //           value: controller.getTrainingSubjects(),
                                                //           icon: const Icon(Icons.arrow_drop_down, size: 24),
                                                //           iconSize: 24,
                                                //           items: subjects.map((String subject) {
                                                //             return DropdownMenuItem<String>(
                                                //               value: subject,
                                                //               child: Text(subject),
                                                //             );
                                                //           }).toList(),
                                                //           onChanged: (String? newValue) {
                                                //             // setState(() {
                                                //             //   selectedSubject = newValue ?? 'ALL';
                                                //             // });
                                                //             controller.training.value = newValue!;
                                                //           },
                                                //         );
                                                //       },
                                                //     ),
                                                //   ),
                                                // ),

                                                Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: InputDecorator(
                                                    decoration: InputDecoration(
                                                      // labelText: 'TRAINING SUBJECT',
                                                      border: const OutlineInputBorder(
                                                        borderSide: BorderSide(color: TsOneColor.greenColor),
                                                      ),
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                      labelStyle: const TextStyle(fontSize: 12, color: Colors.black),
                                                    ),
                                                    child: FutureBuilder<List<String>>(
                                                      future: controller.getTrainingSubjects(),
                                                      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                          return CircularProgressIndicator(); // Show a loading indicator while fetching data
                                                        }

                                                        if (snapshot.hasError) {
                                                          return Text('Error: ${snapshot.error}');
                                                        }

                                                        List<String> subjects = snapshot.data ?? [];

                                                        return DropdownButton<String>(
                                                          value: controller.selectedSubject.value,
                                                          icon: const Icon(Icons.arrow_drop_down, size: 24),
                                                          iconSize: 24,
                                                          items: subjects.map((String subject) {
                                                            return DropdownMenuItem<String>(
                                                              value: subject,
                                                              child: Text(subject),
                                                            );
                                                          }).toList(),
                                                          onChanged: (String? newValue) {
                                                            controller.updateSelectedSubject(newValue ?? 'ALL');
                                                            controller.training.value = newValue!;
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(height: 20),

                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          controller
                                                              .resetDate();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      40,
                                                                  vertical: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors.white,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.3),
                                                                spreadRadius: 2,
                                                                blurRadius: 3,
                                                                offset:
                                                                    const Offset(
                                                                        0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Text(
                                                            "Reset",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          if (_formKey.currentState !=
                                                                  null &&
                                                              _formKey.currentState!
                                                                      .validate() !=
                                                                  0) {
                                                            if (fromC.text
                                                                    .isNotEmpty &&
                                                                toC.text
                                                                    .isNotEmpty) {
                                                              print(fromC.text);
                                                              DateTime from =
                                                                  DateFormat(
                                                                          'dd-MM-yyyy')
                                                                      .parse(fromC
                                                                          .text);
                                                              DateTime to =
                                                                  DateFormat(
                                                                          'dd-MM-yyyy')
                                                                      .parse(toC
                                                                          .text);
                                                              if (from.isBefore(
                                                                  to)) {
                                                                controller.from
                                                                        .value =
                                                                    from;
                                                                controller.to
                                                                    .value = to;
                                                              } else {}
                                                            }

                                                            print(
                                                                "training Type ${controller.training.value}");
                                                            print(
                                                                "from Type ${controller.from.value}");
                                                            print(
                                                                "to Type ${controller.to.value}");
                                                            controller.fetchAttendanceData(
                                                                trainingType:
                                                                    controller
                                                                        .training
                                                                        .value,
                                                                from: controller
                                                                    .from.value,
                                                                to: controller
                                                                    .to.value);
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      40,
                                                                  vertical: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: TsOneColor
                                                                .primary,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.3),
                                                                spreadRadius: 2,
                                                                blurRadius: 3,
                                                                offset:
                                                                    const Offset(
                                                                        0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Text(
                                                            "Apply",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          Center(
                            child:Obx((){
                              return  FutureBuilder<void>(
                                future: controller.fetchAttendanceData(
                                  trainingType: controller.training.value,
                                  from: controller.from.value,
                                  to: controller.to.value,
                                ),
                                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return LoadingScreen();
                                  }

                                  if (snapshot.hasError) {
                                    return ErrorScreen();
                                  }

                                  print("cek");
                                  print(controller.presentCount.value);
                                  print(controller.absentCount.value);
                                  if(controller.presentCount.value == 0 && controller.absentCount.value == 0){
                                    return EmptyScreen();
                                  }

                                  // Check if the data has been fetched and processed
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    return Container(
                                      height: 180,
                                      child: Stack(
                                        children: [
                                          PieChart(
                                            PieChartData(
                                              sections: [
                                                PieChartSectionData(
                                                  value: (controller
                                                      .absentCount.value /
                                                      (controller
                                                          .absentCount.value +
                                                          controller.presentCount
                                                              .value)),
                                                  color: const Color(0xFF116D6E),
                                                  title:
                                                  '${((controller.absentCount.value * 100 / (controller.absentCount.value + controller.presentCount.value))).toStringAsFixed(1)}%',
                                                  radius: 45,
                                                  titleStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                PieChartSectionData(
                                                  value: (controller
                                                      .presentCount.value /
                                                      (controller
                                                          .absentCount.value +
                                                          controller.presentCount
                                                              .value)),
                                                  color: const Color(0xffFFB000),
                                                  title:
                                                  '${((controller.presentCount.value * 100 / (controller.absentCount.value + controller.presentCount.value))).toStringAsFixed(1)}%',
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

                                          //DESCRIPTION
                                          Positioned(
                                            top: 110,
                                            left: 0,
                                            right: -300,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Desc:',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xff116D6E),
                                                        shape: BoxShape.rectangle,
                                                      ),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'Absent',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xff116D6E),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xffff9900),
                                                        shape: BoxShape.rectangle,
                                                      ),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'Present',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xffff9900),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return EmptyScreenAttendanceData();
                                },
                              );
                            })
                            ,
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
