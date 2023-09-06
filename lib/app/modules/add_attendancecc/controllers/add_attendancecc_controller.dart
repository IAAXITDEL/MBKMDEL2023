
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

import '../../../../presentation/shared_components/customdialogbox.dart';

class AddAttendanceccController extends GetxController {


  @override
  void onInit() {
    super.onInit();
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Membuat random string untuk key attendance
  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));


  //Membuat attendance baru
  Future<void> addAttendanceForm( String subject, String date, String vanue, int instructor, int idtrainingtype ) async {
    CollectionReference attendance = firestore.collection("attendance");

    String formattedDate = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
    try {
      if (instructor != 0) {
        await attendance.doc("attendance-${idtrainingtype}-${formattedDate}").set({
          "id" : "attendance-${idtrainingtype}-${formattedDate}",
          "subject": subject,
          "date": date,
          "vanue": vanue,
          "instructor": instructor,
          "status": "pending",
          "keyAttendance": getRandomString(6),
          "idTrainingType": idtrainingtype,
          "creationTime": DateTime.now().toIso8601String(),
          "updatedTime": DateTime.now().toIso8601String(),
        });
      } else {

        print("tidak bisa");
      }
    } catch (e) {
      // Handle any exceptions that may occur during the operation.
    }
  }


  // List untuk asign Instructor
  Stream<QuerySnapshot<Map<String, dynamic>>> instructorStream() {
    return firestore
        .collection('users')
        .where("INSTRUCTOR", arrayContains: "CC")
        .snapshots();
  }



  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
