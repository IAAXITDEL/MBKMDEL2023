import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/routes/app_pages.dart';

import '../../../../presentation/view_model/attendance_model.dart';

class TrainingtypeccController extends GetxController {

  final RxInt argumentid = 0.obs;
  final RxString argumentname = "".obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List untuk training remark
  Stream<QuerySnapshot<Map<String, dynamic>>> attendanceStream(int id, String status) {
    return firestore
        .collection('attendance')
        .where("idTrainingType", isEqualTo: id)
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
      print(attendanceData[0].photoURL);
      return attendanceData;
    } catch (e) {
      print('Error fetching combined data: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(int id, String status) {
    return _firestore.collection('attendance').where("idTrainingType", isEqualTo: id).where("status", isEqualTo: status).snapshots().asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {});
          attendanceModel.name = user['NAME']; // Set 'nama' di dalam model
          attendanceModel.photoURL = user['PHOTOURL'];
          return attendanceModel.toJson();
        }),
      );

      print(attendanceData);
      return attendanceData;
    });
  }

  //delete Trainining
  Future<void> deleteTraining() async {
    CollectionReference training = _firestore.collection('trainingType');
    QuerySnapshot querySnapshot = await training.where("id", isEqualTo: argumentid.value).get();

    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      await document.reference.update({
        "is_delete": 1, // 1 indicates it has been deleted
      });
    }

    Get.toNamed(Routes.TRAININGCC);
  }





  // Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(int id, String status) {
  //   Stream<QuerySnapshot<Object?>> attendanceStream = _firestore.collection('attendance').snapshots();
  //   Stream<QuerySnapshot<Object?>> usersStream = _firestore.collection('users').snapshots();
  //
  //   return attendanceStream.asyncMap((attendanceQuery) async {
  //     final attendanceData = attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data())).toList();
  //
  //     // Ambil data pengguna dalam satu pengambilan
  //     final usersQuery = await usersStream.first;
  //     final usersData = usersQuery.docs.map((doc) => doc.data()).toList();
  //
  //     // Gabungkan data berdasarkan kondisi, misalnya instructor == ID NO
  //     for (final attendance in attendanceData) {
  //       final user = usersData.firstWhere((user) => user['ID NO'] == attendance.instructor, orElse: () => {});
  //       attendance.name = user['NAME']; // Set 'nama' di dalam model
  //     }
  //
  //     return attendanceData;
  //   });
  // }

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
