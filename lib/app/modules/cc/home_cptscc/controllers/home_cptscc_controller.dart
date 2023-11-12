import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../../data/users/user_preferences.dart';
import '../../../../../di/locator.dart';
import 'dart:io';
import '../../../../../presentation/view_model/attendance_model.dart';


class HomeCptsccController extends GetxController {
  late UserPreferences userPreferences;
  late String titleToGreet;
  late String timeToGreet;
  late bool _isCPTS;
  late bool _isInstructor;
  late bool _isPilotAdministrator;
  RxInt instructorCount = 0.obs; // Number of instructors (use .obs here)
  RxInt pilotCount = 0.obs; // Number of pilots (use .obs here)
  RxInt ongoingTrainingCount = 0.obs; // Number of ongoing(use .obs here)
  RxInt completedTrainingCount =
      0.obs; // Number of completed trainings(use .obs here)
  RxInt traineeCount = 0.obs; // Number of trainee (use .obs here)
  RxInt trainingCount = 0.obs; // Number of trainings (use .obs here)
  double instructorPercentage = 0.0;
  double pilotPercentage = 0.0;
  RxInt absentCount = 0.obs; // Number of pilots (use .obs here)
  RxInt presentCount = 0.obs; // Number of pilots (use .obs here)
  double absentPercentage = 0.0;
  double presentPercentage = 0.0;

  RxString training = "ALL".obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxInt idTraining = 0.obs;
  RxInt idTrainingType = 0.obs;
  late final Rx<DateTime> from= DateTime(1900, 1, 1).obs;
  late final Rx<DateTime> to = DateTime.now().obs;

  final RxString nameS = "".obs;

  RxString _selectedSubject = "ALL".obs;

  RxString get selectedSubject => _selectedSubject;




