import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../../presentation/shared_components/formdatefield.dart';
import '../../../../../../presentation/shared_components/formtextfield.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/attendance_pendingcc_controller.dart';

class AttendancePendingccView extends GetView<AttendancePendingccController> {
  const AttendancePendingccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var subjectC = TextEditingController();
    var vanueC = TextEditingController();
    var dateC = TextEditingController();
    var instructorC = TextEditingController();

    var departementC = TextEditingController();
    var trainingtypeC = TextEditingController();
    var roomC = TextEditingController();



    return Scaffold(
        appBar: AppBar(
          title: const Text('Back', style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
          // backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: controller
                    .getCombinedAttendanceStream(controller.argument.value),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingScreen(); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return const ErrorScreen();
                  }

                  var listAttendance = snapshot.data!;
                  if (listAttendance.isNotEmpty) {
                    subjectC.text = listAttendance[0]["subject"];
                    dateC.text = listAttendance[0]["date"];
                    vanueC.text = listAttendance[0]["vanue"];
                    instructorC.text = listAttendance[0]["name"];
                  } else {
                    // Handle the case where the list is empty or null
                    subjectC.text = "No Subject Data Available";
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RedTitleText(text: "ATTENDANCE LIST"),
                          PopupMenuButton(
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                  child: TextButton(
                                    onPressed: () {
                                      Get.toNamed(Routes.EDIT_ATTENDANCECC, arguments: {
                                        "id" : controller.argument.value,
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 16),
                                        SizedBox(width: 5,),
                                        Text("Edit",)
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  child: TextButton(
                                    onPressed: () {
                                      controller.deleteAttendance();
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 16),
                                        SizedBox(width: 5,),
                                        Text("Delete",)
                                      ],
                                    ),
                                  ),
                                ),
                              ];
                            },
                            offset: Offset(0, 30),
                            child: GestureDetector(
                              child: Container(
                                child: Icon(Icons.more_vert_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Text("REDUCED VERTICAL SEPARATION MINIMA (RVSM)"),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FormTextField(
                                text: "Subject",
                                textController: subjectC,
                                readOnly: true),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: FormDateField(
                                text: "Date",
                                textController: dateC,
                                readOnly: true),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FormTextField(
                                text: "Vanue",
                                textController: vanueC,
                                readOnly: true),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        child:  Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: TsOneColor.secondaryContainer,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: ListTile(
                            title: Text(
                              "Chair Person/ Instructor",
                              style: tsOneTextTheme.labelSmall,
                            ),
                            subtitle: Text(
                              listAttendance[0]["name"],
                              style: tsOneTextTheme.headlineMedium,
                            ),
                            trailing: Icon(Icons.navigate_next),
                          ),

                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: (){
                          if(controller.jumlah.value > 0 ){
                            Get.toNamed(Routes.LIST_ATTENDANCECC,arguments: {
                              "id" : controller.argument.value,
                              "status" : "done"
                            });
                          }
                         },
                        child:  Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: TsOneColor.secondaryContainer,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: ListTile(
                            title: Text(
                              "Attendance",
                              style: tsOneTextTheme.labelSmall,
                            ),
                            subtitle: Text(
                              "${controller.jumlah.value.toString()} person",
                              style: tsOneTextTheme.headlineMedium,
                            ),
                            trailing: Icon(Icons.navigate_next),
                          ),

                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      const Text("Class Password"),
                      InkWell(
                        onTap: (){
                          showModalBottomSheet(context: context, builder: (context){
                            return SingleChildScrollView(
                              child: Container(
                                width: Get.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                  color: Theme.of(context).cardColor,
                                ),
                                padding: EdgeInsets.only(
                                    top: 20,
                                    left: 20,
                                    right: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      'QR Code',
                                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                    ),
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 30), child: Text(
                                      'Provide training for those taking classes to take attendance',
                                      style: tsOneTextTheme.labelMedium,
                                    ),),
                                    SizedBox(height: 20),
                                    QrImageView(
                                      data: listAttendance[0]["keyAttendance"],
                                      version: QrVersions.auto,
                                      size: 250,
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Scan this QR code',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(Icons.qr_code, size: 25,),
                            title: Text(
                              "Open QR Code",
                              style: tsOneTextTheme.headlineMedium,
                            ),
                            subtitle: RedTitleText(
                              text: listAttendance[0]["keyAttendance"] ?? "N/A",
                              size: 16,
                            ),
                            trailing: const Icon(Icons.navigate_next),
                          ),
                        ),
                      ),

                    ],
                  );
                }),
          ),
        ));
  }

}
