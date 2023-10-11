import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../../presentation/theme.dart';
import '../../../../../../util/empty_screen.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/pilottraininghistorydetailcc_controller.dart';

class PilottraininghistorydetailccView
    extends GetView<PilottraininghistorydetailccController> {
  const PilottraininghistorydetailccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:   //--------------KELAS TRAINING-------------
        RedTitleText(text :
        "${controller.trainingName.value} TRAINING",),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Text("Congratulations!", style: tsOneTextTheme.headlineLarge,),
                Text("Congratulations for passing the training!", style: tsOneTextTheme.labelSmall,),
                SizedBox(height: 30,),
                Row(children: [
                  Expanded(child:
                  ElevatedButton(onPressed: (){},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                          ),
                        ),
                      ), child: Text("Download Certificate")),),

                 Expanded(child:  ElevatedButton(onPressed: (){
                   Get.toNamed(Routes.PILOTFEEDBACKFORMCC, arguments: {
                     "idAttendance" : controller.idAttendance.value,
                   });
                 },
                     style: ElevatedButton.styleFrom(
                       padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 1.0),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.only(
                           topRight: Radius.circular(20.0),
                           bottomRight: Radius.circular(20.0),
                         ),
                       ),
                     ), child: Text("Give Feedback")),)
                ],),
                SizedBox(height: 20,),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: TsOneColor.surface,
                  ),
                  child:  FutureBuilder<List<Map<String, dynamic>>>(
                    future: controller.getCombinedAttendance(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingScreen(); // Placeholder while loading
                      }

                      if (snapshot.hasError) {
                        return ErrorScreen();
                      }

                      var listAttendance= snapshot.data!;
                      if(listAttendance.isEmpty){
                        return EmptyScreen();
                      }

                      return Column(
                        children: [
                          //SUBJECT
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:  Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Subject")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["subject"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //DEPARTEMENT
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:  Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Department")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["department"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //TRAINING TYPE
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:  Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Training Type")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["trainingType"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //DATE
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:   Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Date")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["date"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //VANUE
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:  Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Vanue")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["vanue"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //ROOM
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Room")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["room"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //INSTRUCTOR
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:   Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Instructor")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["name"] ?? "N/A")),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ),
      )
    );
  }
}
