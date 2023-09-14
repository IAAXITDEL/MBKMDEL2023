import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/app/modules/efb/occ/views/history/detail_history_device_view.dart';

class HistoryAllDeviceView extends StatelessWidget {
  const HistoryAllDeviceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HistoryAllDeviceView'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pilot-device-1")
            .where('status-device-1', whereIn: ['Done', 'handover-to-other-crew'])
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

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              final data = document.data() as Map<String, dynamic>;
              final dataId = document.id;
              final userUid = data['user_uid'];
              final deviceUid = data['device_uid'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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

                    final userData =
                    userSnapshot.data?.data() as Map<String, dynamic>?;

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
                        if (deviceSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (deviceSnapshot.hasError) {
                          return Text('Error: ${deviceSnapshot.error}');
                        }

                        final deviceData =
                        deviceSnapshot.data?.data() as Map<String, dynamic>?;

                        if (deviceData == null) {
                          return Text('Device data not found');
                        }

                        final deviceno = deviceData['deviceno'];

                        return ElevatedButton(
                          onPressed: () {
                            // Navigate to the DetailHistoryDeviceView when the button is pressed.
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
    );
  }
}