import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/modules/efb/occ/views/feedbackDetail/feedbackDetailPage.dart';
import 'package:ts_one/app/modules/efb/occ/views/history/history_all_device_view.dart';

import '../../../../../../presentation/theme.dart';
import '../../../occ/views/history/handover_attachment1.dart';

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

  String getMonthText(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'Desember'
    ];
    return months[month - 1]; // Index 0-11 for Januari-Desember
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No Data';

    DateTime dateTime = timestamp.toDate();
    String formattedDateTime = '${dateTime.day} ${getMonthText(dateTime.month)} ${dateTime.year}'
        ' ; '
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
            final deviceUid = data['device_uid'];
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
                      future: FirebaseFirestore.instance.collection("Device").doc(deviceUid).get(),
                      builder: (context, deviceSnapshot) {
                        if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (deviceSnapshot.hasError) {
                          return Center(child: Text('Error: ${deviceSnapshot.error}'));
                        }

                        if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                          return Center(child: Text('Device data not found'));
                        }

                        final deviceData = deviceSnapshot.data!.data() as Map<String, dynamic>;

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
                              future:
                                  occAccepted != null ? FirebaseFirestore.instance.collection("users").doc(occAccepted).get() : Future.value(null),
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

                                    return SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  //show date
                                                  Align(
                                                    alignment: Alignment.centerRight,
                                                    child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
                                                  ),
                                                  SizedBox(height: 15.0),

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
                                                    ],
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

                                                  //device info
                                                  Text("Device 1", style: tsOneTextTheme.headlineMedium),
                                                  SizedBox(height: 7.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Device No")),
                                                      Expanded(flex: 1, child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${data['device_name'] ?? 'No Data'}'),
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
                                                        child: Text('${deviceData['value']['iosver'] ?? 'No Data'}'),
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
                                                        child: Text('${deviceData['value']['flysmart'] ?? 'No Data'}'),
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
                                                        child: Text('${deviceData['value']['docuversion'] ?? 'No Data'}'),
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
                                                        child: Text('${deviceData['value']['lidoversion'] ?? 'No Data'}'),
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
                                                        child: Text('${deviceData['value']['hub'] ?? 'No Data'}'),
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
                                                  //       child: Text('${deviceData['value']['condition'] ?? 'No Data'}'),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                  SizedBox(
                                                    height: 15.0,
                                                  ),
                                                  //device info
                                                  Text("Device Condition", style: tsOneTextTheme.headlineMedium),
                                                  SizedBox(height: 7.0),
                                                  Row(
                                                    children: [
                                                      Expanded(flex: 6, child: Text("Given")),
                                                      Expanded(flex: 1, child: Text(":")),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Text('${data['initial-condition-category'] ?? 'No Data'}'),
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
                                                        child: Text('${data['initial-condition-remarks'] ?? 'No Data'}'),
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
                                                        child: Text('${data['return-condition-category'] ?? 'No Data'}'),
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
                                                        child: Text('${data['return-condition-remarks'] ?? 'No Data'}'),
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
                                                  SizedBox(height: 5.0),
                                                  if (status == 'Done')
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Received by")),
                                                        Expanded(flex: 1, child: Text(":")),
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text('${occAccepteduserData?['NAME'] ?? 'No Data'}'),
                                                        ),
                                                      ],
                                                    ),
                                                  SizedBox(height: 10.0),
                                                  Text("Return Documentation", style: tsOneTextTheme.headlineMedium),

                                                  SizedBox(height: 10.0),
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

                                                  if (status == 'handover-to-other-crew') SizedBox(height: 7.0),
                                                  if (status == 'handover-to-other-crew')
                                                    Row(
                                                      children: [
                                                        Expanded(flex: 6, child: Text("Remarks")),
                                                        Expanded(child: Text(":")),
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
                                                        Expanded(child: Text(":")),
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

                                                  if (status == 'handover-to-other-crew') SizedBox(height: 15.0),

                                                  if (status == 'handover-to-other-crew') Text("Handover To", style: tsOneTextTheme.headlineMedium),
                                                  if (status == 'handover-to-other-crew') SizedBox(height: 7.0),
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
                                                  if (status == 'handover-to-other-crew') SizedBox(height: 5.0),
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
                                                  if (status == 'handover-to-other-crew') SizedBox(height: 5.0),
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
                                                              // Menggunakan Navigator untuk berpindah ke halaman FeedbackDetailPage
                                                              Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                  builder: (context) => FeedbackDetailPage(feedbackId: feedbackId),
                                                                ),
                                                              );
                                                            } else {
                                                              // Tindakan alternatif jika feedbackId tidak ada atau kosong
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
                                                  // Row(
                                                  //   children: [
                                                  //     Expanded(
                                                  //       child: ElevatedButton(
                                                  //         onPressed: () async {
                                                  //           if (feedbackId != null && feedbackId.isNotEmpty) {
                                                  //             // Menggunakan Navigator untuk berpindah ke halaman FeedbackDetailPage
                                                  //             // Navigator.of(context).push(
                                                  //             //   MaterialPageRoute(
                                                  //             //     builder: (context) => FeedbackDetailPage(feedbackId: feedbackId),
                                                  //             //   ),
                                                  //             // );
                                                  //             //navigateToFeedbackDetailPage(context, feedbackId);
                                                  //             //final pdf = await generateFeedbackForm();
                                                  //           } else if (feedbackId == null || feedbackId == '-') {
                                                  //             // Tindakan alternatif jika feedbackId tidak ada atau kosong
                                                  //             Builder(
                                                  //               builder: (context) {
                                                  //                 // Menampilkan Snackbar "Data Not Found" selama 1 detik
                                                  //                 Future.delayed(Duration(seconds: 1), () {
                                                  //                   ScaffoldMessenger.of(context).showSnackBar(
                                                  //                     SnackBar(
                                                  //                       content: Text('Not Found'),
                                                  //                       action: SnackBarAction(
                                                  //                         label: 'OK',
                                                  //                         onPressed: () {
                                                  //                           ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                  //                         },
                                                  //                       ),
                                                  //                     ),
                                                  //                   );
                                                  //                 });

                                                  //                 return Container();
                                                  //               },
                                                  //             );
                                                  //           }
                                                  //           print(feedbackId);
                                                  //         },
                                                  //         child: Padding(
                                                  //           padding: EdgeInsets.all(15),
                                                  //           child: Text(
                                                  //             'Open Feedback',
                                                  //             style: TextStyle(color: Colors.white),p
                                                  //           ),
                                                  //         ), 3
                                                  //       ),
                                                  //     ),
                                                  //   ],
                                                  // ),

                                                  SizedBox(height: 30.0),
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

                                                              generateLogPdfDevice1(
                                                                userName: userData['NAME'],
                                                                userRank: userData['RANK'],
                                                                userID: userData['ID NO'].toString(),
                                                                occAccept: occAccepteduserData?['NAME'],
                                                                occGiven: occOnDutyuserData?['NAME'],
                                                                deviceNo: data['device_name'],
                                                                iosVer: deviceData['value']['iosver'],
                                                                flySmart: deviceData['value']['flysmart'],
                                                                lido: deviceData['value']['lidoversion'],
                                                                docunet: deviceData['value']['docuversion'],
                                                                deviceCondition: deviceData['value']['condition'],
                                                                ttdUser: data['signature_url'],
                                                                ttdOCC: data['signature_url_occ'],
                                                                loan: data['timestamp'],
                                                                statusdevice: data['statusDevice'],
                                                                ttdOtherCrew: data != null ? data['signature_url_other_crew'] : 'Not Found',
                                                                handoverName: handoverTouserData != null ? handoverTouserData['NAME'] : 'Not Found',
                                                                handoverID: data['handover-to-crew'],
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
                                                              //generateLogPdfDevice1();
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
                                                            )),
                                                      ),
                                                    ],
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
