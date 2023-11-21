import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/app/modules/efb/analytics/views/analytics_view.dart';

class AnalyticsController extends GetxController {
  static String statusDone = "Done";
  static String statusHandover = "handover-to-other-crew";
  static String statusInUse = "in-use-pilot";
  Future<int> countDevicesHub_InUse_AllHubs() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', whereIn: [statusInUse, statusDone, statusHandover])
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();
    final int deviceCount_InUse_AllHubs = querySnapshot.docs.length;
    return deviceCount_InUse_AllHubs;
  }

  Future<double> calculatePercentageDeviceName() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', whereIn: ['Done', 'in-use-pilot', 'handover-to-other-crew'])
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalRecords = documents.length;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['device_name'] != null && data['device_name'] != '-') {
        totalDeviceName++;
      }
    }
    if (totalRecords > 0) {
      double percentageDeviceName = (totalDeviceName / totalRecords) * 100;

      return percentageDeviceName;
    } else {
      return 0.0;
    }
  }

  Future<int> countDeviceName() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', whereIn: ['Done', 'in-use-pilot', 'handover-to-other-crew'])
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['device_name'] != null && data['device_name'] != '-') {
        totalDeviceName++;
      }
    }

    return totalDeviceName;
  }

  Future<double> calculatePercentageDeviceName2and3() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', whereIn: [statusDone, 'in-use-pilot', 'handover-to-other-crew'])
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalRecords = documents.length;
    int totalDeviceName2and3 = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['device_name2'] != null && data['device_name2'] != '-') || (data['device_name3'] != null && data['device_name3'] != '-')) {
        totalDeviceName2and3++;
      }
    }

    if (totalRecords > 0) {
      double percentageDeviceName2and3 = (totalDeviceName2and3 / totalRecords) * 100;
      return percentageDeviceName2and3;
    } else {
      return 0.0;
    }
  }

  Future<Map<String, int>> countDevicesHub(String hub) async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore.collection('Device').get();

    final Map<String, int> deviceCountByHub = {
      'CGK': 0,
      'KNO': 0,
      'DPS': 0,
      'SUB': 0,
    };
    querySnapshot.docs.forEach((doc) {
      final hubValue = doc["value"]['hub'] as String;
      if (deviceCountByHub.containsKey(hubValue)) {
        deviceCountByHub[hubValue] = (deviceCountByHub[hubValue] ?? 0) + 1;
      }
    });
    return deviceCountByHub;
  }

  Future<int> countDeviceName2and3() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', whereIn: ['Done', 'in-use-pilot', 'handover-to-other-crew'])
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalDeviceName2and3 = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['device_name2'] != null && data['device_name2'] != '-') || (data['device_name3'] != null && data['device_name3'] != '-')) {
        totalDeviceName2and3++;
      }
    }

    return totalDeviceName2and3;
  }

  Future<double> calculatePercentageNotReturn() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', isEqualTo: 'in-use-pilot')
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalRecords = documents.length;
    int totalDeviceName2and3 = 0;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['device_name2'] != null && data['device_name2'] != '-') || (data['device_name3'] != null && data['device_name3'] != '-')) {
        totalDeviceName2and3++;
      }
      // Cek field device_name
      else if (data['device_name'] != null && data['device_name'] != '-') {
        totalDeviceName++;
      }
    }
    if (totalRecords > 0) {
      double percentageDeviceName2and3 = (totalDeviceName2and3 / totalRecords) * 100;
      double percentageDeviceName = (totalDeviceName / totalRecords) * 100;
      return percentageDeviceName2and3 + percentageDeviceName;
    } else {
      return 0.0;
    }
  }

  Future<int> countNotReturn() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', isEqualTo: 'in-use-pilot')
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalDeviceName2and3 = 0;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['device_name2'] != null && data['device_name2'] != '-') || (data['device_name3'] != null && data['device_name3'] != '-')) {
        totalDeviceName2and3++;
      }
      // Cek field device_name
      else if (data['device_name'] != null && data['device_name'] != '-') {
        totalDeviceName++;
      }
    }

    return totalDeviceName + totalDeviceName2and3;
  }

  Future<double> calculatePercentageDeviceNameDone() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', whereIn: ['Done', 'handover-to-other-crew'])
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalRecords = documents.length;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['device_name'] != null && data['device_name'] != '-') {
        totalDeviceName++;
      }
    }

    if (totalRecords > 0) {
      double percentageDeviceName = (totalDeviceName / totalRecords) * 100;
      return percentageDeviceName;
    } else {
      return 0.0;
    }
  }

  Future<int> countDeviceNameDone() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', whereIn: ['Done', 'handover-to-other-crew'])
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalDeviceName = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['device_name'] != null && data['device_name'] != '-') {
        totalDeviceName++;
      }
    }
    return totalDeviceName;
  }

  Future<double> calculatePercentageDeviceName2and3Done() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', whereIn: ['Done', 'handover-to-other-crew'])
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalRecords = documents.length;
    int totalDeviceName2and3 = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['device_name2'] != null && data['device_name2'] != '-') || (data['device_name3'] != null && data['device_name3'] != '-')) {
        totalDeviceName2and3++;
      }
    }

    if (totalRecords > 0) {
      double percentageDeviceName2and3 = (totalDeviceName2and3 / totalRecords) * 100;
      return percentageDeviceName2and3;
    } else {
      return 0.0;
    }
  }

  Future<int> countDeviceName2and3Done() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', whereIn: ['Done', 'handover-to-other-crew'])
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    int totalDeviceName2and3 = 0;

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['device_name2'] != null && data['device_name2'] != '-') || (data['device_name3'] != null && data['device_name3'] != '-')) {
        totalDeviceName2and3++;
      }
    }
    return totalDeviceName2and3;
  }

  Future<Map<String, int>> countDevicesHub_InUse(String hub) async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot =
        await firestore.collection('pilot-device-1').where('statusDevice', isEqualTo: 'in-use-pilot').where('field_hub', isEqualTo: hub).get();

    final int deviceCount_InUse = querySnapshot.docs.length;

    final Map<String, int> deviceCountByHub_InUse = {
      hub: deviceCount_InUse,
    };
    return deviceCountByHub_InUse;
  }

  Future<int> countDevicesInUse() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('pilot-device-1')
        .where('timestamp', isGreaterThanOrEqualTo: selectedStartDate, isLessThanOrEqualTo: selectedEndDate)
        .where('statusDevice', isEqualTo: 'in-use-pilot')
        .where('field_hub', isEqualTo: (selectedHub == 'ALL' ? null : selectedHub))
        .get();

    final int deviceCountInUse = querySnapshot.docs.length;

    return deviceCountInUse;
  }

  Map<String, int> calculateHandoverTotals(List<Map<String, dynamic>> data) {
    Map<String, int> handoverTotals = {};

    for (var device in data) {
      if (device['statusDevice'] == 'handover-to-other-crew') {
        String userUid = device['user_uid'];
        if (handoverTotals.containsKey(userUid)) {
          handoverTotals[userUid] = (handoverTotals[userUid]! + 1);
        } else {
          handoverTotals[userUid] = 1;
        }
      }
    }

    return handoverTotals;
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
