import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../di/locator.dart';
import '../../../../../data/users/users.dart';
import '../../../../../presentation/view_model/attendance_detail_model.dart';

class ListAttendanceccController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxString argumentid = "".obs;
  final RxString argumentstatus = "".obs;
  late TextEditingController searchC;
  RxInt jumlah  = 0.obs;
  RxString nameS = "".obs;

  final Rx<List<Map<String, dynamic>>> streamData = Rx<List<Map<String, dynamic>>>([]);
  late UserPreferences userPreferences;

  @override
  void onInit() {
    super.onInit();
    argumentid.value = Get.arguments["id"];
    argumentstatus.value = Get.arguments["status"];
    searchC = TextEditingController();
  }



  // Search dan List data attendance List
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(String name) {
    try {
      userPreferences = getItLocator<UserPreferences>();
      print(userPreferences.getRank());

      final statusFilter = userPreferences.getRank().contains("Pilot Administrator") || userPreferences.getInstructor().contains(UserModel.keyCPTS)
          ? ["donescoring"]
          : ["done", "donescoring"];

      return _firestore
          .collection('attendance-detail')
          .where("idattendance", isEqualTo: argumentid.value)
          .where("status", whereIn: statusFilter)
          .snapshots()
          .asyncMap((attendanceQuery) async {
        List<int?> traineeIds =
        attendanceQuery.docs.map((doc) => AttendanceDetailModel.fromJson(doc.data()).idtraining).toList();

        final usersData = <Map<String, dynamic>>[];

        if (traineeIds.isNotEmpty) {
          final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: traineeIds).get();
          usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
        }

        final attendanceData = await Future.wait(
          attendanceQuery.docs.map((doc) async {
            final attendanceModel = AttendanceDetailModel.fromJson(doc.data());
            final user = usersData.firstWhere(
                  (user) => user['ID NO'] == attendanceModel.idtraining,
              orElse: () => {},
            );
            attendanceModel.name = user['NAME'];
            return attendanceModel.toJson();
          }),
        );

        if (name.isNotEmpty) {
          final filteredData = attendanceData.where(
                (item) => item['name'].toString().toLowerCase().startsWith(name.toLowerCase()),
          ).toList();
          streamData.value = filteredData;
        } else {
          streamData.value = attendanceData;
        }

        jumlah.value = attendanceData.length;
        return streamData.value;
      });
    } catch (e) {
      print('An error occurred: $e');
      return Stream<List<Map<String, dynamic>>>.empty();
    }
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
