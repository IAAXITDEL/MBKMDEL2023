import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/detailhistorycc_cpts_controller.dart';

class DetailhistoryccCptsView extends GetView<DetailhistoryccCptsController> {
  final List<Map<String, dynamic>> listAttendance;

  const DetailhistoryccCptsView({Key? key, required this.listAttendance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: TrainingDetailsWidget(listAttendance: listAttendance),
      ),
    );
  }
}

class TrainingDetailsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> listAttendance;

  const TrainingDetailsWidget({Key? key, required this.listAttendance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      if (listAttendance.isEmpty) {
        return Center(
          child: Text('No training details available'),
        );
      }

    return Column(
      children: [
        //SUBJECT
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child:  Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text("Subject")),
              Expanded(
                  flex: 1,
                  child: Text(":")),
              Expanded(
                  flex: 4,
                  child: Text(listAttendance[0]["subject"] ?? "N/A")),
            ],
          ),
        ),

        //DEPARTEMENT
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child:  Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text("Department")),
              Expanded(
                  flex: 1,
                  child: Text(":")),
              Expanded(
                  flex: 4,
                  child: Text(listAttendance[0]["department"] ?? "N/A")),
            ],
          ),
        ),

        //TRAINING TYPE
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child:  Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text("Training Type")),
              Expanded(
                  flex: 1,
                  child: Text(":")),
              Expanded(
                  flex: 4,
                  child: Text(listAttendance[0]["trainingType"] ?? "N/A")),
            ],
          ),
        ),

        //DATE
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child:   Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text("Date")),
              Expanded(
                  flex: 1,
                  child: Text(":")),
              Expanded(
                  flex: 4,
                  child: Text(listAttendance[0]["date"] ?? "N/A")),
            ],
          ),
        ),

        //VANUE
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child:  Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text("Vanue")),
              Expanded(
                  flex: 1,
                  child: Text(":")),
              Expanded(
                  flex: 4,
                  child: Text(listAttendance[0]["vanue"] ?? "N/A")),
            ],
          ),
        ),

        //ROOM
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text("Room")),
              Expanded(
                  flex: 1,
                  child: Text(":")),
              Expanded(
                  flex: 4,
                  child: Text(listAttendance[0]["room"] ?? "N/A")),
            ],
          ),
        ),

        //INSTRUCTOR
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child:   Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text("Instructor")),
              Expanded(
                  flex: 1,
                  child: Text(":")),
              Expanded(
                  flex: 4,
                  child: Text(listAttendance[0]["name"] ?? "N/A")),
            ],
          ),
        ),
      ],
    );
  }
}