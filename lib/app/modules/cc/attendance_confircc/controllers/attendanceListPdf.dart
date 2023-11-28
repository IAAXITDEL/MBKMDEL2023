import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' show get;
import '../../../../../data/users/users.dart';
import '../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../presentation/view_model/attendance_model.dart';


FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>?> getCombinedAttendance(String idAttendance) async {
  try {
    final attendanceQuery = await firestore
        .collection('attendance')
        .where("id", isEqualTo: idAttendance)
        .get();

    List<int?> instructorIds =
    attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data()).instructor).toList();

    final usersData = <Map<String, dynamic>>[];

    if (instructorIds.isNotEmpty) {
      final usersQuery = await firestore.collection('users').where("ID NO", whereIn: instructorIds).get();
      usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
    }

    final attendanceData = await Future.wait(
      attendanceQuery.docs.map((doc) async {
        final attendanceModel = AttendanceModel.fromJson(doc.data());
        final user = usersData.firstWhere(
              (user) => user['ID NO'] == attendanceModel.instructor,
          orElse: () => {},
        );
        attendanceModel.name = user['NAME'];
        attendanceModel.loano = user['LOA NO'];
        return attendanceModel.toJson();
      }),
    );

    return attendanceData.isNotEmpty ? [attendanceData[0]] : null;
  } catch (e) {
    print("Error in getCombinedAttendanceStream: $e");
    return null;
  }
}


Future<List<Map<String, dynamic>?>> getCombinedAttendanceDetailStream(String idAttendance) async {
  try {
    QuerySnapshot attendanceQuery = await firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: idAttendance)
        .where("status", whereIn: ["donescoring"])
        .get();

    List<int?> traineIds = attendanceQuery.docs.map((doc) {
      final data = doc.data();
      final attendanceModel = AttendanceDetailModel.fromJson(data as Map<String, dynamic>);
      return attendanceModel.idtraining;
    }).toList();

    final attendanceData = List<Map<String, dynamic>?>.filled(23, null);

    await Future.wait(
      attendanceQuery.docs.map((doc) async {
        try {
          final attendanceModel = AttendanceDetailModel.fromJson(doc.data() as Map<String, dynamic>);
          final usersQuery = await firestore.collection('users').where("ID NO", whereIn: traineIds).get();
          final user = usersQuery.docs.firstWhere(
                (userDoc) => userDoc.data()['ID NO'] == attendanceModel.idtraining,
          );
          if (user != null) {
            final userData = UserModel.fromFirebaseUser(user.data());
            attendanceModel.name = userData.name;
            attendanceModel.license = userData.licenseNo;
            attendanceModel.rank = userData.rank;
            attendanceModel.hub = userData.hub;

            // Determine the index to place the data in the result list
            int index = traineIds.indexOf(attendanceModel.idtraining!);
            attendanceData[index] = attendanceModel.toJson();
          } else {
            print("User not found for ID NO: ${attendanceModel.idtraining}");
          }
        } catch (error) {
          print("Error processing attendance detail: $error");
        }
      }),
    );

    return attendanceData;
  } catch (error) {
    print("Error in getCombinedAttendanceDetailStream: $error");
    return List<Map<String, dynamic>?>.filled(23, null);
  }
}


// List untuk Instructor
Future<List<Map<String, dynamic>?>> instructorList(String idAttendance) async {
  QuerySnapshot attendanceQuery = await firestore.collection('attendance').where("id", isEqualTo: idAttendance).get();
  List<int?> instructorIds =
  attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data() as Map<String, dynamic>).instructor).toList();

  final usersData = <Map<String, dynamic>>[];

  if (instructorIds.isNotEmpty) {
    final usersQuery = await firestore.collection('users').where("ID NO", whereIn: instructorIds).get();
    usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
  }

  final attendanceData = await Future.wait(
    attendanceQuery.docs.map((doc) async {
      final attendanceModel = AttendanceModel.fromJson(doc.data() as Map<String, dynamic>);
      final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {});
      attendanceModel.name = user['NAME'];
      attendanceModel.loano = user['LOA NO'];
      return attendanceModel.toJson();
    }),
  );
  return attendanceData;
}


// List untuk Administrator
Future<List<Map<String, dynamic>?>>  administratorList(String idAttendance) async {
  QuerySnapshot attendanceQuery = await firestore.collection('attendance').where("id", isEqualTo: idAttendance).get();
  List<int?> adminIds =
  attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data() as Map<String, dynamic>).idPilotAdministrator).toList();

  final usersData = <Map<String, dynamic>>[];

  if (adminIds.isNotEmpty) {
    final usersQuery = await firestore.collection('users').where("ID NO", whereIn: adminIds).get();
    usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
  }

  final attendanceData = await Future.wait(
    attendanceQuery.docs.map((doc) async {
      final attendanceModel = AttendanceModel.fromJson(doc.data() as Map<String, dynamic>);
      final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.idPilotAdministrator, orElse: () => {});
      attendanceModel.name = user['NAME'];
      attendanceModel.photoURL = user['PHOTOURL'];
      return attendanceModel.toJson();
    }),
  );
  return attendanceData;
}


