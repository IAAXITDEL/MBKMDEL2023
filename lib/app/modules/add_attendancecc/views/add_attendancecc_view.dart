import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';
import 'package:ts_one/presentation/theme.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/shared_components/customdialogbox.dart';
import '../../../../presentation/shared_components/formdatefield.dart';
import '../../../../presentation/shared_components/formtextfield.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../routes/app_pages.dart';
import '../controllers/add_attendancecc_controller.dart';

import 'package:dropdown_search/dropdown_search.dart';

class AddAttendanceccView extends GetView<AddAttendanceccController> {
  AddAttendanceccView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  String selectedUser = "0";
  @override
  Widget build(BuildContext context) {
    var subjectC = TextEditingController();
    var vanueC = TextEditingController();
    var dateC = TextEditingController();

    subjectC.text = controller.argumentname.value;
    int? instructorC = 0;

    Future<void> add(String subject, String date, String vanue, int instructor, int idtrainingtype) async {
      controller.addAttendanceForm(subject, date, vanue, instructor, idtrainingtype).then((status) async {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Add Attendance Completed Successfully!',
        );

        Get.offAllNamed(Routes.TRAININGTYPECC, arguments: {
          "id" : controller.argumentid.value,
          "name" : controller.argumentname.value
        });
      });
    }


    return Scaffold(
        appBar: AppBar(
          title: Text('Back', style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RedTitleText(text: "ADD ATTENDANCE"),
                  Text("REDUCED VERTICAL SEPARATION MINIMA (RVSM)"),

                  SizedBox(height: 20,),

                  //-------------------------SUBJECT-----------------------
                  FormTextField(text: "Subject", textController: subjectC, readOnly: true,),
                  SizedBox(height: 10,),

                  //--------------------------DATE--------------------------
                  FormDateField(text: 'Date', textController: dateC,),
                  SizedBox(height: 10,),

                  //-------------------------VANUE-----------------------
                  FormTextField(text: "Vanue", textController: vanueC),
                  SizedBox(height: 10,),

                  //-------------------------INSTRUCTOR-----------------------
                  // StreamBuilder<QuerySnapshot>(
                  //   stream: controller.instructorStream(),
                  //   builder: (context,snapshot){
                  //     List<DropdownMenuItem> usersItem = [];
                  //     if(!snapshot.hasData)
                  //       {
                  //          LoadingScreen();
                  //       }else{
                  //         final users = snapshot.data?.docs.reversed.toList();
                  //         usersItem.add(DropdownMenuItem(
                  //             value: "0",
                  //             child: Text('INSTRUCTOR')));
                  //
                  //
                  //
                  //         for(var user in users!){
                  //           usersItem.add(
                  //             DropdownMenuItem(
                  //                 value: user.id,
                  //                 child: Text(user["NAME"]))
                  //           );
                  //         }
                  //     }
                  //     // return DropdownButton(items: usersItem, onChanged: (userValue){
                  //     //   print(userValue);
                  //     //   selectedUser = userValue;
                  //     // },
                  //     //   value: selectedUser,
                  //     // isExpanded: false,
                  //     // );
                  //
                  //     return DropdownSearch<String>(
                  //       mode: Mode.MENU,
                  //       showSelectedItems: true,
                  //       dropdownSearchDecoration: InputDecoration(
                  //         labelText: "INSTRUCTOR",
                  //       ),
                  //       showSearchBox: true,
                  //       searchFieldProps: TextFieldProps(
                  //         cursorColor: TsOneColor.primary
                  //       ),
                  //     );
                  //
                  //   },
                  // ),

                  StreamBuilder<QuerySnapshot>(
                    stream: controller.instructorStream(),
                    builder: (context, snapshot) {
                      List<String> userNames = []; // Default value

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final users = snapshot.data?.docs.reversed.toList() ?? [];

                      userNames.addAll(users.map((user) => user['NAME'] as String));

                      int selectedUserId = 0; // Default selected user ID

                      return DropdownSearch<String>(

                        mode: Mode.MENU,
                        showSelectedItems: true,
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "INSTRUCTOR",
                        ),
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          cursorColor: TsOneColor.primary,
                        ),
                        items: userNames,
                        onChanged: (selectedName) {
                          // Find the corresponding user ID based on the selected name
                          final selectedUser = users.firstWhere(
                                  (user) => user['NAME'] == selectedName
                          );

                          if (selectedUser != null) {
                            final selectedUserIdValue = selectedUser['ID NO'] as int; // Cast as int
                            selectedUserId = selectedUserIdValue; // Convert to string
                          } else {
                            // Handle the case where selectedUser is null
                            selectedUserId = 0; // or some other appropriate value
                          }

                          instructorC = selectedUserId;
                          // Handle user selection here, including the selectedUserId
                          print('Selected name: $selectedName, Selected ID: $selectedUserId');
                        },
                      );
                    },
                  ),
                  SizedBox(height: 30,),

                  //-------------------------SUBMIT-----------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {

                        if (_formKey.currentState != null && _formKey.currentState!.validate() && instructorC != 0) {
                          showDialog(context: context,
                              builder: (BuildContext context){
                                return FutureBuilder<void>(
                                  future: add(
                                    subjectC.text,
                                    dateC.text,
                                    vanueC.text,
                                    instructorC!,
                                    controller.argumentid.value,
                                  ),
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
            ),
          ),
        )
    );
  }
}