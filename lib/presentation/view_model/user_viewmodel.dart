import 'dart:developer';
import 'dart:typed_data';

import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/data/users/user_signatures.dart';
import 'package:ts_one/data/users/users.dart';
import 'package:ts_one/domain/user_repo.dart';
import 'package:ts_one/presentation/view_model/loading_viewmodel.dart';
import 'package:ts_one/util/util.dart';

class UserViewModel extends LoadingViewModel {
  UserViewModel({required this.repo,  required this.userPreferences});

  final UserRepo repo;
  final UserPreferences userPreferences;

  List<UserModel> users = [];
  UserModel? lastUser;
  int lengthOfAllUsers = Util.defaultIntIfNull;
  bool isAllUsersLoaded = false;

  Future<UserAuth> login(String email, String password) async {
    isLoading = true;
    UserAuth userAuth = UserAuth();
    try {
      userAuth = await repo.login(email, password);
      if(userAuth.userModel != null) {
        userPreferences.saveUser(userAuth);
      }
      isLoading = false;
    } catch (e) {
      log("Exception in UserViewModel on login: $e");
      isLoading = false;
    }
    return userAuth;
  }

  Future<UserAuth> loginWithGoogle() async {
    isLoading = true;
    UserAuth userAuth = UserAuth();
    try {
      userAuth = await repo.loginWithGoogle();
      if(userAuth.userModel != null) {
        userPreferences.saveUser(userAuth);
      }
      isLoading = false;
    } catch (e) {
      log("Exception in UserViewModel loginWithGoogle: $e");
      isLoading = false;
    }
    return userAuth;
  }

  Future<void> logout() async {
    try {
      repo.logout();
      userPreferences.clearUser();
    } catch (e) {
      log("Exception in UserViewModel on logout: $e");
    }
  }

  Future<List<UserModel>> getAllUsers(int limit) async {
    isLoading = true;

    try {
      if(isAllUsersLoaded) {
        isLoading = false;
        return users;
      }

      final List<UserModel> newUsers = await repo.getUsersPaginated(limit, lastUser);
      users.addAll(newUsers);

      if (newUsers.isNotEmpty) {
        lastUser = newUsers[newUsers.length - 1];
      } else {
        lastUser = null;
        isAllUsersLoaded = true;
      }

      isLoading = false;
    } catch (e) {
      log("Exception in UserViewModel on getAllUsers: $e");
      isLoading = false;
    }

    return users;
  }

  Future<UserModel> getUserByIDNo(String idNo) async {
    isLoading = true;
    UserModel userModel = UserModel();
    try {
      userModel = await repo.getUserByIDNo(idNo);
      isLoading = false;
    } catch (e) {
      log("Exception in UserViewModel on getUserByIDNo: $e");
      isLoading = false;
    }
    return userModel;
  }

  Future<List<UserModel>> getUsersBySearchName(String searchName, int searchLimit) async {
    isLoading = true;
    List<UserModel> users = [];
    try {
      users = await repo.getUsersBySearchName(searchName, searchLimit);
      isLoading = false;
    } catch (e) {
      log("Exception in UserViewModel on getUsersBySearchName: $e");
      isLoading = false;
    }
    return users;
  }

  // Future<List<UserModel>> getUserBySearchIdNo(String searchId, int searchLimit) async {
  //   isLoading = true;
  //   List<UserModel> users = [];
  //   try {
  //     users = await repo.getUserBySearchIdNo(searchId, searchLimit);
  //     isLoading = false;
  //   } catch (e) {
  //     print(e.toString());
  //     isLoading = false;
  //   }
  // }

  Future<UserModel> addUser(UserModel userModel) async {
    isLoading = true;
    UserModel newUserModel = UserModel();
    try {
      newUserModel = await repo.addUser(userModel);
      reset();
      isLoading = false;
    } catch (e) {
      log("Exception in UserViewModel on addUser: $e");
      isLoading = false;
    }
    return newUserModel;
  }

  Future<UserModel> updateUser(String userEmail, UserModel userModel) async {
    isLoading = true;
    UserModel newUserModel = UserModel();
    try {
      newUserModel = await repo.updateUser(userEmail, userModel);
      reset();
      isLoading = false;
    } catch (e) {
      log("Exception in UserViewModel on updateUser: $e");
      isLoading = false;
    }
    return newUserModel;
  }

  Future<void> deleteUserByEmail(String email) async {
    isLoading = true;
    try {
      await repo.deleteUserByEmail(email);
      reset();
      isLoading = false;
    } catch (e) {
      log("Exception in UserViewModel on deleteUserByEmail: $e");
      isLoading = false;
    }
  }

  Future<String> uploadSignature(int idUser, DateTime assessmentDate, Uint8List? signatureBytes) async {
    isLoading = true;
    String downloadURL = "";
    try {
      downloadURL = await repo.uploadSignature(idUser, assessmentDate, signatureBytes);
      isLoading = false;
    } catch (e) {
      log("Exception in UserViewModel on uploadSignature: $e");
      isLoading = false;
    }
    return downloadURL;
  }

  Future<UserSignatures> addSignature(UserSignatures userSignatures) async {
    isLoading = true;
    UserSignatures newUserSignatures = UserSignatures();
    try {
      newUserSignatures = await repo.addSignature(userSignatures);
      isLoading = false;
    } catch (e) {
      log("Exception in UserViewModel on addSignature: $e");
      isLoading = false;
    }
    return newUserSignatures;
  }

  Future<UserSignatures> getSignature(int staffIDNo) async {
    isLoading = true;
    UserSignatures userSignature = UserSignatures();
    try {
      userSignature = await repo.getSignature(staffIDNo);
      isLoading = false;
    } catch (e) {
      log(e.toString());
      isLoading = false;
    }
    return userSignature;
  }

  Future<bool> getPDFTemplate() async {
    try {
      return await repo.getPDFTemplate();
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  void reset() {
    users.clear();
    lastUser = null;
    isAllUsersLoaded = false;
  }
}
