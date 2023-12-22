import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ts_one/app/modules/cc/pilotadministrator/attendance_confircc/controllers/trainingCardSheetsApi.dart';
import 'package:ts_one/app/modules/cc/pilotadministrator/attendance_confircc/controllers/trainingCardsFields.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../data/users/users.dart';
import '../../../../../../di/locator.dart';
import '../../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../../presentation/view_model/attendance_model.dart';

class AttendanceConfirccController extends GetxController {
  var selectedMeeting = "Training".obs;
  late UserPreferences userPreferences;
  List<AttendanceModel> administratorModels = [];
  RxList<Uint8List>? pdfBytes = RxList<Uint8List>();


  void selectMeeting(String? newValue) {
    selectedMeeting.value =
        newValue ?? "Training";
  }

  final RxString argumentid = "".obs;
  final RxString argumentname = "".obs;
  final RxInt jumlah = 0.obs;
  final RxInt total = 0.obs;
  final RxBool showText = false.obs;
  final RxInt argumentTrainingType = 0.obs;

  final RxInt idInstructor = 0.obs;

  final RxString role = "".obs;
  final RxBool isLoading = false.obs;

  RxInt idTrainingType = 0.obs;
  Rx<DateTime> date = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    argumentid.value = Get.arguments["id"];
    attendanceStream();
    getCombinedAttendance();
    cekRole();
    absentList();
  }

  // List untuk asign Training
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where("RANK", whereIn: ["CAPT", "FO"])
        .snapshots();
  }

  // Menampilkan attendance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>?> getCombinedAttendance() async {
    try {
      final attendanceQuery = await _firestore
          .collection('attendance')
          .where("id", isEqualTo: argumentid.value)
          .get();

      List<int?> instructorIds =
      attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data()).instructor).toList();

      final usersData = <Map<String, dynamic>>[];

      if (instructorIds.isNotEmpty) {
        final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: instructorIds).get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere(
                (user) => user['ID NO'] == attendanceModel.instructor,
            orElse: () => {},
          );
          attendanceModel.name = user['NAME'];
          attendanceModel.loano = user['LOA NO'];
          idInstructor.value = attendanceModel.instructor!;
          argumentname.value = attendanceModel.subject!;

          Timestamp? timestamp = attendanceModel.date;
          date.value = timestamp!.toDate();
          idTrainingType.value = attendanceModel.idTrainingType!;

          return attendanceModel.toJson();
        }),
      );

      argumentTrainingType.value = attendanceData.isNotEmpty ? attendanceData[0]["idTrainingType"] : null;

      return attendanceData.isNotEmpty ? [attendanceData[0]] : null;
    } catch (e) {
      print("Error in getCombinedAttendanceStream: $e");
      return null;
    }
  }


  Future<List<Map<String, dynamic>?>> getCombinedAttendanceDetailStream() async {
    try {
      QuerySnapshot attendanceQuery = await _firestore
          .collection('attendance-detail')
          .where("idattendance", isEqualTo: argumentid.value)
          .where("status", whereIn: ["donescoring"])
          .get();

      List<int?> traineIds = attendanceQuery.docs.map((doc) {
        final data = doc.data();
        final attendanceModel = AttendanceDetailModel.fromJson(data as Map<String, dynamic>);
        return attendanceModel.idtraining;
      }).toList();

      final attendanceData = List<Map<String, dynamic>?>.filled(23, null);

      await Future.wait(
        attendanceQuery.docs.map((doc) async {
          try {
            final attendanceModel = AttendanceDetailModel.fromJson(doc.data() as Map<String, dynamic>);
            final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: traineIds).get();
            final user = usersQuery.docs.firstWhere(
                  (userDoc) => userDoc.data()['ID NO'] == attendanceModel.idtraining,
            );
            if (user != null) {
              final userData = UserModel.fromFirebaseUser(user.data());
              attendanceModel.name = userData.name;
              attendanceModel.license = userData.licenseNo;
              attendanceModel.rank = userData.rank;
              attendanceModel.hub = userData.hub;

              // Determine the index to place the data in the result list
              int index = traineIds.indexOf(attendanceModel.idtraining!);
              attendanceData[index] = attendanceModel.toJson();
            } else {
              print("User not found for ID NO: ${attendanceModel.idtraining}");
            }
          } catch (error) {
            print("Error processing attendance detail: $error");
          }
        }),
      );

      return attendanceData;
    } catch (error) {
      print("Error in getCombinedAttendanceDetailStream: $error");
      return List<Map<String, dynamic>?>.filled(23, null);
    }
  }



  Future<void> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI INSTRUCTOR
    if (userPreferences.getInstructor().contains(UserModel.keySubPositionCCP) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionPGI) &&
            userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      role.value = "ICC";
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if (userPreferences.getRank().contains("Pilot Administrator")) {
      role.value = "Pilot Administrator";
    }
  }

  Future<void> saveSignature(Uint8List signatureData) async {
    // Membuat referensi untuk Firebase Storage
    final Reference storageReference = FirebaseStorage.instance.ref().child(
        'signature-cc/${argumentid.value}-pilot-administrator-${DateTime.now()}.png');

    // Mengunggah data gambar ke Firebase Storage
    await storageReference.putData(signatureData);

    // Mendapatkan URL gambar yang diunggah
    final String imageUrl = await storageReference.getDownloadURL();

    // Menyimpan URL gambar di database Firestore
    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(argumentid.value)
        .update({
      'signaturePilotAdministratorUrl': imageUrl,
        });
  }

  //confir attendance oleh pilot administrator
  Future<void> confirattendance() async {
    userPreferences = getItLocator<UserPreferences>();
    CollectionReference attendance = _firestore.collection('attendance');

    QuerySnapshot querySnapshot = await _firestore.collection('trainingType')
        .where('id', isEqualTo: idTrainingType.value)
        .get();

    var lastDayOfMonth;
    var passed;
    var validTo;

    if (querySnapshot.docs.isNotEmpty) {
      for (DocumentSnapshot document in querySnapshot.docs) {
        var dates = date.value;
        passed = DateFormat('dd-MMM-yy').format(dates!);


        var recurrent = (document.data() as Map<String, dynamic>)['recurrent'];
        var nextMonths;

        if(recurrent == "NONE"){
          nextMonths = DateTime(dates.year, dates.month, dates.day);
        }else if(recurrent == "6 MONTH CALENDER"){
           nextMonths = DateTime(dates.year, dates.month + 6, dates.day);
        }else if(recurrent == "12 MONTH CALENDER"){
           nextMonths = DateTime(dates.year, dates.month + 12, dates.day);
        }else if(recurrent == "24 MONTH CALENDER"){
           nextMonths = DateTime(dates.year, dates.month + 24, dates.day);
        }else if(recurrent == "36 MONTH CALENDER"){
          nextMonths = DateTime(dates.year, dates.month + 36, dates.day);
        }else if(recurrent == "LAST MONTH ON THE NEXT YEAR OF THE PREVIOUS TRAINING"){
          nextMonths = DateTime(dates.year + 1, 12, 31);
        }

        // Handling jika bulan melebihi 12 dan 24
        if (nextMonths.month > 12) {
          nextMonths = DateTime(nextMonths.year + (nextMonths.month ~/ 12), nextMonths.month % 12, nextMonths.day);
        }

        // Menghitung tanggal akhir dari bulan
        lastDayOfMonth = DateTime(nextMonths.year, nextMonths.month + 1, 0);
      }
    } else {
      print('No documents found');
    }

    validTo = DateFormat('dd-MMM-yy').format(lastDayOfMonth!);
    await addTrainingCardsSheet(argumentid.value, passed, validTo);

    await attendance.doc(argumentid.value.toString()).update({
      "status": "done",
      "valid_to" : lastDayOfMonth,
      "expiry" : "VALID",
      "idPilotAdministrator": userPreferences.getIDNo(),
      "updatedTime": DateTime.now().toIso8601String(),
    });
  }

  //mendapatkan panjang list attendance
  Stream<int> attendanceStream() {
    return _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: argumentid.value)
        .where("status", isEqualTo: "donescoring")
        .snapshots()
        .map((attendanceQuery) {

      jumlah.value = attendanceQuery.docs.length;
      return attendanceQuery.docs.length;
    });
  }

  //Membuat daftar absent
  Future<void> addAbsentForm(int idtraining) async {

    try {
      await _firestore.collection("absent").doc("$idtraining-${argumentid.value}").set({
        "id" : "$idtraining-${argumentid.value}",
        "idattendance" : argumentid.value,
        "idtraining": idtraining,
        "creationTime": DateTime.now().toIso8601String(),
        "updatedTime": DateTime.now().toIso8601String(),
      });
    } catch (e) {
    }
  }

  // List daftar Absent
  Stream<List<Map<String, dynamic>>> absentStream() {
    return _firestore.collection('absent').where("idattendance", isEqualTo: argumentid.value).snapshots().asyncMap((attendanceQuery) async {
      List<int?> traineeIds =
      attendanceQuery.docs.map((doc) => AttendanceDetailModel.fromJson(doc.data()).idtraining).toList();


      final usersData = <Map<String, dynamic>>[];

      if (traineeIds.isNotEmpty) {
        final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: traineeIds).get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceDetailModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.idtraining, orElse: () => {});
          attendanceModel.name = user['NAME']; // Set 'nama' di dalam model
          attendanceModel.photoURL = user['PHOTOURL'];
          return attendanceModel.toJson();
        }),
      );
      return attendanceData;
    });
  }


  Future<void> absentList() async {
    final absentQuery = await _firestore
        .collection('absent')
        .where("idattendance", isEqualTo: argumentid.value)
        .get();

    total.value = absentQuery.docs.length;
  }

  // Membatalkan daftar absent
  Future<void> deleteAbsent(String id) {
    return _firestore.collection('absent')
        .doc("$id")
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }


  Future addTrainingCardsSheet(String idAttendance, String passed, String validTo) async {
    final attendanceQuery = await _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: argumentid.value)
        .where("status", isEqualTo: "donescoring")
        .where("score", isEqualTo: "PASS")
        .get();

    List<int?> traineeIds = attendanceQuery.docs.map((doc) => AttendanceDetailModel.fromJson(doc.data()).idtraining).toList();

    if (traineeIds.isNotEmpty) {
      for (int? traineeId in traineeIds) {
        if (traineeId != null) {
          final trainingCards = await TrainingCardSheetsApi.getById(traineeId);

          if(trainingCards == null){
            final traineeQuery = await _firestore
                .collection('users')
                .where("ID NO", isEqualTo: traineeId)
                .get();

            if (traineeQuery.docs.isNotEmpty) {
              final attendanceModel = AttendanceDetailModel.fromJson(attendanceQuery.docs[0].data());

              final user = traineeQuery.docs.firstWhere(
                    (user) => user['ID NO'] == attendanceModel.idtraining,
              );

              if (user != null) {
                attendanceModel.name = user['NAME'];
                attendanceModel.hub = user['HUB'];
                attendanceModel.email = user['EMAIL'];
                attendanceModel.rank = user['RANK'];


                final training = {
                  TrainingCardsFields.id: attendanceModel.id,
                  TrainingCardsFields.name: attendanceModel.name,
                  TrainingCardsFields.rank: attendanceModel.rank,
                  TrainingCardsFields.hub: attendanceModel.hub,
                  TrainingCardsFields.nolicense: attendanceModel.license,
                };

                await TrainingCardSheetsApi.insert([training]);
                print("Training card berhasil ditambahkan untuk ID: $traineeId");
              } else {
                print("Tidak ada data user yang cocok untuk ID: ${attendanceModel.idtraining}");
              }
            } else {
              print("traineeQuery.docs kosong, tidak ada data trainee untuk ID: $traineeId");
              // Lakukan sesuatu jika query tidak mengembalikan hasil apa pun
            }

          }

          await TrainingCardSheetsApi.updateCell(id: traineeId, key: 'LAST PASSED ${argumentname.value}', value: passed);
          await TrainingCardSheetsApi.updateCell(id: traineeId, key: 'EXPIRY ${argumentname.value}', value: validTo);
        } else {
          print("traineeId null, penanganan khusus jika diperlukan.");
        }
      }
      // Lakukan sesuatu setelah loop selesai, jika diperlukan
    } else {
      print("traineeIds kosong, tidak ada data training untuk diproses.");
      // Atau lakukan sesuatu yang sesuai dengan kasus ketika traineeIds kosong
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
