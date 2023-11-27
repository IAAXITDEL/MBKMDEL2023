
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
    argumentid.value = Get.arguments["id"];
    argumentname.value = Get.arguments["name"];
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Membuat random string untuk key attendance
  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));


  //Membuat attendance baru
  Future<void> addAttendanceForm( String subject, DateTime date, String trainingType,String department,String room,String venue, int instructor, int idtrainingtype ) async {
    CollectionReference attendance = firestore.collection("attendance");

    String formattedDate = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
    try {
      if (instructor != 0) {
        await attendance.doc("attendance-$idtrainingtype-$formattedDate").set({
          "id" : "attendance-$idtrainingtype-$formattedDate",
          "subject": subject,
          "date": date,
          'trainingType' : trainingType,
          'department' : department,
          'room' : room,
          "venue": venue,
          "instructor": instructor,
          "status": "pending",
          "keyAttendance": getRandomString(6),
          "idTrainingType": idtrainingtype,
          "is_delete" : 0,
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
    return FirebaseFirestore.instance
        .collection('users')
        .where("INSTRUCTOR", arrayContainsAny: ["FIS", "FIA", "GI", "CCP"])
        .snapshots();
  }

}
