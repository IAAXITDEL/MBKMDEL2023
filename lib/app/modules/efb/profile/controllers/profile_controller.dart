import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../data/users/users.dart';
import '../../../../../di/locator.dart';
import '../../../../../presentation/view_model/user_viewmodel.dart';
import '../../../../routes/app_pages.dart';


class ProfileController extends GetxController {

  late UserViewModel viewModel;
  late UserPreferences userPreferences;
  late bool _canViewAllAssessments;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

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



}
