import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../di/locator.dart';

class HomeOCCController extends GetxController {
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

  RxString selectedHub = RxString(''); // Initialize with an empty string

  void updateSelectedHub(String hub) {
    selectedHub.value = hub;
  }

  final selectedIndex = 0.obs;

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  String? selectedHubText;  // Define selectedHubText here

  void increment() => count.value++;
}
