import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../data/users/user_preferences.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../presentation/view_model/attendance_model.dart';

class PilotfeedbackformccController extends GetxController {
  RxString idAttendance ="".obs;
  RxDouble rating = 1.0.obs;

  late UserPreferences userPreferences;

  @override
  void onInit() {
    super.onInit();
    idAttendance.value = Get.arguments["idAttendance"];
    feedbackStream();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // mendaptkan data attendance
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream() {
    return _firestore
        .collection('attendance')
        .where("id", isEqualTo: idAttendance.value)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere(
                  (user) => user['ID NO'] == attendanceModel.instructor,
              orElse: () => {});
          attendanceModel.name = user['NAME'];
          return attendanceModel.toJson();
        }),
      );
      return attendanceData;
    });
  }


  //feedback form
  Future<void> addFeedback(String feedback) async {
    CollectionReference attendancedetail = _firestore.collection('attendance-detail');
    userPreferences = getItLocator<UserPreferences>();

    QuerySnapshot querySnapshot = await attendancedetail
        .where("idattendance", isEqualTo: idAttendance.value.toString())
        .where("idtraining", isEqualTo: userPreferences.getIDNo())
        .get();

    querySnapshot.docs.forEach((doc) async {
      await doc.reference.update({
        "rating": rating.value,
        "feedbackforinstructor" : feedback,
        "updatedTime": DateTime.now().toIso8601String(),
      });
    });
  }


  Future<List<AttendanceDetailModel>> feedbackStream() async {
    userPreferences = getItLocator<UserPreferences>();
    final attendanceQuery = await _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: idAttendance.value)
        .where("idtraining", isEqualTo: userPreferences.getIDNo())
        .get();

    List<AttendanceDetailModel> attendanceList = [];
    attendanceQuery.docs.forEach((attendanceDoc) {
      AttendanceDetailModel attendance = AttendanceDetailModel();

      // Check if 'feedbackforinstructor' exists in the document
      if (attendanceDoc.data().containsKey('feedbackforinstructor')) {
        attendance.feedbackforinstructor = attendanceDoc['feedbackforinstructor'];
      }

      // Check if 'rating' exists in the document
      if (attendanceDoc.data().containsKey('rating')) {
        attendance.rating = attendanceDoc['rating'];
      }
      attendanceList.add(attendance);
    });

    rating.value = attendanceList.isNotEmpty ? attendanceList[0].rating ?? 1 : 1;
    return attendanceList;
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
