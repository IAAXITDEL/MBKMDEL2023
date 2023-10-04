import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../../presentation/view_model/attendance_model.dart';

class PilottraininghistorydetailccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxInt idTrainingType = 0.obs;
  RxString idAttendance ="".obs;

  @override
  void onInit() {
    super.onInit();
    idTrainingType.value = Get.arguments["idTrainingType"];
    idAttendance.value = Get.arguments["idAttendance"];
  }

  //Mendapatkan Training
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return firestore
        .collection('trainingType')
        .where("id", isEqualTo: idTrainingType.value)
        .snapshots();
  }

  //Mendapatkan data kelas yang diikuti
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream() {
    return firestore.collection('attendance').where("id", isEqualTo: idAttendance.value).snapshots().asyncMap((attendanceQuery) async {
      final usersQuery = await firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {});
          attendanceModel.name = user['NAME'];
          attendanceModel.photoURL = user['PHOTOURL'];
          return attendanceModel.toJson();
        }),
      );

      return attendanceData;
    });
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
