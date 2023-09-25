import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:ts_one/app/modules/efb/occ/views/history/detail_history_device_view.dart';

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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Device Used'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Name or Device No',
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("pilot-device-1")
                  .where('statusDevice', whereIn: ['Done', 'handover-to-other-crew'])
                  .where('timestamp', isGreaterThanOrEqualTo: _startDate, isLessThanOrEqualTo: _endDate) // Add this line
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

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
                  final deviceName = data['device_name'].toString().toLowerCase();
                  final searchTerm = _searchController.text.toLowerCase();

                  return userName.contains(searchTerm) || deviceName.contains(searchTerm);
                }).toList();

                return ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final document = filteredDocuments[index];
                    final data = document.data() as Map<String, dynamic>;
                    final dataId = document.id;
                    final userUid = data['user_uid'];
                    final deviceUid = data['device_uid'];
                    final timestamp = data['timestamp'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userUid)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (userSnapshot.hasError) {
                            return Text('Error: ${userSnapshot.error}');
                          }

                          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                          if (userData == null) {
                            return Text('User data not found');
                          }

                          final userName = userData['NAME'];

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('Device')
                                .doc(deviceUid)
                                .get(),
                            builder: (context, deviceSnapshot) {
                              if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              if (deviceSnapshot.hasError) {
                                return Text('Error: ${deviceSnapshot.error}');
                              }

                              final deviceData = deviceSnapshot.data?.data() as Map<String, dynamic>?;

                              if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                                final deviceUid2 = data['device_uid2'];
                                final deviceUid3 = data['device_uid3'];

                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('Device')
                                      .doc(deviceUid2)
                                      .get(),
                                  builder: (context, deviceUid2Snapshot) {
                                    if (deviceUid2Snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }

                                    if (deviceUid2Snapshot.hasError) {
                                      return Text('Error: ${deviceUid2Snapshot.error}');
                                    }

                                    final deviceData2 = deviceUid2Snapshot.data?.data() as Map<String, dynamic>?;

                                    if (!deviceUid2Snapshot.hasData || !deviceUid2Snapshot.data!.exists) {
                                      return Text('Device Not Found');
                                    }

                                    final deviceno2 = deviceData2?['deviceno'];

                                        return FutureBuilder<DocumentSnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('Device')
                                            .doc(deviceUid3)
                                            .get(),
                                        builder: (context, deviceUid3Snapshot) {
                                        if (deviceUid3Snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                        }

                                        if (deviceUid3Snapshot.hasError) {
                                        return Text('Error: ${deviceUid3Snapshot.error}');
                                        }

                                        final deviceData3 = deviceUid3Snapshot.data?.data() as Map<String, dynamic>?;

                                        if (!deviceUid2Snapshot.hasData || !deviceUid3Snapshot.data!.exists) {
                                        return Text('Device Not Found');
                                        }

                                        final deviceno3 = deviceData3?['deviceno'];


                                    return ElevatedButton(
                                      onPressed:  () {
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => DetailHistoryDeviceFOView(
                                            dataId: dataId,
                                            userName: userName,
                                            deviceno2: deviceno2,
                                            deviceno3: deviceno3,
                                          ),
                                        ));
                                      },
                                      child: Column(
                                        children: [
                                          Text('Crew Name: $userName'),
                                          Text('Device No 1: $deviceno2'),
                                          Text('Device No 2: $deviceno3'),
                                          Text('Loan Date: ${DateFormat('yyyy-MM-dd ; HH:mm').format(timestamp.toDate())}'),
                                        ],
                                      ),
                                    );
                                        },
                                    );
                                  },
                                );
                              }

                              final deviceno = deviceData?['deviceno'];


                              return ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => DetailHistoryDeviceView(
                                      dataId: dataId,
                                      userName: userName,
                                      deviceno: deviceno,
                                    ),
                                  ));
                                },
                                child: Column(
                                  children: [
                                    Text('Crew Name: $userName'),
                                    Text('Device No: $deviceno'),
                                    Text('Loan Date: ${DateFormat('yyyy-MM-dd ; HH:mm').format(timestamp.toDate())}'),
                                  ],
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
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final Function(DateTime, DateTime) onDateRangeSelected;

  const FilterBottomSheet({required this.onDateRangeSelected});

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late DateTime startDate = DateTime.now();
  late DateTime endDate = DateTime.now();

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
      height: 200,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Filter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start Date: ${startDate.toLocal().toString().split(' ')[0]}',
                  ),
                  ElevatedButton(
                    onPressed: () => _selectStartDate(context),
                    child: Text('Pick'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'End Date: ${endDate.toLocal().toString().split(' ')[0]}',
                  ),
                  ElevatedButton(
                    onPressed: () => _selectEndDate(context),
                    child: Text('Pick'),
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
                child: Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}