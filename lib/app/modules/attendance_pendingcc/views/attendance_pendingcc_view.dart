import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/shared_components/formdatefield.dart';
import '../../../../presentation/shared_components/formtextfield.dart';
import '../../../../presentation/theme.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../routes/app_pages.dart';
import '../controllers/attendance_pendingcc_controller.dart';

class AttendancePendingccView extends GetView<AttendancePendingccController> {
  const AttendancePendingccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var subjectC = TextEditingController();
    var vanueC = TextEditingController();
    var dateC = TextEditingController();
    var instructorC = TextEditingController();

    var departmentC = TextEditingController();
    var trainingtypeC = TextEditingController();
    var roomC = TextEditingController();



    return Scaffold(
        appBar: AppBar(
          title: Text('Back', style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(color: Colors.black),
          // backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: controller
                    .getCombinedAttendanceStream(controller.argument.value),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen(); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return ErrorScreen();
                  }

                  var listAttendance = snapshot.data!;
                  if (listAttendance != null && listAttendance.isNotEmpty) {
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
                      RedTitleText(text: "ATTENDANCE LIST"),
                      Text("REDUCED VERTICAL SEPARATION MINIMA (RVSM)"),
                      SizedBox(
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
                          SizedBox(
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
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FormTextField(
                              text: "Department",
                              textController: departmentC,),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: FormTextField(
                                text: "Vanue",
                                textController: vanueC,
                                readOnly: true),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FormTextField(
                                text: "Training Type",
                                textController: trainingtypeC),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: FormTextField(
                              text: "Room",
                              textController: roomC,),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: (){Get.toNamed(Routes.LIST_ATTENDANCECC,arguments: {
                          "id" : controller.argument.value,
                        });},
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
                        onTap: (){Get.toNamed(Routes.LIST_ATTENDANCECC,arguments: {
                          "id" : controller.argument.value,
                        });},
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
                      Text("Class Password"),
                      RedTitleText(
                        text: listAttendance[0]["keyAttendance"],
                        size: 16,
                      ),

                    ],
                  );
                }),
          ),
        ));
  }

}
