import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../data/users/user_preferences.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/view_model/attendance_model.dart';

class HomeAdminccController extends GetxController {

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


  // LIST NEED CONFIRMATION
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream() {
    return firestore.collection('attendance').where("status", isEqualTo: "confirmation").snapshots().asyncMap((attendanceQuery) async {
      final usersQuery = await firestore.collection('users').get();
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
