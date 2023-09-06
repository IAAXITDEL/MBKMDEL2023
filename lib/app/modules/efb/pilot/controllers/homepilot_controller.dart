import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../di/locator.dart';

class HomePilotController extends GetxController {
  //TODO: Implement HomeccController
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserPreferences userPreferences;
  late String titleToGreet;
  late String timeToGreet;

  final count = 0.obs;
  @override
  void onInit() {
    userPreferences = getItLocator<UserPreferences>();


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

    // assessmentResults = [];
    // assessmentResultsNotConfirmedByCPTS = [];

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

  Future<QuerySnapshot> _getPilotDevices() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String uid = user.uid;

      // Ambil data perangkat yang dipinjam oleh pilot dengan status "in-use-pilot".
      QuerySnapshot snapshot = await _firestore.collection('pilot-device-1')
          .where('user_uid', isEqualTo: uid)
          .where('status-device-1', isEqualTo: 'in-use-pilot')
          .get();

      return snapshot; // Return the QuerySnapshot directly.
    } else {
      throw Exception('User not logged in'); // You can handle this case as needed.
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

  void increment() => count.value++;
}
