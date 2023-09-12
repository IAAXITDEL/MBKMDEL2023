import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../data/users/user_preferences.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/view_model/attendance_model.dart';

class TrainingInstructorccController extends GetxController {

  final RxInt argumentid = 0.obs;
  final RxString argumentname = "".obs;
  late UserPreferences userPreferences;
  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final int id = args["id"] as int;
    argumentid.value = id;
    final String name = (Get.arguments as Map<String, dynamic>)["name"];
    argumentname.value = name;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(int id, String status) {
    userPreferences = getItLocator<UserPreferences>();
    return _firestore.collection('attendance').where("idTrainingType", isEqualTo: id).where("instructor", isEqualTo: userPreferences.getIDNo()).where("status", isEqualTo: status).snapshots().asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').where("ID NO", isEqualTo: userPreferences.getIDNo()).get();
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

      return attendanceData;
    });
  }



}
