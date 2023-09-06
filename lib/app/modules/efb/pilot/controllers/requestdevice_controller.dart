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

  void requestDevice(String deviceUid, String deviceName, String occOnDuty, String statusdevice1) async {
    User? user = _auth.currentUser;

    if (user != null) {
      String uid = user.uid; // Mendapatkan UID pengguna yang saat ini masuk

      await _firestore.collection('pilot-device-1').add({
        'device_uid': deviceUid,
        'device_name': deviceName,
        'occ_on_duty': occOnDuty,
        'status-device-1' : 'in-use-pilot',
        'user_uid': uid, // Merekam UID pengguna yang saat ini masuk
        'timestamp': FieldValue.serverTimestamp(),
      });
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
      String uid = user.uid;

      // Ambil data perangkat yang dipinjam oleh pilot dengan status "in-use-pilot".
      QuerySnapshot snapshot = await _firestore.collection('pilot-device-1')
          .where('user_uid', isEqualTo: uid)
          .where('status-device-1', isEqualTo: 'in-use-pilot')
          .get();

      return snapshot; // Return the QuerySnapshot directly.
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
