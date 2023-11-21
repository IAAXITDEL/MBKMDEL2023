import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../di/locator.dart';
import '../../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../../presentation/view_model/attendance_model.dart';

class PilotfeedbackformccController extends GetxController {
  RxString idAttendance ="".obs;
  RxDouble rating = 1.0.obs;

  late UserPreferences userPreferences;
  RxDouble ratingTeachingMethod = 1.0.obs;
  RxDouble ratingMastery = 1.0.obs;
  RxDouble ratingTimeManagement = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    idAttendance.value = Get.arguments["idAttendance"];
    feedbackStream();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  //Mendapatkan data kelas yang diikuti
  Future<List<Map<String, dynamic>>> getCombinedAttendance() async {
    final attendanceQuery = await _firestore.collection('attendance').where("id", isEqualTo: idAttendance.value).get();

    List<Map<String, dynamic>> attendanceData = [];

    for (var doc in attendanceQuery.docs) {
      final attendanceModel = AttendanceModel.fromJson(doc.data());

      // Ambil informasi pengguna hanya untuk instruktur yang terkait
      final usersQuery = await _firestore.collection('users').where("ID NO", isEqualTo: attendanceModel.instructor).get();
      if (usersQuery.docs.isNotEmpty) {
        final userData = usersQuery.docs[0].data();

        // Ambil informasi yang diperlukan dari dokumen attendance
        Map<String, dynamic> data = {
          'subject': attendanceModel.subject,
          'date': attendanceModel.date,
          'name': userData['NAME'],
          'department':  attendanceModel.department,
          'trainingType': attendanceModel.trainingType,
          'venue': attendanceModel.venue,
          'room': attendanceModel.room,
        };

        attendanceData.add(data);
      }

    }

    return attendanceData;
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
        // "rating": rating.value,

        "rTeachingMethod": ratingTeachingMethod.value,
        "rMastery": ratingMastery.value,
        "rTimeManagement": ratingTimeManagement.value,
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

      if (attendanceDoc.data().containsKey('rTeachingMethod')) {
        attendance.rTeachingMethod = attendanceDoc['rTeachingMethod'];
      }

      if (attendanceDoc.data().containsKey('rMastery')) {
        attendance.rMastery = attendanceDoc['rMastery'];
      }

      if (attendanceDoc.data().containsKey('rTimeManagement')) {
        attendance.rTimeManagement = attendanceDoc['rTimeManagement'];
      }

      attendanceList.add(attendance);
    });

    // Check if the list is not empty before accessing its elements
    if (attendanceList.isNotEmpty) {
      rating.value = attendanceList[0].rating ?? 1.0;

      if (attendanceList[0].rTeachingMethod != null) {
        ratingTeachingMethod.value = attendanceList[0].rTeachingMethod!;
      }

      if (attendanceList[0].rMastery != null) {
        ratingMastery.value = attendanceList[0].rMastery!;
      }

      if (attendanceList[0].rTimeManagement != null) {
        ratingTimeManagement.value = attendanceList[0].rTimeManagement!;
      }
    }

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
