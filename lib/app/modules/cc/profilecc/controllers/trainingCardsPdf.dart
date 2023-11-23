import 'dart:core';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../../data/users/users.dart';
import '../../../../../presentation/view_model/attendance_model.dart';


FirebaseFirestore firestore = FirebaseFirestore.instance;
Future<List<Map<String, dynamic>>?> getHistoryData(int idTrainee, String subject, int longlist) async {
  try {
    QuerySnapshot attendanceQuery = await firestore
        .collection('attendance')
        .where("expiry", isEqualTo: "VALID")
        .where("status", isEqualTo: "done")
        .where("subject", isEqualTo: subject)
        .where("is_delete", isEqualTo: 0)
        .get();

    if (attendanceQuery.docs.isNotEmpty) {
      print(subject);
      final attendanceDetailQuery = await firestore.collection(
          'attendance-detail').where(
          "idtraining", isEqualTo: idTrainee).where(
          "status", isEqualTo: "donescoring").get();
      final attendanceDetailData = attendanceDetailQuery.docs.map((doc) =>
      doc.data() as Map<String, dynamic>).toList();
      if (attendanceDetailData.isEmpty) {
        return null; // Mengembalikan null jika data kosong
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(
              doc.data() as Map<String, dynamic>);
          final matchingDetail = attendanceDetailData.where((
              attendanceDetail) =>
          attendanceDetail['idattendance'] == attendanceModel.id);

          if (matchingDetail.isNotEmpty) {
            return attendanceModel.toJson();
          }

          return null;
        }),
      );

      List<Map<String, dynamic>> relevantData = [];
      for (var attendanceModel in attendanceData) {
        // final date = attendanceModel?['date'];
        // Timestamp? timestamp = attendanceModel?['date'];
        // DateTime? dateTime = timestamp?.toDate();
        final validTo = attendanceModel?['valid_to'];
        final dates = attendanceModel?['date'];
        if (dates != null) {
          print(dates);
          print(validTo);
          relevantData.add({
            'date': dates,
            'valid_to': validTo,
          });
        }
      }

      // Mengurutkan berdasarkan tanggal valid_to yang terkecil
      relevantData.sort((a, b) =>
          a['valid_to'].toDate().compareTo(b['valid_to'].toDate()));

      // Tentukan panjang target list
      int targetLength = longlist;

      // Mengambil panjang sesuai yang lebih kecil
      int finalLength = min(targetLength, relevantData.length);

      final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

      // Membuat list dengan panjang sesuai target
      List<Map<String, dynamic>> finalData = List.generate(targetLength, (index) {
        if (index < finalLength) {
          final DateTime validTo = relevantData[index]['valid_to'].toDate();
          String formattedValidTo = dateFormat.format(validTo);

          final DateTime dates = relevantData[index]['date'].toDate();
          String formatteddates = dateFormat.format(dates);

          Timestamp? timestamp = relevantData[index]['date'];
          DateTime? dateTime = timestamp?.toDate();
          return {
            'date': formatteddates,
            'valid_to': formattedValidTo,
          };
        } else {
          return {'date': null, 'valid_to': null};
        }
      });

      return finalData; // Mengembalikan finalData
    }
  } catch (error) {
    print('Error fetching attendance data: $error');
    return null; // Mengembalikan null jika terjadi kesalahan
  }
}

Future<List<UserModel>?> getProfileData(int id) async {
  try {
    QuerySnapshot usersQuery = await firestore
        .collection('users')
        .where("ID NO", isEqualTo: id)
        .get();

    List<UserModel> usersData = [];

    if (usersQuery.docs.isNotEmpty) {
      usersData = usersQuery.docs.map((doc) {
        return UserModel.fromFirebaseUser(doc.data() as Map<String, dynamic>);
      }).toList();
    }

    return usersData;
  } catch (error) {
    print('Error getting profile data: $error');
    return null;
  }
}

