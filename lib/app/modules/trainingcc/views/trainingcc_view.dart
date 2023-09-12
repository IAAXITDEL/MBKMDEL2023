import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/theme.dart';
import '../../../../presentation/view_model/attendance_model.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../routes/app_pages.dart';
import '../controllers/trainingcc_controller.dart';

class TrainingccView extends GetView<TrainingccController> {
  const TrainingccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    Future<void> add(int training) async {
      String message = '';

      List<AttendanceModel> attendanceList = await controller.checkClassStream(controller.argumentid.value);

      print("cek ${attendanceList.isNotEmpty}");
      if (attendanceList.isNotEmpty) {
        // Do something with the attendanceList
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'You have been joined to the class!',
        );
       Get.toNamed(Routes.ATTENDANCE_PILOTCC, arguments: {
         "id" : attendanceList[0].id,
       });
      } else {
        // The list is empty
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          barrierDismissible: true,
          confirmBtnText: 'Submit',
          title: 'Attendance Key',
          widget: TextFormField(
            decoration: const InputDecoration(
              alignLabelWithHint: true,
              hintText: '',
              prefixIcon: Icon(
                Icons.lock_outline,
              ),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (value) => message = value,
          ),
          onConfirmBtnTap: () async {
            if (message.length < 5) {
              await QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                text: 'Please input something',
              );
              return;
            }

            await showDialog(
              context: context,
              builder: (context) {
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: controller.joinClassStream(message, training),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingScreen();
                    }

                    if (snapshot.hasError) {
                      return ErrorScreen();
                    }
                    var listAttendance= snapshot.data!;
                    if (snapshot.data!.isEmpty) {
                      Future.delayed(Duration.zero, () {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          text: "The class key is wrong, Please enter the key again!",
                        );
                      });
                    } else {
                      print(listAttendance[0]["id"]);
                      Future.delayed(Duration.zero, () {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.success,
                          text: "You have been joined to the class!",
                        );
                      });

                      // Get.toNamed(Routes.ATTENDANCE_PILOTCC, arguments: {
                      //   "id" : listAttendance[0]["id"],
                      // });
                    }
                    return SizedBox.shrink(); // Return an empty widget to avoid the error.
                  },
                );
              },
            );

            Navigator.of(context, rootNavigator: true).pop();
          },
        );
        
      }
      
    }



    return Scaffold(
      appBar: AppBar(
        title: RedTitleText(text :'TRAINING'),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
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

                    var listTraining= snapshot.data!.docs;

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
                              controller.argumentid.value =  trainingData["id"];
                            controller.argumentname.value =  trainingData["training"];
                                controller.cekRole();
                               if(controller.cekPilot.value  == true){
                                 add(controller.argumentid.value);
                               }
                            },
                            splashColor: TsOneColor.primary,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                                child: Text( trainingData["training"],),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: 20,),
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
                SizedBox(height: 20,),

              ],
            )
        ),
      ),
    );
  }
}
