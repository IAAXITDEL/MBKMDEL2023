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
import 'package:ts_one/app/modules/efb/occ/views/feedbackDetail/feedback_atachment.dart';
import 'package:ts_one/presentation/theme.dart';

//dsf
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
        future: FirebaseFirestore.instance.collection('feedback-device').doc(feedbackId).get(),
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

                              //if (devicename1 != null && devicename2 == null)
                              Row(
                                children: [
                                  Expanded(child: Text("Device No", style: tsOneTextTheme.titleSmall)),
                                  // Expanded(flex: 1, child: Text(":")),
                                  // Expanded(
                                  //   flex: 6,
                                  //   child: Text(devicename1),
                                  // ),
                                ],
                              ),

                              if (devicename1 != null)
                                Row(
                                  children: [
                                    Expanded(flex: 6, child: Text("Device 1")),
                                    Expanded(flex: 1, child: Text(":")),
                                    Expanded(
                                      flex: 6,
                                      child: Text(devicename1),
                                    ),
                                  ],
                                ),
                              //Fo
                              if (devicename2 != null)
                                Row(
                                  children: [
                                    Expanded(flex: 6, child: Text("Device 2")),
                                    Expanded(flex: 1, child: Text(":")),
                                    Expanded(
                                      flex: 6,
                                      child: Text(devicename2),
                                    ),
                                  ],
                                ),
                              if (devicename3 != null)
                                Row(
                                  children: [
                                    Expanded(flex: 6, child: Text("Device 3")),
                                    Expanded(flex: 1, child: Text(":")),
                                    Expanded(
                                      flex: 6,
                                      child: Text(devicename3),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 10),

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
                                          Text(q1, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q2, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q3, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q4, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q5, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q6, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                        child:
                                            Text("BATTERY LEVEL AFTER ENGINE SHUTDOWN (with or without charging)", style: tsOneTextTheme.titleMedium),
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
                                            child: Text(sector1, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(flex: 6, child: Text("2nd Sector", style: tsOneTextTheme.labelMedium)),
                                          Expanded(flex: 1, child: Text(":", style: tsOneTextTheme.labelMedium)),
                                          Expanded(
                                            flex: 6,
                                            child: Text(sector2, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(flex: 6, child: Text("3rd Sector", style: tsOneTextTheme.labelMedium)),
                                          Expanded(flex: 1, child: Text(":", style: tsOneTextTheme.labelMedium)),
                                          Expanded(
                                            flex: 6,
                                            child: Text(sector3, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(flex: 6, child: Text("4th sector", style: tsOneTextTheme.labelMedium)),
                                          Expanded(flex: 1, child: Text(":", style: tsOneTextTheme.labelMedium)),
                                          Expanded(
                                            flex: 6,
                                            child: Text(sector4, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(flex: 6, child: Text("5th Sector", style: tsOneTextTheme.labelMedium)),
                                          Expanded(flex: 1, child: Text(":", style: tsOneTextTheme.labelMedium)),
                                          Expanded(
                                            flex: 6,
                                            child: Text(sector5, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(flex: 6, child: Text("6th Sector", style: tsOneTextTheme.labelMedium)),
                                          Expanded(flex: 1, child: Text(":", style: tsOneTextTheme.labelMedium)),
                                          Expanded(
                                            flex: 6,
                                            child: Text(sector6, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q7, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q8, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q9, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q10, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q11, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q12, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Wrap(
                                              children: [
                                                Text("If high please write down your concern in the comment box below",
                                                    style: tsOneTextTheme.labelMedium),
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
                                                Text(ifhigh, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q13, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q14, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                          Text(q15, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
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
                                  Flexible(
                                    child: Wrap(
                                      children: [
                                        Text(additionalComment, style: tsOneTextTheme.bodySmall?.copyWith(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 30),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // Show AlertDialog with CircularProgressIndicator immediately
                                        var dialog = showDialog(
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
                                        // Delay for 7 seconds
                                        await Future.delayed(Duration(seconds: 7));

                                        try {
                                          // Call your asynchronous function (generateFeedbackForm)
                                          await generateFeedbackForm(
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
                                            recNo: formatData?['RecNo'] ?? '-',
                                            datedoc: formatData?['Date'] ?? '-',
                                            page: formatData?['Page'] ?? '-',
                                            footerLeft: formatData?['FooterLeft'] ?? '-',
                                            footerRight: formatData?['FooterRight'] ?? '-',
                                          );
                                        } catch (error) {
                                          print('Error generating PDF: $error');
                                        } finally {
                                          // Close the AlertDialog when the asynchronous function completes or encounters an error
                                          Navigator.pop(context);
                                        }
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
