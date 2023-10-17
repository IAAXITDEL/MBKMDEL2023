import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ts_one/presentation/view_model/attendance_detail_model.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../data/users/users.dart';
import '../../../../../../di/locator.dart';
import '../../../../../../presentation/view_model/attendance_model.dart';

class PilottraininghistorydetailccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxInt idTrainingType = 0.obs;
  RxString idAttendance = "".obs;
  RxString trainingName = "".obs;

  late UserPreferences userPreferences;

  final RxBool isTrainee = false.obs;

  @override
  void onInit() {
    super.onInit();
    idTrainingType.value = Get.arguments["idTrainingType"];
    idAttendance.value = Get.arguments["idAttendance"];
    getCombinedAttendance();
    cekRole();
  }

  //Mendapatkan Training
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return firestore
        .collection('trainingType')
        .where("id", isEqualTo: idTrainingType.value)
        .snapshots();
  }

  //Mendapatkan data kelas yang diikuti
  Future<List<Map<String, dynamic>>> getCombinedAttendance() async {
    final attendanceQuery = await firestore
        .collection('attendance')
        .where("id", isEqualTo: idAttendance.value)
        .get();

    final attendanceDetailQuery = await firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: idAttendance.value)
        .get();

    List<Map<String, dynamic>> attendanceData = [];

    for (var doc in attendanceQuery.docs) {
      final attendanceDetailModel = AttendanceDetailModel.fromJson(doc.data());

      for (var doc in attendanceQuery.docs) {
        final attendanceModel = AttendanceModel.fromJson(doc.data());

        // Ambil informasi pengguna hanya untuk trainer yang terkait
        final trainersQuery = await firestore
            .collection('users')
            .where("ID NO", isEqualTo: attendanceModel.instructor)
            .get();

        // Ambil informasi pengguna hanya untuk trainee yang terkait
        final traineesQuery = await firestore
            .collection('users')
            .where("ID NO", isEqualTo: attendanceDetailModel.idtraining)
            .get();

        // Ambil informasi pengguna hanya untuk trainee yang terkait
        final attendanceDetailsQuery = await firestore
            .collection('attendance-detail')
            .where("idattendance", isEqualTo: attendanceModel.id)
            .get();
        if (trainersQuery.docs.isNotEmpty) {
          final trainerData = trainersQuery.docs[0].data();
          final traineeData = traineesQuery.docs[0].data();
          final attendanceDetailData = attendanceDetailsQuery.docs[0].data();

          // Ambil informasi yang diperlukan dari dokumen attendance
          Map<String, dynamic> data = {
            'subject': attendanceModel.subject,
            'date': attendanceModel.date,
            'trainer-name': trainerData['NAME'],
            'trainee-name' : traineeData['NAME'],
            'department': attendanceModel.department,
            'trainingType': attendanceModel.trainingType,
            'vanue': attendanceModel.vanue,
            'room': attendanceModel.room,
            'feedback-from-trainer': attendanceDetailData['feedback'],
            'feedback-from-trainee': attendanceDetailData['feedbackforinstructor'],
            'rating' : attendanceDetailData['rating'],
          };

          // Tambahkan data ke list
          attendanceData.add(data);
        }

        trainingName.value = attendanceModel.subject!;
      }
    }

    return attendanceData;
  }

  Future<bool> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if (userPreferences.getInstructor().contains(UserModel.keyCPTS) &&
        userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
    }
    // SEBAGAI INSTRUCTOR
    else if (userPreferences
        .getInstructor()
        .contains(UserModel.keySubPositionCCP) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionPGI) &&
            userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
    }
    // SEBAGAI PILOT
    else if (userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      isTrainee.value = true;
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if (userPreferences.getRank().contains("Pilot Administrator")) {
    }
    // SEBAGAI ALL STAR
    else {
      return false;
    }
    return false;
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
