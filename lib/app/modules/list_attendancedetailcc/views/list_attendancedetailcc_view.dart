import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../presentation/theme.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../controllers/list_attendancedetailcc_controller.dart';

class ListAttendancedetailccView
    extends GetView<ListAttendancedetailccController> {
  const ListAttendancedetailccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Back'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric( vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: TsOneColor.surface,
              ),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.profileList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingScreen(); // Placeholder while loading
                    }

                    if (snapshot.hasError) {
                      return ErrorScreen();
                    }

                    var listAttendance = snapshot.data!.docs;
                    var documentData = listAttendance[0].data();

                    return Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Column(
                        children: [
                          AvatarGlow(
                            endRadius: 110,
                            glowColor: Colors.black,
                            duration: Duration(seconds: 2),
                            child: Container(
                                margin: EdgeInsets.all(15),
                                width: 175,
                                height: 175,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: documentData["PHOTOURL"] == null ?  Image.asset(
                                      "assets/images/placeholder_person.png",
                                      fit: BoxFit.cover,
                                    ) : Image.network("${documentData["PHOTOURL"]}", fit: BoxFit.cover),)),
                          ),
                          SizedBox(height: 20,),
                          Row(
                            children: [
                              Expanded(flex: 3, child: Text("SCORE")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(flex: 6, child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Pass",
                                      style: TextStyle(fontSize: 10, color: Colors.green),
                                    ),
                                  ),
                                ],
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(flex: 3, child: Text("NAME")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(
                                  flex: 6, child: Text(documentData["NAME"] ?? "N/A")),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(flex: 3, child: Text("EMAIL")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(
                                  flex: 6, child: Text(documentData["EMAIL"] ?? "N/A")),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(flex: 3, child: Text("RANK")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(flex: 6, child: Text(documentData["RANK"] ?? "N/A")),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(flex: 3, child: Text("LICENSE NO")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(
                                  flex: 6, child: Text( documentData["LICENSE NO."] ?? "N/A")),
                            ],
                          )
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      )
    );
  }
}
