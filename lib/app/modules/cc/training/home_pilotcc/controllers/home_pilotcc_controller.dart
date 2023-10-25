import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/modules/cc/training/attendance_pilotcc/controllers/attendance_pilotcc_controller.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../di/locator.dart';
import '../../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../../presentation/view_model/attendance_model.dart';
import '../../../../../routes/app_pages.dart';

class HomePilotccController extends GetxController {
  late UserPreferences userPreferences;
  late String titleToGreet;
  late String timeToGreet;
  late bool _isCPTS;
  late bool _isInstructor;
  late bool _isPilotAdministrator;



  @override
  void onInit() {
    userPreferences = getItLocator<UserPreferences>();
    _isPilotAdministrator = false;

    switch (userPreferences.getRank()) {
      case 'CAPT':
        titleToGreet = 'Captain';
        break;
      case 'FO':
        titleToGreet = 'First Officer';
        break;
      case 'Pilot Administrator':
        titleToGreet = 'Pilot Administrator';
        _isPilotAdministrator = true;
        break;
      default:
        titleToGreet = 'Allstar';
    }

    var hour = DateTime.now().hour;
    if (hour < 12) {
      timeToGreet = "Morning";
    } else if (hour < 17) {
      timeToGreet = "Afternoon";
    } else {
      timeToGreet = "Evening";
    }

    super.onInit();
  }


  FirebaseFirestore firestore = FirebaseFirestore.instance;


  // Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream() {
  //   userPreferences = getItLocator<UserPreferences>();
  //   return firestore.collection('attendance').where("status", isEqualTo: "pending").snapshots().asyncMap((attendanceQuery) async {
  //     final attendanceDetailQuery = await firestore.collection('attendance-detail').where("idtraining", isEqualTo: userPreferences.getIDNo()).where("status", isEqualTo: "confirmation").get();
  //     final attendanceDetailData = attendanceDetailQuery.docs.map((doc) => doc.data()).toList();
  //
  //     if (attendanceDetailData.isEmpty) {
  //       return [];
  //     }
  //
  //     final attendanceData = await Future.wait(
  //       attendanceQuery.docs.map((doc) async {
  //         final attendanceModel = AttendanceModel.fromJson(doc.data());
  //         final attendanceDetail = attendanceDetailData.firstWhere((attendanceDetail) => attendanceDetail['idattendance'] == attendanceModel.id, orElse: () => {});
  //         return attendanceModel.toJson();
  //       }),
  //     );
  //     return attendanceData;
  //   });
  // }
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream() {
    userPreferences = getItLocator<UserPreferences>();
    return firestore.collection('attendance').where("status", isEqualTo: "pending").snapshots().asyncMap((attendanceQuery) async {

      var attendanceDetailData = <Map<String, dynamic>>[];
      if (attendanceQuery.docs.isNotEmpty) {
        final attendanceDetailQuery = await firestore.collection('attendance-detail').where("idtraining", isEqualTo: userPreferences.getIDNo()).where("status", isEqualTo: "confirmation").get();
        attendanceDetailData = attendanceDetailQuery.docs.map((doc) => doc.data()).toList();
      }

      if (attendanceDetailData.isEmpty) {
        return [];
      }

      // Filter attendanceQuery based on whether there is a corresponding attendanceDetail
      final filteredAttendanceQuery = attendanceQuery.docs.where((doc) {
        final attendanceModel = AttendanceModel.fromJson(doc.data());
        return attendanceDetailData.any((attendanceDetail) => attendanceDetail['idattendance'] == attendanceModel.id);
      });

      final attendanceData = <Map<String, dynamic>>[];
      for (var doc in filteredAttendanceQuery) {
        final attendanceModel = AttendanceModel.fromJson(doc.data());
        final attendanceDetail = attendanceDetailData.firstWhere(
              (attendanceDetail) => attendanceDetail['idattendance'] == attendanceModel.id,
          orElse: () => <String, dynamic>{}, // Return an empty map
        );

        print(attendanceModel);
        if (attendanceDetail != null) {
          attendanceData.add(attendanceModel.toJson());
        }
      }

      return attendanceData;
    });
  }

  Future<void> toAttendance(String id) async {
    Get.toNamed(Routes.ATTENDANCE_PILOTCC, arguments: {
      "id": id,
    });
    Get.find<AttendancePilotccController>().onInit();
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