import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../../presentation/theme.dart';
import '../../../../util/empty_screen.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../routes/app_pages.dart';
import '../controllers/list_attendancedetailcc_controller.dart';


class ListAttendancedetailccView
    extends GetView<ListAttendancedetailccController> {
  ListAttendancedetailccView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var scoreC = TextEditingController();
    var feedbackC = TextEditingController();
    List<String> list = <String>['SUCCESS', 'FAIL'];
    final RxString dropdownValue = RxString(list.first);


    Future<void> updateScoring(String score, String feedback) async {
      controller.updateScoring(score, feedback).then((status) async {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Add Attendance Completed Successfully!',
        );

        Get.back();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Back'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: controller.profileList(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingScreen(); // Placeholder while loading
                      }

                      if (snapshot.hasError) {
                        return ErrorScreen();
                      }


                      var listAttendance = snapshot.data!;
                      if(listAttendance.isEmpty){
                        return EmptyScreen();
                      }
                      var documentData = listAttendance[0];
                      controller.idattendancedetail.value = documentData["id"];
                      return Container(
                        child: Column(
                          children: [
                            AvatarGlow(
                              endRadius: 110,
                              glowColor: Colors.black,
                              duration: Duration(seconds: 2),
                              child: Container(
                                  width: 175,
                                  height: 175,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: documentData["photoURL"] == null ?  Image.asset(
                                      "assets/images/placeholder_person.png",
                                      fit: BoxFit.cover,
                                    ) : Image.network("${documentData["photoURL"]}", fit: BoxFit.cover),)),
                            ),
                            SizedBox(height: 10,),

                            controller.argumentstatus.value == "pending" ?
                            SizedBox() : Row(
                              children: [
                                Expanded(flex: 3, child: Text("SCORE")),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(flex: 6, child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "Pass",
                                        style: TextStyle(fontSize: 10, color: Colors.green),
                                      ),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(flex: 3, child: Text("NAME")),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                    flex: 6, child: Text(documentData["name"] ?? "N/A")),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(flex: 3, child: Text("EMAIL")),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                    flex: 6, child: Text(documentData["email"] ?? "N/A")),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(flex: 3, child: Text("RANK")),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(flex: 6, child: Text(documentData["rank"] ?? "N/A")),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(flex: 3, child: Text("LICENSE NO")),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                    flex: 6, child: Text( documentData["license"] ?? "N/A")),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            controller.argumentstatus.value == "pending" ?
                            Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(flex: 3, child: Text("SCORE")),
                                        Expanded(flex: 1, child: Text(":")),
                                        Expanded(flex: 6, child: Row(
                                          children: [
                                            Obx(() => Container(
                                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.4),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: DropdownButton<String>(
                                                value: dropdownValue.value,
                                                onChanged: (String? newValue) {
                                                  // Update the dropdown value when a new value is selected
                                                  dropdownValue.value = newValue!;
                                                  scoreC.text = dropdownValue.value;
                                                },
                                                items: list.map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                              ),
                                            ))
                                            ,
                                          ],
                                        ))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(flex: 3, child: Text("FEEDBACK")),
                                        Expanded(flex: 1, child: Text(":")),
                                        Expanded(flex: 6, child: Row(
                                          children: [

                                          ],
                                        ))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: tsOneColorScheme.secondaryContainer),
                                          borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: TextFormField(
                                        controller: feedbackC,
                                        maxLines: 4,
                                        keyboardType: TextInputType.multiline,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {   // Validation Logic
                                            return 'Please review the legal agreement and check this box to proceed';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration.collapsed(hintText: "Enter your text here"),
                                      ),
                                    ),

                                    Obx(() => CheckboxListTile(
                                      title: Text("I agree with all of the results", style: tsOneTextTheme.labelSmall,),
                                      value: controller.checkAgree.value,
                                      onChanged: (newValue) {
                                        controller.checkAgree.value = newValue!;
                                      },
                                      controlAffinity: ListTileControlAffinity.leading,
                                    )),

                                    Obx(() {
                                      return controller.showText.value
                                          ? Container(
                                        padding: EdgeInsets.symmetric(horizontal: 5),
                                        child:  Text("Please review the legal agreement and check this box to proceed", style: TextStyle(color: Colors.red)),
                                      )
                                          : SizedBox();
                                    }),

                                    //-------------------------SUBMIT-----------------------
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if(controller.checkAgree.value == false){
                                            controller.showText.value = true;
                                            controller.update();
                                          }
                                          if (_formKey.currentState != null && _formKey.currentState!.validate() && controller.checkAgree.value == true) {
                                            showDialog(context: context,
                                                builder: (BuildContext context){
                                                  return FutureBuilder<void>(
                                                    future: updateScoring(dropdownValue.value, feedbackC.text),
                                                    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return LoadingScreen(); // Show loading screen
                                                      }

                                                      if (snapshot.hasError) {
                                                        // Handle error if needed
                                                        return ErrorScreen();
                                                      } else {
                                                        return Container();
                                                      }
                                                    },
                                                  );
                                                }
                                            );
                                          }

                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: TsOneColor.greenColor,
                                          minimumSize: Size(double.infinity, 50),
                                        ),
                                        child:  Text('Submit', style: TextStyle(color: Colors.white),),
                                      ),
                                    )

                                  ],
                                ),
                            )
                             : SizedBox()
                          ],
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      )
    );
  }
}