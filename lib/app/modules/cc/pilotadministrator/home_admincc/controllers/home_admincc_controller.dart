import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../di/locator.dart';
import '../../../../../../presentation/view_model/attendance_model.dart';

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

    var hour = DateTime
        .now()
        .hour;
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
    return firestore
        .collection('attendance')
        .where("status", isEqualTo: "confirmation")
        .where("is_delete", isEqualTo: 0)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      final instructorIds = attendanceQuery.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()).instructor)
          .toList();

      final usersData = <Map<String, dynamic>>[];

      if (instructorIds.isNotEmpty) {
        final usersQuery = await firestore.collection('users').where("ID NO", whereIn: instructorIds).get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          attendanceModel.name = usersData
              .firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {})['NAME'] ??
              'N/A';

          Timestamp? timestamp = attendanceModel.valid_to;

          // Konversi Timestamp menjadi DateTime
          DateTime? dateTime = timestamp?.toDate();

          print('DateTime: $dateTime');
          print(attendanceModel.name);
          return attendanceModel.toJson();
        }),
      );
      print(attendanceData);

      return attendanceData;
    });
  }

}

