import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../data/users/users.dart';
import '../../../../../di/locator.dart';
import '../../../../../presentation/view_model/user_viewmodel.dart';
import '../../../../routes/app_pages.dart';


class ProfileccController extends GetxController {

  late UserViewModel viewModel;
  late UserPreferences userPreferences;
  late bool _canViewAllAssessments;

  RxBool isTraining = false.obs;
  RxInt idTraining = 0.obs;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void onInit() {
    // viewModel = Provider.of<UserViewModel>(context, listen: false);
    userPreferences = getItLocator<UserPreferences>();
    _canViewAllAssessments = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkCanViewAllAssessments();
    });
    cekRole();
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



  void checkCanViewAllAssessments() {
    if (userPreferences.getPrivileges().contains(UserModel.keyPrivilegeViewAllAssessments)) {
      _canViewAllAssessments = true;
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
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

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}