import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/theme.dart';
import '../../../../util/empty_screen.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
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
            RedTitleText(text: 'TRAINING OVERVIEW', size: 14,),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Training Simulator",
                  style: tsOneTextTheme.labelMedium,
                ),
                Icon(Icons.search),
              ],
            ),
            SizedBox(height: 20,),
            Expanded(child: StreamBuilder<List<Map<String, dynamic>>>(
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
                    itemCount: listAttendance.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: (){

                          },
                          child: ListTile(
                            title: Text(
                              listAttendance[index]["subject"],
                              style: tsOneTextTheme.headlineMedium,
                            ),
                            subtitle: Text(
                              listAttendance[index]["date"],
                              style: tsOneTextTheme.labelSmall,
                            ),
                            trailing: Icon(Icons.navigate_next),
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
