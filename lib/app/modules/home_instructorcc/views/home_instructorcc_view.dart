import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/theme.dart';
import '../../../../util/empty_screen.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../../util/util.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_instructorcc_controller.dart';

class HomeInstructorccView extends GetView<HomeInstructorccController> {
  const HomeInstructorccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hi, ${controller.titleToGreet}!",
                  style: tsOneTextTheme.headlineLarge,
                ),
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
            const RedTitleText(text: 'TRAINING OVERVIEW', size: 14,),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Training Simulator",
                  style: tsOneTextTheme.labelMedium,
                ),
                const Icon(Icons.search),
              ],
            ),
            const SizedBox(height: 20,),
            Expanded(child: StreamBuilder<List<Map<String, dynamic>>>(
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


                return ListView.builder(
                    itemCount: listAttendance.length,
                    itemBuilder: (context, index) {
                      return Container(
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
                              listAttendance[index]["date"],
                              style: tsOneTextTheme.labelSmall,
                            ),
                            trailing: const Icon(Icons.navigate_next),
                          ),
                        ),
                      );
                    }
                );
              },
            ),)
          ],
    );
  }
}
