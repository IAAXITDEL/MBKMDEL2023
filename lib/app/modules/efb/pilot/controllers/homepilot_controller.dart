import 'package:get/get.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../di/locator.dart';

class HomePilotController extends GetxController {
  //TODO: Implement HomeccController
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
