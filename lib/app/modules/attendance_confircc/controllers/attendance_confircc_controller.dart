import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/view_model/attendance_model.dart';

class AttendanceConfirccController extends GetxController {

  var selectedMeeting = "Training".obs;
  late UserPreferences userPreferences;

  void selectMeeting(String? newValue) {
    selectedMeeting.value = newValue ?? "Training"; // Default to "Meeting 1" if newValue is null
  }

  final RxString argumentid = "".obs;
  final RxString argumentname = "".obs;
  final RxInt jumlah = 0.obs;

  final RxString role = "".obs;
  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final String id = args["id"];
    argumentid.value = id;
    attendanceStream();
    cekRole();
  }



  // Menampilkan attendance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(String id) {
    return _firestore.collection('attendance').where("id", isEqualTo: id).snapshots().asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {});
          attendanceModel.name = user['NAME'];
          return attendanceModel.toJson();
        }),
      );
      return attendanceData;
    });
  }


  Future<void> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI INSTRUCTOR
    if( userPreferences.getInstructor().contains(UserModel.keySubPositionICC) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      role.value = "ICC";
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if( userPreferences.getRank().contains("Pilot Administrator")){
      role.value = "Pilot Administrator";
    }

    print(role.value);

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
    await FirebaseFirestore.instance.collection('attendance').doc(argumentid.value).update({
      'signature-pilot-administrator-url': imageUrl
    });
  }

  //confir attendance oleh instructor
  Future<void> confirattendance() async {
    CollectionReference attendance = _firestore.collection('attendance');
    await attendance.doc(argumentid.value.toString()).update({
      "status" : "done",
      "updatedTime": DateTime.now().toIso8601String(),
      //signature icc url
    });
  }


//mendapatkan panjang list attendance
  Future<int> attendanceStream() async {
    final attendanceQuery = await _firestore
        .collection('attendance-detail')
        .where("status", isEqualTo: "done")
        .where("idattendance", isEqualTo: argumentid.value)
        .get();

    jumlah.value = attendanceQuery.docs.length;
    print(attendanceQuery.docs.length);
    return attendanceQuery.docs.length;
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
