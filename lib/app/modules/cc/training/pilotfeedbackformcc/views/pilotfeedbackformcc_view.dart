import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../controllers/pilotfeedbackformcc_controller.dart';

class PilotfeedbackformccView extends GetView<PilotfeedbackformccController> {
  PilotfeedbackformccView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  var subjectC = TextEditingController();
  var venueC = TextEditingController();
  var dateC = TextEditingController();
  var instructorC = TextEditingController();
  var departmentC = TextEditingController();
  var trainingtypeC = TextEditingController();
  var roomC = TextEditingController();
  var feedbackC = TextEditingController();

  Future<void> addFeedback(context, String feedback) async {
    controller.addFeedback(feedback).then((status) async {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Add Rating and Feedback Completed Successfully!',
      );

      Get.back();
      // Get.back();
    });


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RedTitleText(
          text: "FEEDBACK FORM",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Give Feedback!",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              FutureBuilder<List<AttendanceDetailModel>>(
                future: controller.feedbackStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return LoadingScreen(); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return ErrorScreen();
                  }

                  List<AttendanceDetailModel> listAttendance =
                  snapshot.data!;
                  if (listAttendance != null &&
                      listAttendance.isNotEmpty) {
                    feedbackC.text =
                        listAttendance[0].feedbackforinstructor ??
                            "";
                  } else {
                    // Handle the case where the list is empty or null
                    subjectC.text = "No Subject Data Available";
                  }

                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Teaching Methods",
                              style: tsOneTextTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "Effective teaching methods",
                              style: TextStyle(
                                  color: TsOneColor.secondaryContainer,
                                  fontSize: 11),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Ineffective",
                                  style: tsOneTextTheme.labelSmall,
                                ),
                                Text(
                                  "Effective",
                                  style: tsOneTextTheme.labelSmall,
                                )
                              ],
                            ),
                            Obx(() {
                              return Slider(
                                value: controller.ratingTeachingMethod.value,
                                min: 1,
                                max: 5,
                                divisions: 4,
                                label: controller.ratingTeachingMethod.value
                                    .round()
                                    .toString(),
                                onChanged: (double value) {
                                  controller.ratingTeachingMethod.value =
                                      value;
                                },
                                // activeColor: Colors.blue[900],
                                activeColor : Color(0XFFFFFB000),
                              );
                            }),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mastery of Subject Matter",
                              style: tsOneTextTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "Proficient in delivering content",
                              style: TextStyle(
                                  color: TsOneColor.secondaryContainer,
                                  fontSize: 11),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Limited",
                                  style: tsOneTextTheme.labelSmall,
                                ),
                                Text(
                                  "Exceptional",
                                  style: tsOneTextTheme.labelSmall,
                                )
                              ],
                            ),
                            Obx(() {
                              return Slider(
                                value: controller.ratingMastery.value,
                                min: 1,
                                max: 5,
                                divisions: 4,
                                label: controller.ratingMastery.value
                                    .round()
                                    .toString(),
                                onChanged: (double value) {
                                  controller.ratingMastery.value = value;
                                },
                                // activeColor: Colors.green[900],
                                activeColor : Color(0XFFF004225),
                              );
                            }),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Time Management",
                              style: tsOneTextTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "Efficient time use",
                              style: TextStyle(
                                  color: TsOneColor.secondaryContainer,
                                  fontSize: 11),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Poor",
                                  style: tsOneTextTheme.labelSmall,
                                ),
                                Text(
                                  "Excellent",
                                  style: tsOneTextTheme.labelSmall,
                                )
                              ],
                            ),
                            Obx(() {
                              return Slider(
                                value: controller.ratingTimeManagement.value,
                                min: 1,
                                max: 5,
                                divisions: 4,
                                label: controller.ratingTimeManagement.value
                                    .round()
                                    .toString(),
                                onChanged: (double value) {
                                  controller.ratingTimeManagement.value =
                                      value;
                                },
                                // activeColor: Colors.red[900],
                                activeColor : Color(0XFFF071952),

                              );
                            }),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(children: [Text(
                          "Provide Additional Information",
                          style: tsOneTextTheme.headlineMedium,
                        ),],),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: tsOneColorScheme
                                      .secondaryContainer),
                              borderRadius:
                              BorderRadius.circular(5)),
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
                                  _formKey.currentState!
                                      .validate()) {
                                addFeedback(context, feedbackC.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: TsOneColor.greenColor,
                              minimumSize:
                              Size(double.infinity, 50),
                            ),
                            child: Text(
                              (listAttendance.isNotEmpty &&
                                  listAttendance[0]
                                      .feedbackforinstructor
                                      ?.isNotEmpty ==
                                      true)
                                  ? 'Resend'
                                  : 'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
