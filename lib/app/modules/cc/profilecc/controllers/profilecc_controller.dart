import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../data/users/users.dart';
import '../../../../../di/locator.dart';
import '../../../../../presentation/view_model/attendance_model.dart';
import '../../../../../presentation/view_model/user_viewmodel.dart';
import '../../../../routes/app_pages.dart';


class ProfileccController extends GetxController {

  late UserViewModel viewModel;
  late UserPreferences userPreferences;

  RxBool isTraining = false.obs;
  RxBool isInstructor = false.obs;
  RxString instructorType = "".obs;

  RxInt idTraining = 0.obs;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxBool isReady = false.obs;

  @override
  void onInit() {
    userPreferences = getItLocator<UserPreferences>();
    cekRole();
    print("two");
    fetchAttendanceData();
    print("one");
    super.onInit();
  }

  //Mendapatkan data pribadi
  Stream<QuerySnapshot<Map<String, dynamic>>> profileList() {
    userPreferences = getItLocator<UserPreferences>();
    return firestore
        .collection('users')
        .where("ID NO", isEqualTo: userPreferences.getIDNo())
        .snapshots();
  }

  // List untuk training stream
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return firestore
        .collection('trainingType')
        .where("is_delete", isEqualTo : 0)
        .snapshots();
  }

  Future<void> logout() async {
    try {
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        print("Failed to disconnect: $e");
      }

      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print("Failed to sign out: $e");
      }

      userPreferences.clearUser();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      print("Exception in UserViewModel on logout: $e");
    }
  }

  Future<void> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if( userPreferences.getInstructor().contains(UserModel.keyCPTS) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){

    }
    // SEBAGAI INSTRUCTOR
    else if( userPreferences.getInstructor().contains(UserModel.keySubPositionCCP) || userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) || userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) || userPreferences.getInstructor().contains(UserModel.keySubPositionPGI)&& userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      isTraining.value = true;
      isInstructor.value = true;
      instructorType.value = userPreferences.getInstructorString();
      print(userPreferences.getInstructorString());
    }
    // SEBAGAI TRAINING
    else if( userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      isTraining.value = true;
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if( userPreferences.getRank().contains("Pilot Administrator")){

    }
    // SEBAGAI ALL STAR
    else{
    }
  }

  //add LOA NO.
  Future<void> addLoaNo(String loaNo) async {
    userPreferences = getItLocator<UserPreferences>();
    CollectionReference users = firestore.collection("users");
    try {
      await users.doc(userPreferences.getIDNo().toString()).update({
        "LOA NO": loaNo,
      });
    } catch (e) {
      // Handle any exceptions that may occur during the operation.
      print("Error updating LOA NO.: $e");
    }
  }


  Future<void> fetchAttendanceData() async {
    try {
      userPreferences = getItLocator<UserPreferences>();
      QuerySnapshot attendanceQuery = await firestore
          .collection('attendance')
          .where("expiry", isEqualTo: "VALID")
          .where("status", isEqualTo: "done")
          .get();

      if (attendanceQuery.docs.isNotEmpty) {
        final attendanceDetailQuery = await firestore.collection('attendance-detail').where("idtraining", isEqualTo: userPreferences.getIDNo()).where("status", isEqualTo: "donescoring").get();
        final attendanceDetailData = attendanceDetailQuery.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        if (attendanceDetailData.isEmpty) {
          return;
        }

        final attendanceData = await Future.wait(
          attendanceQuery.docs.map((doc) async {
            final attendanceModel = AttendanceModel.fromJson(doc.data() as Map<String, dynamic>);
            final matchingDetail = attendanceDetailData.where((attendanceDetail) => attendanceDetail['idattendance'] == attendanceModel.id);

            if (matchingDetail.isNotEmpty) {
              return attendanceModel.toJson();
            }

            return null;
          }),
        );

        // Remove null values from attendanceData
        final filteredAttendanceData = attendanceData.where((item) => item != null).toList();

        final groupedAttendanceData = <String, Map<String, dynamic>>{};
        for (var attendance in filteredAttendanceData) {
          final subject = attendance?['subject'];
          if (!groupedAttendanceData.containsKey(subject) ||
              attendance?['valid_to'].compareTo(groupedAttendanceData[subject]!['valid_to']) > 0) {
            groupedAttendanceData[subject] = attendance!;
          }
        }

        // Sort the grouped attendance data by valid_to
        final sortedAttendanceData = groupedAttendanceData.values.toList()
          ..sort((a, b) {
            Timestamp timestampA = a['valid_to'];
            Timestamp timestampB = b['valid_to'];
            return timestampB.compareTo(timestampA);
          });

        // Print the final attendance data
        print("Final attendance data:");
        sortedAttendanceData.forEach((attendance) {
          print(attendance['id']);
          print(attendance["expiry"]);
          print(attendance["subject"]);
          print(attendance["valid_to"]);
        });

        QuerySnapshot trainingQuery = await firestore
            .collection('trainingType')
            .get();

        List<String?> trainingNames = trainingQuery.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>
          return data != null ? data['training']?.toString() : null;
        }).toList();

        print(trainingNames);

        // Create a map with keys from trainingNames and values from sortedAttendanceData
        Map<String?, List<Map<String, dynamic>>> attendanceMap = {};

        for (var attendance in sortedAttendanceData) {
          final subject = attendance['subject'];
          final expiry = attendance['expiry'];

          // Check if the subject is present in trainingNames
          if (trainingNames.contains(subject)) {
            if (!attendanceMap.containsKey(subject)) {
              attendanceMap[subject] = [];
            }
            attendanceMap[subject]!.add({
              'id': attendance['id'],
              'expiry': expiry,
              'subject': subject,
              'valid_to': attendance['valid_to'],
            });
          }
        }

    // Print the attendance map
        print("Attendance Map:");
        attendanceMap.forEach((key, value) {
          print('Subject: $key');
          value.forEach((attendance) {
            print('  ${attendance['id']} - ${attendance['expiry']} - ${attendance['valid_to']}');
          });
        });

        if(trainingNames.length > attendanceMap.length){
          print("NOT VALID");
          isReady.value = false;
        }else{
          isReady.value = true;
        }

      } else {
        return;
      }
    } catch (error) {
      print('Error fetching attendance data: $error');
      // Handle the error accordingly
    }
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