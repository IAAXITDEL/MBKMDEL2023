import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../../presentation/theme.dart';
import '../../../../../../util/empty_screen.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../../util/util.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/home_admincc_controller.dart';

class HomeAdminccView extends GetView<HomeAdminccController> {
  const HomeAdminccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30,),
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
              SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Need Confirmation",
                    style: tsOneTextTheme.headlineMedium,
                  )
                ],
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: controller.getCombinedAttendanceStream("confirmation"),
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

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: listAttendance.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Get.toNamed(Routes.ATTENDANCE_CONFIRCC,  arguments: {
                              "id" : listAttendance[index]["id"],
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
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
                                listAttendance[index]["name"],
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
              SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Waiting",
                    style: tsOneTextTheme.headlineMedium,
                  ),
                ],
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: controller.getCombinedAttendanceStream("pending"),
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

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: listAttendance.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Get.toNamed(Routes.ATTENDANCE_PENDINGCC,  arguments: {
                              "id" : listAttendance[index]["id"],
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
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
                                listAttendance[index]["name"],
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
      ),
    );
  }
}
