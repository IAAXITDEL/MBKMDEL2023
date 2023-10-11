import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../../presentation/view_model/attendance_model.dart';

class PilottraininghistorydetailccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxInt idTrainingType = 0.obs;
  RxString idAttendance ="".obs;

  RxString trainingName = "".obs;

  @override
  void onInit() {
    super.onInit();
    idTrainingType.value = Get.arguments["idTrainingType"];
    idAttendance.value = Get.arguments["idAttendance"];
    getCombinedAttendance();
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
    final attendanceQuery = await firestore.collection('attendance').where("id", isEqualTo: idAttendance.value).get();

    List<Map<String, dynamic>> attendanceData = [];

    for (var doc in attendanceQuery.docs) {
      final attendanceModel = AttendanceModel.fromJson(doc.data());

      // Ambil informasi pengguna hanya untuk instruktur yang terkait
      final usersQuery = await firestore.collection('users').where("ID NO", isEqualTo: attendanceModel.instructor).get();
      if (usersQuery.docs.isNotEmpty) {
        final userData = usersQuery.docs[0].data();

        // Ambil informasi yang diperlukan dari dokumen attendance
        Map<String, dynamic> data = {
          'subject': attendanceModel.subject,
          'date': attendanceModel.date,
          'name': userData['NAME'],
          'department':  attendanceModel.department,
          'trainingType': attendanceModel.trainingType,
          'vanue': attendanceModel.vanue,
          'room': attendanceModel.room,
        };

        // Tambahkan data ke list
        attendanceData.add(data);
      }

      trainingName.value = attendanceModel.subject!;
    }

    return attendanceData;
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
