import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../di/locator.dart';
import '../../../../../../presentation/view_model/attendance_model.dart';

class TrainingInstructorccController extends GetxController {

  final RxInt argumentid = RxInt((Get.arguments as Map<String, dynamic>)["id"]);
  final RxString argumentname = RxString((Get.arguments as Map<String, dynamic>)["name"]);
  late UserPreferences userPreferences;


  @override
  void onInit() {
    super.onInit();
    argumentid.value = (Get.arguments as Map<String, dynamic>)["id"] as int;
    final String name = (Get.arguments as Map<String, dynamic>)["name"];
    argumentname.value = name;
  }

  @override
  void onReady() {
    super.onReady();
  }


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(List<String> statuses) {
    userPreferences = getItLocator<UserPreferences>();
    return _firestore.collection('attendance')
        .where("idTrainingType", isEqualTo: argumentid.value)
        .where("instructor", isEqualTo: userPreferences.getIDNo())
        .where("status", whereIn: statuses)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').where("ID NO", isEqualTo: userPreferences.getIDNo()).get();
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

      attendanceData.sort((a, b) => b['date'].compareTo(a['date']));
      return attendanceData;
    });
  }




}
