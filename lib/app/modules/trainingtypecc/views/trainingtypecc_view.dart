import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../presentation/theme.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../routes/app_pages.dart';
import '../controllers/trainingtypecc_controller.dart';


class TrainingtypeccView extends StatefulWidget {
  final int id = (Get.arguments as Map<String, dynamic>)["id"];
  final String name = (Get.arguments as Map<String, dynamic>)["name"];
  TrainingtypeccView({Key? key}) : super(key: key);

  @override
  _TrainingtypeccViewState createState() => _TrainingtypeccViewState();
}

class _TrainingtypeccViewState extends State<TrainingtypeccView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TrainingtypeccController controller = Get.find<TrainingtypeccController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Back', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RedTitleText(text: widget.name),
            Text("REDUCED VERTICAL SEPARATION MINIMA"),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.ADD_ATTENDANCECC, arguments: {
                      "id" : widget.id,
                      "name" : widget.name
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(7),
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: TsOneColor.greenColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_box_outlined,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Add Attendance",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),

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
                  Tab(text: "Pending"),
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
                        return LoadingScreen(); // Placeholder while loading
                      }

                      if (snapshot.hasError) {
                        return ErrorScreen();
                      }

                      var listAttendance= snapshot.data!;

                      return ListView.builder(
                          itemCount: listAttendance.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () => Get.toNamed(Routes.ATTENDANCE_CONFIRCC(listAttendance[index]["id"]),  arguments: {
                                "id" : listAttendance[index]["id"],
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
                              title: Text(listAttendance[index]["name"].toString()),
                              subtitle: Text(listAttendance[index]["date"]),
                              trailing: Icon(Icons.navigate_next),
                            );
                          }
                      );
                    },
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: controller.getCombinedAttendanceStream(widget.id, "confirmation"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingScreen(); // Placeholder while loading
                      }

                      if (snapshot.hasError) {
                        return ErrorScreen();
                      }

                      var listAttendance= snapshot.data!;

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
                              trailing: Icon(Icons.navigate_next),
                              onTap: () {
                                // Action when item is tapped
                              },
                            );
                          }
                      );
                    },
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: controller.getCombinedAttendanceStream(widget.id, "done"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingScreen(); // Placeholder while loading
                      }

                      if (snapshot.hasError) {
                        return ErrorScreen();
                      }

                      var listAttendance= snapshot.data!;

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
                              trailing: Icon(Icons.navigate_next),
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
