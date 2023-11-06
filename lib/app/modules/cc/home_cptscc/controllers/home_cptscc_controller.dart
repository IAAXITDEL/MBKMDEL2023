import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../../data/users/user_preferences.dart';
import '../../../../../di/locator.dart';
import 'dart:io';


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

  // Function to export data to CSV
  Future<String> exportToCSV(List<List<dynamic>> data, String filename) async {
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/$filename.csv';
    File file = File(path);

    String csv = const ListToCsvConverter().convert(data);
    await file.writeAsString(csv);
    return path; // Mengembalikan path file yang telah disimpan
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