//
// Future<Uint8List> _getImageBytes(String imageUrl) async {
//   final response = await http.get(Uri.parse(imageUrl));
//   if (response.statusCode == 200) {
//     return response.bodyBytes;
//   } else {
//     throw Exception('Failed to load image. Status code: ${response.statusCode}');
//   }
// }

Future<String> eksportAttendanceListPDF(String idAttendance) async {
  try {

    // get Attendance
    final List<Map<String, dynamic>>? attendanceModels = await getCombinedAttendance(idAttendance);

    // get Attendance Detail (Daftar Training)
    final List<Map<String, dynamic>?> attendanceDetailStream = await getCombinedAttendanceDetailStream(idAttendance);

    // get Instructor
    final List<Map<String, dynamic>?> instructorSt = await instructorList(idAttendance);

    // Memanggil Data Pilot Administrator
    final List<Map<String, dynamic>?> administratorSt = await administratorList(idAttendance);



    final outputDirectory = await getTemporaryDirectory();
    // Load the existing PDF document.
    final ByteData data = await rootBundle.load('assets/documents/AttendanceList.pdf');
    final List<int> bytes = data.buffer.asUint8List();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    // Get the existing PDF page.
    final PdfPage page = document.pages[0];
    double x = 50;
    double cellWidth = 100;
    double cellHeight = 14.5;
    double y = 133;

    for (var item in attendanceModels!) {
      x = 170;
      y = 133;
      page.graphics.drawString(
        item['subject'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      y += cellHeight;
      page.graphics.drawString(
        item['department'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      y += cellHeight;
      page.graphics.drawString(
        item['trainingType'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      x = 433;
      y = 133;
      page.graphics.drawString(
          DateFormat('dd MMMM yyyy').format(item['date']?.toDate()!) ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      y += cellHeight;
      page.graphics.drawString(
        item['venue'] ?? 'N/A',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      y += cellHeight;
      page.graphics.drawString(
        item['room'] ?? 'N/A',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );
    }


    y = 210;
    int ind = 1;
    //LIST OF TRAINEE
    for (var item in attendanceDetailStream!) {
      x = 60;

      page.graphics.drawString(
        ind.toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  15, cellHeight),
      );

      x += 20;
      page.graphics.drawString(
        item?['name'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      x += 173;
      page.graphics.drawString(
        item?['idtraining'].toString() ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      x += 65;
      page.graphics.drawString(
        item?['rank'].toString() ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );


      x += 53;
      page.graphics.drawString(
        item?['license'].toString() ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );


      x += 60;
      page.graphics.drawString(
        item?['hub'].toString() ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      x += 50;

      //Read the image data from the weblink.
      var url = item?['signature_url'];
      if(url != null ){
        var response = await get(Uri.parse(url));
        var data = response.bodyBytes;

        //Create a bitmap object.
        PdfBitmap image = PdfBitmap(data);

        //Draw an image to the document.
        page.graphics.drawImage(
            image,
            Rect.fromLTWH(
                x, y, 50, 15));
      }

      ind++;
      y += cellHeight;
    }


    y = 581;
    //LIST OF TRAINER
    for (var item in instructorSt!) {
      x = 59;

      page.graphics.drawString(
        item?['name'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      x += 195;
      page.graphics.drawString(
        item?['instructor'].toString() ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      x += 60;
      page.graphics.drawString(
        item?['loano'].toString() ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );


      x += 145;

      //Read the image data from the weblink.
      var url = item?['signatureIccUrl'];
      if(url != null ){
        var response = await get(Uri.parse(url));
        var data = response.bodyBytes;

        //Create a bitmap object.
        PdfBitmap image = PdfBitmap(data);

        //Draw an image to the document.
        page.graphics.drawImage(
            image,
            Rect.fromLTWH(
                x, y, 50, 15));
      }

      y += cellHeight;
    }



    y = 690;
    //LIST OF TRAINER
    for (var item in administratorSt!) {
      x = 59;

      page.graphics.drawString(
        item?['name'] ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      x += 195;
      page.graphics.drawString(
        item?['idPilotAdministrator'].toString() ?? '',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(x, y,  cellWidth, cellHeight),
      );

      x += 205;

      //Read the image data from the weblink.
      var url = item?['signaturePilotAdministratorUrl'];
      if(url != null ){
        var response = await get(Uri.parse(url));
        var data = response.bodyBytes;

        //Create a bitmap object.
        PdfBitmap image = PdfBitmap(data);

        //Draw an image to the document.
        page.graphics.drawImage(
            image,
            Rect.fromLTWH(
                x, y, 50, 15));
      }

      y += cellHeight;
    }





    // Save the document.
    final List<int> outputBytes = await document.save();
    final File file = File('${outputDirectory.path}/AttendanceList14.pdf');
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
