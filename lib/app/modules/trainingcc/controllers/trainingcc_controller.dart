import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ts_one/app/modules/training_instructorcc/views/training_instructorcc_view.dart';
import 'package:ts_one/app/modules/trainingtypecc/controllers/trainingtypecc_controller.dart';

import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../presentation/view_model/attendance_model.dart';
import '../../../routes/app_pages.dart';
import '../../training_instructorcc/controllers/training_instructorcc_controller.dart';

class TrainingccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late UserPreferences userPreferences;

  final RxInt argumentid = 0.obs;
  final RxString argumentname = "".obs;

  final RxBool cekPilot = false.obs;

  // List untuk training remark
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingRemarkStream() {
    return firestore
        .collection('trainingRemark')
        .orderBy("id", descending: false)
        .where("remark", isNotEqualTo: null)
        .snapshots();
  }

  // List untuk training stream
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return firestore
        .collection('trainingType')
        .orderBy("id", descending: false)
        .snapshots();
  }


  Future<bool> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if( userPreferences.getInstructor().contains(UserModel.keyCPTS) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){

    }
    // SEBAGAI INSTRUCTOR
    else if( userPreferences.getInstructor().contains(UserModel.keySubPositionICC) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      Get.toNamed(Routes.TRAINING_INSTRUCTORCC, arguments: {
        "id" : argumentid.value,
        "name" : argumentname.value
      });
      Get.find<TrainingInstructorccController>().onInit();
    }
    // SEBAGAI PILOT
    else if( userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      cekPilot.value = true;
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if( userPreferences.getRank().contains("Pilot Administrator")){
      Get.toNamed(Routes.TRAININGTYPECC, arguments: {
        "id" : argumentid.value,
        "name" : argumentname.value
      });
      Get.find<TrainingtypeccController>().onInit();
    }
    // SEBAGAI ALL STAR
    else{
      return false;
    }
    return false;
  }


  // cek key sesuai dengan kelas yang sedang dibuka
  Stream<List<Map<String, dynamic>>> joinClassStream( String key, int idtraining) {
    return firestore.collection('attendance').where("keyAttendance", isEqualTo: key).where("idTrainingType", isEqualTo: idtraining).snapshots().asyncMap((attendanceQuery) async {
      final usersQuery = await firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {});
          return attendanceModel.toJson();
        }),
      );

      if(attendanceData.isNotEmpty){
        // tambah data pilot kedalam attendance
        await addAttendancePilotForm( attendanceData[0]["id"], attendanceData[0]["idTrainingType"]);
      }

      return attendanceData;
    });
  }

  //Membuat attendance untuk setiap  pilot
  Future<void> addAttendancePilotForm( String idattendance , int idtraining) async {
    userPreferences = getItLocator<UserPreferences>();
    CollectionReference attendance = firestore.collection("attendance-detail");

    String formattedDate = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
    try {
      await attendance.doc("${userPreferences.getIDNo()}-${idtraining}--${formattedDate}").set({
        "id" : "attendance-${idtraining}-${userPreferences.getIDNo()}-${formattedDate}",
        "idattendance" : idattendance,
        "idpilot" : userPreferences.getIDNo(),
        "status" : "join",
        "creationTime": DateTime.now().toIso8601String(),
        "updatedTime": DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Handle any exceptions that may occur during the operation.
      print(e);
    }
  }


  // cek class ada yang buka atau belum
  Future<List<AttendanceModel>> checkClassOpenStream(int idTrainingType) async {
    try {

      final attendanceQuery = await firestore
          .collection('attendance')
          .where("status", isEqualTo: "pending")
          .where("idTrainingType", isEqualTo: idTrainingType)
          .get();

      final attendanceDocs = attendanceQuery.docs;

      final List<AttendanceModel> attendanceList = attendanceDocs
          .map((doc) => AttendanceModel.fromJson(doc.data()))
          .toList();
      return attendanceList;
    } catch (e) {
      print('Error fetching combined data: $e');
      return [];
    }
  }


  // cek class sudah join atau belum
  Future<List<AttendanceModel>> checkClassStream(int idTrainingType) async {
    try {
      userPreferences = getItLocator<UserPreferences>();
      final attendancedetailQuery = await firestore
          .collection('attendance-detail')
          .where("idpilot", isEqualTo: userPreferences.getIDNo())
          .get();
      final attendanceQuery = await firestore
          .collection('attendance')
          .where("status", isEqualTo: "pending")
          .where("idTrainingType", isEqualTo: idTrainingType)
          .get();
      final attendancedetailData = attendancedetailQuery.docs
          .map((doc) => AttendanceDetailModel.fromJson(doc.data()))
          .toList();
      final attendanceData = attendanceQuery.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()))
          .toList();
      final combinedData = <AttendanceModel>[];
      for (final attendance in attendanceData) {
        for (final detail in attendancedetailData) {
          if (attendance.id == detail.idattendance) {
            combinedData.add(attendance);
            break;
          }
        }
      }

      return combinedData;
    } catch (e) {
      print('Error fetching combined data: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(List<String> statuses) {
    userPreferences = getItLocator<UserPreferences>();
    return firestore.collection('attendance')
        .where("idTrainingType", isEqualTo: argumentid.value)
        .where("instructor", isEqualTo: userPreferences.getIDNo())
        .where("status", whereIn: statuses)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      final usersQuery = await firestore.collection('users').where("ID NO", isEqualTo: userPreferences.getIDNo()).get();
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

      return attendanceData;
    });
  }


  @override
  void onInit() {
    super.onInit();
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