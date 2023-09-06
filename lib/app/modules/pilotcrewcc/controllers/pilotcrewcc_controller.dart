import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PilotcrewccController extends GetxController {

  late TextEditingController searchC;
  DocumentSnapshot? lastDocument;
  var isClicked = false.obs;

  void toggleClick() {
    isClicked.toggle();
  }

  int currentPage = 1; // Halaman saat ini
  int itemsPerPage = 10; // Jumlah item per halaman
  RxList<DocumentSnapshot> data = <DocumentSnapshot>[].obs; // Gunakan RxList untuk mengelola perubahan state

  @override
  void onInit() {
    searchC = TextEditingController();
    pilotCrewStream().listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      // Gunakan .assignAll untuk memperbarui RxList
      data.assignAll(snapshot.docs);
    });
    super.onInit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> pilotCrewStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where("RANK", whereIn: ["CAPT", "FO"])
        .snapshots();
  }

  List<DocumentSnapshot> getCurrentPageData() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    // Pastikan endIndex tidak melebihi panjang data
    if (endIndex > data.length) {
      return data.sublist(startIndex); // Ambil sampai akhir dari data
    }

    return data.sublist(startIndex, endIndex);
  }

  void goToPage(int page) {
    if (page >= 1 && page <= (data.length / itemsPerPage).ceil()) {
      currentPage = page;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    searchC.dispose();
    super.onClose();
  }

}
