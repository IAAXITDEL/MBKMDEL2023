import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ts_one/util/util.dart';

class UserModel with ChangeNotifier {
  UserModel({
    this.email = "",
    this.idNo = Util.defaultIntIfNull,
    this.name = "",
    this.rank = "",
    this.licenseNo = "",
    this.attribute = "",
  });

  String email = "";
  int idNo = Util.defaultIntIfNull;
  String name = "";
  String rank = "";
  List <String> instructor = [];
  String licenseNo = "";
  String attribute = "";
  DateTime licenseExpiry = DateTime.now();
  List<String> privileges = [];

  // this is the collection name in firebase
  static String firebaseCollection = "users";

  // all the keys for the map stored in firebase
  static String keyEmail = "EMAIL";
  static String keyLicenseExpiry = "LICENSE EXPIRY";
  static String keyLicenseNo = "LICENSE NO.";
  static String keyAttribute = "ATTRIBUTE";
  static String keyName = "NAME";
  static String keyRank = "RANK";
  static String keyInstructor = "INSTRUCTOR";
  static String keyIDNo = "ID NO";
  static String keyPrivileges = "PRIVILEGES";

  /** ALL PRIVILEGES */
  static String keyPrivilegeCreateAssessment = "create-assessment"; // for instructor to make a new assessment
  static String keyPrivilegeUpdateAssessment = "update-assessment"; // for instructor to update an unconfirmed assessment

  // for instructor, examinee, CPTS, and admin to confirm an assessment.
  // for instructor, examinee, and CPTS to any assessments related to them.
  static String keyPrivilegeConfirmAssessment = "confirm-assessment";

  static String keyPrivilegeViewAllAssessments = "view-all-assessments"; // for CPTS and admin to view all assessments
  static String keyPrivilegeManageFormAssessment = "manage-form-assessment"; // for CPTS and admin to manage form assessment
  static String keyPrivilegeCreateUser = "create-user"; // for admin to create a new user
  static String keyPrivilegeUpdateUser = "update-user"; // for admin to update a user
  static String keyPrivilegeDeleteUser = "delete-user"; // for admin to delete a user

  /** ALL POSITIONS */
  static String keyPositionCaptain = "CAPT";
  static String keyPositionFirstOfficer = "FO";

  /** ALL SUBPOSITIONS */
  static String keySubPositionCCP = "CCP"; // chief check pilot
  static String keyCPTS = "CPTS"; // chief pilot training standards
  static String keySubPositionFIA = "FIA"; // flight instructor assistant
  static String keySubPositionFIS = "FIS"; // flight instructor
  static String keySubPositionPGI = "PGI"; // pilot ground instructor
  static String keySubPositionREG = "REG"; // regular pilot
  static String keySubPositionTRG = "TRG"; // trainee pilot
  static String keySubPositionUT = "UT"; // under training pilot

  UserModel.fromFirebaseUser(Map<String, dynamic> map) {
    email = map[keyEmail]; // if null, return empty string
    idNo = map[keyIDNo];
    name = map[keyName];
    rank = map[keyRank];
    instructor = (map[keyInstructor] as List<dynamic>).map((item) => item.toString()).toList();
    attribute = map[keyAttribute];
    licenseNo = map[keyLicenseNo];
    licenseExpiry = DateTime.fromMillisecondsSinceEpoch(map[keyLicenseExpiry].seconds * 1000);
    if (map[keyPrivileges] != null) {
      privileges = (map[keyPrivileges] as List<dynamic>).map((item) => item.toString()).toList();
    }
  }

  Map<String, dynamic> toFirebase() {
    return {
      keyEmail: email,
      keyIDNo: idNo,
      keyName: name,
      keyRank: rank,
      keyInstructor: instructor,
      keyAttribute: attribute,
      keyLicenseNo: licenseNo,
      keyLicenseExpiry: licenseExpiry,
      keyPrivileges: privileges,
    };
  }

  String getInstructorString() {
    String subPositionString = Util.defaultStringIfNull;

    for (int i = 0; i < instructor.length; i++) {
      subPositionString += instructor[i];
      if (i != instructor.length - 1) {
        subPositionString += ", ";
      }
    }

    return subPositionString;
  }

  @override
  String toString() {
    return 'User(email: $email, staffNo: $idNo, name: $name, position: $rank, subPosition: $instructor, licenseNo: $licenseNo, licenseExpiry: $licenseExpiry,'
        ' privileges: $privileges)';
  }
}

class UserAuth {
  UserAuth({
    UserCredential? userCredential,
    UserModel? userModel,
  });

  UserCredential? userCredential;
  UserModel? userModel;
  String errorMessage = "";

  @override
  String toString() => 'UserAuth(userCredential: $userCredential, userModel: $userModel)';
}