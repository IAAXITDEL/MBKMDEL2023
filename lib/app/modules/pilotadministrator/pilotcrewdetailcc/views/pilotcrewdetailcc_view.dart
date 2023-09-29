import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../presentation/theme.dart';
import '../../../../../util/error_screen.dart';
import '../../../../../util/loading_screen.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/pilotcrewdetailcc_controller.dart';

class PilotcrewdetailccView extends GetView<PilotcrewdetailccController> {
  const PilotcrewdetailccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Back'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: TsOneColor.surface,
                ),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.profileList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingScreen(); // Placeholder while loading
                    }

                    if (snapshot.hasError) {
                      return ErrorScreen();
                    }

                    var listAttendance = snapshot.data!.docs;
                    var documentData = listAttendance[0].data();
                    controller.idTraining.value = documentData["ID NO"];
                    return Column(
                      children: [
                        RedTitleText(text: "PROFILE"),
                        AvatarGlow(
                          endRadius: 110,
                          glowColor: Colors.black,
                          duration: Duration(seconds: 2),
                          child: Container(
                              margin: EdgeInsets.all(15),
                              width: 175,
                              height: 175,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(200),
                                  child: documentData["PHOTOURL"]  == null ?  Image.asset(
                                    "assets/images/placeholder_person.png",
                                    fit: BoxFit.fitWidth,
                                  ) : Image.network("${documentData["PHOTOURL"]}", fit: BoxFit.cover),)),
                        ),
                        BlackTitleText(
                          text: documentData["NAME"] ,
                        ),
                        Text(
                          documentData["ID NO"].toString(),
                          style: TextStyle(color: tsOneColorScheme.secondaryContainer),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("RANK")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(flex: 6, child: Text(documentData["RANK"] ?? "N/A")),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("Email")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(
                                      flex: 6, child: Text(documentData["EMAIL"] ?? "N/A")),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("HUB")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(
                                      flex: 6, child: Text( documentData["HUB"] ?? "N/A")),
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
                                      flex: 6, child: Text( documentData["LICENSE NO."] ?? "N/A")),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("ID NO")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(
                                      flex: 6, child: Text( documentData["ID NO"].toString() ?? "N/A")),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 20,),
              Row(children: [
                RedTitleText(text:"TRAINING"),
              ],),
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

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: listTraining.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Get.toNamed(Routes.PILOTTRAININGHISTORYCC, arguments: {
                            "idTrainingType" : listTraining[index]["id"],
                            "idTraining" : controller.idTraining.value,
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child :  Image.asset(
                                  "assets/images/success.png",
                                  fit: BoxFit.cover,
                                )),
                            ),
                            title: Text(listTraining[index]["training"], maxLines: 1, style: tsOneTextTheme.labelMedium,),
                            // subtitle: Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Text(listTraining[index]["ID NO"].toString() ?? "", style: tsOneTextTheme.labelSmall,),
                            //     Container(
                            //       padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            //       decoration: BoxDecoration(
                            //         color: Colors.green.withOpacity(0.4),
                            //         borderRadius: BorderRadius.circular(10),
                            //       ),
                            //       child: const Text(
                            //         "Ready",
                            //         style: TextStyle(fontSize: 10, color: Colors.green),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            trailing: const Icon(Icons.navigate_next),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

            ],
          ),
        ),
      )
    );
  }
}
