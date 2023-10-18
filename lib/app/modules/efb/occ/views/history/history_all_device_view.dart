import 'dart:io';

import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ts_one/app/modules/efb/occ/views/history/detail_history_device_view.dart';
import 'package:ts_one/presentation/theme.dart';

import 'detailhistorydeviceFo.dart';

class HistoryAllDeviceView extends StatefulWidget {
  const HistoryAllDeviceView({Key? key}) : super(key: key);

  @override
  _HistoryAllDeviceViewState createState() => _HistoryAllDeviceViewState();
}

class _HistoryAllDeviceViewState extends State<HistoryAllDeviceView> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool isFoChecked = false;
  bool isCaptChecked = false;

  Future<void> exportToExcel(List<Map<String, dynamic>> data) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16.0),
              Text('Please Wait'),
            ],
          ),
        );
      },
    );

    // Delay execution for demonstration purposes (you can remove this in your actual code)
    await Future.delayed(Duration(seconds: 2));


    final CollectionReference deviceCollection = FirebaseFirestore.instance.collection('pilot-device-1');
    QuerySnapshot deviceSnapshot = await deviceCollection
        .where('statusDevice', whereIn: ['Done', 'handover-to-other-crew'])
        .get();

    List<Map<String, dynamic>> devicesData = deviceSnapshot.docs
        .map((DocumentSnapshot document) => document.data() as Map<String, dynamic>)
        .toList();


    // Create an Excel workbook
    final excel = Excel.createExcel();

    // Create a worksheet
    final sheet = excel['Handover Data'];

    // Add headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Timestamp';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = 'Crew ID';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = 'NAME';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = 'RANK';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = 'HUB';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = 'Device 1';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value = 'iOS Version (1st)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0)).value = 'Flysmart Version (1st)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0)).value = 'Docu Version (1st)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0)).value = 'LiDo Version (1st)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 0)).value = 'HUB (1st)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 0)).value = 'Condition (1st)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: 0)).value = 'Device 2';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 0)).value = 'iOS Version (2nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: 0)).value = 'Flysmart Version (2nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: 0)).value = 'Docu Version (2nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: 0)).value = 'LiDo Version (2nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: 0)).value = 'HUB (2nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: 0)).value = 'Condition (2nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 19, rowIndex: 0)).value = 'Device 3';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 20, rowIndex: 0)).value = 'iOS Version (3nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 21, rowIndex: 0)).value = 'Flysmart Version (3nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 22, rowIndex: 0)).value = 'Docu Version (3nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 23, rowIndex: 0)).value = 'LiDo Version (3nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 24, rowIndex: 0)).value = 'HUB (3nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 25, rowIndex: 0)).value = 'Condition (3nd)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 26, rowIndex: 0)).value = 'Status';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 27, rowIndex: 0)).value = 'OCC On Duty (ID)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 28, rowIndex: 0)).value = 'OCC On Duty (Name)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 29, rowIndex: 0)).value = 'OCC On Duty (HUB)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 30, rowIndex: 0)).value = 'OCC Accept (ID)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 31, rowIndex: 0)).value = 'OCC Accept (Name)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 32, rowIndex: 0)).value = 'OCC Accept (HUB)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 33, rowIndex: 0)).value = 'Handover To (ID)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 34, rowIndex: 0)).value = 'Handover To (Name)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 35, rowIndex: 0)).value = 'Handover To (Rank)';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 36, rowIndex: 0)).value = 'Handover To (HUB)';

    // Access 'users' collection to get 'RANK' and 'HUB' based on 'user_uid'
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    // Access 'Device' collection to get 'iosver' based on 'device_uid'
    CollectionReference devicesCollection = FirebaseFirestore.instance.collection('Device');

    for (var i = 0; i < devicesData.length; i++) {
      final device = devicesData[i];

      DocumentSnapshot userSnapshot = await usersCollection.doc(device['user_uid']).get();
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      String crewRank = userData['RANK'];
      String crewHub = userData['HUB'];
      String crewName = userData['NAME'];

      DocumentSnapshot occgivenSnapshot = await usersCollection.doc(device['occ-on-duty']).get();
      Map<String, dynamic> occgivenData = occgivenSnapshot.data() as Map<String, dynamic>;
      String occName = occgivenData['NAME'];
      String occHub = occgivenData['HUB'];

      // Check if device_uid is '-'
      String iosVersion = '-';
      String flysmartVersion = '-';
      String docuVersion = '-';
      String lidoVersion = '-';
      String hub = '-';
      String condition = '-';

      // Check if device_uid2 & device_uid3 is '-'
      String iosVersion2 = '-';
      String flysmartVersion2 = '-';
      String docuVersion2 = '-';
      String lidoVersion2 = '-';
      String hub2 = '-';
      String condition2 = '-';
      String iosVersion3 = '-';
      String flysmartVersion3 = '-';
      String docuVersion3 = '-';
      String lidoVersion3 = '-';
      String hub3 = '-';
      String condition3 = '-';

      String occAcceptedName = '-';
      String occAcceptedHub = '-';

      String handoverToName = '-';
      String handoverToHub = '-';
      String handoverToRank = '-';

      if (device['occ-accepted-device'] != null && device['occ-accepted-device'] != '-') {
        // If device_uid is not '-', get the 'iosver'
        DocumentSnapshot userSnapshot = await usersCollection.doc(device['occ-accepted-device']).get();
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        occAcceptedName = userData['NAME'] ?? '-';
        occAcceptedHub = userData['HUB'] ?? '-';
      }

      if (device['handover-to-crew'] != null && device['handover-to-crew'] != '-') {
        // If device_uid is not '-', get the 'iosver'
        DocumentSnapshot userSnapshot = await usersCollection.doc(device['handover-to-crew']).get();
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        handoverToName = userData['NAME'] ?? '-';
        handoverToHub = userData['HUB'] ?? '-';
        handoverToRank = userData['RANK'] ?? '-';
      }

      if (device['device_uid'] != null && device['device_uid'] != '-') {
        // If device_uid is not '-', get the 'iosver'
        DocumentSnapshot deviceSnapshot = await devicesCollection.doc(device['device_uid']).get();
        Map<String, dynamic> deviceData = deviceSnapshot.data() as Map<String, dynamic>;
        iosVersion = deviceData['iosver'] ?? '-';
        flysmartVersion = deviceData['flysmart'] ?? '-';
        docuVersion = deviceData['docuversion'] ?? '-';
        lidoVersion = deviceData['lidoversion'] ?? '-';
        hub = deviceData['hub'] ?? '-';
        condition = deviceData['condition'] ?? '-';
      }

      if (device['device_uid2'] != null && device['device_uid2'] != '-') {
        // If device_uid is not '-', get the 'iosver'
        DocumentSnapshot device2Snapshot = await devicesCollection.doc(device['device_uid2']).get();
        Map<String, dynamic> deviceData = device2Snapshot.data() as Map<String, dynamic>;
        iosVersion2 = deviceData['iosver'] ?? '-';
        flysmartVersion2 = deviceData['flysmart'] ?? '-';
        docuVersion2 = deviceData['docuversion'] ?? '-';
        lidoVersion2 = deviceData['lidoversion'] ?? '-';
        hub2 = deviceData['hub'] ?? '-';
        condition2 = deviceData['condition'] ?? '-';
      }

      if (device['device_uid3'] != null && device['device_uid3'] != '-') {
        // If device_uid is not '-', get the 'iosver'
        DocumentSnapshot device3Snapshot = await devicesCollection.doc(device['device_uid3']).get();
        Map<String, dynamic> deviceData = device3Snapshot.data() as Map<String, dynamic>;
        iosVersion3 = deviceData['iosver'] ?? '-';
        flysmartVersion3 = deviceData['flysmart'] ?? '-';
        docuVersion3 = deviceData['docuversion'] ?? '-';
        lidoVersion3 = deviceData['lidoversion'] ?? '-';
        hub3 = deviceData['hub'] ?? '-';
        condition3 = deviceData['condition'] ?? '-';
      }

      // Check if device_name is '-'
      String deviceName = (device['device_name'] ?? '-') == '-' ? '-' : device['device_name'] ?? '-';
      String deviceName2 = (device['device_name2'] ?? '-') == '-' ? '-' : device['device_name2'] ?? '-';
      String deviceName3 = (device['device_name3'] ?? '-') == '-' ? '-' : device['device_name3'] ?? '-';
      String OccAccepted = (device['occ-accepted-device'] ?? '-') == '-' ? '-' : device['occ-accepted-device'] ?? '-';
      String HandoverToCrew = (device['handover-to-crew'] ?? '-') == '-' ? '-' : device['handover-to-crew'] ?? '-';

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = device['timestamp'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = device['user_uid'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = crewName;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = crewRank;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = crewHub;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = deviceName;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = iosVersion;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1)).value = flysmartVersion;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1)).value = docuVersion;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 1)).value = lidoVersion;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: i + 1)).value = hub;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: i + 1)).value = condition;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: i + 1)).value = deviceName2;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: i + 1)).value = iosVersion2;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: i + 1)).value = flysmartVersion2;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: i + 1)).value = docuVersion2;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: i + 1)).value = lidoVersion2;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: i + 1)).value = hub2;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: i + 1)).value = condition2;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 19, rowIndex: i + 1)).value = deviceName3;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 20, rowIndex: i + 1)).value = iosVersion3;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 21, rowIndex: i + 1)).value = flysmartVersion3;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 22, rowIndex: i + 1)).value = docuVersion3;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 23, rowIndex: i + 1)).value = lidoVersion3;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 24, rowIndex: i + 1)).value = hub3;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 25, rowIndex: i + 1)).value = condition3;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 26, rowIndex: i + 1)).value = device['statusDevice'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 27, rowIndex: i + 1)).value = device['occ-on-duty'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 28, rowIndex: i + 1)).value = occName;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 29, rowIndex: i + 1)).value = occHub;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 30, rowIndex: i + 1)).value = OccAccepted;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 31, rowIndex: i + 1)).value = occAcceptedName;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 32, rowIndex: i + 1)).value = occAcceptedHub;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 33, rowIndex: i + 1)).value = HandoverToCrew;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 34, rowIndex: i + 1)).value = handoverToName;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 35, rowIndex: i + 1)).value = handoverToHub;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 36, rowIndex: i + 1)).value = handoverToRank;
    }

    // Save the Excel file
    final excelBytes = excel.encode();
    final output = await getTemporaryDirectory();
    final excelFile = File('${output.path}/handover-history.xlsx');
    await excelFile.writeAsBytes(excelBytes!);

    // Close the dialog
    Navigator.pop(context);  // Close the dialog

    // Open the Excel file using a platform-specific API
    await OpenFile.open(excelFile.path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FilterBottomSheet(
          onDateRangeSelected: (DateTime startDate, DateTime endDate) {
            setState(() {
              _startDate = startDate;
              _endDate = endDate;
            });
          },
          onRankFilterChanged: (bool foChecked, bool captChecked) {
            setState(() {
              isFoChecked = foChecked;
              isCaptChecked = captChecked;
            });
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchDataFromFirebase() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('pilot-device-1').get();

    List<Map<String, dynamic>> data = [];
    querySnapshot.docs.forEach((doc) {
      data.add(doc.data() as Map<String, dynamic>);
    });

    return data;
  }

  String? userHub; // Add this variable

  Future<void> _fetchUserHub() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userEmail = user.email;
    if (userEmail == null) return;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('EMAIL', isEqualTo: userEmail)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userDoc = userSnapshot.docs.first;
      setState(() {
        userHub = userDoc['HUB'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserHub(); // Fetch the userHub when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Set background color to white
        title: Text(
          'History',
          style: TextStyle(
            color: Colors.black, // Set text color to red
            fontSize: 20.1,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Tooltip(
            message: 'Export to Sheet',
            child: IconButton(
              icon: Icon(
                Icons.table_chart_rounded,
              ),
              onPressed: () async {
                List<Map<String, dynamic>> data = await fetchDataFromFirebase();
                await exportToExcel(data);
              },
            ),
          ),
        ],
        centerTitle: true, // Center the title
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by Device No',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      size: 45,
                    ),
                    onPressed: _showFilterBottomSheet,
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("pilot-device-1")
                    .where('statusDevice',
                        whereIn: ['Done', 'handover-to-other-crew'])
                    .where('timestamp',
                        isGreaterThanOrEqualTo: _startDate,
                        isLessThanOrEqualTo: _endDate) // Add this line
                    .where('field_hub', isEqualTo: userHub)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  print(userHub);

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final documents = snapshot.data?.docs;

                  if (documents == null || documents.isEmpty) {
                    return Center(child: Text('No data available.'));
                  }

                  // Filter documents based on search
                  final filteredDocuments = documents.where((document) {
                    final data = document.data() as Map<String, dynamic>;
                    final userName = data['NAME'].toString().toLowerCase();
                    final deviceName =
                        data['device_name'].toString().toLowerCase();
                    final deviceName2 =
                        data['device_name2'].toString().toLowerCase();
                    final deviceName3 =
                        data['device_name3'].toString().toLowerCase();
                    final searchTerm = _searchController.text.toLowerCase();

                    return userName.contains(searchTerm) ||
                        deviceName.contains(searchTerm) ||
                        deviceName2.contains(searchTerm) ||
                        deviceName3.contains(searchTerm);
                  }).toList();

                  // Filter documents based on rank (FO and CAPT)
                  final rankFilteredDocuments =
                      filteredDocuments.where((document) {
                    final data = document.data() as Map<String, dynamic>;
                    final rank = data['RANK'].toString().toLowerCase();

                    if (isFoChecked && isCaptChecked) {
                      // Both FO and CAPT are selected
                      return true;
                    } else if (isFoChecked) {
                      // Only FO is selected
                      return rank.contains('fo');
                    } else if (isCaptChecked) {
                      // Only CAPT is selected
                      return rank.contains('capt');
                    } else {
                      // Neither FO nor CAPT is selected
                      return true;
                    }
                  }).toList();

                  return ListView.builder(
                    itemCount: rankFilteredDocuments.length,
                    itemBuilder: (context, index) {
                      final document = rankFilteredDocuments[index];
                      final data = document.data() as Map<String, dynamic>;
                      final dataId = document.id;
                      final userUid = data['user_uid'];
                      final deviceUid = data['device_uid'];
                      final timestamp = data['timestamp'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        child: FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userUid)
                              .get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (userSnapshot.hasError) {
                              return Text('Error: ${userSnapshot.error}');
                            }

                            final userData = userSnapshot.data?.data()
                                as Map<String, dynamic>?;

                            if (userData == null) {
                              return Text('User data not found');
                            }

                            final userName = userData['NAME'];
                            final userRank = userData['RANK'];
                            final photoUrl = userData['PHOTOURL']
                                as String?; // Get the profile photo URL

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('Device')
                                  .doc(deviceUid)
                                  .get(),
                              builder: (context, deviceSnapshot) {
                                if (deviceSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }

                                if (deviceSnapshot.hasError) {
                                  return Text('Error: ${deviceSnapshot.error}');
                                }

                                final deviceData = deviceSnapshot.data?.data()
                                    as Map<String, dynamic>?;

                                if (!deviceSnapshot.hasData ||
                                    !deviceSnapshot.data!.exists) {
                                  final deviceUid2 = data['device_uid2'];
                                  final deviceUid3 = data['device_uid3'];

                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('Device')
                                        .doc(deviceUid2)
                                        .get(),
                                    builder: (context, deviceUid2Snapshot) {
                                      if (deviceUid2Snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }

                                      if (deviceUid2Snapshot.hasError) {
                                        return Text(
                                            'Error: ${deviceUid2Snapshot.error}');
                                      }

                                      final deviceData2 =
                                          deviceUid2Snapshot.data?.data()
                                              as Map<String, dynamic>?;

                                      if (!deviceUid2Snapshot.hasData ||
                                          !deviceUid2Snapshot.data!.exists) {
                                        return Text('Device Not Found');
                                      }

                                      final deviceno2 =
                                          deviceData2?['deviceno'];

                                      return FutureBuilder<DocumentSnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('Device')
                                            .doc(deviceUid3)
                                            .get(),
                                        builder: (context, deviceUid3Snapshot) {
                                          if (deviceUid3Snapshot
                                                  .connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          }

                                          if (deviceUid3Snapshot.hasError) {
                                            return Text(
                                                'Error: ${deviceUid3Snapshot.error}');
                                          }

                                          final deviceData3 =
                                              deviceUid3Snapshot.data?.data()
                                                  as Map<String, dynamic>?;

                                          if (!deviceUid2Snapshot.hasData ||
                                              !deviceUid3Snapshot
                                                  .data!.exists) {
                                            return Text('Device Not Found');
                                          }

                                          final deviceno3 =
                                              deviceData3?['deviceno'];

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Card(
                                                  color: tsOneColorScheme
                                                      .secondary,
                                                  surfaceTintColor:
                                                      TsOneColor.surface,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  elevation:
                                                      3, // You can adjust the elevation as needed
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              DetailHistoryDeviceFOView(
                                                            dataId: dataId,
                                                            userName: userName,
                                                            deviceno2:
                                                                deviceno2,
                                                            deviceno3:
                                                                deviceno3,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(width: 8.0),
                                                          CircleAvatar(
                                                            backgroundImage: photoUrl !=
                                                                    null
                                                                ? NetworkImage(
                                                                    photoUrl
                                                                        as String)
                                                                : AssetImage(
                                                                        'assets/default_profile_image.png')
                                                                    as ImageProvider,
                                                            radius: 25.0,
                                                          ),
                                                          SizedBox(width: 12.0),
                                                          Flexible(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  child: Text(
                                                                    '$userName',
                                                                    style: tsOneTextTheme
                                                                        .titleMedium,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '$userRank',
                                                                  style: tsOneTextTheme
                                                                      .labelSmall,
                                                                ),
                                                                Text(
                                                                  '$deviceno2' +
                                                                      ' & ' +
                                                                      '$deviceno3',
                                                                  style: tsOneTextTheme
                                                                      .labelSmall,
                                                                ),
                                                                Text(
                                                                  '${DateFormat('yyyy-MM-dd HH:mm a').format(timestamp.toDate())}',
                                                                  style: tsOneTextTheme
                                                                      .labelSmall,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const Icon(
                                                            Icons.chevron_right,
                                                            color: TsOneColor
                                                                .onSecondary,
                                                            size: 30,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                }

                                final deviceno = deviceData?['deviceno'];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Card(
                                    color: tsOneColorScheme.secondary,

                                    surfaceTintColor: TsOneColor.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation:
                                        3, // You can adjust the elevation as needed
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(15.0),
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) =>
                                              DetailHistoryDeviceView(
                                            dataId: dataId,
                                            userName: userName,
                                            deviceno: deviceno,
                                          ),
                                        ));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            10.0), // Adjust padding as needed
                                        child: Row(
                                          children: [
                                            SizedBox(width: 8.0),
                                            CircleAvatar(
                                              backgroundImage: photoUrl != null
                                                  ? NetworkImage(
                                                      photoUrl as String)
                                                  : AssetImage(
                                                          'assets/default_profile_image.png')
                                                      as ImageProvider,
                                              radius: 25.0,
                                            ),
                                            SizedBox(width: 17.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    child: Text(
                                                      '$userName',
                                                      style: tsOneTextTheme
                                                          .titleMedium,
                                                    ),
                                                  ),
                                                  Text(
                                                    '$userRank',
                                                    style: tsOneTextTheme
                                                        .labelSmall,
                                                  ),
                                                  Text(
                                                    '$deviceno',
                                                    style: tsOneTextTheme
                                                        .labelSmall,
                                                  ),
                                                  Text(
                                                    '${DateFormat('yyyy-MM-dd HH:mm a').format(timestamp.toDate())}',
                                                    style: tsOneTextTheme
                                                        .labelSmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right,
                                              color: TsOneColor
                                                  .onSecondary,
                                              size: 30,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final Function(DateTime, DateTime) onDateRangeSelected;
  final Function(bool, bool) onRankFilterChanged;

  const FilterBottomSheet({
    required this.onDateRangeSelected,
    required this.onRankFilterChanged,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late DateTime startDate = DateTime.now();
  late DateTime endDate = DateTime.now();
  bool isFoChecked = false;
  bool isCaptChecked = false;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != startDate)
      setState(() {
        startDate = picked;
      });
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != endDate)
      setState(() {
        endDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar untuk menambahkan tombol Reset
            AppBar(
              automaticallyImplyLeading: false, // Menghilangkan tombol back
              title: Text(
                'Filter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          startDate.toLocal().toString().split(' ')[0],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          endDate.toLocal().toString().split(' ')[0],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  widget.onDateRangeSelected(startDate, endDate);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  primary: TsOneColor.primary,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width,
                    48,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
