import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../occ/model/device.dart';

class FORequestdeviceController extends GetxController {
  //TODO: Implement RequestdeviceController
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late List<Device> devices = [];

  Device? selectedDevice2;
  Device? selectedDevice3;
  TextEditingController borrowerNameController = TextEditingController();
  TextEditingController deviceNoController = TextEditingController();

  Future<List<Device>> getDevices() async {
    QuerySnapshot snapshot = await _firestore.collection("Device").get();
    return snapshot.docs.map((doc) => Device.fromFirestore(doc)).toList();
  }

  Future<QuerySnapshot> getFODevices() async {
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
            .where('statusDevice', whereIn: [
          'in-use-pilot',
          'in-use-fo',
          'waiting-confirmation-2',
          'need-confirmation-occ',
          'waiting-confirmation-other-pilot'
        ]).get();

        return snapshot; // Return the QuerySnapshot directly.
      } else {
        throw Exception('User not found in the "users" collection');
      }
    } else {
      throw Exception(
          'User not logged in'); // You can handle this case as needed.
    }
  }

  Future<bool> isDeviceInUse(String deviceUid2, String deviceUid3) async {
    // Check if deviceUid is in 'device_uid'
    QuerySnapshot snapshot1 = await _firestore
        .collection('pilot-device-1')
        .where('device_uid2', isEqualTo: deviceUid2)
        .where('statusDevice', whereIn: [
      'in-use-pilot',
      'waiting-confirmation-1',
      'need-confirmation-occ',
      'waiting-confirmation-other-pilot'
    ]).get();

    // Check if deviceUid is in 'device_uid2'
    QuerySnapshot snapshot2 = await _firestore
        .collection('pilot-device-1')
        .where('device_uid3', isEqualTo: deviceUid3)
        .where('statusDevice', whereIn: [
      'in-use-pilot',
      'waiting-confirmation-1',
      'need-confirmation-occ',
      'waiting-confirmation-other-pilot'
    ]).get();

    return snapshot1.docs.isNotEmpty || snapshot2.docs.isNotEmpty;
  }

  void requestDevice(
      String deviceUid2,
      String deviceName2,
      String deviceUid3,
      String deviceName3,
      String statusdevice1,
      String fieldHub2,
      String fieldHub3) async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Query koleksi 'users' untuk mendapatkan dokumen pengguna berdasarkan emailnya
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('EMAIL', isEqualTo: user.email)
          .get();

      QuerySnapshot deviceQuery = await _firestore
          .collection('Device')
          .where('device_name', whereIn: [deviceName2, deviceName3]).get();

      if (userQuery.docs.isNotEmpty) {
        // Mengambil ID dokumen pengguna dari hasil query
        String userUid = userQuery.docs.first.id;

        // Membuat referensi koleksi 'pilot-device-1' tanpa menambahkan dokumen
        CollectionReference pilotDeviceCollection =
            _firestore.collection('pilot-device-1');

        // Mendapatkan ID dokumen yang baru akan dibuat
        String newDeviceId = pilotDeviceCollection.doc().id;

        await pilotDeviceCollection.doc(newDeviceId).set({
          'user_uid':
              userUid, // Menggunakan ID dokumen pengguna sebagai 'user_uid'
          'device_uid': '',
          'device_name': '',
          'device_uid2': deviceUid2,
          'device_name2': deviceName2,
          'device_uid3': deviceUid3,
          'device_name3': deviceName3,
          'statusDevice': 'waiting-confirmation-1',
          'document_id': newDeviceId, // Menyimpan ID dokumen sebagai field
          'timestamp': FieldValue.serverTimestamp(),
          'handover-from': '-',
          'handover-to-crew': '-',
          'remarks': '',
          'prove_image_url': '',
          'occ-accepted-device': '-',
          'field_hub2': fieldHub2, // Include the field hub in the data
          'field_hub3': fieldHub3, // Include the field hub in the data
        });
      }
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
