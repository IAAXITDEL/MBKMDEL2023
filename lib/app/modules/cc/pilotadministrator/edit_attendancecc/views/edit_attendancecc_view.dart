import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../../presentation/shared_components/formdatefield.dart';
import '../../../../../../presentation/shared_components/formtextfield.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../controllers/edit_attendancecc_controller.dart';

class EditAttendanceccView extends GetView<EditAttendanceccController> {
  EditAttendanceccView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dropdownController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var subjectC = TextEditingController();
    var trainingTypeC = TextEditingController();
    var departmentC = TextEditingController();
    var roomC = TextEditingController();
    var venueC = TextEditingController();
    var dateC = TextEditingController();
    int? instructorC = 0;


    Future<void> edit(String subject, DateTime date, String trainingType,String department,String room,String venue, int instructor) async {
      controller.editAttendanceForm(subject, date, trainingType, department, room,venue, instructor).then((status) async {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Edit Attendance Completed Successfully!',
        );

       Get.back();
        Get.back();
      });
    }




    return Scaffold(
        appBar: AppBar(
          title:  RedTitleText(text: "EDIT ATTENDANCE"),
          centerTitle: true,
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

                  //Text("REDUCED VERTICAL SEPARATION MINIMA (RVSM)"),

                  SizedBox(
                    height: 20,
                  ),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: controller.attendanceStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LoadingScreen(); // Placeholder while loading
                        }

                        if (snapshot.hasError) {
                          return const ErrorScreen();
                        }

                        var listAttendance = snapshot.data!.docs;
                        if (listAttendance.isNotEmpty) {
                          DateTime? dateTime = listAttendance[0]["date"].toDate();
                          dateC.text = dateTime != null ? DateFormat('dd MMM yyyy').format(dateTime) : 'Invalid Date';

                          subjectC.text = listAttendance[0]["subject"];
                          trainingTypeC.text = listAttendance[0]["trainingType"];
                          departmentC.text = listAttendance[0]["department"];
                          roomC.text = listAttendance[0]["room"];
                          venueC.text = listAttendance[0]["venue"];
                          controller.instructor.value = listAttendance[0]["instructor"];
                        } else {
                          // Handle the case where the list is empty or null
                          subjectC.text = "No Subject Data Available";
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //-------------------------SUBJECT-----------------------
                            FormTextField(
                              text: "Subject",
                              textController: subjectC,
                              readOnly: true,
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            //--------------------------DATE--------------------------
                            FormDateField(
                              text: 'Date',
                              textController: dateC,
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            // //-------------------------VENUE-----------------------
                            // FormTextField(text: "Training Type", textController: trainingTypeC),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            //
                            // //-------------------------VENUE-----------------------
                            // FormTextField(text: "Department", textController: departmentC),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            //
                            // //-------------------------VENUE-----------------------
                            // FormTextField(text: "Room", textController: roomC),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            //
                            // //-------------------------VENUE-----------------------
                            // FormTextField(text: "Venue", textController: venueC),
                            // SizedBox(
                            //   height: 10,
                            // ),

                            //-------------------------TRAINING TYPE-----------------------
                            Column(
                              children: [
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
                                  selectedItem: trainingTypeC.text,
                                ),
                                SizedBox(height: 10), // Atur jarak antara DropdownSearch dan FormTextField
                              ],
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
                              selectedItem: departmentC.text,
                            ),
                            SizedBox(height: 10,),

                            //-------------------------ROOM-----------------------
                            Column(
                              children: [
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
                                      return 'Please choose a Room';
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
                                  maxHeight: 200,
                                  selectedItem: roomC.text,
                                ),
                                SizedBox(height: 10), // Atur jarak antara DropdownSearch dan FormTextField
                              ],
                            ),

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
                              selectedItem: venueC.text,
                            ),
                            SizedBox(height: 10,),

                          ],
                        );
                      }),

                  //-------------------------INSTRUCTOR-----------------------

              StreamBuilder<QuerySnapshot>(
                stream: controller.instructorStream(),
                builder: (context, snapshot) {
                  List<String> userNames = [];
                  int selectedInstructorId = controller.instructor.value; // Default selected instructor ID

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final users = snapshot.data?.docs.reversed.toList() ?? [];

                  // Populate userNames with names from Firestore
                  userNames.addAll(users.map((user) => user['NAME'] as String));

                  // Find the selected user based on the ID
                  final selectedUser = users.firstWhere(
                        (user) => user['ID NO'] == selectedInstructorId,
                  );

                  String selectedInstructorName = selectedUser != null ? selectedUser['NAME'] as String : '';

                  return DropdownSearch<String>(
                    mode: Mode.MENU,
                    showSelectedItems: true,
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Instructor",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      cursorColor: TsOneColor.primary,
                    ),
                    items: userNames,
                    selectedItem: selectedInstructorName, // Set the selected item
                    onChanged: (selectedName) {
                      // Find the corresponding user based on the selected name
                      final selectedUser = users.firstWhere(
                            (user) => user['NAME'] == selectedName,
                      );

                      final selectedUserIdValue = selectedUser['ID NO'] as int;
                      selectedInstructorId = selectedUserIdValue;
                      controller.instructor.value = selectedInstructorId;


                      print('Selected name: $selectedName, Selected ID: $selectedInstructorId');
                    },
                  );
                },
              ),

              SizedBox(
                    height: 30,
                  ),

                  //-------------------------SUBMIT-----------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate() &&
                            controller.instructor.value != 0) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return FutureBuilder<void>(
                                  future: edit(
                                    subjectC.text,
                                    DateFormat('dd MMM yyyy').parse(dateC.text),
                                    trainingTypeC.text,
                                    departmentC.text,
                                    roomC.text,
                                    venueC.text,
                                    controller.instructor.value,
                                  ),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<void> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
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
                              });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: TsOneColor.greenColor,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
