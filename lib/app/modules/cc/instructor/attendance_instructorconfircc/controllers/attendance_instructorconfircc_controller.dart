import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../data/users/users.dart';
import '../../../../../../di/locator.dart';
import '../../../../../../presentation/view_model/attendance_model.dart';

class AttendanceInstructorconfirccController extends GetxController {
  var selectedMeeting = "Training".obs;
  late UserPreferences userPreferences;
  // late RxString dropdownValueDepartment = "".obs;
  // late RxString dropdownValueTrainingType = "".obs;
  // late RxString dropdownValueRoom = "".obs;

  void selectMeeting(String? newValue) {
    selectedMeeting.value = newValue ?? "Training";
  }

  final RxString argumentid = "".obs;
  final RxInt argumentTrainingType = 0.obs;
  final RxString argumentname = "".obs;
  final RxInt jumlah = 0.obs;
  final RxString role = "".obs;

  final RxBool ceksign = false.obs;
  final RxBool showText = false.obs;

  final RxBool cekScoring = false.obs;
  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final String id = args["id"];
    argumentid.value = id;
    attendanceStream();
    cekRole();
  }



  // Menampilkan attendance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(String id) {
    return _firestore.collection('attendance').where("id", isEqualTo: id).snapshots().asyncMap((attendanceQuery) async {
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
          attendanceModel.name = user['NAME'];
          attendanceModel.loano = user['LOA NO'];
          return attendanceModel.toJson();
        }),
      );
      argumentTrainingType.value = attendanceData[0]["idTrainingType"];
      return attendanceData;
    });
  }


  Future<void> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI INSTRUCTOR
    if(userPreferences.getInstructor().contains(UserModel.keySubPositionCCP) || userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) || userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) || userPreferences.getInstructor().contains(UserModel.keySubPositionPGI) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      role.value = "ICC";
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if( userPreferences.getRank().contains("Pilot Administrator")){
      role.value = "Pilot Administrator";
    }

  }

  //confir attendance oleh instructor
  Future<void> confirattendance(String loano, String remarks) async {
    CollectionReference attendance = _firestore.collection('attendance');
    await attendance.doc(argumentid.value.toString()).update({
    //   "department": department,
    //   "trainingType" :  trainingType,
    //   "room" : room,
      "attendanceType" : selectedMeeting.value,
      "status" : "confirmation",
      "remarks" : remarks,
      "updatedTime": DateTime.now().toIso8601String(),
      "keyAttendance" : null
      //signature icc url
    });


    QuerySnapshot querySnapshot = await _firestore.collection('attendance-detail')
        .where("idattendance", isEqualTo: argumentid.value.toString())
        .get();


    querySnapshot.docs.forEach((doc) async {
      await doc.reference.update({
        "updatedTime": DateTime.now().toIso8601String(),
      });
    });

    // update LOA NO pada instructor
    userPreferences = getItLocator<UserPreferences>();
    await _firestore.collection("users").doc(userPreferences.getIDNo().toString()).update({
      "LOA NO": loano,
    });
  }


  //mendapatkan panjang list attendance
  Stream<int> attendanceStream() {
    return _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: argumentid.value)
        .where("status", whereIn: ["done", "donescoring"])
        .snapshots()
        .map((attendanceQuery) {
      jumlah.value = attendanceQuery.docs.length;

      return attendanceQuery.docs.length;
    });
  }

  //mendapatkan panjang list attendance
  Stream<int> cekScoringStream() {
    return _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: argumentid.value)
        .where("status", isEqualTo: "done")
        .snapshots()
        .map((attendanceQuery) {
      return attendanceQuery.docs.length;
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