  @override
  void onInit() {
    userPreferences = getItLocator<UserPreferences>();
    getTrainingSubjects();
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

    // Future<List<Map<String, dynamic>>> getCombinedAttendance({String? trainingType, DateTime? from, DateTime? to}) async {


    // Fetch Firestore data to count instructors
    FirebaseFirestore.instance
        .collection('users')
        .where('INSTRUCTOR', arrayContainsAny: ["CCP", "FIA", "FIS", "PGI"])
        .get()
        .then((querySnapshot) {
      instructorCount.value = querySnapshot.docs.length;
    });

    // Fetch Firestore data to count pilots
    FirebaseFirestore.instance
        .collection('users')
        .where('INSTRUCTOR', arrayContains: "")
        .get()
        .then((querySnapshot) {
      pilotCount.value = querySnapshot.docs.length;
    });

    // Fetch Firestore data to count completed trainings
    FirebaseFirestore.instance
        .collection('attendance')
        .where('status', isEqualTo: "done")
        .get()
        .then((querySnapshot) {
      completedTrainingCount.value = querySnapshot.docs.length;
    });

    // Fetch Firestore data to count ongoing trainings
    FirebaseFirestore.instance
        .collection('attendance')
        .where('status', isEqualTo: "pending")
        .get()
        .then((querySnapshot) {
      ongoingTrainingCount.value = querySnapshot.docs.length;
    });

    // Fetch Firestore data to count trainee
    FirebaseFirestore.instance
        .collection('attendance-detail')
        .get()
        .then((querySnapshot) {
      traineeCount.value = querySnapshot.docs.length;
    });

    // Fetch Firestore data to count trainings
    FirebaseFirestore.instance
        .collection('trainingType')
        .get()
        .then((querySnapshot) {
      trainingCount.value = querySnapshot.docs.length;
    });


    // Fetch Firestore data to count absent
    // FirebaseFirestore.instance
    //     .collection('absent')
    //     .get()
    //     .then((absentQuerySnapshot) {
    //   Map<String, List<DocumentSnapshot>> absentDataByAttendance = {};
    //   absentQuerySnapshot.docs.forEach((doc) {
    //     String idAttendance = doc.data()['idAttendance'];
    //     if (!absentDataByAttendance.containsKey(idAttendance)) {
    //       absentDataByAttendance[idAttendance] = [];
    //     }
    //     absentDataByAttendance[idAttendance]?.add(doc);
    //   });
    //
    //   // After grouping the 'absent' data
    //   print("Absent data grouped by idAttendance:");
    //   absentDataByAttendance.forEach((idAttendance, data) {
    //     print("idAttendance: $idAttendance");
    //     data.forEach((doc) {
    //       print("Document: ${doc.data()}");
    //     });
    //   });
    // });


// Fetch Firestore data to count attendance
//     FirebaseFirestore.instance
//         .collection('attendance-detail')
//         .get()
//         .then((attendanceQuerySnapshot) {
//       Map<String, List<DocumentSnapshot>> attendanceDataByAttendance = {};
//       attendanceQuerySnapshot.docs.forEach((doc) {
//         String idAttendance = doc.data()['idAttendance'];
//         if (!attendanceDataByAttendance.containsKey(idAttendance)) {
//           attendanceDataByAttendance[idAttendance] = [];
//         }
//         attendanceDataByAttendance[idAttendance]?.add(doc);
//       });
//
//       // After grouping the 'attendance' data
//       print("Attendance data grouped by idAttendance:");
//       attendanceDataByAttendance.forEach((idAttendance, data) {
//         print("idAttendance: $idAttendance");
//         data.forEach((doc) {
//           print("Document: ${doc.data()}");
//         });
//       });
//     });
//

    // Fetch Firestore data to count instructors

    FirebaseFirestore.instance
        .collection('users')
        .where('INSTRUCTOR', arrayContainsAny: ["CCP", "FIA", "FIS", "PGI"])
        .get()
        .then((querySnapshot) {
      instructorCount.value = querySnapshot.docs.length;

      // Calculate percentage
      int totalUsers = querySnapshot.docs.length + pilotCount.value;
      instructorPercentage = (querySnapshot.docs.length / totalUsers) * 100;
    });

    // Fetch Firestore data to count pilots
    FirebaseFirestore.instance
        .collection('users')
        .where('INSTRUCTOR', arrayContains: "")
        .get()
        .then((querySnapshot) {
      pilotCount.value = querySnapshot.docs.length;

      // Calculate percentage
      int totalUsers = querySnapshot.docs.length + instructorCount.value;
      pilotPercentage = (querySnapshot.docs.length / totalUsers) * 100;
    });
  }

  // Future<List<String>> getTrainingSubjects() async {
  //   List<String> subjects = ["ALL"];
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('trainingType')
  //         .get();
  //
  //     subjects = querySnapshot.docs.map((doc) => doc['subject'].toString()).toList();
  //   } catch (e) {
  //     print("Error fetching training subjects: $e");
  //   }
  //   return subjects;
  // }