Future<String> eksportPDF(int idCrew) async {
  try {

    final List<Map<String, dynamic>>? historyDataBasicIndoc = await getHistoryData(idCrew, "BASIC INDOC", 1);
    final List<Map<String, dynamic>>? historyDataLSWB = await getHistoryData(idCrew, "LOAD SHEET / WEIGHT & BALANCE", 1);
    final List<Map<String, dynamic>>? historyDataRVSM = await getHistoryData(idCrew, "RVSM", 1);
    final List<Map<String, dynamic>>? historyDataWNDSHEAR = await getHistoryData(idCrew, "WNDSHEAR", 8);
    final List<Map<String, dynamic>>? historyDataAlarCfit = await getHistoryData(idCrew, "ALAR/CFIT", 4);
    final List<Map<String, dynamic>>? historyDataSEP = await getHistoryData(idCrew, "SEP", 4);
    final List<Map<String, dynamic>>? historyDataSEPDRILL = await getHistoryData(idCrew, "SEP DRILL", 2);
    final List<Map<String, dynamic>>? historyDataDGR = await getHistoryData(idCrew, "DGR & AVSEC", 2);
    final List<Map<String, dynamic>>? historyDataSMS = await getHistoryData(idCrew, "SMS", 4);
    final List<Map<String, dynamic>>? historyDataCRM = await getHistoryData(idCrew, "CRM", 4);
    final List<Map<String, dynamic>>? historyDataPBN = await getHistoryData(idCrew, "PBN", 2);
    final List<Map<String, dynamic>>? historyDataRGT = await getHistoryData(idCrew, "RGT", 8);
    final List<Map<String, dynamic>>? historyDataRHS = await getHistoryData(idCrew, "RHS CHECK (SIM)", 8);
    final List<Map<String, dynamic>>? historyDataUPRT = await getHistoryData(idCrew, "UPRT", 2);
    final List<Map<String, dynamic>>? historyDataRNP = await getHistoryData(idCrew, "RNP (GNSS)", 4);
    final List<Map<String, dynamic>>? historyDataLINECHECK = await getHistoryData(idCrew, "LINE CHECK", 4);
    final List<Map<String, dynamic>>? historyDataLVO = await getHistoryData(idCrew, "LVO", 2);
    final List<Map<String, dynamic>>? historyDataETOPSSIM = await getHistoryData(idCrew, "ETOPS SIM", 2);
    final List<Map<String, dynamic>>? historyDataETOPSFLT = await getHistoryData(idCrew, "ETOPS FLT", 2);


    List<UserModel>? usersData = await getProfileData(idCrew);

    String userName = "";
    String userLicense = "";
    int userEmp = 0;
    if (usersData != null) {
      // You can now work with the usersData list
      for (UserModel user in usersData) {
        userName = user.name.toUpperCase();
        userLicense = user.licenseNo;
        userEmp = user.idNo;
      }
    } else {
      print('No user data found or there was an error.');
    }

    final outputDirectory = await getTemporaryDirectory();
    // Load the existing PDF document.
    final ByteData data = await rootBundle.load('assets/documents/TrainingCards.pdf');
    final List<int> bytes = data.buffer.asUint8List();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    // Get the existing PDF page.
    final PdfPage page = document.pages[0];

    page.graphics.drawString(
      userName ?? '',
      PdfStandardFont(PdfFontFamily.helvetica, 6),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(412, 163, 300, 10.3),
    );


    page.graphics.drawString(
      userLicense ?? '',
      PdfStandardFont(PdfFontFamily.helvetica, 6),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(412, 173, 300, 10.3),
    );

    page.graphics.drawString(
      userEmp.toString() ?? '',
      PdfStandardFont(PdfFontFamily.helvetica, 6),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(412, 183, 300, 10.3),
    );





// Set the initial position for the table
    double x = 50;
    double y = 73;
    double cellWidth = 50;
    double cellHeight = 10.3;


    // --------------------RNP----------------
    for (var item in historyDataRNP!) {
      x = 105; // Reset x to the beginning of the row

      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------LINE CHECK----------------
    for (var item in historyDataLINECHECK!) {
      x = 105;

      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

   // --------------------LVO----------------
    for (var item in historyDataLVO!) {
      x = 105;

      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------ETOPS SIM----------------
    for (var item in historyDataETOPSSIM!) {
      x = 105;

      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------ETOPS FLT----------------
    for (var item in historyDataETOPSFLT!) {
      x = 105;

      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica,7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }


    // --------------------Basic Indoc----------------
    for (var item in historyDataBasicIndoc!) {
      x = 105;
      y = 298;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        '-',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------LSWB----------------
    for (var item in historyDataLSWB!) {
      x = 105;
      y = 325;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        '-',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------RVSM----------------
    for (var item in historyDataRVSM!) {
      x = 105;
      y = 346;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        '-',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------WNDSHEAR----------------
    for (var item in historyDataWNDSHEAR!) {
      x = 105;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------AlarCfit----------------
    for (var item in historyDataAlarCfit!) {
      x = 105;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------SEP----------------
    for (var item in historyDataSEP!) {
      x = 268;
      y = 295;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------SEP DRILL----------------
    for (var item in historyDataSEPDRILL!) {
      x = 268;
      y = 336;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------DGR----------------
    for (var item in historyDataDGR!) {
      x = 268;
      y = 356;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------SMS----------------
    for (var item in historyDataSMS!) {
      x = 268;
      y = 377;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------CRM----------------
    for (var item in historyDataCRM!) {
      x = 268;
      y = 418;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------PBN----------------
    for (var item in historyDataPBN!) {
      x = 268;
      y = 460;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------RGT----------------
    for (var item in historyDataRGT!) {
      x = 430;
      y = 295;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------RHS----------------
    for (var item in historyDataRHS!) {
      x = 430;
      y = 377;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }

    // --------------------UPRT----------------
    for (var item in historyDataUPRT!) {
      x = 430;
      y = 460;
      page.graphics.drawString(
        item['date'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      x += cellWidth; // Move to the next column

      page.graphics.drawString(
        item['valid_to'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 7),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y, cellWidth, cellHeight),
      );

      // Move to the next row
      y += cellHeight;
    }


    // Save the document.
    final List<int> outputBytes = await document.save();
    final File file = File('${outputDirectory.path}/TrainingCards${userName}.pdf');
    await file.writeAsBytes(outputBytes);

    // Dispose the document.
    document.dispose();

    return file.path;
  } catch (e) {
    print("Error generating PDF: $e");
    return Future.value();
  }
}

Future<void> openExportedPDF(String path) async {
  try {
    await OpenFile.open(path);
  } catch (e) {
    print("Error opening PDF: $e");
    // Handle the error as needed
  }
}
