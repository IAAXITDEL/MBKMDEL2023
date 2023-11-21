import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../util/empty_screen.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../controllers/list_attendancedetailcc_controller.dart';

class ListAttendancedetailccView
    extends GetView<ListAttendancedetailccController> {
  ListAttendancedetailccView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var scoreC = TextEditingController();
    var feedbackC = TextEditingController();
    var gradeC = TextEditingController();


    Future<void> updateScoring(String score, String feedback, double grade, double communication, double knowledge, double active) async {
      controller.updateScoring(score, feedback, grade, communication, knowledge, active ).then((status) async {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Add Score and Feedback Completed Successfully!',
        );

        Get.back();
        Get.back();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: RedTitleText(text: "PROFILE"),
        centerTitle: true,
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
                      return LoadingScreen();
                    }

                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return ErrorScreen();
                    }

                    var listAttendance = snapshot.data!;

                    if (listAttendance.isEmpty) {
                      return EmptyScreen();
                    }
                    var documentData = listAttendance[0];
                    controller.idattendancedetail.value = documentData["id"];
                    feedbackC.text = documentData["feedback"] ?? "";
                    gradeC.text = documentData["grade"].toString() ?? "";
                    List<String> list = ['PASS', 'FAIL'];
                    RxString dropdownValue =
                        RxString(documentData["score"] ?? list.first);
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
                                      child: documentData["photoURL"] == null
                                          ? Image.asset(
                                              "assets/images/placeholder_person.png",
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              "${documentData["photoURL"]}",
                                              fit: BoxFit.cover),
                                    )),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                          Row(
                            children: [
                              Expanded(flex: 3, child: Text("NAME")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(
                                  flex: 6,
                                  child: Text(documentData["name"] ?? "N/A")),
                            ],
                          ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          // Row(
                          //   children: [
                          //     Expanded(flex: 3, child: Text("EMAIL")),
                          //     Expanded(flex: 1, child: Text(":")),
                          //     Expanded(
                          //         flex: 6,
                          //         child: Text(documentData["email"] ?? "N/A")),
                          //   ],
                          // ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(flex: 3, child: Text("RANK")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(
                                  flex: 6,
                                  child: Text(documentData["rank"] ?? "N/A")),
                            ],
                          ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          // Row(
                          //   children: [
                          //     Expanded(flex: 3, child: Text("LICENSE NO")),
                          //     Expanded(flex: 1, child: Text(":")),
                          //     Expanded(
                          //         flex: 6,
                          //         child:
                          //             Text(documentData["license"] ?? "N/A")),
                          //   ],
                          // ),
                          SizedBox(
                            height: 10,
                          ),
                            controller.argumentstatus.value == "pending"
                                  ? Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 3,
                                                  child: Text("SCORE")),
                                              Expanded(
                                                  flex: 1, child: Text(":")),
                                              Expanded(
                                                  flex: 6,
                                                  child: Row(
                                                    children: [
                                                      Obx(() => Container(
                                                            height: 30.0,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: scoreC.text.isEmpty ? Colors.green.withOpacity(0.4) : scoreC.text == "PASS" ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.4),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child:
                                                                DropdownButton<String>(
                                                              underline: Container(),
                                                              focusColor: tsOneColorScheme.onSecondaryContainer,
                                                              value: dropdownValue.value,
                                                              onChanged: (String? newValue) {
                                                                dropdownValue.value = newValue!;
                                                                scoreC.text = dropdownValue.value;
                                                              },
                                                              items: list.map(
                                                                  (String value) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: value,
                                                                  child: Text(value,
                                                                    style: TextStyle(fontSize: 14),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          )),
                                                    ],
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 3,
                                                  child: Text("GRADE")),
                                              Expanded(
                                                  flex: 1, child: Text(":")),
                                              Expanded(
                                                  flex: 6,
                                                  child:  TextFormField(
                                                    controller: gradeC,
                                                    keyboardType: TextInputType.number,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        // Validation Logic
                                                        return 'Please enter the Grade';
                                                      } else {
                                                        // Convert the value to double for numeric comparison
                                                        double? numericValue = double.tryParse(value);
                                                        if (numericValue == null || numericValue < 0 || numericValue > 100) {
                                                          return 'Please enter a valid numeric Grade between 0 and 100';
                                                        }
                                                      }
                                                      return null;
                                                    },
                                                  )
                                                ,)
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Communication Skills", style: tsOneTextTheme.headlineMedium,textAlign: TextAlign.center,),
                                              Text("Clear and effective communication", style: TextStyle(color: TsOneColor.secondaryContainer, fontSize: 11),textAlign: TextAlign.start,),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text("Very Poor", style: tsOneTextTheme.labelSmall,),
                                                  Text("Excellent", style: tsOneTextTheme.labelSmall,)
                                                ],
                                              ),
                                              Obx(() {
                                                return Slider(
                                                  value: controller.ratingCommunication.value,
                                                  min: 1,
                                                  max: 5,
                                                  divisions: 4,
                                                  label: controller.ratingCommunication.value.round().toString(),
                                                  onChanged: (double value) {
                                                    controller.ratingCommunication.value = value;
                                                  },
                                                  activeColor: Colors.blue[900],
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
                                              Text("Knowledge Acquisition", style: tsOneTextTheme.headlineMedium,textAlign: TextAlign.center,),
                                              Text("Understanding and applying training materials", style: TextStyle(color: TsOneColor.secondaryContainer, fontSize: 11),textAlign: TextAlign.start,),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text("Very Low", style: tsOneTextTheme.labelSmall,),
                                                  Text("Very High", style: tsOneTextTheme.labelSmall,)
                                                ],
                                              ),
                                              Obx(() {
                                                return Slider(
                                                  value: controller.ratingKnowledge.value,
                                                  min: 1,
                                                  max: 5,
                                                  divisions: 4,
                                                  label: controller.ratingKnowledge.value.round().toString(),
                                                  onChanged: (double value) {
                                                    controller.ratingKnowledge.value = value;
                                                  },
                                                  activeColor: Colors.green[900],
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
                                              Text("Active Participation", style: tsOneTextTheme.headlineMedium,textAlign: TextAlign.center,),
                                              Text("Engaging actively", style: TextStyle(color: TsOneColor.secondaryContainer, fontSize: 11),textAlign: TextAlign.start,),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text("Very Low", style: tsOneTextTheme.labelSmall,),
                                                  Text("Very High", style: tsOneTextTheme.labelSmall,)
                                                ],
                                              ),
                                              Obx(() {
                                                return Slider(
                                                  value: controller.ratingActive.value,
                                                  min: 1,
                                                  max: 5,
                                                  divisions: 4,
                                                  label: controller.ratingActive.value.round().toString(),
                                                  onChanged: (double value) {
                                                    controller.ratingActive.value = value;
                                                  },
                                                  activeColor: Colors.red[900],
                                                );
                                              }),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text("Provide Additional Information", style: tsOneTextTheme.headlineMedium,)),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: tsOneColorScheme
                                                        .secondaryContainer),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: TextFormField(
                                              controller: feedbackC,
                                              maxLines: 4,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  // Validation Logic
                                                  return 'Please enter the Feedback';
                                                }
                                                return null;
                                              },
                                              decoration:
                                                  InputDecoration.collapsed(
                                                      hintText:
                                                          "Enter your text here"),
                                            ),
                                          ),

                                          Obx(() => CheckboxListTile(
                                              title: Text(
                                                "I agree with all of the results",
                                                style:
                                                    tsOneTextTheme.labelSmall,
                                              ),
                                              value:
                                                  controller.checkAgree.value,
                                              onChanged: (newValue) {
                                                controller.checkAgree.value =
                                                    newValue!;
                                              },
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              activeColor: Colors.green)),

                                          Obx(() {
                                            return controller.showText.value
                                                ? Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    child: Text(
                                                        "Please review the legal agreement and check this box to proceed",
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12)),
                                                  )
                                                : SizedBox();
                                          }),

                                          //-------------------------SUBMIT-----------------------
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5.0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (controller
                                                        .checkAgree.value ==
                                                    false) {
                                                  controller.showText.value =
                                                      true;
                                                  controller.update();
                                                }
                                                if (_formKey.currentState !=
                                                        null &&
                                                    _formKey.currentState!
                                                        .validate() &&
                                                    controller
                                                            .checkAgree.value ==
                                                        true) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return FutureBuilder<void>(
                                                          future: updateScoring(dropdownValue.value, feedbackC.text, double.tryParse(gradeC.text)! , controller.ratingCommunication.value, controller.ratingKnowledge.value, controller.ratingActive.value ),
                                                          builder: (BuildContextcontext, AsyncSnapshot<void>snapshot) {
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
                                                      });
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: TsOneColor.greenColor,
                                                minimumSize:
                                                    Size(double.infinity, 50),
                                              ),
                                              child: Text(
                                                'Submit',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : SizedBox(),
                              controller.argumentstatus.value == "pending" || controller.argumentstatus.value == "confirmation"
                                  ? SizedBox()
                                  : Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(flex: 3, child: Text("GRADE")),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                          flex: 6,
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 3,
                                                    horizontal: 10),
                                                child: Text(
                                                  documentData["grade"].round().toString() ?? "",
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
                                    Expanded(flex: 3, child: Text("SCORE")),
                                    Expanded(flex: 1, child: Text(":")),
                                    Expanded(
                                        flex: 6,
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 3,
                                                  horizontal: 10),
                                              decoration: BoxDecoration(
                                                color: documentData["score"] == "PASS" || documentData["score"] ==  null ? Colors.green.withOpacity(0.4)
                                                    : Colors.red
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10),
                                              ),
                                              child: Text(
                                                documentData["score"],
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: documentData[
                                                    "score"] ==
                                                        "PASS"  || documentData["score"] ==  null
                                                        ? Colors.green
                                                        : Colors.red),
                                              ),
                                            ),
                                          ],
                                        ))
                                  ],
                                )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                          controller.isCPTS.value
                              ? Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(flex: 2,child: Text("Communication Skills", style: tsOneTextTheme.labelSmall)),
                                  Expanded(
                                    flex: 3,
                                    child: Obx(() {
                                      return Slider(
                                        value: controller.ratingCommunication.value,
                                        min: 1,
                                        max: 5,
                                        divisions: 4,
                                        label: controller.ratingCommunication.value.round().toString(),
                                        onChanged: (double value) {
                                        },
                                        activeColor: Colors.blue[900],
                                      );
                                    }),
                                  ),
                                  Text("${controller.ratingCommunication.value.round().toString()}/5"),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 2,child: Text("Knowledge", style: tsOneTextTheme.labelSmall,)),
                                  Expanded( flex: 3,
                                    child: Obx(() {
                                      return Slider(
                                        value: controller.ratingKnowledge.value,
                                        min: 1,
                                        max: 5,
                                        divisions: 4,
                                        label: controller.ratingKnowledge.value.round().toString(),
                                        onChanged: (double value) {
                                        },
                                        activeColor: Colors.green[900],
                                      );
                                    }),
                                  ),
                                  Text("${controller.ratingKnowledge.value.round().toString()}/5"),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 2, child: Text("Active Participation", style: tsOneTextTheme.labelSmall)),
                                  Expanded(
                                    flex: 3,
                                    child: Obx(() {
                                      return Slider(
                                        value: controller.ratingActive.value,
                                        min: 1,
                                        max: 5,
                                        divisions: 4,
                                        label: controller.ratingActive.value.round().toString(),
                                        onChanged: (double value) {
                                        },
                                        activeColor: Colors.red[900],
                                      );
                                    }),
                                  ),
                                  Text("${controller.ratingActive.value.round().toString()}/5"),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(10.0),
                                        color: TsOneColor.surface,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Feedback from instructor',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            documentData["feedback"],
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                              : SizedBox()
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
