import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/view_model/user_viewmodel.dart';
import '../../../routes/app_pages.dart';

class ProfileccController extends GetxController {

  late UserViewModel viewModel;
  late UserPreferences userPreferences;
  late bool _canViewAllAssessments;

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

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
