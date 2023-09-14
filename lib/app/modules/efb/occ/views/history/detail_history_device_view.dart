import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../presentation/theme.dart';

class DetailHistoryDeviceView extends GetView {
  final String dataId;
  final String userName;
  final String deviceno;

  const DetailHistoryDeviceView({
    Key? key,
    required this.dataId,
    required this.userName,
    required this.deviceno,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DETAIL'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("pilot-device-1")
              .doc(dataId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Data not found'));
            }

            final data = snapshot.data!.data()
            as Map<String, dynamic>;

            final userUid = data['user_uid'];
            final deviceUid = data['device_uid'];
            final otherCrewid = data['handover-to-crew'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(userUid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${userSnapshot.error}'));
                }

                if (!userSnapshot.hasData ||
                    !userSnapshot.data!.exists) {
                  return Center(child: Text('User data not found'));
                }

                final userData = userSnapshot.data!.data()
                as Map<String, dynamic>;

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("Device")
                      .doc(deviceUid)
                      .get(),
                  builder: (context, deviceSnapshot) {
                    if (deviceSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator());
                    }

                    if (deviceSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${deviceSnapshot.error}'));
                    }

                    if (!deviceSnapshot.hasData ||
                        !deviceSnapshot.data!.exists) {
                      return Center(child: Text('Device data not found'));
                    }

                    final deviceData =
                    deviceSnapshot.data!.data()
                    as Map<String, dynamic>;



                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text("CREW INFO",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 7.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("ID NO")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${userData['ID NO'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Name")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${userData['NAME'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Rank")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${userData['RANK'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  Text("DEVICE INFO",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 7.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Device ID")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${data['device_name'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("iOS Version")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${deviceData['iosver'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("FlySmart Version")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${deviceData['flysmart'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Docu Version")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${deviceData['docuversion'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Lido Version")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${deviceData['lidoversion'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("Condition")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${deviceData['condition'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  Text("OCC ON DUTY",
                                    style: tsOneTextTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 7.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("OCC That Gives")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${data['occ-on-duty'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Text("OCC Who Received")),
                                      Expanded(
                                          flex: 1, child: Text(":")),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${data['occ-accepted-device'] ?? 'No Data'}'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 70.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      // confirmInUse(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: TsOneColor.greenColor,
                                      minimumSize: const Size(double.infinity, 50),
                                    ),
                                    child: const Text('Download PDF', style: TextStyle(color: Colors.white),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
