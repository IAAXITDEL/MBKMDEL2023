import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../di/locator.dart';
import '../../../../../presentation/view_model/user_viewmodel.dart';

class HomeFOController extends GetxController {
  //TODO: Implement HomeccController

  //TODO: Implement HomeccController
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserPreferences userPreferences;
  late String titleToGreet;
  late String timeToGreet;
  late UserViewModel viewModel;

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




  void increment() => count.value++;
}
