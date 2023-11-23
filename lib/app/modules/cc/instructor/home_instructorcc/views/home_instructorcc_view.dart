import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../../presentation/theme.dart';
import '../../../../../../util/empty_screen.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../../util/util.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/home_instructorcc_controller.dart';

class HomeInstructorccView extends GetView<HomeInstructorccController> {
  const HomeInstructorccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hi, ${controller.titleToGreet} ${controller.nameC.value}!",
                        style: tsOneTextTheme.headlineLarge,
                      ),
                    ],
                  ),),
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
                  SizedBox(height: 20,),
                  Text(
                    "TRAINING OVERVIEW",
                    style: tsOneTextTheme.headlineMedium,
                  ),
                  // const SizedBox(height: 20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       "Training Simulator",
                  //       style: tsOneTextTheme.labelMedium,
                  //     ),
                  //     const Icon(Icons.search),
                  //   ],
                  // ),
                  // const SizedBox(height: 10,),

                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: controller.getCombinedAttendanceStream("pending"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingScreen();
                      }

                      if (snapshot.hasError) {
                        return const ErrorScreen();
                      }

                      var listAttendance= snapshot.data!;

                      if(listAttendance.isEmpty){
                        return const EmptyScreen();
                      }

                      listAttendance.sort((a, b) {
                        DateTime dateA = (a["date"]).toDate();
                        DateTime dateB = (b["date"]).toDate();
                        return dateA.compareTo(dateB); // Compare in descending order
                      });
                      
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: listAttendance.length,
                          itemBuilder: (context, index) {
                            DateTime? dateTime = listAttendance[index]["date"].toDate();
                            String dateC = dateTime != null ? DateFormat('dd MMMM yyyy').format(dateTime) : 'Invalid Date';
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
                              child: InkWell(
                                onTap: () => Get.toNamed(Routes.ATTENDANCE_INSTRUCTORCONFIRCC,  arguments: {
                                  "id" : listAttendance[index]["id"],
                                }),
                                child: ListTile(
                                  title: Text(
                                    listAttendance[index]["subject"],
                                    style: tsOneTextTheme.headlineMedium,
                                  ),
                                  subtitle: Text(
                                    dateC,
                                    style: tsOneTextTheme.labelSmall,
                                  ),
                                  trailing: const Icon(Icons.navigate_next),
                                ),
                              ),
                            );
                          }
                      );
                    },
                  )
                ],
              )
          ),
        )
    );
  }
}
