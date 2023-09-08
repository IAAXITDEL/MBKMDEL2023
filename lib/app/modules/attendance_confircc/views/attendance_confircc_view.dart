import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/shared_components/formtextfield.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../controllers/attendance_confircc_controller.dart';

class AttendanceConfirccView extends GetView<AttendanceConfirccController> {
  final String id = (Get.arguments as Map<String, dynamic>)["id"];
  AttendanceConfirccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
  controller.argument.value = id;
  print("Test ${controller.argument.value}");

    var subjectC = TextEditingController();
    var vanueC = TextEditingController();
    var dateC = TextEditingController();


    return Scaffold(
        appBar: AppBar(
          title: Text('Back', style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: controller.getCombinedAttendanceStream(
                    controller.argument.value
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen(); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return ErrorScreen();
                  }

                  var listAttendance = snapshot.data!;
                  print(listAttendance);
                  if (listAttendance != null && listAttendance.isNotEmpty) {
                    subjectC.text = listAttendance[0]["subject"];
                    vanueC.text = listAttendance[0]["vanue"];// Accessing "Subject" from the first map in the list
                  } else {
                    // Handle the case where the list is empty or null
                    subjectC.text = "No Subject Data Available";
                  }
                  return Column(
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
                            child: FormTextField(
                                text: "Subject",
                                textController: subjectC,
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
                                text: "Subject",
                                textController: subjectC,
                                readOnly: true),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: FormTextField(
                                text: "Subject",
                                textController: subjectC,
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
                                text: "Subject",
                                textController: subjectC,
                                readOnly: true),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: FormTextField(
                                text: "Subject",
                                textController: subjectC,
                                readOnly: true),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FormTextField(
                          text: "Subject",
                          textController: subjectC,
                          readOnly: true),
                      SizedBox(
                        height: 20,
                      ),
                      FormTextField(
                          text: "Subject",
                          textController: subjectC,
                          readOnly: true),
                    ],
                  );
                }),
          ),
        ));
  }
}
