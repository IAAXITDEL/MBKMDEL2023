import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/view_model/attendance_model.dart';

class AttendanceConfirccController extends GetxController {

  var selectedMeeting = "Training".obs;
  late UserPreferences userPreferences;

  void selectMeeting(String? newValue) {
    selectedMeeting.value = newValue ?? "Training"; // Default to "Meeting 1" if newValue is null
  }

  final RxString argumentid = "".obs;
  final RxString argumentname = "".obs;

  final RxString role = "".obs;
  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final String id = args["id"];
    argumentid.value = id;

    cekRole();
  }



  // Menampilkan attendance
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


  Future<void> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI INSTRUCTOR
    if( userPreferences.getInstructor().contains(UserModel.keySubPositionICC) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      role.value = "ICC";
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if( userPreferences.getRank().contains("Pilot Administrator")){
      role.value = "Pilot Administrator";
    }

    print(role.value);

  }

  //confir attendance oleh instructor
  Future<void> confirattendance(String departement, String trainingType, String room) async {
    CollectionReference attendance = _firestore.collection('attendance');
    await attendance.doc(argumentid.value.toString()).update({
      "departement": departement,
      "trainingType" :  trainingType,
      "room" : room,
      "attendance" : selectedMeeting.value,
      "status" : "confirmation",

      //signature icc url
    });
  }





}
