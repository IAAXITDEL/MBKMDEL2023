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
  RxString nameS = "".obs;

  final ScrollController scrollController = ScrollController();

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
    getFilteredStream();
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
      return query.snapshots().map((snapshot) {
        final filteredData = snapshot.docs
            .where((doc) =>
            doc['NAME']
                .toString()
                .toLowerCase()
                .startsWith(nameS.toLowerCase()))
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

    final additionalList = additionalData.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    streamData.value.addAll(additionalList); // Append the new data to the existing list

    isLoading.value = false;
  }


  DocumentSnapshot? _getLastDocument() {
    return null;
  }

  void _loadData() {
    currentPage = 1;
    update();
  }

  @override
  void onClose() {
    searchC.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }
}
