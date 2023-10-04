import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

enum FilterType {
  none,
  instructor,
  pilot,
}

class ListPilotcptsccController extends GetxController {
  late TextEditingController searchC;
  DocumentSnapshot? lastDocument;
  var isClicked = false.obs;
  RxBool isLoading = false.obs;

  final ScrollController scrollController = ScrollController();

  RxString nameS = "".obs;
  final Rx<List<Map<String, dynamic>>> streamData =
      Rx<List<Map<String, dynamic>>>([]);

  int currentPage = 1; // Current page
  int itemsPerPage = 10; // Items per page
  FilterType filterType =
      FilterType.none; // Default to FilterType.none initially

  @override
  void onInit() {
    searchC = TextEditingController();
    scrollController.addListener(_scrollListener);

    super.onInit();
  }

  void setFilterType(FilterType type) {
    filterType = type;
    _loadData();
  }

  Stream<List<Map<String, dynamic>>> getFilteredStream() {
    var query = FirebaseFirestore.instance
        .collection('users')
        .where("RANK", whereIn: ["CAPT", "FO"]);
    print(filterType);

    if (filterType == FilterType.instructor) {
      query = query
          .where("INSTRUCTOR", arrayContainsAny: ["CCP", "FIA", "FIS", "PGI"]);
    } else if (filterType == FilterType.pilot) {
      query = query.where("INSTRUCTOR", arrayContainsAny: [""]);
    }

    if (nameS.isNotEmpty) {
      query = query
          .where("NAME", isGreaterThanOrEqualTo: nameS.value)
          .where("NAME", isLessThan: nameS.value + "z");
    }

    return query.snapshots().map((snapshot) {
      final dataList = snapshot.docs.map((doc) => doc.data()).toList();
      return dataList;
    });
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
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

  void _loadData() {
    currentPage = 1;
    update(); // Trigger a UI update when changing the filter type.
  }

  @override
  void onClose() {
    searchC.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }
}
