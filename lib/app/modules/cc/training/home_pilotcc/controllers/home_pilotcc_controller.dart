import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../di/locator.dart';
import '../../../../../../presentation/view_model/attendance_detail_model.dart';

class HomePilotccController extends GetxController {
  late UserPreferences userPreferences;
  late String titleToGreet;
  late String timeToGreet;
  RxString nameC = "".obs;
  RxInt idTrainee = 0.obs;
  @override
  void onInit() {
    userPreferences = getItLocator<UserPreferences>();
    idTrainee.value = userPreferences.getIDNo();
    getName();

    switch (userPreferences.getRank()) {
      case 'CAPT':
        titleToGreet = 'Captain';
        break;
      case 'FO':
        titleToGreet = 'First Officer';
        break;
      case 'Pilot Administrator':
        titleToGreet = 'Pilot Administrator';
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



  Future<void> getName() async{
    try{
      userPreferences = getItLocator<UserPreferences>();
      final usersQuery = await firestore
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


  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream() {
    userPreferences = getItLocator<UserPreferences>();
    return firestore
        .collection('attendance')
        .where("status", isEqualTo: "done")
        .snapshots()
        .asyncMap((attendanceQuery) async {

      List<AttendanceDetailModel> attendanceDetailData = [];
      if (attendanceQuery.docs.isNotEmpty) {
        final attendanceDetailQuery = await firestore
            .collection('attendance-detail')
            .where("idtraining", isEqualTo: userPreferences.getIDNo())
            .get();

        attendanceDetailData =
            attendanceDetailQuery.docs.map((doc) => AttendanceDetailModel.fromJson(doc.data())).toList();
      }

      if (attendanceDetailData.isEmpty) {
        return [];
      }

      final filteredAttendanceIds = attendanceDetailData
          .where((attendanceDetail) => attendanceDetail.feedbackforinstructor == null)
          .map((attendanceDetail) => attendanceDetail.idattendance)
          .toList();

      final filteredAttendanceQuery = attendanceQuery.docs
          .where((attendanceDoc) =>
          filteredAttendanceIds.contains(attendanceDoc['id']))
          .map((attendanceDoc) => attendanceDoc.data())
          .toList();

      print("Filtered attendance query: $filteredAttendanceQuery");
      return filteredAttendanceQuery;
    });
  }


  Future<void> refreshData() async {
    // Implement the logic to fetch updated data here
    try {
      // For example, you might await a new data fetch operation
      await getCombinedAttendanceStream();
      print("tes");
      // Update the state or perform other actions with the new data as needed

    } catch (error) {
      // Handle errors if the data fetching fails
      print('Error fetching data: $error');
    }
  }




  // Future<void> toAttendance(String id) async {
  //   Get.toNamed(Routes.PILOTTRAININGHISTORYDETAILCC, arguments: {
  //     "idTrainingType": idTrainingType.value,
  //     "idAttendance": id,
  //     "idTraining": idTraining.value,
  //   });
  //   Get.find<AttendancePilotccController>().onInit();
  // }


  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}