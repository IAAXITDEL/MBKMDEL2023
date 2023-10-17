import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../presentation/theme.dart';
import '../../../../../util/empty_screen.dart';
import '../../../../../util/error_screen.dart';
import '../../../../../util/loading_screen.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/detailhistorycc_cpts_controller.dart';

class DetailhistoryccCptsView extends GetView<DetailhistoryccCptsController> {
  final List<Map<String, dynamic>> listAttendance;

  const DetailhistoryccCptsView({Key? key, required this.listAttendance})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TRAINING DETAIL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                  SizedBox(height: 5,),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: TsOneColor.surface,
                    ),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: controller.getCombinedAttendance(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return LoadingScreen(); // Placeholder while loading
                        }

                        if (snapshot.hasError) {
                          return ErrorScreen();
                        }

                        var listAttendance = snapshot.data!;
                        if (listAttendance.isEmpty) {
                          return EmptyScreen();
                        }

                        return Column(
                          children: [
                            SizedBox(height: 20),
                            //SUBJECT
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text("Subject")),
                                  Expanded(
                                      flex: 1,
                                      child: Text(":")),
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                          listAttendance[0]["subject"] ??
                                              "N/A")),
                                ],
                              ),
                            ),

                            //DEPARTEMENT
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text("Department")),
                                  Expanded(
                                      flex: 1,
                                      child: Text(":")),
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                          listAttendance[0]["department"] ??
                                              "N/A")),
                                ],
                              ),
                            ),

                            //TRAINING TYPE
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text("Training Type")),
                                  Expanded(
                                      flex: 1,
                                      child: Text(":")),
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                          listAttendance[0]["trainingType"] ??
                                              "N/A")),
                                ],
                              ),
                            ),

                            //DATE
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text("Date")),
                                  Expanded(
                                      flex: 1,
                                      child: Text(":")),
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                          listAttendance[0]["date"] ?? "N/A")),
                                ],
                              ),
                            ),

                            //VANUE
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text("Vanue")),
                                  Expanded(
                                      flex: 1,
                                      child: Text(":")),
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                          listAttendance[0]["vanue"] ?? "N/A")),
                                ],
                              ),
                            ),

                            //ROOM
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text("Room")),
                                  Expanded(
                                      flex: 1,
                                      child: Text(":")),
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                          listAttendance[0]["room"] ?? "N/A")),
                                ],
                              ),
                            ),

                            //INSTRUCTOR
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text("Instructor")),
                                  Expanded(
                                      flex: 1,
                                      child: Text(":")),
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                          listAttendance[0]["name"] ?? "N/A")),
                                ],
                              ),
                            ),


                          ],
                        );
                      },
                    ),
                  ),
                SizedBox(height: 20,),
                InkWell(
                  onTap: () {
                    if (controller.jumlah.value > 0) {
                      print(controller.jumlah.value);
                      Get.toNamed(Routes.LIST_ATTENDANCECC, arguments: {
                        "id": controller.idAttendance.value,
                        "status": "donescoring"
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: TsOneColor.secondaryContainer,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        "Attendance",
                        style: tsOneTextTheme.labelSmall,
                      ),
                      subtitle: Obx((){
                        return Text(
                          "${controller.jumlah.value.toString()} person",
                          style: tsOneTextTheme.headlineMedium,
                        );
                      }),
                      trailing: Icon(Icons.navigate_next),
                    ),
                  ),
                ),

                SizedBox(height: 20,),
                InkWell(
                  onTap: () {
                    if (controller.jumlah.value > 0) {
                      print(controller.jumlah.value);
                      Get.toNamed(Routes.LIST_ABSENTCPTSCC, arguments: {
                        /*"id": controller.idAttendance.value,
                        "status": "donescoring"*/
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: TsOneColor.secondaryContainer,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        "Absent",
                        style: tsOneTextTheme.labelSmall,
                      ),
                      subtitle: Obx((){
                        return Text(
                          "${controller.jumlah.value.toString()} person",
                          style: tsOneTextTheme.headlineMedium,
                        );
                      }),
                      trailing: Icon(Icons.navigate_next),
                    ),
                  ),
                ),

                ]
            ),
          ),
        ),
      ),
      );
  }
}