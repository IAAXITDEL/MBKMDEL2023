import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ts_one/presentation/view_model/attendance_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../../../../../data/users/user_preferences.dart';
import '../../../../../../data/users/users.dart';
import '../../../../../../di/locator.dart';
import '../../../../../../presentation/view_model/attendance_model.dart';
import 'dart:io';

class PilottraininghistorydetailccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxInt idTrainingType = 0.obs;
  RxString idAttendance = "".obs;
  RxString trainingName = "".obs;

  late UserPreferences userPreferences;

  final RxBool isTrainee = false.obs;
  final RxBool isCPTS = false.obs;

  @override
  void onInit() {
    super.onInit();
    idTrainingType.value = Get.arguments["idTrainingType"];
    idAttendance.value = Get.arguments["idAttendance"];
    getCombinedAttendance();
    cekRole();
    absentStream();
  }

  //Mendapatkan Training
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return firestore
        .collection('trainingType')
        .where("id", isEqualTo: idTrainingType.value)
        .snapshots();
  }

  //Mendapatkan data kelas yang diikuti
  Future<List<Map<String, dynamic>>> getCombinedAttendance() async {
    final attendanceQuery = await firestore
        .collection('attendance')
        .where("id", isEqualTo: idAttendance.value)
        .get();

    final attendanceDetailQuery = await firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: idAttendance.value)
        .get();

    List<Map<String, dynamic>> attendanceData = [];

    for (var doc in attendanceQuery.docs) {
      final attendanceModel = AttendanceModel.fromJson(doc.data());
      for (var doc in attendanceDetailQuery.docs) {
        final attendanceDetailModel =
            AttendanceDetailModel.fromJson(doc.data());

        // Ambil informasi pengguna hanya untuk trainer yang terkait
        final trainersQuery = await firestore
            .collection('users')
            .where("ID NO", isEqualTo: attendanceModel.instructor)
            .get();

        // Ambil informasi pengguna hanya untuk trainee yang terkait
        final attendanceDetailsQuery = await firestore
            .collection('attendance-detail')
            .where("idattendance", isEqualTo: attendanceModel.id)
            .get();

        // Ambil informasi pengguna hanya untuk trainee yang terkait
        final traineesQuery = await firestore
            .collection('users')
            .where("ID NO", isEqualTo: attendanceDetailModel.idtraining)
            .get();

        if (traineesQuery.docs.isNotEmpty) {
          final trainerData = trainersQuery.docs[0].data();
          final traineeData = traineesQuery.docs[0].data();
          final attendanceDetailData = attendanceDetailsQuery.docs[0].data();

          // Ambil informasi yang diperlukan dari dokumen attendance, attendance detail dan users
          Map<String, dynamic> data = {
            'subject': attendanceModel.subject,
            'date': attendanceModel.date,
            'trainer-name': trainerData['NAME'],
            'trainee-name': traineeData['NAME'],
            'department': attendanceModel.department,
            'trainingType': attendanceModel.trainingType,
            'vanue': attendanceModel.vanue,
            'room': attendanceModel.room,
            'feedback-from-trainer': attendanceDetailData['feedback'],
            'feedback-from-trainee':
                attendanceDetailData['feedbackforinstructor'],
            'rating': attendanceDetailData['rating'],
          };

          // Tambahkan data ke list
          attendanceData.add(data);
        }

        trainingName.value = attendanceModel.subject!;
      }
    }
    return attendanceData;
  }

  Future<bool> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if (userPreferences.getInstructor().contains(UserModel.keyCPTS) &&
            userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      isCPTS.value = true;
    }
    // SEBAGAI INSTRUCTOR
    else if (userPreferences
            .getInstructor()
            .contains(UserModel.keySubPositionCCP) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionPGI) &&
            userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
    }
    // SEBAGAI PILOT
    else if (userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      isTrainee.value = true;
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if (userPreferences.getRank().contains("Pilot Administrator")) {
    }
    // SEBAGAI ALL STAR
    else {
      return false;
    }
    return false;
  }
  
  Future<List> absentStream() async {
    try{
      userPreferences = getItLocator<UserPreferences>();
      final attendanceQuery = await firestore
          .collection('attendance')
          .where("id", isEqualTo: idAttendance.value)
          .get();

      final attendanceDetailQuery = await firestore
          .collection('attendance-detail')
          .where("idattendance", isEqualTo: idAttendance.value)
          .where("idtraining", isEqualTo: userPreferences.getIDNo())
          .get();


      final usersData = <Map<String, dynamic>>[];

      final attendanceDetailData = <Map<String, dynamic>>[];

      for (final doc in attendanceDetailQuery.docs) {
        final attendanceDetailModel = AttendanceDetailModel.fromJson(doc.data());
        attendanceDetailData.add(attendanceDetailModel.toJson());
      }

      final usersQuery = await firestore.collection('users').where("ID NO", isEqualTo: userPreferences.getIDNo()).get();
      usersData.addAll(usersQuery.docs.map((doc) => doc.data()));


      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final attendanceDetail = attendanceDetailData as List<Map<String, dynamic>>;
          final user = usersData as List<Map<String, dynamic>>;
          attendanceModel.name = user[0]['NAME'];
          attendanceModel.formatNo = attendanceDetail[0]['formatNo'];
          return attendanceModel.toJson();
        }),
      );

      print(attendanceData);
      return attendanceData;
    }catch (e){
          return [];
    }

  }

  Future<bool> checkFeedbackIsProvided() async {
    userPreferences = getItLocator<UserPreferences>();

    final attendanceDetailQuery = await firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: idAttendance.value)
        .where("idtraining", isEqualTo: userPreferences.getIDNo())
        .get();

    final attendanceDetailData = <Map<String, dynamic>>[];

    for (final doc in attendanceDetailQuery.docs) {
      final attendanceDetailModel = AttendanceDetailModel.fromJson(doc.data());
      attendanceDetailData.add(attendanceDetailModel.toJson());
    }

    print(attendanceDetailData[0]);
    if (attendanceDetailData[0]["feedbackforinstructor"] != null) {
      return true;
    } else {
      return false;
    }
  }
  
  
  Future<Uint8List> createCertificate() async {
    try {
      final font = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
      final ttf = pw.Font.ttf(font);

      final fontBold = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
      final ttfBold = pw.Font.ttf(fontBold);

      final pdf = pw.Document();
      final Uint8List backgroundImageData = (await rootBundle
              .load('assets/images/Template-Certificate-Pilot.png'))
          .buffer
          .asUint8List();

      final List certificateDate = await absentStream();
      var name = certificateDate[0]['name'];
      var formatNo = certificateDate[0]['formatNo'];
      var subject = certificateDate[0]['subject'];
      var trainingType = certificateDate[0]['trainingType'];

      Timestamp? date = certificateDate[0]["date"];
      DateTime? dates = date?.toDate();
      var datePases = DateFormat('dd MMM yyyy').format(dates!);

      String year = "";
      String month = "";
      if (dates != null) {
        month = DateFormat('MM').format(dates);
        year = DateFormat('yyyy').format(dates);
      }

      String certificateNo = "IAA/FC/${formatNo}/${month}/${year}";
      // ------------------- PDF ------------------
      pdf.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat(1122.17, 794),
            margin: pw.EdgeInsets.all(0),
          ),
          build: (pw.Context context) {
            final pageWidth = 1122.17;
            final pageHeight = 794;

            return pw.Stack(
              children: [
                pw.Image(pw.MemoryImage(backgroundImageData),
                    fit: pw.BoxFit.cover),
                pw.Positioned(
                  top: 345,
                  child: pw.Container(
                    width: pageWidth,
                    child: pw.Center(
                      child: pw.Text(
                          name,
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 32 ,
                            fontWeight: pw.FontWeight.bold,
                          )
                      ),
                    )
                  )
                ),

                pw.Positioned(
                    top: 400,
                    child: pw.Container(
                        width: pageWidth,
                        child: pw.Center(
                          child: pw.Text(
                              "Certificate No:  ${certificateNo}",
                              style: pw.TextStyle(
                                font: ttfBold,
                                fontSize: 12 ,
                                fontWeight: pw.FontWeight.bold,
                              )
                          ),
                        )
                    )
                ),


                pw.Positioned(
                    top: 460,
                    child: pw.Container(
                        width: pageWidth,
                        child: pw.Center(
                          child: pw.Text(
                              "Has successfully completed",
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 16,
                              )
                          ),
                        )
                    )
                ),

                pw.Positioned(
                    top: 480,
                    child: pw.Container(
                        width: pageWidth,
                        child: pw.Center(
                          child: pw.Text(
                              "${subject} ${trainingType} Training",
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 16,
                              )
                          ),
                        )
                    )
                ),

                pw.Positioned(
                    top: 500,
                    child: pw.Container(
                        width: pageWidth,
                        child: pw.Center(
                          child: pw.Text(
                              "Conducted with total of 8 hours",
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 16,
                              )
                          ),
                        )
                    )
                ),

              pw.Positioned(
                  top: 520,
                  child: pw.Container(
                      width: pageWidth,
                      child: pw.Center(
                        child: pw.Text(
                            "Date passes, ${datePases}",
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 16,
                            )
                        ),
                      )
                  )
              ),
              ],
            );
          },
        ),
      );

      return pdf.save();
    } catch (e) {
      print("Error generating PDF: $e");
      return Future.value();
    }
  }

  Future<void> savePdfFile(Uint8List byteList) async {
    var listAttendance = await getCombinedAttendance();

    Timestamp? date = listAttendance[0]["date"];
    DateTime? dates = date?.toDate();
    String dateC = DateFormat('dd-MM-yyyy').format(dates!);


    Directory('/storage/emulated/0/Download/').createSync();
    final output = await getTemporaryDirectory();
    var filePath = "/storage/emulated/0/Download/Certificate/Certificate-${dateC}.pdf";
    final file = File(filePath);
    print("step 1");
    await file.writeAsBytes(byteList);
    print("step 2");

    final filePaths = "${output.path}/Certificate-${dateC}.pdf";
    final files = File(filePaths);
    print("step 1");
    await files.writeAsBytes(byteList);
    print("step 2");
    await OpenFile.open(filePaths);
    print("stetep 3");
  }


  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
