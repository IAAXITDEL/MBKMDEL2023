import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:ts_one/presentation/theme.dart';

import '../../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../../presentation/shared_components/formdatefield.dart';
import '../../../../../../presentation/shared_components/formtextfield.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/add_attendancecc_controller.dart';

import 'package:dropdown_search/dropdown_search.dart';

class AddAttendanceccView extends GetView<AddAttendanceccController> {
  AddAttendanceccView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  String selectedUser = "0";
  @override
  Widget build(BuildContext context) {
    var subjectC = TextEditingController();
    var venueC = TextEditingController();
    var dateC = TextEditingController();

    var departmentC = TextEditingController();
    var trainingTypeC = TextEditingController();
    var roomC = TextEditingController();

    subjectC.text = controller.argumentname.value;
    int? instructorC = 0;

    Future<void> add(String subject, DateTime date, String trainingType,String department,String room, String venue, int instructor, int idtrainingtype) async {
      controller.addAttendanceForm(subject, date, trainingType,department, room, venue, instructor, idtrainingtype).then((status) async {
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
          title: RedTitleText(text: "ADD ATTENDANCE"),
          centerTitle: true,
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
                  // RedTitleText(text: controller.argumentname.value),
                  //Text("REDUCED VERTICAL SEPARATION MINIMA (RVSM)"),

                  SizedBox(height: 20,),

                  //-------------------------SUBJECT-----------------------
                  FormTextField(text: "Subject", textController: subjectC, readOnly: true,),
                  SizedBox(height: 10,),

                  //--------------------------DATE--------------------------
                  FormDateField(text: 'Date', textController: dateC,),
                  SizedBox(height: 10,),

                  //-------------------------TRAINING TYPE-----------------------
                  DropdownSearch<String>(
                    mode: Mode.MENU,
                    items: ['Initial', 'Recurrent'],
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Training Type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    onChanged: (String? newValue) {
                      trainingTypeC.text = newValue!;
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please choose a training type';
                      }
                      return null;
                    },
                    popupItemBuilder: (BuildContext context, String item, bool isSelected) {
                      return Padding(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          title: Text(item),
                          tileColor: isSelected ? Colors.grey : null,
                        ),
                      );
                    },
                    maxHeight: 120,
                  ),
                  SizedBox(height: 10,),

                 //-------------------------DEPARTMENT-----------------------
                  DropdownSearch<String>(
                    mode: Mode.MENU,
                    items: ['Flight Ops'],
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Department",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    onChanged: (String? newValue) {
                      departmentC.text = newValue!;
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please choose a department';
                      }
                      return null;
                    },
                    popupItemBuilder: (BuildContext context, String item, bool isSelected) {
                      return Padding(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          title: Text(item),
                          tileColor: isSelected ? Colors.grey : null,
                        ),
                      );
                    },
                    maxHeight: 60,
                  ),
                  SizedBox(height: 10,),

                  //-------------------------ROOM-----------------------
                  DropdownSearch<String>(
                    mode: Mode.MENU,
                    items: ['Throttle', 'Wing Tip', 'Sharklet', 'Windshear', 'Joystick', 'Fuselage', 'Spoiler', 'Rudder', 'Windshield', 'Apron', 'Flap', 'Noseweel'],
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Room",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    onChanged: (String? newValue) {
                      roomC.text = newValue!;
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please choose a room';
                      }
                      return null;
                    },
                    popupItemBuilder: (BuildContext context, String item, bool isSelected) {
                      return Padding(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          title: Text(item),
                          tileColor: isSelected ? Colors.grey : null,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10,),

                  //-------------------------VENUE-----------------------
                  DropdownSearch<String>(
                    mode: Mode.MENU,
                    items: ['IAA RH'],
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Venue",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    onChanged: (String? newValue) {
                      venueC.text = newValue!;
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please choose a venue';
                      }
                      return null;
                    },
                    popupItemBuilder: (BuildContext context, String item, bool isSelected) {
                      return Padding(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          title: Text(item),
                          tileColor: isSelected ? Colors.grey : null,
                        ),
                      );
                    },
                    maxHeight: 60,
                  ),
                  SizedBox(height: 10,),

                  //-------------------------INSTRUCTOR-----------------------
                  StreamBuilder<QuerySnapshot>(
                    stream: controller.instructorStream(),
                    builder: (context, snapshot) {
                      List<String> userNamesWithId = []; // Updated to store names with IDs

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final users = snapshot.data?.docs.reversed.toList() ?? [];

                      // Create a list of names with their corresponding IDs in the desired format
                      userNamesWithId.addAll(users.map(
                            (user) => '${user['NAME']} (${user['ID NO']})',
                      ));

                      int selectedUserId = 0; // Default selected user ID

                      return DropdownSearch<String>(
                        mode: Mode.MENU,
                        showSelectedItems: true,
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Instructor",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 5.0,
                            ),
                          ),
                        ),
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          cursorColor: TsOneColor.secondaryContainer,
                        ),
                        items: userNamesWithId,
                        onChanged: (selectedName) {
                          // Extract the ID from the selected string
                          final selectedUserIdMatch = RegExp(r'\((\d+)\)').firstMatch(selectedName!);

                          if (selectedUserIdMatch != null) {
                            final selectedUserIdValue = int.parse(selectedUserIdMatch.group(1)!);
                            selectedUserId = selectedUserIdValue;
                          } else {
                            selectedUserId = 0;
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
                                    DateFormat('dd MMM yyyy').parse(dateC.text),
                                    trainingTypeC.text,
                                    departmentC.text,
                                    roomC.text,
                                    venueC.text,
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