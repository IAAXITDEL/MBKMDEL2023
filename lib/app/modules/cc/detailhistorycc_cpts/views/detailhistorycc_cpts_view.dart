import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../presentation/theme.dart';
import '../../../../../util/empty_screen.dart';
import '../../../../../util/error_screen.dart';
import '../../../../../util/loading_screen.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/detailhistorycc_cpts_controller.dart';


class DetailhistoryccCptsView extends StatefulWidget {
  DetailhistoryccCptsView({Key? key}) : super(key: key);

  @override
  _DetailhistoryccCptsView createState() => _DetailhistoryccCptsView();
}

class _DetailhistoryccCptsView extends State<DetailhistoryccCptsView>
with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final List<Map<String, dynamic>> listAttendance;

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
    DetailhistoryccCptsController controller = Get.find<DetailhistoryccCptsController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TRAINING DETAIL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),


            Container(
              child: TabBar(
                labelPadding: EdgeInsets.symmetric(horizontal: 1.0),
                indicatorColor: TsOneColor.primary,
                indicatorWeight: 2,
                labelColor: TsOneColor.primary,
                unselectedLabelColor: TsOneColor.secondaryContainer,
                controller: _tabController,
                tabs: [
                  Tab(text: "Information"),
                  Tab(text: "Feedback for Instructor"),
                ],
              ),
            ),
              Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Column(
                    children: [
                      //CLASS DETAIL
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: TsOneColor.surface,
                        ),
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: controller.getCombinedAttendance(),
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
                            DateTime? dates = listAttendance[0]["date"].toDate();
                            String dateC = DateFormat('dd MMMM yyyy').format(dates!);
                            return Column(
                              children: [
                                //SUBJECT
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 3, child: Text("Subject")),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                          flex: 4,
                                          child: Text(
                                              listAttendance[0]["subject"] ?? "N/A")),
                                    ],
                                  ),
                                ),

                                //DEPARTEMENT
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 3, child: Text("Department")),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                          flex: 4,
                                          child: Text(listAttendance[0]
                                          ["department"] ??
                                              "N/A")),
                                    ],
                                  ),
                                ),

                                //TRAINING TYPE
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 3, child: Text("Training Type")),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                          flex: 4,
                                          child: Text(listAttendance[0]
                                          ["trainingType"] ??
                                              "N/A")),
                                    ],
                                  ),
                                ),

                                //DATE
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 3, child: Text("Date")),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                          flex: 4,
                                          child: Text(
                                              dateC ?? "N/A")),
                                    ],
                                  ),
                                ),

                                //VENUE
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 3, child: Text("Venue")),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                          flex: 4,
                                          child: Text(
                                              listAttendance[0]["venue"] ?? "N/A")),
                                    ],
                                  ),
                                ),

                                //ROOM
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 3, child: Text("Room")),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                          flex: 4,
                                          child: Text(
                                              listAttendance[0]["room"] ?? "N/A")),
                                    ],
                                  ),
                                ),

                                //INSTRUCTOR
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 3, child: Text("Instructor")),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                          flex: 4,
                                          child: Text(listAttendance[0]
                                          ["trainer-name"] ??
                                              "N/A")),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      //LIST ATTENDANCE
                      InkWell(
                        onTap: () {
                          if (controller.jumlah.value > 0) {
                            Get.toNamed(
                              Routes.LIST_ATTENDANCECC,
                              arguments: {
                                "id": controller.idAttendance.value,
                                "status": "donescoring"
                              },
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: TsOneColor.secondaryContainer,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              "Attendance",
                              style: tsOneTextTheme.labelSmall,
                            ),
                            subtitle: Obx(
                                  () {
                                return Text(
                                  "${controller.jumlah.value.toString()} person",
                                  style: tsOneTextTheme.headlineMedium,
                                );
                              },
                            ),
                            trailing: Icon(Icons.navigate_next),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      //LIST ABSENT
                      InkWell(
                        onTap: () {
                          if (controller.jumlah.value > 0) {
                            Get.toNamed(
                              Routes.LIST_ABSENTCPTSCC,
                              arguments: {
                                "id": controller.idAttendance.value
                              },
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: TsOneColor.secondaryContainer,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              "Absent",
                              style: tsOneTextTheme.labelSmall,
                            ),
                            subtitle: Obx(() {
                              return Text(
                                "${controller.total.value.toString()} person",
                                style: tsOneTextTheme.headlineMedium,
                              );
                            }),
                            trailing: Icon(Icons.navigate_next),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        child: FutureBuilder<List<Map<String, dynamic>?>>(
                          future: controller.getFeedbackDataList(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return LoadingScreen(); // Placeholder while loading
                            }

                            if (snapshot.hasError) {
                              print("Error : ${snapshot.error}");
                              return ErrorScreen();
                            }

                            if (snapshot.data == null) {
                              return EmptyScreen();
                            }

                            var listFeedback = snapshot.data!;

                            if (listFeedback.isEmpty) {
                              return EmptyScreen();
                            }

                            SizedBox(
                              height: 15,
                            );

                            return Column(
                              children: [
                                // Text("Review", style: tsOneTextTheme.headlineMedium,),
                                SizedBox(height: 20,),
                                Text("${controller.allAverage.value.toStringAsFixed(1)}", style: tsOneTextTheme.displayLarge,),
                                RatingBar.builder(
                                  initialRating: controller.allAverage.value,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemPadding: EdgeInsets.symmetric(
                                      horizontal: 1.0),
                                  itemSize: 20.0,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  ignoreGestures: true,
                                  onRatingUpdate: (rating) {
                                    print(rating);
                                  },
                                ),
                                Text("Based on ${listFeedback.length} reviews", style: tsOneTextTheme.labelSmall,),
                                SizedBox(height: 20,),
                                controller.averageRTeachings.value != 0.0 ?
                                Row(
                                  children: [
                                    Expanded(flex : 2, child: Text("Teaching Methods", style: tsOneTextTheme.labelSmall,)),
                                    Expanded(
                                      flex: 3,
                                      child: Obx(() {
                                        return Slider(
                                          value: controller.averageRTeachings.value,
                                          min: 1,
                                          max: 5,
                                          divisions: 4,
                                          label: controller.averageRTeachings.value
                                              .round()
                                              .toString(),
                                          onChanged: (double value) {
                                          },
                                          // activeColor: Colors.purple[900],
                                          activeColor : Color(0XFFFFFB000),
                                        );
                                      }),
                                    ),
                                    Text("${controller.averageRTeachings.value
                                        .toStringAsFixed(1)
                                        .toString()}/5", style: tsOneTextTheme.labelSmall,),
                                  ],
                                ) : SizedBox(),
                                controller.averageRMastery.value != 0.0 ?
                                Row(
                                  children: [
                                    Expanded(flex : 2, child: Text("Proficiency", style: tsOneTextTheme.labelSmall,)),
                                    Expanded(
                                      flex: 3,
                                      child: Obx(() {
                                        return Slider(
                                          value: controller.averageRMastery.value,
                                          min: 1,
                                          max: 5,
                                          divisions: 4,
                                          label: controller.averageRMastery.value
                                              .round()
                                              .toString(),
                                          onChanged: (double value) {
                                          },
                                          //activeColor: Colors.green[900],
                                          activeColor : Color(0XFFF004225),
                                        );
                                      }),
                                    ),
                                    Text("${controller.averageRMastery.value
                                        .toStringAsFixed(1)}/5", style: tsOneTextTheme.labelSmall,),
                                  ],
                                ) : SizedBox(),
                                controller.averageRTimes.value != 0.0 ?
                                Row(
                                  children: [
                                    Expanded(flex: 2,child: Text("Time Management", style: tsOneTextTheme.labelSmall,)),
                                    Expanded(
                                      flex: 3,
                                      child: Obx(() {
                                        return Slider(
                                          value: controller.averageRTimes.value,
                                          min: 1,
                                          max: 5,
                                          divisions: 4,
                                          label: controller.averageRTimes.value
                                              .round()
                                              .toString(),
                                          onChanged: (double value) {
                                            controller.averageRTimes.value =
                                                value;
                                          },
                                          //activeColor: Colors.red[900],
                                          activeColor : Color(0XFFF071952),
                                        );
                                      }),
                                    ),
                                    Text("${controller.averageRTimes.value
                                        .toStringAsFixed(1)}/5", style: tsOneTextTheme.labelSmall,),
                                  ],
                                ) : SizedBox(),
                                SizedBox(height: 20,),
                                ListView.builder(
                                  itemCount: listFeedback.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(right: 16),
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Colors.black26,
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(100),
                                                  child: listFeedback[index]
                                                  !["photoURL"] ==
                                                      null
                                                      ? Image.asset(
                                                    "assets/images/placeholder_person.png",
                                                    fit: BoxFit.cover,
                                                  )
                                                      : Image.network(
                                                    "${listFeedback[index]!["photoURL"]}",
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  // listFeedback[index]["traineeName"] ??
                                                  //     "N/A",
                                                  listFeedback[index]!["name"]
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold),
                                                  maxLines: 1,
                                                ),
                                                // RatingBar.builder(
                                                //   initialRating: listFeedback[index]
                                                //   !['rating'] !=
                                                //       null
                                                //       ? double.tryParse(
                                                //       listFeedback[index]
                                                //       !['rating']
                                                //           .toString()) ??
                                                //       0.0
                                                //       : 0.0,
                                                //   minRating: 1,
                                                //   direction: Axis.horizontal,
                                                //   allowHalfRating: false,
                                                //   itemCount: 5,
                                                //   itemPadding: EdgeInsets.symmetric(
                                                //       horizontal: 1.0),
                                                //   itemSize: 20.0,
                                                //   itemBuilder: (context, _) => Icon(
                                                //     Icons.star,
                                                //     color: Colors.amber,
                                                //   ),
                                                //   ignoreGestures: true,
                                                //   onRatingUpdate: (rating) {
                                                //     print(rating);
                                                //   },
                                                // ),
                                                Text(
                                                  listFeedback[index]
                                                  ?["feedbackforinstructor"] ??
                                                      "-",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.normal),
                                                  maxLines:
                                                  2, // Set the maximum number of lines you want to display
                                                  overflow: TextOverflow
                                                      .ellipsis, // Specify how to handle overflow
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ) ;
                                  },
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  )
                ])),
          ],
        ),
      ),
    );
  }
}
