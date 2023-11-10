import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:ts_one/presentation/theme.dart';

//
class FeedbackDetailPage extends StatelessWidget {
  final String feedbackId;

  FeedbackDetailPage({required this.feedbackId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Feedback Detail',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('feedback-device')
            .doc(feedbackId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Feedback data not found'));
          }

          // DATA PDF
          // generateFeedbackForm(
          //   date: feedbackData['timestamp'],
          //   q1: feedbackData['q1'],
          // );

          // Ambil data feedback dari Firestore
          final feedbackData = snapshot.data!.data() as Map<String, dynamic>;

          // Tampilkan data sesuai yang Anda butuhkan, misalnya, field 1-sector
          final q1 = feedbackData['q1'] ?? '-';
          final q2 = feedbackData['q2'] ?? '-';
          final q3 = feedbackData['q3'] ?? '-';
          final q4 = feedbackData['q4'] ?? '-';
          final q5 = feedbackData['q5'] ?? '-';
          final q6 = feedbackData['q6'] ?? '-';
          final q7 = feedbackData['q7'] ?? '-';
          final q8 = feedbackData['q8'] ?? '-';
          final q9 = feedbackData['q9'] ?? '-';
          final q10 = feedbackData['q10'] ?? '-';
          final q11 = feedbackData['q11'] ?? '-';
          final q12 = feedbackData['q12'] ?? '-';
          final q13 = feedbackData['q13'] ?? '-';
          final q14 = feedbackData['q14'] ?? '-';
          final q15 = feedbackData['q15'] ?? '-';
          final sector1 = feedbackData['1-sector'] ?? '-';
          final sector2 = feedbackData['2-sector'] ?? '-';
          final sector3 = feedbackData['3-sector'] ?? '-';
          final sector4 = feedbackData['4-sector'] ?? '-';
          final sector5 = feedbackData['5-sector'] ?? '-';
          final sector6 = feedbackData['6-sector'] ?? '-';
          final ifhigh = feedbackData['ifHigh'] ?? '-';
          final additionalComment = feedbackData['additionalComment'] ?? '-';
          final date = feedbackData['timestamp'] ?? '-';

          // Ambil feedbackId yang sesuai dari feedbackData
          final pilotDeviceId = feedbackData['handover-id'];

          // Sekarang kita akan mengambil data dari koleksi 'pilot-device-1'
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('pilot-device-1').doc(pilotDeviceId).get(),
            builder: (context, pilotDeviceSnapshot) {
              if (pilotDeviceSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (pilotDeviceSnapshot.hasError) {
                return Center(child: Text('Error: ${pilotDeviceSnapshot.error}'));
              }

              if (!pilotDeviceSnapshot.hasData || !pilotDeviceSnapshot.data!.exists) {
                return Center(child: Text('Pilot device data not found'));
              }

              // Ambil data dari koleksi 'pilot-device-1'
              final pilotDeviceData = pilotDeviceSnapshot.data!.data() as Map<String, dynamic>;

              final devicename1 = pilotDeviceData['device_name'] ?? '-';
              final devicename2 = pilotDeviceData['device_name2'] ?? '-';
              final devicename3 = pilotDeviceData['device_name3'] ?? '-';

              final userid = pilotDeviceData['user_uid'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(userid).get(),
                builder: (context, userDeviceSnapshot) {
                  if (userDeviceSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (userDeviceSnapshot.hasError) {
                    return Center(child: Text('Error: ${userDeviceSnapshot.error}'));
                  }

                  if (!userDeviceSnapshot.hasData || !userDeviceSnapshot.data!.exists) {
                    return Center(child: Text('User not found'));
                  }

                  // Ambil data dari koleksi 'pilot-device-1'
                  // final userData = userDeviceSnapshot.data!.data() as Map<String, dynamic>;

                  // final userRank = userData['RANK'] ?? '-';
                  // final userName = userData['NAME'] ?? '-';

                  final userData = userDeviceSnapshot.data?.data() as Map<String, dynamic> ?? {};
                  final userRank = userData['RANK'] as String? ?? '-';
                  final userName = userData['NAME'] as String? ?? '-';

                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(_formatTimestamp(date), style: tsOneTextTheme.labelSmall),
                          ),
                          SizedBox(height: 15.0),
                          if ('$userRank' == 'CAPT')
                          Row(
                            children: [
                              Expanded(flex: 6, child: Text("Device No")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(
                                flex: 6,
                                child: Text(devicename1),
                              ),
                            ],
                          ),

                          if ('$userRank' == 'FO')
                            Row(
                              children: [
                                Expanded(flex: 6, child: Text("1st Device")),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                  flex: 6,
                                  child: Text(devicename2),
                                ),
                              ],
                            ),
                          if ('$userRank' == 'FO')
                            Row(
                              children: [
                                Expanded(flex: 6, child: Text("2nd Device")),
                                Expanded(flex: 1, child: Text(":")),
                                Expanded(
                                  flex: 6,
                                  child: Text(devicename3),
                                ),
                              ],
                            ),
                          Row(
                            children: [
                              Expanded(flex: 6, child: Text("Crew Name")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(
                                flex: 6,
                                child: Text(userName),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(flex: 6, child: Text("RANK")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(
                                flex: 6,
                                child: Text(userRank),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
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
                                    'Feedback Details',
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

                          //Part 1
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey), // Atur warna dan tipe garis sesuai kebutuhan Anda
                              borderRadius: BorderRadius.all(Radius.circular(10)), // Atur sudut border sesuai kebutuhan Anda
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Agar teks tetap di kiri
                                children: [
                                  Center(
                                    child: Text("BATTERY INTEGRITY", style: tsOneTextTheme.titleMedium),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Do you Charge the device during your duty?", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q1,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Do you find any risk or concern on the cabling?", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q2,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),


                                  //Part 2
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("If charging the device is REQUIRED.", style: tsOneTextTheme.titleSmall),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Flight Phase", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q3,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Charging duration", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q4,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),


                                  //Part 3
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("If charging the device is NOT REQUIRED.", style: tsOneTextTheme.titleSmall),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Did you utilize ALL EFB software during your duty?", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q5,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Which software did you utilize the most?", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q6,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),

                          //Part 4
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey), // Atur warna dan tipe garis sesuai kebutuhan Anda
                              borderRadius: BorderRadius.all(Radius.circular(10)), // Atur sudut border sesuai kebutuhan Anda
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Agar teks tetap di kiri
                                children: [
                                  Center(
                                    child: Text("BATTERY LEVEL AFTER ENGINE SHUTDOWN (with or without charging)", style: tsOneTextTheme.titleMedium),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                  ), // D
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("1st Sector", style: tsOneTextTheme.labelMedium)),
                                      Expanded(flex: 1, child: Text(":", style: tsOneTextTheme.labelMedium)),
                                      Expanded(
                                        flex: 6,
                                        child: Text(sector1,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("2nd Sector", style: tsOneTextTheme.labelMedium)),
                                      Expanded(flex: 1, child: Text(":", style: tsOneTextTheme.labelMedium)),
                                      Expanded(
                                        flex: 6,
                                        child: Text(sector2,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("3rd Sector", style: tsOneTextTheme.labelMedium)),
                                      Expanded(flex: 1, child: Text(":", style: tsOneTextTheme.labelMedium)),
                                      Expanded(
                                        flex: 6,
                                        child: Text(sector3,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("4th sector", style: tsOneTextTheme.labelMedium)),
                                      Expanded(flex: 1, child: Text(":", style: tsOneTextTheme.labelMedium)),
                                      Expanded(
                                        flex: 6,
                                        child: Text(sector4,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("5th Sector", style: tsOneTextTheme.labelMedium)),
                                      Expanded(flex: 1, child: Text(":", style: tsOneTextTheme.labelMedium)),
                                      Expanded(
                                        flex: 6,
                                        child: Text(sector5,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(flex: 6, child: Text("6th Sector", style: tsOneTextTheme.labelMedium)),
                                      Expanded(flex: 1, child: Text(":", style: tsOneTextTheme.labelMedium)),
                                      Expanded(
                                        flex: 6,
                                        child: Text(sector6,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),



                          //Part 5
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey), // Atur warna dan tipe garis sesuai kebutuhan Anda
                              borderRadius: BorderRadius.all(Radius.circular(10)), // Atur sudut border sesuai kebutuhan Anda
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Agar teks tetap di kiri
                                children: [
                                  Center(
                                    child: Text("BRACKET (RAM-MOUNT) INTEGRITY", style: tsOneTextTheme.titleMedium),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Strong Mechanical Integrity During Flight", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q7,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Strong Mechanical Integrity During Flight", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q8,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Easy to detached during emergency, if required", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q9,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Obstruct emergency egress", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q10,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),

                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Bracket position obstruct your vision", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q11,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("If Yes, How severe did it obstruct your vision?", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q12,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("If high please write down your concern in the comment box below", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text(ifhigh,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),


                          //Part 6
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey), // Atur warna dan tipe garis sesuai kebutuhan Anda
                              borderRadius: BorderRadius.all(Radius.circular(10)), // Atur sudut border sesuai kebutuhan Anda
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Agar teks tetap di kiri
                                children: [
                                  Center(
                                    child: Text("EFB SOFTWARE INTEGRITY", style: tsOneTextTheme.titleMedium),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Airbus Flysmart (Performance)", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q13,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Lido (Navigation)", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q14,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),

                                  Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: [
                                            Text("Vistair Docunet (Library Document)", style: tsOneTextTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(q15,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),


                          Row(
                            children: [
                              Flexible(
                                child: Wrap(
                                  children: [
                                    Text("Additional comment on all observation", style: tsOneTextTheme.labelMedium),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(additionalComment,style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                            ],
                          ),

                          SizedBox(height: 30),
                          Row(
                            children: [
                              ElevatedButton(
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
                                  generateFeedbackForm(
                                    //handoverID: handoverTouserData != null ? handoverTouserData['ID NO'].toString() : 'Not Found',
                                    date: feedbackData['timestamp'] ?? '-',
                                    q1: feedbackData['q1'] ?? '-',
                                    q2: feedbackData['q2'] ?? '-',
                                    q3: feedbackData['q3'] ?? '-',
                                    q4: feedbackData['q4'] ?? '-',
                                    q5: feedbackData['q5'] ?? '-',
                                    q6: feedbackData['q6'] ?? '-',
                                    q7: feedbackData['q7'] ?? '-',
                                    q8: feedbackData['q8'] ?? '-',
                                    q9: feedbackData['q9'] ?? '-',
                                    q10: feedbackData['q10'] ?? '-',
                                    q11: feedbackData['q11'] ?? '-',
                                    q12: feedbackData['q12'] ?? '-',
                                    q13: feedbackData['q13'] ?? '-',
                                    q14: feedbackData['q14'] ?? '-',
                                    q15: feedbackData['q15'] ?? '-',
                                    sector1: feedbackData['1-sector'] ?? '-',
                                    sector2: feedbackData['2-sector'] ?? '-',
                                    sector3: feedbackData['3-sector'] ?? '-',
                                    sector4: feedbackData['4-sector'] ?? '-',
                                    sector5: feedbackData['5-sector'] ?? '-',
                                    sector6: feedbackData['6-sector'] ?? '-',
                                    ifhigh: feedbackData['ifHigh'] ?? '-',
                                    additionalComment: feedbackData['additionalComment'] ?? '-',
                                    devicename1: pilotDeviceData['device_name'] ?? '-',
                                    devicename2: pilotDeviceData['device_name2'] ?? '-',
                                    devicename3: pilotDeviceData['device_name3'] ?? '-',
                                    userName: userData['NAME'] as String? ?? '-',
                                    userRank: userData['RANK'] as String? ?? '-',
                                  ).then((_) {
                                    Navigator.pop(context);
                                  }).catchError((error) {
                                    print('Error generating PDF: $error');
                                    Navigator.pop(context);
                                  });
                                  // generateLogPdfDevice23();
                                  print("Test" + q1);
                                  print(sector1);
                                  print(userName);
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
                                    'Open Attachment Feedback',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

String _formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) return 'No Data';

  DateTime dateTime = timestamp.toDate();
  // Format the date and time as desired, e.g., 'dd/MM/yyyy HH:mm:ss'
  String formattedDateTime = '${dateTime.day}/${dateTime.month}/${dateTime.year}'
      ' at '
      '${dateTime.hour}:${dateTime.minute}';
  return formattedDateTime;
}

Future<List<Map<String, dynamic>>> getAllFeedbackData() async {
  // Ambil semua dokumen dari koleksi 'pilot-feedback'
  QuerySnapshot feedbackQuerySnapshot = await FirebaseFirestore.instance.collection('pilot-feedback').get();

  List<Map<String, dynamic>> feedbackDataList = [];

  for (QueryDocumentSnapshot doc in feedbackQuerySnapshot.docs) {
    String feedbackId = doc['feedback_id'];
    // Gunakan feedbackId untuk mencari data dari koleksi 'feedback-device'
    QuerySnapshot feedbackDeviceQuerySnapshot =
        await FirebaseFirestore.instance.collection('feedback-device').where('feedback_id', isEqualTo: feedbackId).get();

    if (feedbackDeviceQuerySnapshot.docs.isNotEmpty) {
      // Jika data cocok, tambahkan data ke dalam list feedbackDataList
      DocumentSnapshot feedbackDocument = feedbackDeviceQuerySnapshot.docs.first;
      Map<String, dynamic> feedbackData = feedbackDocument.data() as Map<String, dynamic>;
      feedbackDataList.add(feedbackData);
    }
  }

  return feedbackDataList;
}

// PDF FEEDBACK
Future<void> generateFeedbackForm({
  Timestamp? date,
  String? q1,
  String? q2,
  String? q3,
  String? q4,
  String? q5,
  String? q6,
  String? q7,
  String? q8,
  String? q9,
  String? q10,
  String? q11,
  String? q12,
  String? q13,
  String? q14,
  String? q15,
  // String? q16,
  String? sector1,
  String? sector2,
  String? sector3,
  String? sector4,
  String? sector5,
  String? sector6,
  String? ifhigh,
  String? additionalComment,
  String? devicename1,
  String? devicename2,
  String? devicename3,
  String? userName,
  String? userRank,
}) async {
  final pdf = pw.Document();

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/feedback_form.pdf");

  final ByteData logo = await rootBundle.load('assets/images/airasia_logo_circle.png');
  final Uint8List uint8list = logo.buffer.asUint8List();

  final font = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  final ttf = pw.Font.ttf(font);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.letter.copyWith(
        marginLeft: 72.0,
        marginRight: 72.0,
        marginTop: 36.0,
        marginBottom: 72.0,
      ),
      build: (context) {
        return pw.Column(children: [
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Image(
                          pw.MemoryImage(uint8list),
                          width: 65,
                          height: 65,
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Padding(
                      padding: pw.EdgeInsets.symmetric(vertical: 5),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'IAA EFB',
                            style: pw.TextStyle(
                              // font: ttf,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'FEEDBACK FORM',
                            style: pw.TextStyle(
                              // font: ttf,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          if ('$userRank' == 'CAPT')
                            pw.Text(
                              '$devicename1',
                              style: pw.TextStyle(
                                // font: ttf,
                                fontSize: 12,
                              ),
                            ),
                          if ('$userRank' == 'FO')
                            pw.Text(
                              '$devicename2 & $devicename3',
                              style: pw.TextStyle(
                                // font: ttf,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'DCC No.',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                              pw.Text(
                                'IAA/FOP/F/009',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Revision',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                              pw.Text(
                                '3',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Date',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                              pw.Text(
                                '06-12-21',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Page',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                              pw.Text(
                                '1 of 1',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              'Dear Pilots, The following test must be conducted on the IPAD PRO 10.5',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 11,
              ),
            ),
          ),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: reguler("DATE", context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: reguler(_formatTimestamp(date), context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: reguler("RANK", context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: reguler("$userRank", context),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: reguler("Device No.", context),
                  ),
                  if ('$userRank' == 'CAPT')
                    pw.Container(
                      height: 20.0,
                      child: reguler("$devicename1", context),
                    ),
                  if ('$userRank' == 'FO')
                    pw.Container(
                      height: 20.0,
                      child: reguler("$devicename2 & $devicename3", context),
                    ),
                  pw.Container(
                    height: 20.0,
                    child: reguler("CREW NAME", context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: reguler("$userName", context),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 25.0,
                    child: boldTitle('BATTERY INTEGRITY', context),
                  )
                ],
              ),
            ],
          ),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Column(children: [
                    reguler("Do you charge the device during your duty?\n" + "$q1", context),
                    bold("If charging the device is REQUIRED.", context),
                    pw.Column(children: [
                      reguler("1.  Flight Phase\n" + "     $q3", context),
                      reguler("2.  Charging duration\n" + "     $q4", context),
                    ])
                  ]),
                  pw.Column(children: [
                    reguler("Do you find any risk or concern on the cabling?\n" + "$q2", context),
                    bold("If charging the device is NOT REQUIRED.", context),
                    pw.Column(children: [
                      reguler("1.  Did you utilize ALL EFB software during your duty?\n" + "     $q5", context),
                      reguler("2.  Which software did you utilize the most?\n" + "     $q6", context),
                    ])
                  ]),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 25.0,
                    child: boldTitle('BATTERY LEVEL AFTER ENGINE SHUTDOWN (with or without charging)', context),
                  )
                ],
              ),
            ],
          ),
          pw.Table(tableWidth: pw.TableWidth.min, border: pw.TableBorder.all(), columnWidths: {
            0: pw.FlexColumnWidth(1),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
            4: pw.FlexColumnWidth(2),
            5: pw.FlexColumnWidth(2),
            6: pw.FlexColumnWidth(2),
          }, children: [
            pw.TableRow(
              children: [
                reguler("%", context),
                reguler("1st  " + "  $sector1", context),
                reguler("2nd  " + "  $sector2", context),
                reguler("3rd  " + "  $sector3", context),
                reguler("4th  " + "  $sector4", context),
                reguler("5th  " + "  $sector5", context),
                reguler("6th  " + "  $sector6", context),
              ],
            ),
          ]),
          pw.SizedBox(height: 10),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 25.0,
                    child: boldTitle('BRACKET (RAM-MOUNT) INTEGRITY', context),
                  )
                ],
              ),
            ],
          ),
          pw.Table(tableWidth: pw.TableWidth.min, border: pw.TableBorder.all(), columnWidths: {
            0: pw.FlexColumnWidth(1),
          }, children: [
            pw.TableRow(
              children: [
                pw.Column(children: [
                  reguler(
                    'Please observe the bracket and tick on your answer :\n' +
                        '\n' +
                        '  1.  Strong Mechanical Integrity Flight\n' +
                        "       $q7\n" +
                        '  2.  Easy to use\n' +
                        "       $q8\n" +
                        '  3.  Easy to detached during emergency, if required\n' +
                        "       $q8\n" +
                        '  4.  Obstruct emergency egress\n' +
                        "       $q10\n" +
                        '  5.  Bracket position obstruct Pilot vision\n' +
                        "       $q11 (If Yes, How severe did it obstruct your vision)?\n" +
                        "       $q12\n",
                    context,
                  ),
                ])
              ],
            ),
          ]),
          pw.SizedBox(height: 10),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 25.0,
                    child: boldTitle('EFB SOFTWARE INTEGRITY', context),
                  )
                ],
              ),
            ],
          ),
          pw.Table(tableWidth: pw.TableWidth.min, border: pw.TableBorder.all(), columnWidths: {
            0: pw.FlexColumnWidth(1),
          }, children: [
            pw.TableRow(
              children: [
                pw.Column(children: [
                  reguler(
                    '  1.  Airbus Flysmart (Performance)' +
                        "             $q13\n" +
                        '  2.  Lido (Navigation)' +
                        "                                $q14\n" +
                        '  3.  Vistair Docunet (Library Document)' +
                        "      $q15\n",
                    context,
                  ),
                ])
              ],
            ),
          ]),
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              'Additional comment on all observation : $additionalComment',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 8,
              ),
            ),
          )
        ]);
      },
    ),
  );
  final pdfBytes = await pdf.save();
  await file.writeAsBytes(pdfBytes);

  OpenFile.open(file.path);
}
//child: _buildHeaderCellLeft('Handover To', context),

pw.Widget bold(String text, pw.Context context) {
  // final fontData = rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  // final ttf = pw.Font.ttf(fontData as ByteData);

  return pw.Container(
    alignment: pw.Alignment.centerLeft,
    decoration: pw.BoxDecoration(
      border: pw.TableBorder.all(),
    ),
    padding: pw.EdgeInsets.all(5.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        // font: ttf,
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
      ),
    ),
  );
}

pw.Widget boldTitle(String text, pw.Context context) {
  // final fontData = rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  // final ttf = pw.Font.ttf(fontData as ByteData);

  return pw.Container(
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      border: pw.TableBorder.all(),
    ),
    padding: pw.EdgeInsets.all(5.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        // font: ttf,
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
    ),
  );
}

pw.Widget reguler(String text, pw.Context context) {
  // final fontData = rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  // final ttf = pw.Font.ttf(fontData as ByteData);

  return pw.Container(
    alignment: pw.Alignment.centerLeft,
    decoration: pw.BoxDecoration(
      border: pw.TableBorder.all(),
    ),
    padding: pw.EdgeInsets.all(5.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        //font: ttf,
        fontSize: 9,
      ),
    ),
  );
}
