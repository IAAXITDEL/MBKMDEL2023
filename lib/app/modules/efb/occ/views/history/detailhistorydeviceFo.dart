import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/modules/efb/occ/views/feedbackDetail/feedbackDetailPage.dart';

import '../../../../../../presentation/theme.dart';
import '../../../occ/views/history/handover_attachment23.dart';

class DetailHistoryDeviceFOView extends GetView {
  final String dataId;
  final String userName;
  final String deviceno2;
  final String deviceno3;

  const DetailHistoryDeviceFOView({
    Key? key,
    required this.dataId,
    required this.userName,
    required this.deviceno2,
    required this.deviceno3,
  }) : super(key: key);

  @override
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No Data';

    DateTime dateTime = timestamp.toDate();
    // Format the date and time as desired, e.g., 'dd/MM/yyyy HH:mm:ss'
    String formattedDateTime = '${dateTime.day}/${dateTime.month}/${dateTime.year}'
        ' at '
        '${dateTime.hour}:${dateTime.minute}';
    return formattedDateTime;
  }

  Future<String> getDocumentIdForFeedback(String feedbackId) async {
    // Ambil semua dokumen dari koleksi 'pilot-feedback'
    QuerySnapshot feedbackQuerySnapshot = await FirebaseFirestore.instance.collection('pilot-feedback').get();

    for (QueryDocumentSnapshot doc in feedbackQuerySnapshot.docs) {
      // Untuk setiap dokumen, periksa apakah 'id' sesuai dengan 'feedbackId'
      if (doc['feedback_id'] == feedbackId) {
        // Jika cocok, kembalikan id dokumen yang sesuai
        return feedbackId;
      }
    }

    // Jika tidak ada yang cocok, kembalikan 'N/A' atau nilai default lainnya
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Device Usage History',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection("pilot-device-1").doc(dataId).get(),
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

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final userUid = data['user_uid'];
            final deviceUid2 = data['device_uid2'];
            final deviceUid3 = data['device_uid3'];
            final status = data['statusDevice'];
            final handoverTo = data['handover-to-crew'];
            final occOnDuty = data['occ-on-duty'];
            final occAccepted = data['occ-accepted-device'];
            final feedbackId = data['feedbackId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("users").doc(userUid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Center(child: Text('User data not found'));
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                //handover from
                return FutureBuilder<DocumentSnapshot>(
                  future: handoverTo != null ? FirebaseFirestore.instance.collection("users").doc(handoverTo).get() : Future.value(null),
                  builder: (context, handoverToSnapshot) {
                    if (handoverToSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (handoverToSnapshot.hasError) {
                      return Center(child: Text('Error: ${handoverToSnapshot.error}'));
                    }

                    final handoverTouserData = handoverToSnapshot.data?.data() as Map<String, dynamic>?;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection("Device").doc(deviceUid2).get(),
                      builder: (context, deviceUid2Snapshot) {
                        if (deviceUid2Snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (deviceUid2Snapshot.hasError) {
                          return Center(child: Text('Error: ${deviceUid2Snapshot.error}'));
                        }

                        if (!deviceUid2Snapshot.hasData || !deviceUid2Snapshot.data!.exists) {
                          return Center(child: Text('Device data not found'));
                        }

                        final deviceData2 = deviceUid2Snapshot.data!.data() as Map<String, dynamic>;

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection("Device").doc(deviceUid3).get(),
                          builder: (context, deviceUid3Snapshot) {
                            if (deviceUid3Snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (deviceUid3Snapshot.hasError) {
                              return Center(child: Text('Error: ${deviceUid3Snapshot.error}'));
                            }

                            if (!deviceUid3Snapshot.hasData || !deviceUid3Snapshot.data!.exists) {
                              return Center(child: Text('Device data 3 not found'));
                            }

                            final deviceData3 = deviceUid3Snapshot.data!.data() as Map<String, dynamic>;

                            //occ on duty from
                            return FutureBuilder<DocumentSnapshot>(
                              future: occOnDuty != null ? FirebaseFirestore.instance.collection("users").doc(occOnDuty).get() : Future.value(null),
                              builder: (context, occOnDutySnapshot) {
                                if (occOnDutySnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                if (occOnDutySnapshot.hasError) {
                                  return Center(child: Text('Error: ${occOnDutySnapshot.error}'));
                                }

                                final occOnDutyuserData = occOnDutySnapshot.data?.data() as Map<String, dynamic>?;

                                //occ accepted from
                                return FutureBuilder<DocumentSnapshot>(
                                  future: occAccepted != null
                                      ? FirebaseFirestore.instance.collection("users").doc(occAccepted).get()
                                      : Future.value(null),
                                  builder: (context, occAcceptedSnapshot) {
                                    if (occAcceptedSnapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }

                                    if (occAcceptedSnapshot.hasError) {
                                      return Center(child: Text('Error: ${occAcceptedSnapshot.error}'));
                                    }

                                    final occAccepteduserData = occAcceptedSnapshot.data?.data() as Map<String, dynamic>?;

                                    // Format document
                                    return FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance.collection("efb-document").doc("handover-log").get(),
                                      builder: (context, formatSnapshot) {
                                        if (formatSnapshot.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator());
                                        }

                                        if (formatSnapshot.hasError) {
                                          return Center(child: Text('Error: ${formatSnapshot.error}'));
                                        }

                                        final formatData = formatSnapshot.data?.data() as Map<String, dynamic>?;

                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    //show date
                                                    Align(
                                                      alignment: Alignment.centerRight,
                                                      child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
                                                    ),
                                                    // SizedBox(height: 7),
                                                    // Row(
                                                    //   children: [
                                                    //     Expanded(flex: 6, child: Text("Loan Date")),
                                                    //     Expanded(flex: 1, child: Text(":")),
                                                    //     Expanded(
                                                    //       flex: 6,
                                                    //       child: Text(_formatTimestamp(data['timestamp'])),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    SizedBox(height: 15.0),

                                                    // Text(
                                                    //   "CREW INFO",
                                                    //   style: tsOneTextTheme.headlineLarge,
                                                    // ),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("ID NO")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${userData['ID NO'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Name")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${userData['NAME'] ?? 'No Data'}'),
                                                        ),
                                                      ], //
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Rank")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${userData['RANK'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 15.0),

                                                    const Padding(
                                                      padding: EdgeInsets.only(bottom: 16.0),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Divider(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                            child: Text(
                                                              'EFB Details',
                                                              style: TextStyle(color: Colors.grey),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Divider(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15.0),
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text("Handover", style: tsOneTextTheme.displaySmall),
                                                    ),
                                                    const SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text(
                                                            "Remarks",
                                                            style: tsOneTextTheme.bodySmall,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            ":",
                                                            style: tsOneTextTheme.bodySmall,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text(
                                                            '${data['remarks-handover'] ?? 'No Remarks'}',
                                                            style: tsOneTextTheme.bodySmall,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5.0),
                                                    if (userData['RANK'] == 'FO')
                                                      Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text("Charger", style: tsOneTextTheme.headlineMedium),
                                                      ),
                                                    if (userData['RANK'] == 'FO') const SizedBox(height: 10.0),
                                                    if (userData['RANK'] == 'FO')
                                                      Row(
                                                        children: [
                                                          Expanded(flex: 6, child: Text("Charger No")),
                                                          Expanded(child: Text(":")),
                                                          Expanded(
                                                            flex: 6,
                                                            child: Text(
                                                              '${data['charger_no'] ?? 'No Data'}',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (userData['RANK'] == 'FO') SizedBox(height: 15.0),

                                                    //device info
                                                    Text("Device 2", style: tsOneTextTheme.headlineMedium),
                                                    SizedBox(height: 7.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Device No")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${data['device_name2'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("IOS Version")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${deviceData2['value']['iosver'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("FlySmart Version")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${deviceData2['value']['flysmart'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Docunet Version")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${deviceData2['value']['docuversion'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Lido mPilot Version")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${deviceData2['value']['lidoversion'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("HUB")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${deviceData2['value']['hub'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    // SizedBox(height: 5.0),
                                                    // Row(
                                                    //   children: [
                                                    //     Expanded(flex: 6, child: Text("Condition")),
                                                    //     Expanded(flex: 1, child: Text(":")),
                                                    //     Expanded(
                                                    //       flex: 6,
                                                    //       child: Text('${deviceData2['value']['condition'] ?? 'No Data'}'),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    SizedBox(
                                                      height: 15.0,
                                                    ),
                                                    //device info
                                                    Text("Device 2 Condition", style: tsOneTextTheme.headlineMedium),
                                                    SizedBox(height: 7.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Given")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${data['initial-condition-category2'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 7.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Given Remarks")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${data['initial-condition-remarks2'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 7.0),
                                                    // Center(
                                                    //   child: Icon(Icons.arrow_downward, size: 24), // Icon panah ke bawah di tengah
                                                    // ),
                                                    SizedBox(height: 7.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Accepted")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${data['return-condition-category2'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 7.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Accepted Remarks")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${data['return-condition-remarks3'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8.0),

                                                    const Padding(
                                                      padding: EdgeInsets.only(bottom: 16.0),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Divider(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    Text("Device 3", style: tsOneTextTheme.headlineMedium),
                                                    SizedBox(height: 7.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Device No")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${data['device_name3'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("IOS Version")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${deviceData3['value']['iosver'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("FlySmart Version")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${deviceData3['value']['flysmart'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Docunet Version")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${deviceData3['value']['docuversion'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Lido mPilot Version")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${deviceData3['value']['lidoversion'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("HUB")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${deviceData3['value']['hub'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15.0,
                                                    ),
                                                    // Row(
                                                    //   children: [
                                                    //     Expanded(flex: 6, child: Text("Condition")),
                                                    //     Expanded(flex: 1, child: Text(":")),
                                                    //     Expanded(
                                                    //       flex: 6,
                                                    //       child: Text('${deviceData3['value']['condition'] ?? 'No Data'}'),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    Text("Device 3 Condition", style: tsOneTextTheme.headlineMedium),
                                                    SizedBox(height: 7.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Given")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${data['initial-condition-category3'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 7.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Given Remarks")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${data['initial-condition-remarks3'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 7.0),
                                                    // Center(
                                                    //   child: Icon(Icons.arrow_downward, size: 24), // Icon panah ke bawah di tengah
                                                    // ),
                                                    SizedBox(height: 7.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Accepted")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${data['return-condition-category3'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 7.0),
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Accepted Remarks")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${data['return-condition-remarks3'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 15.0),

                                                    const Padding(
                                                      padding: EdgeInsets.only(bottom: 15.0),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Divider(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                            child: Text(
                                                              'Handover Documentation',
                                                              style: TextStyle(color: Colors.grey),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Divider(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    if (status == 'Done') Text("OCC On Duty", style: tsOneTextTheme.headlineMedium),
                                                    if (status == 'Done') SizedBox(height: 7.0),
                                                    if (status == 'Done')
                                                      Row(
                                                        children: [
                                                          Expanded(flex: 6, child: Text("Given by")),
                                                          Expanded(flex: 1, child: Text(":")),
                                                          Expanded(
                                                            flex: 6,
                                                            child: Text('${occOnDutyuserData?['NAME'] ?? 'No Data'}'),
                                                          ),
                                                        ],
                                                      ),
                                                    if (status == 'Done') SizedBox(height: 5.0),
                                                    if (status == 'Done')
                                                      Row(
                                                        children: [
                                                          Expanded(flex: 6, child: Text("Received by")),
                                                          Expanded(flex: 1, child: Text(":")),
                                                          Expanded(flex: 6, child: Text('${occAccepteduserData?['NAME'] ?? 'No Data'}')),
                                                        ],
                                                      ),

                                                    if (status == 'handover-to-other-crew') Text("Given To", style: tsOneTextTheme.headlineMedium),
                                                    SizedBox(height: 7.0),
                                                    if (status == 'handover-to-other-crew')
                                                      Row(
                                                        children: [
                                                          Expanded(flex: 6, child: Text("ID NO")),
                                                          Expanded(flex: 1, child: Text(":")),
                                                          Expanded(
                                                            flex: 6,
                                                            child: handoverTouserData != null
                                                                ? Text('${handoverTouserData['ID NO'] ?? 'Not Found'}')
                                                                : Text('Not Found'),
                                                          ),
                                                        ],
                                                      ),
                                                    SizedBox(height: 5.0),
                                                    if (status == 'handover-to-other-crew')
                                                      Row(
                                                        children: [
                                                          Expanded(flex: 6, child: Text("NAME")),
                                                          Expanded(flex: 1, child: Text(":")),
                                                          Expanded(
                                                            flex: 6,
                                                            child: handoverTouserData != null
                                                                ? Text('${handoverTouserData['NAME'] ?? 'Not Found'}')
                                                                : Text('Not Found'),
                                                          ),
                                                        ],
                                                      ),
                                                    SizedBox(height: 5.0),
                                                    if (status == 'handover-to-other-crew')
                                                      Row(
                                                        children: [
                                                          Expanded(flex: 6, child: Text("RANK")),
                                                          Expanded(flex: 1, child: Text(":")),
                                                          Expanded(
                                                            flex: 6,
                                                            child: handoverTouserData != null
                                                                ? Text('${handoverTouserData['RANK'] ?? 'Not Found'}')
                                                                : Text('Not Found'),
                                                          ),
                                                        ],
                                                      ),
                                                    if (status == 'handover-to-other-crew')
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                    if (status == 'handover-to-other-crew')
                                                      Text("Return Documentation", style: tsOneTextTheme.headlineMedium),
                                                    if (status == 'handover-to-other-crew')
                                                      Row(
                                                        children: [
                                                          Expanded(flex: 6, child: Text("Remarks")),
                                                          Expanded(flex: 1, child: Text(":")),
                                                          Expanded(
                                                            flex: 6,
                                                            child: handoverTouserData != null
                                                                ? Text('${data['remarks'] ?? 'Not Found'}')
                                                                : Text('Not Found'),
                                                          ),
                                                        ],
                                                      ),
                                                    if (status == 'handover-to-other-crew') SizedBox(height: 7.0),
                                                    if (status == 'handover-to-other-crew')
                                                      Row(
                                                        children: [
                                                          Expanded(flex: 6, child: Text("Proof of Remarks")),
                                                          Expanded(flex: 1, child: Text(":")),
                                                          Expanded(
                                                            flex: 6,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                if (status == 'handover-to-other-crew' && data['prove_image_url'] == null ||
                                                                    data['prove_image_url'].isEmpty)
                                                                  Text(
                                                                    'There is no image',
                                                                    style: TextStyle(color: Colors.black),
                                                                  ),
                                                                if (data['prove_image_url'] != null && data['prove_image_url'].isNotEmpty)
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (BuildContext context) {
                                                                          return AlertDialog(
                                                                            content: Container(
                                                                              width: 400,
                                                                              height: 400,
                                                                              child: Image.network(
                                                                                data['prove_image_url'] ?? 'No Data',
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      );
                                                                    },
                                                                    child: Align(
                                                                      alignment: Alignment.centerLeft,
                                                                      child: Text(
                                                                        'Open Picture',
                                                                        style: TextStyle(
                                                                          color: TsOneColor.primary,
                                                                          fontWeight: FontWeight.bold,
                                                                          decoration: TextDecoration.underline,
                                                                          decorationColor: TsOneColor.primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                    if (status == 'Done') SizedBox(height: 15.0),
                                                    if (status == 'Done') Text("Return Documentation", style: tsOneTextTheme.headlineMedium),
                                                    if (status == 'Done') SizedBox(height: 10.0),
                                                    if (status == 'Done')
                                                      Row(
                                                        children: [
                                                          Expanded(flex: 6, child: Text("Proof Back To Base")),
                                                          Expanded(flex: 1, child: Text(":")),
                                                          Expanded(
                                                            flex: 6,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                if (status == 'Done' && data['prove_back_to_base'] == null ||
                                                                    data['prove_back_to_base'].isEmpty)
                                                                  Text(
                                                                    'There is no image',
                                                                    style: TextStyle(color: Colors.black),
                                                                  ),
                                                                if (data['prove_back_to_base'] != null && data['prove_back_to_base'].isNotEmpty)
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (BuildContext context) {
                                                                          return AlertDialog(
                                                                            content: Container(
                                                                              width: 400,
                                                                              height: 400,
                                                                              child: Image.network(
                                                                                data['prove_back_to_base']!,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      );
                                                                    },
                                                                    child: Align(
                                                                      alignment: Alignment.centerLeft,
                                                                      child: Text(
                                                                        'Open Picture',
                                                                        style: TextStyle(
                                                                          color: TsOneColor.primary,
                                                                          fontWeight: FontWeight.bold,
                                                                          decoration: TextDecoration.underline,
                                                                          decorationColor: TsOneColor.primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                    // if (status == 'Done') SizedBox(height: 15),
                                                    // if (status == 'Done') Text("OCC On Duty", style: tsOneTextTheme.headlineMedium),
                                                    // if (status == 'Done') SizedBox(height: 7.0),
                                                    // if (status == 'Done')
                                                    //   Row(
                                                    //     children: [
                                                    //       Expanded(flex: 6, child: Text("Given by")),
                                                    //       Expanded(flex: 1, child: Text(":")),
                                                    //       Expanded(
                                                    //         flex: 6,
                                                    //         child: Text('${occOnDutyuserData?['NAME'] ?? 'No Data'}'),
                                                    //       ),
                                                    //     ],
                                                    //   ),
                                                    // if (status == 'Done') SizedBox(height: 5.0),
                                                    // if (status == 'Done')
                                                    //   Row(
                                                    //     children: [
                                                    //       Expanded(flex: 6, child: Text("Received by")),
                                                    //       Expanded(flex: 1, child: Text(":")),
                                                    //       Expanded(flex: 6, child: Text('${occAccepteduserData?['NAME'] ?? 'No Data'}')),
                                                    //     ],
                                                    //   ),

                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text("Feedback Form"),
                                                        ),
                                                        Expanded(child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: TextButton(
                                                            onPressed: () async {
                                                              if (feedbackId != null && feedbackId.isNotEmpty) {
                                                                Navigator.of(context).push(
                                                                  MaterialPageRoute(
                                                                    builder: (context) => FeedbackDetailPage(feedbackId: feedbackId),
                                                                  ),
                                                                );
                                                              } else {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text('No Feedback'),
                                                                    action: SnackBarAction(
                                                                      label: 'OK',
                                                                      onPressed: () {
                                                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                                      },
                                                                    ),
                                                                  ),
                                                                );

                                                                Future.delayed(Duration(seconds: 1), () {
                                                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                                });
                                                              }
                                                              print(feedbackId);
                                                            },
                                                            child: Align(
                                                              alignment: Alignment.center,
                                                              child: Text(
                                                                'Open Feedback',
                                                                style: TextStyle(
                                                                  color: TsOneColor.primary,
                                                                  fontWeight: FontWeight.bold,
                                                                  decoration: TextDecoration.underline,
                                                                  decorationColor: TsOneColor.primary,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    SizedBox(height: 15.0),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              showDialog(
                                                                context: context,
                                                                barrierDismissible: false,
                                                                builder: (context) {
                                                                  return AlertDialog(
                                                                    content: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        CircularProgressIndicator(),
                                                                        SizedBox(height: 20),
                                                                        Text('Please Wait...'),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );

                                                              generateLogPdfDevice23(
                                                                userName: userData['NAME'],
                                                                userRank: userData['RANK'],
                                                                userID: userData['ID NO'].toString(),
                                                                occAccept: occAccepteduserData?['NAME'],
                                                                occGiven: occOnDutyuserData?['NAME'],
                                                                deviceNo2: data['device_name2'],
                                                                iosVer2: deviceData2['value']['iosver'],
                                                                charger: data['charger_no'] ?? '-',
                                                                flySmart2: deviceData2['value']['flysmart'],
                                                                lido2: deviceData2['value']['lidoversion'],
                                                                docunet2: deviceData2['value']['docuversion'],
                                                                deviceCondition2: deviceData2['value']['condition'],
                                                                deviceNo3: data['device_name3'],
                                                                iosVer3: deviceData3['value']['iosver'],
                                                                flySmart3: deviceData3['value']['flysmart'],
                                                                lido3: deviceData3['value']['lidoversion'],
                                                                docunet3: deviceData3['value']['docuversion'],
                                                                deviceCondition3: deviceData3['value']['condition'],
                                                                ttdUser: data['signature_url'],
                                                                ttdOCC: data['signature_url_occ'],
                                                                ttdOtherCrew: data != null ? data['signature_url_other_crew'] : 'Not Found',
                                                                loan: data['timestamp'],
                                                                statusdevice: data['statusDevice'],
                                                                handoverName: handoverTouserData != null ? handoverTouserData['NAME'] : 'Not Found',
                                                                handoverID:
                                                                    handoverTouserData != null ? handoverTouserData['ID NO'].toString() : 'Not Found',
                                                                recNo: formatData?['RecNo'] ?? '-',
                                                                date: formatData?['Date'] ?? '-',
                                                                page: formatData?['Page'] ?? '-',
                                                                footerLeft: formatData?['FooterLeft'] ?? '-',
                                                                footerRight: formatData?['FooterRight'] ?? '-',
                                                              ).then((_) {
                                                                Navigator.pop(context);
                                                              }).catchError((error) {
                                                                print('Error generating PDF: $error');
                                                                Navigator.pop(context);
                                                              });
                                                              // generateLogPdfDevice23();
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: TsOneColor.greenColor,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(4.0),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets.all(15),
                                                              child: Text(
                                                                'Open Handover Log',
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
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
                            );
                          },
                        );
                      },
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
