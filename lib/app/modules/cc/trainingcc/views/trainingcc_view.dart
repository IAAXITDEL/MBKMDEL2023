import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../presentation/theme.dart';
import '../../../../../presentation/view_model/attendance_model.dart';
import '../../../../../util/error_screen.dart';
import '../../../../../util/loading_screen.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/trainingcc_controller.dart';

class TrainingccView extends GetView<TrainingccController> {
  const TrainingccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var passwordC = TextEditingController();

    passwordC.text = controller.passwordKey.value;

    ever(controller.passwordKey, (value) {
      passwordC.text = value;
    });

    Future<void> add(int training) async {
      String message = '';

      List<AttendanceModel> attendanceList =
          await controller.checkClassStream(controller.argumentid.value);
      List<AttendanceModel> classList =
          await controller.checkClassOpenStream(controller.argumentid.value);

      if (classList.isNotEmpty) {
        if (attendanceList.isNotEmpty) {
          Get.toNamed(Routes.ATTENDANCE_PILOTCC, arguments: {
            "id": attendanceList[0].id,
          });
          return;
        } else {
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.info,
            barrierDismissible: true,
            confirmBtnText: 'Submit',
            title: 'Attendance Key',
            widget: Column(
              children: [
                TextFormField(
                  controller: passwordC,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: '',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    controller.scanQRCode(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: TsOneColor.secondaryContainer,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Icon(
                        Icons.qr_code,
                        size: 25,
                      ),
                      title: Text(
                        "Using QR Code",
                        style: tsOneTextTheme.headlineMedium,
                      ),
                      trailing: const Icon(Icons.navigate_next),
                    ),
                  ),
                )
              ],
            ),
            onConfirmBtnTap: () async {
              if (passwordC.text.length < 5) {
                await QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  text: 'Please input something',
                );
                return;
              }

              try {
                 List<Map<String, dynamic>> listAttendance = await controller.joinClassFuture(passwordC.text, training);
                  print(listAttendance);
                if (listAttendance.isEmpty) {
                  Navigator.of(context, rootNavigator: true).pop();
                  await QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    text: "The class key is wrong, Please enter the key again!",
                  );
                } else {
                  await Get.toNamed(Routes.ATTENDANCE_PILOTCC, arguments: {
                    "id": listAttendance[0]["id"],
                  });
                }
              } catch (e) {
                print("Error joining class: $e");
              }
            },
          );
        }
      } else {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          text: 'No class opened!',
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RedTitleText(text: 'TRAINING'),
          controller.isAdministrator.value == true
              ? //ADD NEW SUBJECT
          // ElevatedButton(
          //   onPressed: () async {
          //     String newSubject = '';
          //     String newRemark = '';
          //     String newTrainingDescription = '';
          //     int newExpiryDate = 0;
          //
          //     // Show a dialog to input the new subject, remark and description
          //     await showDialog(
          //       context: context,
          //       builder: (context) {
          //         return AlertDialog(
          //           title: Text('Add New Subject'),
          //           content: Column(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               Container(
          //                 margin: EdgeInsets.only(bottom: 16),
          //                 child: TextField(
          //                   onChanged: (value) {
          //                     newSubject = value; //
          //                   },
          //                   decoration: InputDecoration(
          //                     hintText: 'Enter the new subject',
          //                     border: OutlineInputBorder(),
          //                     labelText: 'Subject',
          //                   ),
          //                 ),
          //               ),
          //               Container(
          //                 margin: EdgeInsets.only(bottom: 16),
          //                 child: TextField(
          //                   onChanged: (value) {
          //                     newRemark = value;
          //                   },
          //                   decoration: InputDecoration(
          //                     hintText: 'Enter the remark',
          //                     border: OutlineInputBorder(),
          //                     labelText: 'Remark',
          //                   ),
          //                 ),
          //               ),
          //               Container(
          //                 margin: EdgeInsets.only(bottom: 16),
          //                 child: TextField(
          //                   onChanged: (value) {
          //                     newExpiryDate = value as int;
          //                   },
          //                   decoration: InputDecoration(
          //                     hintText: 'Enter the expiry date',
          //                     border: OutlineInputBorder(),
          //                     labelText: 'Expiry Date',
          //                   ),
          //                 ),
          //               ),
          //               Container(
          //                 child: TextField(
          //                   onChanged: (value) {
          //                     newTrainingDescription = value;
          //                   },
          //                   maxLines:
          //                   null, // Allow multiple lines for long text
          //                   decoration: InputDecoration(
          //                     hintText: 'About training',
          //                     border: OutlineInputBorder(),
          //                     labelText: 'Training Description',
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           actions: <Widget>[
          //             TextButton(
          //               onPressed: () {
          //                 Navigator.of(context).pop();
          //               },
          //               child: Text('Cancel'),
          //             ),
          //             ElevatedButton(
          //               // Use ElevatedButton for the "Add" button
          //               onPressed: () async {
          //                 if (newSubject.isNotEmpty &&
          //                     newRemark.isNotEmpty) {
          //                   await controller.addNewSubject(
          //                       newSubject,
          //                       newRemark,
          //                       newExpiryDate,
          //                       newTrainingDescription);
          //                   Navigator.of(context).pop();
          //                 }
          //               },
          //               child: Text('Add'),
          //             ),
          //           ],
          //         );
          //       },
          //     );
          //   },
          //   child: Text('Add New Subject'),
          //   style: ElevatedButton.styleFrom(),
          // )
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(Routes.ADD_TRAININGCC);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 16),
                          SizedBox(width: 5,),
                          Text("Add New Training",)
                        ],
                      ),
                    )
                ),
              ];
            },
            offset: Offset(0, 30),
            child: GestureDetector(
              child: Container(
                child: Icon(Icons.more_vert_outlined),
              ),
            ),
          )
              : SizedBox()
        ],
      )),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              controller.isAdministrator.value == false ?
              Text("TRAINEE / PILOT", style: tsOneTextTheme.labelMedium,) : SizedBox(),
              // ------------------------------------ LIST TRAINING ----------------------------------

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.trainingStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen(); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return ErrorScreen();
                  }

                  var listTraining = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: 1.5,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listTraining.length,
                    itemBuilder: (context, index) {
                      var trainingData = listTraining[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: InkWell(
                          onTap: () {
                            controller.argumentid.value = trainingData["id"];
                            controller.argumentname.value =
                                trainingData["training"];
                            controller.update();
                            controller.cekRole();
                            if (controller.cekPilot.value == true) {
                              add(controller.argumentid.value);
                            }
                          },
                          splashColor: TsOneColor.primary,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 10),
                              child: Text(
                                trainingData["training"],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              SizedBox(
                height: 20,
              ),

              // ------------------------------------ TRAINING REMARK ----------------------------------
              Row(
                children: [
                  RedTitleText(text: "TRAINING REMARK"),
                ],
              ),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.trainingRemarkStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen(); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  var listTrainingRemark = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: listTrainingRemark.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              listTrainingRemark[index]["training_code"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(listTrainingRemark[index]["remark"]),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
