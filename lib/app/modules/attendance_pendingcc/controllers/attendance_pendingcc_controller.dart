import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

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

      print(attendanceData);
      return attendanceData;
    });
  }

  //mendapatkan panjang list attendance
  Future<int> attendanceStream() async {
    final attendanceQuery = await _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: argument.value)
        .get();

    jumlah.value = attendanceQuery.docs.length;
    print(attendanceQuery.docs.length);
    return attendanceQuery.docs.length;
  }




}
