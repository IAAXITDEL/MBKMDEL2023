import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/routes/app_pages.dart';
import 'package:ts_one/data/users/users.dart';

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
      case 'OCC':
        titleToGreet = 'OCC';
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

  RxBool isHubSelected = false.obs;

  final selectedIndex = 0.obs;

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  String? selectedHubText; // Define selectedHubText here

  void increment() => count.value++;

  Future<void> checkRoleEFB() async {
    userPreferences = getItLocator<UserPreferences>();

    // AS OCC
    if (userPreferences.getRank().contains(UserModel.keyPositionOCC)) {
      Get.toNamed(Routes.NAVOCC);
    }
    // AS PILOT
    else if (userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      Get.toNamed(Routes.NAVOCC);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text("Please checklist consent"),
      //     duration: const Duration(milliseconds: 1000),
      //     action: SnackBarAction(
      //       label: 'Close',
      //       onPressed: () {
      //         ScaffoldMessenger.of(context).hideCurrentSnackBar();
      //       },
      //     ),
      //   ),
      // );
      Get.snackbar(
        'Access Denied',
        'You do not have access.',
        duration: const Duration(milliseconds: 1000),
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
