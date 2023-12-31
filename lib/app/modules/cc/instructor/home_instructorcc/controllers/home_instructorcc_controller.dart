import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../di/locator.dart';
import '../../../../../../presentation/view_model/attendance_model.dart';

class HomeInstructorccController extends GetxController {

  late UserPreferences userPreferences;
  late String titleToGreet;
  late String timeToGreet;
  RxString nameC  = "".obs;

  @override
  void onInit() {
    userPreferences = getItLocator<UserPreferences>();
    getName();

    switch (userPreferences.getRank()) {
      case 'CAPT':
        titleToGreet = 'Captain';
        break;
      case 'FO':
        titleToGreet = 'First Officer';
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> getName() async{
    try{
      userPreferences = getItLocator<UserPreferences>();
      final usersQuery = await _firestore
          .collection('users')
          .where("ID NO", isEqualTo: userPreferences.getIDNo())
          .get();


      if (usersQuery.docs.isNotEmpty) {
        final fullName = usersQuery.docs[0]["NAME"];
        final words = fullName.split(" ");
        if (words.isNotEmpty) {
          final firstName = words[0];
          nameC.value = firstName;
        } else {
        }
      } else {
      }
    }catch(e){
    }
  }

  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(String status) {
    userPreferences = getItLocator<UserPreferences>();
    return _firestore.collection('attendance').where("instructor", isEqualTo: userPreferences.getIDNo()).where("status", isEqualTo: status).where("is_delete", isEqualTo: 0).snapshots().asyncMap((attendanceQuery) async {
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
      attendanceData.sort((a, b) => b['date'].compareTo(a['date']));
      return attendanceData;
    });
  }




}
