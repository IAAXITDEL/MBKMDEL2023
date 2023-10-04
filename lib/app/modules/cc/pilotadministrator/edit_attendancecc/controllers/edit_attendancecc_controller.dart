import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditAttendanceccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final RxString argument = "".obs;
  final RxInt instructor = 0.obs;
  @override
  void onInit() {
    super.onInit();
    final String id = (Get.arguments as Map<String, dynamic>)["id"];
    argument.value = id;
  }


  // List untuk asign Instructor
  Stream<QuerySnapshot<Map<String, dynamic>>> attendanceStream() {
    return firestore
        .collection('attendance')
        .where("id", isEqualTo: argument.value)
        .snapshots();
  }


  // List untuk asign Instructor
  Stream<QuerySnapshot<Map<String, dynamic>>> instructorStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where("INSTRUCTOR", arrayContainsAny: ["FIS", "FIA", "GI", "CCP"])
        .snapshots();
  }


  //Edit Attendance Form
  Future<void> editAttendanceForm(String subject, String date, String vanue, int instructor) async {
    CollectionReference attendance = firestore.collection("attendance");
    try {
      if (instructor != 0) {
        await attendance.doc(argument.value).update({
          "subject": subject,
          "date": date,
          "vanue": vanue,
          "instructor": instructor,
          "updatedTime": DateTime.now().toIso8601String(),
        });
      } else {
        print("tidak bisa");
      }
    } catch (e) {
      // Handle any exceptions that may occur during the operation.
    }
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
