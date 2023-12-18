import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../di/locator.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../../../../../../presentation/view_model/attendance_model.dart';
class AttendancePilotccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final RxString idattendance = "".obs;
  late UserPreferences userPreferences;
  final RxBool showText = false.obs;
  final RxBool cekstatus = false.obs;

  @override
  void onInit() {
    super.onInit();

    idattendance.value = Get.arguments["id"];
    print("id : ${Get.arguments["id"]}");
    checkSignature();
  }

  //Mendapatkan data kelas yang diikuti
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream() {
    return firestore.collection('attendance').where("id", isEqualTo: idattendance.value).where("status", isEqualTo: "pending").snapshots().asyncMap((attendanceQuery) async {
      List<int?> instructorIds =
      attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data()).instructor).toList();

      final usersData = <Map<String, dynamic>>[];

      if (instructorIds.isNotEmpty) {
        final usersQuery = await firestore.collection('users').where("ID NO", whereIn: instructorIds).get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {});

          attendanceModel.name = user['NAME'];
          return attendanceModel.toJson();
        }),
      );
      checkSignature();
      return attendanceData;
    });
  }

  //Mendapatkan status pilot apakah sudah tanda tangan atau belum
  Future<void> checkSignature() async {
    try {
      final attendancedet = await firestore.collection('attendance-detail').where("idattendance", isEqualTo: idattendance.value).get();
      print(idattendance.value);
      if (attendancedet.docs.isNotEmpty) {
        final status = attendancedet.docs[0]["status"];
        if(status == "confirmation"){
          cekstatus.value = true;
        }else{
          cekstatus.value = false;
        }
        print("hasilnya ${cekstatus.value}");
      } else {
        print("Tidak ada data yang sesuai dengan kriteria pencarian.");
      }
    } catch (e) {
      print('Error in : $e');
    }
  }



  Future<void> saveSignature(GlobalKey<SfSignaturePadState> _signaturePadKey) async {
    try{
      userPreferences = getItLocator<UserPreferences>();
      // Mengambil objek ui.Image dari SfSignaturePad
      ui.Image image = await _signaturePadKey.currentState!.toImage();

      // Mengonversi ui.Image menjadi data gambar
      ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png);
      Uint8List? uint8List = byteData?.buffer.asUint8List();

      // Membuat referensi untuk Firebase Storage
      final Reference storageReference = FirebaseStorage.instance.ref().child(
          'signature-cc/${idattendance.value}-${userPreferences.getIDNo()}-${DateTime.now()}.png');

      // Mengunggah gambar ke Firebase Storage
      await storageReference.putData(uint8List!);

      // Mendapatkan URL gambar yang diunggah
      final String imageUrl = await storageReference.getDownloadURL();

      // Menyimpan URL gambar di database Firestore
      final CollectionReference attendanceDetailCollection = FirebaseFirestore.instance.collection('attendance-detail');
      final Query query = attendanceDetailCollection.where("idattendance", isEqualTo: idattendance.value).where("idtraining", isEqualTo: userPreferences.getIDNo());

      // Get the documents that match the query
      final QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there's only one document that matches the query, you can update it like this:
        final DocumentReference documentReference = querySnapshot.docs[0].reference;
        await documentReference.update({
          'signature_url': imageUrl,
          "status" : "done"
        });

      } else {
        // Handle the case where no documents match the query
      }
    }catch(e){
      print('Error in saveSignature: $e');
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
