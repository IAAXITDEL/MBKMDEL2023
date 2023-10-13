import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:get/get.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../../presentation/theme.dart';
import '../../../../../../util/empty_screen.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/pilottraininghistorydetailcc_controller.dart';

class PilottraininghistorydetailccView
    extends GetView<PilottraininghistorydetailccController> {
  const PilottraininghistorydetailccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: //--------------KELAS TRAINING-------------
            RedTitleText(
          text: "${controller.trainingName.value} TRAINING",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Text(
                  "Congratulations!",
                  style: tsOneTextTheme.headlineLarge,
                ),
                Text(
                  "Congratulations for passing the training!",
                  style: tsOneTextTheme.labelSmall,
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 1.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                bottomLeft: Radius.circular(20.0),
                              ),
                            ),
                          ),
                          child: Text("Download Certificate")),
                    ),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            Get.toNamed(Routes.PILOTFEEDBACKFORMCC, arguments: {
                              "idAttendance": controller.idAttendance.value,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 1.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                            ),
                          ),
                          child: Text("Give Feedback")),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),

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
                                        listAttendance[0]["date"] ?? "N/A")),
                              ],
                            ),
                          ),
                          //VANUE
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text("Vanue")),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                        listAttendance[0]["vanue"] ?? "N/A")),
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
                                    child: Text(
                                        listAttendance[0]["name"] ?? "N/A")),
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

                //FEEDBACK FROM TRAINER
                Container(
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

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feedback from Trainer',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    right: 16), // Adjust the margin as needed
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.black26,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: listAttendance[0]["PHOTOURL"] == null
                                        ? Image.asset(
                                            "assets/images/placeholder_person.png",
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            "${listAttendance[0]["PHOTOURL"]}",
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listAttendance[0]["trainer-name"],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          250, // Adjust the width as needed
                                    ),
                                    child: Text(
                                      listAttendance[0]["feedback-from-trainer"] ?? "N/A",
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                //FEEDBACK FROM TRAINEE
                Container(
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

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feedback from Trainee',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    right: 16),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.black26,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: listAttendance[0]["PHOTOURL"] == null
                                        ? Image.asset(
                                      "assets/images/placeholder_person.png",
                                      fit: BoxFit.cover,
                                    )
                                        : Image.network(
                                      "${listAttendance[0]["PHOTOURL"]}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listAttendance[0]["trainee-name"],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                  ),
                                  RatingBar.builder(
                                    initialRating: listAttendance[0]["rating"].toDouble(), // Ubah rating sesuai data Anda
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                    itemSize: 20.0,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating); // Anda dapat meng-handle perubahan rating di sini
                                    },
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 250,
                                    ),
                                    child: Text(
                                      listAttendance[0]["feedback-from-trainee"] ?? "N/A",
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                      ;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
