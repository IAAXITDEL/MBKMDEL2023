import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../util/empty_screen.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../routes/app_pages.dart';
import '../../../../pa/navinstructor/views/navinstructor_view.dart';
import '../controllers/training_instructorcc_controller.dart';

class TrainingInstructorccView extends StatefulWidget {
  TrainingInstructorccView({Key? key}) : super(key: key);

  @override
  _TrainingInstructorccViewState createState() => _TrainingInstructorccViewState();
}

class _TrainingInstructorccViewState extends State<TrainingInstructorccView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TrainingInstructorccController controller = Get.find<TrainingInstructorccController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(()=>NavinstructorView(initialIndex: 1,));
          },
        ),
        title: RedTitleText(text: "TRAINING",),
        centerTitle: true,
      ),
      body:  Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RedTitleText(text: controller.argumentname.value),

            SizedBox(height: 20,),
            //-------------------- TAB BAR ------------------------
            Container(
              child: TabBar(
                labelPadding: EdgeInsets.symmetric(horizontal: 1.0),
                indicatorColor: TsOneColor.primary,
                indicatorWeight: 3,
                labelColor: TsOneColor.primary,
                unselectedLabelColor: TsOneColor.secondaryContainer,
                controller: _tabController,
                tabs: [
                  Tab(text: "Confirmation"),
                  Tab(text: "Done",)
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: controller.getCombinedAttendanceStream(["pending"]),
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
                            DateTime? dateTime = listAttendance[index]["date"].toDate();
                            String dateC = dateTime != null ? DateFormat('dd MMMM yyyy').format(dateTime) : 'Invalid Date';

                            return ListTile(
                              onTap: () => Get.toNamed(Routes.ATTENDANCE_INSTRUCTORCONFIRCC,  arguments: {
                                "id" : listAttendance[index]["id"],
                                "name" : listAttendance[index]["subject"],
                              }),
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black26,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child : listAttendance[index]["photoURL"] == "noimage" ?  Image.asset(
                                    "assets/images/placeholder_person.png",
                                    fit: BoxFit.cover,
                                  ) : Image.network("${listAttendance[index]["photoURL"]}", fit: BoxFit.cover),),
                              ),
                              title: Text(listAttendance[index]["subject"].toString()),
                              subtitle: Text(dateC),
                              trailing: Icon(Icons.navigate_next),
                            );
                          }
                      );
                    },
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: controller.getCombinedAttendanceStream(["confirmation", "done"]),
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
                            DateTime? dateTime = listAttendance[index]["date"].toDate();
                            String dateC = dateTime != null ? DateFormat('dd MMMM yyyy').format(dateTime) : 'Invalid Date';

                            return ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black26,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child : listAttendance[index]["photoURL"] == "noimage" ?  Image.asset(
                                    "assets/images/placeholder_person.png",
                                    fit: BoxFit.cover,
                                  ) : Image.network("${listAttendance[index]["photoURL"]}", fit: BoxFit.cover),),
                              ),
                              title: Text(listAttendance[index]["name"].toString()),
                              subtitle: Text(dateC),
                              trailing: Icon(Icons.navigate_next),
                              onTap: () => Get.toNamed(Routes.ATTENDANCE_CONFIRCC,  arguments: {
                                "id" : listAttendance[index]["id"],
                              }),
                            );
                          }
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}