  Future<List<String>> getTrainingSubjects() async {
    List<String> subjects = ["ALL"];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('trainingType')
          .get();

      subjects = querySnapshot.docs.map((doc) => doc['subject'].toString()).toList();
    } catch (e) {
      print("Error fetching training subjects: $e");
    }
    return subjects;
  }

  void updateSelectedSubject(String newSubject) {
    _selectedSubject.value = newSubject;
  }


  Future<List<Map<String, dynamic>>> getCombinedAttendance({String? trainingType, DateTime? from, DateTime? to}) async {
    try {
      print("ppp");
      var attendanceData = <Map<String, dynamic>>[];
      CollectionReference<Map<String, dynamic>>? attendanceQuery = firestore.collection("attendance");

      Query<Map<String, dynamic>> attendance;
      if (trainingType != "ALL") {
        attendance = attendanceQuery.where("subject", isEqualTo: trainingType);
      }else{
        attendance = attendanceQuery;
      }

      QuerySnapshot<Map<String, dynamic>> attendanceDatas = await attendance.get();

      attendanceData.addAll(attendanceDatas.docs.map((doc) => doc.data()) ?? []);

      print(attendanceData);
      if(from != null && to!= null && attendanceData.isNotEmpty){
        print("adaad");
        attendanceData = attendanceData.where((attendance) {
          DateTime attendanceDate = attendance["date"].toDate();

          // Compare dates only, ignoring the time component
          DateTime fromDate = DateTime(from.year, from.month, from.day);
          DateTime toDate = DateTime(to.year, to.month, to.day);
          DateTime attendanceDateOnly = DateTime(attendanceDate.year, attendanceDate.month, attendanceDate.day);

          return attendanceDateOnly.isAtSameMomentAs(fromDate) ||
              (attendanceDateOnly.isAfter(fromDate) && attendanceDateOnly.isBefore(toDate)) ||
              attendanceDateOnly.isAtSameMomentAs(toDate);
        }).toList();

        List<String?> attendanceId = attendanceData.map((doc) => AttendanceModel.fromJson(doc).id).toList();

        print(attendanceId);
        print(attendanceId.length);
        if(attendanceId.isNotEmpty){
          final absentQuery = await firestore
              .collection('absent')
              .where("idattendance", whereIn: attendanceId)
              .get();
          // int totalAbsents = absentQuery.docs.length;
          absentCount.value = await absentQuery.docs.length;
          absentQuery.docs.forEach((doc) {
            print("dasd ${doc["idattendance"]}");
            print("dasd ${doc["id"]}");
          });
          print("absent loihhhh ${absentCount.value}");

          final attendanceDetailQuery = await firestore
              .collection('attendance-detail')
              .where("idattendance", whereIn: attendanceId)
              .get();
          int totalPresents = attendanceDetailQuery.docs.length;
          presentCount.value = totalPresents;
        } else {
          // Handle the case when attendanceId is empty
          print("Attendance ID is empty");
        }

        // if (trainingType != "ALL") {
        //   final absentQuery = await firestore
        //       .collection('absent')
        //       .where("idattendance", whereIn: attendanceId)
        //       .get();
        //   int totalAbsents = absentQuery.docs.length;
        //   absentCount.value = totalAbsents;
        //   print(absentCount.value);
        //
        //   final attendanceDetailQuery = await firestore
        //       .collection('attendance-detail')
        //       .where("idattendance", whereIn: attendanceId)
        //       .get();
        //   int totalPresents = attendanceDetailQuery.docs.length;
        //   presentCount.value = totalPresents;
        // }
        // else {
        //   attendanceData = attendanceData.where((attendance) {
        //     String attendanceSubject = attendance["subject"].toDate();
        //
        //     return attendanceSubject == trainingType;
        //   }).toList();
        //   attendanceId = attendanceData.map((doc) => AttendanceModel.fromJson(doc).id);
        //
        //   final absentQuery = await firestore
        //       .collection('absent')
        //       .where("idattendance", whereIn: attendanceId)
        //       .get();
        //   int totalAbsents = absentQuery.docs.length;
        //   absentCount.value = totalAbsents;
        //
        //   final attendanceDetailQuery = await firestore
        //       .collection('attendance-detail')
        //       .where("idattendance", whereIn: attendanceId)
        //       .get();
        //   int totalPresents = attendanceDetailQuery.docs.length;
        //   presentCount.value = totalPresents;
        // }
      }

      return attendanceData;
    } catch (e) {
      // Handle any errors that might occur during the async operation
      print("Error fetching attendance data: $e");
      return []; // or throw an exception if needed
    }
  }





  // Function to export data to CSV
  Future<String> exportToCSV(List<List<dynamic>> data, String filename) async {
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/$filename.csv';
    File file = File(path);

    String csv = const ListToCsvConverter().convert(data);
    await file.writeAsString(csv);
    return path; // Mengembalikan path file yang telah disimpan
  }


  void resetDate() {
    from.value  = DateTime(1900, 1, 1);
    to.value  = DateTime.now();
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
