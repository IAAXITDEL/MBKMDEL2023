import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../occ/model/device.dart';

class RequestdeviceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late List<Device> devices = [];

  Device? selectedDevice;
  TextEditingController borrowerNameController = TextEditingController();
  TextEditingController deviceNoController = TextEditingController();
  //TODO: Implement RequestdeviceController

  Future<List<Device>> getDevices() async {
    QuerySnapshot snapshot = await _firestore.collection("Device").get();
    return snapshot.docs.map((doc) => Device.fromFirestore(doc)).toList();
  }

  void requestDevice(String deviceUid, String deviceName, String statusdevice1) async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Query koleksi 'users' untuk mendapatkan dokumen pengguna berdasarkan emailnya
      QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user.email).get();

      if (userQuery.docs.isNotEmpty) {
        // Mengambil ID dokumen pengguna dari hasil query
        String userUid = userQuery.docs.first.id;

        // Membuat referensi koleksi 'pilot-device-1' tanpa menambahkan dokumen
        CollectionReference pilotDeviceCollection = _firestore.collection('pilot-device-1');

        // Mendapatkan ID dokumen yang baru akan dibuat
        String newDeviceId = pilotDeviceCollection.doc().id;

        await pilotDeviceCollection.doc(newDeviceId).set({
          'user_uid': userUid, // Menggunakan ID dokumen pengguna sebagai 'user_uid'
          'device_uid': deviceUid,
          'device_name': deviceName,
          'status-device-1': 'waiting-confirmation-1',
          'document_id': newDeviceId, // Menyimpan ID dokumen sebagai field
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Tambahkan method untuk memeriksa apakah perangkat sudah digunakan
  Future<bool> isDeviceInUse(String deviceUid) async {
    QuerySnapshot snapshot = await _firestore.collection('pilot-device-1')
        .where('device_uid', isEqualTo: deviceUid)
        .where('status-device-1', isEqualTo: 'in-use-pilot')
        .get();

    return snapshot.docs.isNotEmpty;
  }


  Future<QuerySnapshot> getPilotDevices() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Get the user's email
      String userEmail = user.email ?? "";

      // Query the 'users' collection to find the document with the matching email
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('EMAIL', isEqualTo: userEmail)
          .limit(1) // Limit to 1 document, assuming email is unique
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // Get the user's document ID (user_id)
        String userId = userSnapshot.docs.first.id;

        // Query the 'pilot-device-1' collection based on the 'user_id'
        QuerySnapshot snapshot = await _firestore
            .collection('pilot-device-1')
            .where('user_uid', isEqualTo: userId)
            .where('status-device-1', whereIn: ['in-use-pilot', 'waiting-confirmation-1','need-confirmation-occ'])
            .get();

        return snapshot; // Return the QuerySnapshot directly.
      } else {
        throw Exception('User not found in the "users" collection');
      }
    } else {
      throw Exception('User not logged in'); // You can handle this case as needed.
    }
  }


  final count = 0.obs;

  @override

  void onInit() {
    super.onInit();
  }


  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
