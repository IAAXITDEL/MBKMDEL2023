import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EfbDokumenController extends GetxController {
  final RxString dccNo = '-'.obs;

  Future<void> addDocument() async {
    try {
      final CollectionReference efbDocumentCollection = FirebaseFirestore.instance.collection('efb-document');

      await efbDocumentCollection.add({
        'DCC No.': dccNo.value,
      });

      print('Dokumen berhasil ditambahkan');
    } catch (e) {
      print('Error: $e');
    }
  }

  // Fungsi untuk mengambil data dokumen dari Firestore
  Future<void> getDocument() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore.instance.collection('efb-document').get();

      if (result.docs.isNotEmpty) {
        final Map<String, dynamic> data = result.docs.first.data();
        dccNo.value = data['DCC No.'] ?? '-';
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  final count = 0.obs;
  @override
  void onInit() {

    Get.put<EfbDokumenController>(EfbDokumenController());
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
