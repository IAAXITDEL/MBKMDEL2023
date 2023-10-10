import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../data/users/users.dart';
import '../../../../../di/locator.dart';
import '../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../presentation/view_model/attendance_model.dart';
import '../../../../routes/app_pages.dart';
import '../../instructor/training_instructorcc/controllers/training_instructorcc_controller.dart';
import '../../pilotadministrator/trainingtypecc/controllers/trainingtypecc_controller.dart';
class TrainingccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late UserPreferences userPreferences;

  final RxInt argumentid = 0.obs;
  final RxString argumentname = "".obs;

  final RxBool cekPilot = false.obs;
  RxBool isAdministrator = false.obs;
  final RxString passwordKey = "".obs;

  // List untuk training remark
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingRemarkStream() {
    return firestore
        .collection('trainingRemark')
        .orderBy("id", descending: false)
        .where("remark", isNotEqualTo: null)
        .snapshots();
  }

  // List untuk training stream
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return firestore
        .collection('trainingType')
        .where("is_delete", isEqualTo: 0)
        .snapshots();
  }

  Future<bool> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if (userPreferences.getInstructor().contains(UserModel.keyCPTS) &&
            userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
    }
    // SEBAGAI INSTRUCTOR
    // else if (userPreferences
    //         .getInstructor()
    //         .contains(UserModel.keySubPositionCCP) ||
    //     userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) ||
    //     userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) ||
    //     userPreferences.getInstructor().contains(UserModel.keySubPositionPGI) &&
    //         userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
    //     userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
    //   Get.toNamed(Routes.TRAINING_INSTRUCTORCC,
    //       arguments: {"id": argumentid.value, "name": argumentname.value});
    //   Get.find<TrainingInstructorccController>().onInit();
    // }
    // SEBAGAI PILOT
    else if (userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      cekPilot.value = true;
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if (userPreferences.getRank().contains("Pilot Administrator")) {
      Get.toNamed(Routes.TRAININGTYPECC,
          arguments: {"id": argumentid.value, "name": argumentname.value});
      Get.lazyPut<TrainingtypeccController>(
            () => TrainingtypeccController(),
      );
      Get.find<TrainingtypeccController>().onInit();
    }
    // SEBAGAI ALL STAR
    else {
      return false;
    }
    return false;
  }

  Future<bool> cekAdministrator() async {
    userPreferences = getItLocator<UserPreferences>();

    if (userPreferences.getRank().contains("Pilot Administrator")) {
      isAdministrator.value = true;
      return true;
    }
    // SEBAGAI ALL STAR
    else {
      return false;
    }
    return false;
  }

  // Add a new subject to Firestore
  Future<void> addNewSubject(String newSubject, String newRemark,
      int newExpiryDate, String newTrainingDescription) async {
    try {
      // Get the count of existing documents in both collections
      QuerySnapshot trainingTypeSnapshot =
          await FirebaseFirestore.instance.collection('trainingType').get();
      int trainingTypeCount = trainingTypeSnapshot.size;

      QuerySnapshot trainingRemarkSnapshot =
          await FirebaseFirestore.instance.collection('trainingRemark').get();
      int trainingRemarkCount = trainingRemarkSnapshot.size;

      // Add a new document to the 'trainingType' collection
      await FirebaseFirestore.instance.collection('trainingType').add({
        'id': trainingTypeCount + 1,
        'training': newSubject,
      });

      // Add a new document to the 'trainingRemark' collection
      await FirebaseFirestore.instance.collection('trainingRemark').add({
        'id': trainingRemarkCount + 1,
        'remark': newRemark,
        'training_code': newSubject,
        'expiry_date': newExpiryDate,
        'training_description': newTrainingDescription,
      });
    } catch (e) {
      print('Error adding subject: $e');
    }
  }

  // cek key sesuai dengan kelas yang sedang dibuka
  Stream<List<Map<String, dynamic>>> joinClassStream(
      String key, int idtraining) {
    return firestore
        .collection('attendance')
        .where("keyAttendance", isEqualTo: key)
        .where("idTrainingType", isEqualTo: idtraining)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      final usersQuery = await firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere(
              (user) => user['ID NO'] == attendanceModel.instructor,
              orElse: () => {});
          return attendanceModel.toJson();
        }),
      );

      if (attendanceData.isNotEmpty) {
        // tambah data pilot kedalam attendance
        await addAttendancePilotForm(
            attendanceData[0]["id"], attendanceData[0]["idTrainingType"]);
      }
      return attendanceData;
    });
  }

  //Membuat attendance untuk setiap  pilot
  Future<void> addAttendancePilotForm(
      String idattendance, int idtraining) async {
    userPreferences = getItLocator<UserPreferences>();
    CollectionReference attendance = firestore.collection("attendance-detail");

    String formattedDate = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
    try {
      await attendance
          .doc("${userPreferences.getIDNo()}-${idtraining}-${formattedDate}")
          .set({
        "id": "${userPreferences.getIDNo()}-${idtraining}-${formattedDate}",
        "idattendance": idattendance,
        "idtraining": userPreferences.getIDNo(),
        "status": "confirmation",
        "creationTime": DateTime.now().toIso8601String(),
        "updatedTime": DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Handle any exceptions that may occur during the operation.
      print(e);
    }
  }

  // cek class ada yang buka atau belum
  Future<List<AttendanceModel>> checkClassOpenStream(int idTrainingType) async {
    try {
      final attendanceQuery = await firestore
          .collection('attendance')
          .where("status", isEqualTo: "pending")
          .where("idTrainingType", isEqualTo: idTrainingType)
          .get();

      final attendanceDocs = attendanceQuery.docs;

      final List<AttendanceModel> attendanceList = attendanceDocs
          .map((doc) => AttendanceModel.fromJson(doc.data()))
          .toList();
      return attendanceList;
    } catch (e) {
      print('Error fetching combined data: $e');
      return [];
    }
  }

  // cek class sudah join atau belum
  Future<List<AttendanceModel>> checkClassStream(int idTrainingType) async {
    try {
      userPreferences = getItLocator<UserPreferences>();
      final attendancedetailQuery = await firestore
          .collection('attendance-detail')
          .where("idtraining", isEqualTo: userPreferences.getIDNo())
          .get();
      final attendanceQuery = await firestore
          .collection('attendance')
          .where("status", isEqualTo: "pending")
          .where("idTrainingType", isEqualTo: idTrainingType)
          .get();
      final attendancedetailData = attendancedetailQuery.docs
          .map((doc) => AttendanceDetailModel.fromJson(doc.data()))
          .toList();
      final attendanceData = attendanceQuery.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()))
          .toList();
      final combinedData = <AttendanceModel>[];
      for (final attendance in attendanceData) {
        for (final detail in attendancedetailData) {
          if (attendance.id == detail.idattendance) {
            combinedData.add(attendance);
            break;
          }
        }
      }

      return combinedData;
    } catch (e) {
      print('Error fetching combined data: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(
      List<String> statuses) {
    userPreferences = getItLocator<UserPreferences>();
    return firestore
        .collection('attendance')
        .where("idTrainingType", isEqualTo: argumentid.value)
        .where("instructor", isEqualTo: userPreferences.getIDNo())
        .where("status", whereIn: statuses)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      final usersQuery = await firestore
          .collection('users')
          .where("ID NO", isEqualTo: userPreferences.getIDNo())
          .get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere(
              (user) => user['ID NO'] == attendanceModel.instructor,
              orElse: () => {});
          attendanceModel.name = user['NAME'];
          attendanceModel.photoURL = user['PHOTOURL'];
          return attendanceModel.toJson();
        }),
      );

      return attendanceData;
    });
  }

  Future<void> scanQRCode(BuildContext context) async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Cancel",
      true,
      ScanMode.DEFAULT,
    );

    passwordKey.value = barcodeScanResult;

    // Process the QR code result (barcodeScanResult)
    print("Scanned QR code: $barcodeScanResult");
    // Add your code to handle the scanned QR code result here
  }

  @override
  void onInit() {
    super.onInit();
    cekAdministrator();
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
