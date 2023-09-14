import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../presentation/view_model/attendance_detail_model.dart';

class ListAttendanceccController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxString argumentid = "".obs;
  final RxString argumentstatus = "".obs;
  late TextEditingController searchC;
  RxInt jumlah  = 0.obs;
  RxString nameS = "".obs;

  final Rx<List<Map<String, dynamic>>> streamData = Rx<List<Map<String, dynamic>>>([]);


  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final String id = args["id"];
    argumentid.value = id;

    final Map<String, dynamic> sta = Get.arguments as Map<String, dynamic>;
    final String status = sta["status"];
    argumentstatus.value = status;

    searchC = TextEditingController();
    attendanceStream();
  }



  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(String name) {
    print(name);
    return _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: argumentid.value)
        .where("status", isEqualTo: argumentstatus.value)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceDetailModel.fromJson(doc.data());
          final user = usersData.firstWhere(
                (user) => user['ID NO'] == attendanceModel.idpilot,
            orElse: () => {},
          );
          attendanceModel.name = user['NAME'];
          attendanceModel.rank = user['RANK'];
          attendanceModel.license = user['LICENSE NO.'];

          return attendanceModel.toJson();
        }),
      );
      if (name.isNotEmpty) {
        // Filter attendanceData by name
        final filteredData = attendanceData.where(
              (item) => item['name'].toString().toLowerCase().startsWith(name.toLowerCase()),
        ).toList();
        streamData.value = filteredData;
      } else {
        streamData.value = attendanceData;
      }

      return streamData.value; // Return the streamData value
    });
  }

  //mendapatkan panjang list attendance
  Future<int> attendanceStream() async {
    final attendanceQuery = await _firestore
        .collection('attendance-detail')
        .where("status", isEqualTo: "done")
        .where("idattendance", isEqualTo: argumentid.value)
        .get();

    jumlah.value = attendanceQuery.docs.length;
    return attendanceQuery.docs.length;
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
