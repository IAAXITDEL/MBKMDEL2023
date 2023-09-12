import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/theme.dart';
import '../../../../util/empty_screen.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../routes/app_pages.dart';
import '../controllers/training_instructorcc_controller.dart';

class TrainingInstructorccView extends StatefulWidget {
  final int id = (Get.arguments as Map<String, dynamic>)["id"];
  final String name = (Get.arguments as Map<String, dynamic>)["name"];
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
        title: const Text('Back', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RedTitleText(text: controller.argumentname.value),

            const SizedBox(height: 20,),
            //-------------------- TAB BAR ------------------------
            Container(
              child: TabBar(
                labelPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                indicatorColor: TsOneColor.primary,
                indicatorWeight: 3,
                labelColor: TsOneColor.primary,
                unselectedLabelColor: TsOneColor.secondaryContainer,
                controller: _tabController,
                tabs: const [
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
                    stream: controller.getCombinedAttendanceStream(widget.id, "pending"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingScreen(); // Placeholder while loading
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
                              subtitle: Text(listAttendance[index]["date"]),
                              trailing: const Icon(Icons.navigate_next),
                            );
                          }
                      );
                    },
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: controller.getCombinedAttendanceStream(widget.id, "confirmation"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingScreen(); // Placeholder while loading
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
                              subtitle: Text(listAttendance[index]["date"]),
                              trailing: const Icon(Icons.navigate_next),
                              onTap: () {
                                // Action when item is tapped
                              },
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
