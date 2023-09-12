
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class AddAttendanceccController extends GetxController {

  final RxInt argumentid = 0.obs;
  final RxString argumentname = "".obs;
  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final int id = args["id"] as int;
    argumentid.value = id;
    final String name = (Get.arguments as Map<String, dynamic>)["name"];
    argumentname.value = name;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Membuat random string untuk key attendance
  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));


  //Membuat attendance baru
  Future<void> addAttendanceForm( String subject, String date, String vanue, int instructor, int idtrainingtype ) async {
    CollectionReference attendance = firestore.collection("attendance");

    String formattedDate = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
    try {
      if (instructor != 0) {
        await attendance.doc("attendance-$idtrainingtype-$formattedDate").set({
          "id" : "attendance-$idtrainingtype-$formattedDate",
          "subject": subject,
          "date": date,
          "vanue": vanue,
          "instructor": instructor,
          "status": "pending",
          "keyAttendance": getRandomString(6),
          "idTrainingType": idtrainingtype,
          "room" : null,
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
        .where("INSTRUCTOR", arrayContains: "ICC")
        .snapshots();
  }





}
