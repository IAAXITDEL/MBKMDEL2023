import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../util/empty_screen.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../../util/util.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/home_pilotcc_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;


class HomePilotccView extends GetView<HomePilotccController> {
  const HomePilotccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      "Hi, ${controller.titleToGreet} ${controller.nameC.value}!",
                      style: tsOneTextTheme.headlineLarge,
                    ),)
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Good ${controller.timeToGreet}',
                    style: tsOneTextTheme.labelMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 4.0),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          color: TsOneColor.onSecondary,
                          size: 32,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Util.convertDateTimeDisplay(DateTime.now().toString(), "EEEE"),
                            style: tsOneTextTheme.labelSmall,
                          ),
                          Text(
                            Util.convertDateTimeDisplay(DateTime.now().toString(), "dd MMMM yyyy"),
                            style: tsOneTextTheme.labelSmall,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Feedback Required ",
                      style: tsOneTextTheme.headlineMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: controller.getCombinedAttendanceStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingScreen(); // Placeholder while loading
                    }

                    if (snapshot.hasError) {
                      print(snapshot.error.toString());
                      return ErrorScreen();
                    }

                    var listAttendance= snapshot.data!;
                    if(listAttendance.isEmpty){
                      return EmptyScreenFeedbackRequired();
                    }


                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: listAttendance.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {

                          firestore.Timestamp? date = listAttendance[index]["date"];
                          DateTime? dates = date?.toDate();
                          String dateTraining = DateFormat('dd MMM yyyy').format(dates!);

                          return InkWell(
                            onTap: () {
                              Get.toNamed(Routes.PILOTTRAININGHISTORYDETAILCC, arguments: {
                                "idTrainingType": listAttendance[index]["idTrainingType"],
                                "idAttendance": listAttendance[index]["id"],
                                "idTraining": controller.idTrainee.value,
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


                              child: ListTile(
                                title: Text(
                                  listAttendance[index]["subject"],
                                  style: tsOneTextTheme.headlineMedium,
                                ),
                                subtitle: Text(
                                  dateTraining,
                                  style: tsOneTextTheme.labelSmall,
                                ),
                                trailing: const Icon(Icons.navigate_next),
                              ) ,
                            ),
                          );
                        }
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