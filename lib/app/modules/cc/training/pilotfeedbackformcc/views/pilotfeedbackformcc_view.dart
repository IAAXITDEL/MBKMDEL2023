import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../../presentation/shared_components/formdatefield.dart';
import '../../../../../../presentation/shared_components/formtextfield.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../controllers/pilotfeedbackformcc_controller.dart';

class PilotfeedbackformccView extends GetView<PilotfeedbackformccController> {
  PilotfeedbackformccView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var subjectC = TextEditingController();
    var vanueC = TextEditingController();
    var dateC = TextEditingController();
    var instructorC = TextEditingController();
    var departmentC = TextEditingController();
    var trainingtypeC = TextEditingController();
    var roomC = TextEditingController();
    var feedbackC = TextEditingController();

    Future<void> addFeedback(String feedback) async {
      controller.addFeedback(feedback).then((status) async {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Add Rating and Feedback Completed Successfully!',
        );

        Get.back();
        Get.back();
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: RedTitleText(
            text: "FEEDBACK FORM",
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                    future: controller.getCombinedAttendance(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingScreen(); // Placeholder while loading
                      }

                      if (snapshot.hasError) {
                        return ErrorScreen();
                      }

                      var listAttendance = snapshot.data!;

                      if (listAttendance != null && listAttendance.isNotEmpty) {
                        subjectC.text = listAttendance[0]["subject"] ?? "N/A";
                        dateC.text = listAttendance[0]["date"] ?? "N/A";
                        departmentC.text =
                            listAttendance[0]["department"] ?? "N/A";
                        vanueC.text = listAttendance[0]["vanue"] ?? "N/A";
                        trainingtypeC.text =
                            listAttendance[0]["trainingType"] ?? "N/A";
                        roomC.text = listAttendance[0]["room"] ?? "N/A";
                        instructorC.text = listAttendance[0]["name"] ?? "N/A";
                      } else {
                        // Handle the case where the list is empty or null
                        subjectC.text = "No Subject Data Available";
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                    textController: departmentC,
                                    readOnly: true),
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
                                    textController: trainingtypeC,
                                    readOnly: true),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: FormTextField(
                                  text: "Room",
                                  textController: roomC,
                                    readOnly: true
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: TsOneColor.secondaryContainer,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                title: Text(
                                  "Chair Person/ Instructor",
                                  style: tsOneTextTheme.labelSmall,
                                ),
                                subtitle: Text(
                                  listAttendance[0]["name"],
                                  style: tsOneTextTheme.headlineMedium,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Share your experience in scalling",
                            style: tsOneTextTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Obx((){
                          //   return Row(
                          //     crossAxisAlignment: CrossAxisAlignment.center,
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Expanded(
                          //           child: Center(
                          //             child: RatingBar.builder(
                          //               initialRating: controller.rating.value,
                          //               itemCount: 5,
                          //               itemSize: 60.0,
                          //               itemBuilder: (context, index) {
                          //                 switch (index) {
                          //                   case 0:
                          //                     return Icon(
                          //                       Icons.sentiment_very_dissatisfied,
                          //                       color: Colors.red,
                          //                     );
                          //                   case 1:
                          //                     return Icon(
                          //                       Icons.sentiment_dissatisfied,
                          //                       color: Colors.redAccent,
                          //                     );
                          //                   case 2:
                          //                     return Icon(
                          //                       Icons.sentiment_neutral,
                          //                       color: Colors.amber,
                          //                     );
                          //                   case 3:
                          //                     return Icon(
                          //                       Icons.sentiment_satisfied,
                          //                       color: Colors.lightGreen,
                          //                     );
                          //                   case 4:
                          //                     return Icon(
                          //                       Icons.sentiment_very_satisfied,
                          //                       color: Colors.green,
                          //                     );
                          //                   default:
                          //                     return Icon(
                          //                       Icons.sentiment_very_satisfied,
                          //                       color: Colors.green,
                          //                     );
                          //                 }
                          //               },
                          //               onRatingUpdate: (rating) {
                          //                 print(rating);
                          //                 controller.rating.value = rating;
                          //               },
                          //             ),
                          //           ))
                          //     ],
                          //   );
                          // }),
                          FutureBuilder<List<AttendanceDetailModel>>(
                              future: controller.feedbackStream(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return LoadingScreen(); // Placeholder while loading
                                }

                                if (snapshot.hasError) {
                                  return ErrorScreen();
                                }

                                List<AttendanceDetailModel> listAttendance = snapshot.data!;
                                print(listAttendance);
                                if (listAttendance != null && listAttendance.isNotEmpty) {
                                  feedbackC.text = listAttendance[0].feedbackforinstructor ?? "";
                                } else {
                                  // Handle the case where the list is empty or null
                                  subjectC.text = "No Subject Data Available";
                                }

                                return Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Obx(() {
                                        return Center(
                                          child: RatingBar.builder(
                                            initialRating:controller.rating.value,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: false,
                                            itemCount: 5,
                                            itemSize: 50.0,
                                            itemPadding:
                                            EdgeInsets.symmetric(horizontal: 7.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            glowColor: Colors.blue,
                                            glowRadius: 1,
                                            onRatingUpdate: (rating) {
                                              print(rating);
                                              controller.rating.value = rating;
                                            },
                                          ),
                                        );
                                      }),
                                      Obx(() {
                                        return Slider(
                                          value: controller.rating.value,
                                          min: 0,
                                          max: 5,
                                          divisions: 5,
                                          label: controller.rating.value
                                              .round()
                                              .toString(),
                                          onChanged: (double value) {
                                            controller.rating.value = value;
                                          },
                                          activeColor: Colors.blue[900],
                                        );
                                      }),
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: tsOneColorScheme
                                                    .secondaryContainer),
                                            borderRadius: BorderRadius.circular(5)),
                                        child: TextFormField(
                                          controller: feedbackC,
                                          maxLines: 4,
                                          keyboardType: TextInputType.multiline,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              // Validation Logic
                                              return 'Please enter the Feedback';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration.collapsed(
                                              hintText: "Add your comments"),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (_formKey.currentState != null &&
                                                _formKey.currentState!.validate()) {
                                              addFeedback(feedbackC.text);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: TsOneColor.greenColor,
                                            minimumSize: Size(double.infinity, 50),
                                          ),
                                          child: Text(
                                            (listAttendance.isNotEmpty && listAttendance[0].feedbackforinstructor?.isNotEmpty == true)
                                                ? 'Resend'
                                                : 'Submit',
                                            style: TextStyle(color: Colors.white),
                                          )
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ],
                      );
                    }),
              ],
            ),
          ),
        ));
  }
}
