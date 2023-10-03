import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../presentation/theme.dart';
import '../../../../util/empty_screen.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../routes/app_pages.dart';
import '../controllers/pilottraininghistorycc_controller.dart';

class PilottraininghistoryccView
    extends GetView<PilottraininghistoryccController> {
  const PilottraininghistoryccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: RedTitleText(text: 'TRAINING HISTORY'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //--------------KELAS TRAINING-------------
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

                    return Text(
                      listTraining[0]["training"],
                      maxLines: 1,
                      style: tsOneTextTheme.bodyLarge,
                    );
                  },
                ),

                SizedBox(
                  height: 10,
                ),

                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: controller.historyStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingScreen(); // Placeholder while loading
                    }

                    if (snapshot.hasError) {
                      return ErrorScreen();
                    }

                    var listAttendance = snapshot.data!;
                    if (listAttendance.isEmpty) {
                      return EmptyScreen();
                    }

                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: listAttendance.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          String dateString = listAttendance[index]["date"];

                          DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);

                          String formattedDate = DateFormat('dd MMMM yyyy').format(date);
                          return InkWell(
                            onTap: () {
                              Get.toNamed(Routes.PILOTTRAININGHISTORYDETAILCC, arguments: {
                                "idTrainingType" : controller.idTrainingType.value,
                                "idAttendance" : listAttendance[index]["id"]
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
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
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      radius: 15,
                                      child: Text("${index+1}"),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                            flex: 4,
                                            child: Text(
                                              "Date",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              ":",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                            flex: 8,
                                            child: Text(
                                              formattedDate,
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Expanded(
                                            flex: 4,
                                            child: Text(
                                              "Valid To",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              ":",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                        Expanded(
                                            flex: 8,
                                            child: Text(
                                              "31 September 2023",
                                              style: tsOneTextTheme.labelMedium,
                                            )),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.navigate_next),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                )
                // InkWell(
                //   onTap: () {},
                //   child: Container(
                //     margin: EdgeInsets.symmetric(vertical: 5),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(10.0),
                //       color: Colors.white,
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.grey.withOpacity(0.3),
                //           spreadRadius: 2,
                //           blurRadius: 3,
                //           offset: const Offset(0, 2),
                //         ),
                //       ],
                //     ),
                //     child: ListTile(
                //       leading: CircleAvatar(
                //         radius: 15,
                //         child: Text("1"),
                //       ),
                //       title: Row(
                //         children: [
                //           Expanded(
                //               flex: 4,
                //               child: Text(
                //                 "Date",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //           Expanded(
                //               flex: 1,
                //               child: Text(
                //                 ":",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //           Expanded(
                //               flex: 8,
                //               child: Text(
                //                 "31 September 2023",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //         ],
                //       ),
                //       subtitle: Row(
                //         children: [
                //           Expanded(
                //               flex: 4,
                //               child: Text(
                //                 "Valid To",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //           Expanded(
                //               flex: 1,
                //               child: Text(
                //                 ":",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //           Expanded(
                //               flex: 8,
                //               child: Text(
                //                 "31 September 2023",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //         ],
                //       ),
                //       trailing: const Icon(Icons.navigate_next),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ));
  }
}
