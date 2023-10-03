import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../presentation/view_model/attendance_model.dart';

class AttendancePendingccController extends GetxController {
  final RxString argument = "".obs;
  final RxInt jumlah = 0.obs;
  @override
  void onInit() {
    super.onInit();
    final String id = (Get.arguments as Map<String, dynamic>)["id"];
    argument.value = id;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(String id) {
    return _firestore.collection('attendance').where("id", isEqualTo: id).snapshots().asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {});
          attendanceModel.name = user['NAME'];
          return attendanceModel.toJson();
        }),
      );
      return attendanceData;
    });
  }

  //mendapatkan panjang list attendance
  // Future<int> attendanceStream() async {
  //   final attendanceQuery = await _firestore
  //       .collection('attendance-detail')
  //       .where("idattendance", isEqualTo: argument.value)
  //       .where("status", isEqualTo: "done")
  //       .get();
  //
  //   jumlah.value = attendanceQuery.docs.length;
  //   return attendanceQuery.docs.length;
  // }

  Future<List<AttendanceDetailModel>> attendanceStream() async {
    final attendanceQuery = await _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: argument.value)
        .where("status", isEqualTo: "done")
        .get();

    List<AttendanceDetailModel> attendanceList = [];
    attendanceQuery.docs.forEach((attendanceDoc) {
      AttendanceDetailModel attendance = AttendanceDetailModel(
        idattendance: attendanceDoc['idattendance'] as String,
        status: attendanceDoc['status'] as String,
      );
      attendanceList.add(attendance);
    });

    jumlah.value = attendanceList.length;

    return attendanceList;
  }

  //delete attendance
  Future<void> deleteAttendance() async {
    CollectionReference attendance = _firestore.collection('attendance');
    await attendance.doc(argument.value).update({
      "is_delete": 1
    });

    Get.back();
  }

}
