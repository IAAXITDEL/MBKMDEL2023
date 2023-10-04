import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PilotcrewccController extends GetxController {

  late TextEditingController searchC;
  DocumentSnapshot? lastDocument;
  var isClicked = false.obs;
  RxBool isLoading = false.obs;

  final ScrollController scrollController = ScrollController();

  RxString nameS = "".obs;
  final Rx<List<Map<String, dynamic>>> streamData = Rx<List<Map<String, dynamic>>>([]);

  void toggleClick() {
    isClicked.toggle();
  }

  int currentPage = 1; // Halaman saat ini
  int itemsPerPage = 10; // Jumlah item per halaman
  RxList<DocumentSnapshot> data = <DocumentSnapshot>[].obs; // Gunakan RxList untuk mengelola perubahan state

  @override
  void onInit() {
    searchC = TextEditingController();
    scrollController.addListener(_scrollListener);
    super.onInit();
  }


  // Search dan tampilkan data
  Stream<List<Map<String, dynamic>>> pilotCrewStream(String name) {
    final query = FirebaseFirestore.instance
        .collection('users')
        .where("RANK", whereIn: ["CAPT", "FO"]);

    if (name.isNotEmpty) {
      return query.snapshots().map((snapshot) {
        final filteredData = snapshot.docs
            .where((doc) =>
            doc['NAME']
                .toString()
                .toLowerCase()
                .startsWith(name.toLowerCase()))
            .map((doc) => doc.data())
            .toList();
        streamData.value = filteredData;
        return filteredData;
      });
    }

    return query.snapshots().map((snapshot) {
      final dataList = snapshot.docs.map((doc) => doc.data()).toList();
      return dataList;
    });
  }


  void _scrollListener() {
    if (scrollController.offset >=
        scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      if (!isLoading.value) {
          isLoading.value = true;
        _loadMoreData();
      }
    }
  }

  Future<void> _loadMoreData() async {
    final lastDocument = _getLastDocument();
    final additionalData = await FirebaseFirestore.instance
        .collection('users')
        .where("RANK", whereIn: ["CAPT", "FO"])
        .startAfterDocument(lastDocument!)
        .limit(20)
        .get();

    isLoading.value = false;
  }


  DocumentSnapshot? _getLastDocument() {
    return null;
  }


  @override
  void onClose() {
    searchC.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

}
