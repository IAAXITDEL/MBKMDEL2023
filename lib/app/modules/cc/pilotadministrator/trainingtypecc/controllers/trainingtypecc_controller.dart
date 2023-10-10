import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/routes/app_pages.dart';

import '../../../../../../presentation/view_model/attendance_model.dart';


class TrainingtypeccController extends GetxController {

  final RxInt argumentid = 0.obs;
  final RxString argumentname = "".obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List untuk training remark
  Stream<QuerySnapshot<Map<String, dynamic>>> attendanceStream(int id, String status) {
    return firestore
        .collection('attendance')
        .where("idTrainingType", isEqualTo: id)
        .where("is_delete", isEqualTo: 0)
        .where("status", isEqualTo: status)
        .snapshots();
  }


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AttendanceModel>> thisc() async {
    try {
      final attendanceQuery = await _firestore.collection('attendance').get();
      final usersQuery = await _firestore.collection('users').get();

      final attendanceData = attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data())).toList();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      // Gabungkan data berdasarkan kondisi, misalnya instructor == ID NO
      for (final attendance in attendanceData) {
        final user = usersData.firstWhere((user) => user['ID NO'] == attendance.instructor, orElse: () => {});
        attendance.name = user['NAME']; // Set 'nama' di dalam model
        attendance.photoURL = user['PHOTOURL'];
      }
      return attendanceData;
    } catch (e) {
      print('Error fetching combined data: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(int id, String status) {
    return _firestore
        .collection('attendance')
        .where("idTrainingType", isEqualTo: id)
        .where("status", isEqualTo: status)
        .where("is_delete", isEqualTo: 0)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      List<int?> instructorIds =
      attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data()).instructor).toList();

      final usersData = <Map<String, dynamic>>[];

      if (instructorIds.isNotEmpty) {
        final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: instructorIds).get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {});
          attendanceModel.name = user['NAME'] ?? 'N/A';
          attendanceModel.photoURL = user['PHOTOURL'] ?? 'N/A';
          return attendanceModel.toJson();
        }),
      );

      return attendanceData;
    });
  }


  //delete Trainining
  Future<void> deleteTraining() async {
    CollectionReference training = _firestore.collection('trainingType');
    QuerySnapshot querySnapshot = await training.where("id", isEqualTo: argumentid.value).get();

    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      await document.reference.update({
        "is_delete": 1,
      });
    }

    Get.offAllNamed(Routes.TRAININGCC);
  }

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final int id = args["id"] as int;
    argumentid.value = id;

    final String name = (Get.arguments as Map<String, dynamic>)["name"];
    argumentname.value = name;
  }



}
