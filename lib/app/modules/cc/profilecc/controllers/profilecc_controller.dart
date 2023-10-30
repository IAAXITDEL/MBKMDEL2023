import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'dart:math';
import '../../../../../data/users/user_preferences.dart';
import '../../../../../data/users/users.dart';
import '../../../../../di/locator.dart';
import '../../../../../presentation/shared_components/remarkTextCard.dart';
import '../../../../../presentation/shared_components/textCard.dart';
import '../../../../../presentation/shared_components/textTrainingCodeCard.dart';
import '../../../../../presentation/view_model/attendance_model.dart';
import '../../../../../presentation/view_model/user_viewmodel.dart';
import '../../../../routes/app_pages.dart';


class ProfileccController extends GetxController {

  late UserViewModel viewModel;
  late UserPreferences userPreferences;

  RxBool isTraining = false.obs;
  RxBool isInstructor = false.obs;
  RxBool isAdministrator = false.obs;
  RxString instructorType = "".obs;

  RxInt idTraining = 0.obs;
  RxInt idTrainee = 0.obs;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxBool isReady = false.obs;
  final RxBool isLoading = false.obs;

  List<pw.TableRow> alarcfitList = [];

  @override
  void onInit() {
    userPreferences = getItLocator<UserPreferences>();
    idTrainee.value = userPreferences.getIDNo();
    cekRole();
    fetchAttendanceData(userPreferences.getIDNo());
    super.onInit();
  }

  //Mendapatkan data pribadi
  Stream<QuerySnapshot<Map<String, dynamic>>> profileList() {
    userPreferences = getItLocator<UserPreferences>();
    return firestore
        .collection('users')
        .where("ID NO", isEqualTo: userPreferences.getIDNo())
        .snapshots();
  }

  // List untuk training stream
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return firestore
        .collection('trainingType')
        .where("is_delete", isEqualTo : 0)
        .snapshots();
  }

  Future<void> logout() async {
    try {
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        print("Failed to disconnect: $e");
      }

      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print("Failed to sign out: $e");
      }

      userPreferences.clearUser();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      print("Exception in UserViewModel on logout: $e");
    }
  }

  Future<void> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI CPTS
    if( userPreferences.getInstructor().contains(UserModel.keyCPTS) && userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){

    }
    // SEBAGAI INSTRUCTOR
    else if( userPreferences.getInstructor().contains(UserModel.keySubPositionCCP) || userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) || userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) || userPreferences.getInstructor().contains(UserModel.keySubPositionPGI)&& userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      isTraining.value = true;
      isInstructor.value = true;
      instructorType.value = userPreferences.getInstructorString();
      print(userPreferences.getInstructorString());
    }
    // SEBAGAI TRAINING
    else if( userPreferences.getRank().contains(UserModel.keyPositionCaptain) || userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)){
      isTraining.value = true;
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if( userPreferences.getRank().contains("Pilot Administrator")){
      isAdministrator.value = true;
    }
    // SEBAGAI ALL STAR
    else{
    }
  }

  //add LOA NO.
  Future<void> addLoaNo(String loaNo) async {
    userPreferences = getItLocator<UserPreferences>();
    CollectionReference users = firestore.collection("users");
    try {
      await users.doc(userPreferences.getIDNo().toString()).update({
        "LOA NO": loaNo,
      });
    } catch (e) {
      // Handle any exceptions that may occur during the operation.
      print("Error updating LOA NO.: $e");
    }
  }


  Future<bool> fetchAttendanceData(int idCrew) async {
    try {
      QuerySnapshot attendanceQuery = await firestore
          .collection('attendance')
          .where("expiry", isEqualTo: "VALID")
          .where("status", isEqualTo: "done")
          .where("is_delete", isEqualTo: 0)
          .get();

      print("test 1");
      if (attendanceQuery.docs.isNotEmpty) {
        final attendanceDetailQuery = await firestore.collection('attendance-detail').where("idtraining", isEqualTo: idCrew).where("status", isEqualTo: "donescoring").get();
        final attendanceDetailData = attendanceDetailQuery.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        if (attendanceDetailData.isEmpty) {
          return false;
        }
        final attendanceData = await Future.wait(
          attendanceQuery.docs.map((doc) async {
            final data = doc.data() as Map<String, dynamic>;
            final matchingDetail = attendanceDetailData.where((attendanceDetail) => attendanceDetail['idattendance'] == data['id']);
            return matchingDetail.isNotEmpty
                ? {
              'id': data['id'],
              'expiry': data['expiry'],
              'subject': data['subject'],
              'valid_to': data['valid_to'],
            } : null;
          }),
        );

        final filteredAttendanceData = attendanceData.where((item) => item != null).toList();

        final groupedAttendanceData = <String, Map<String, dynamic>>{};
        for (var attendance in filteredAttendanceData) {
          final subject = attendance?['subject'] as String?;
          if (subject != null) {
            final validTo = attendance?['valid_to'];
            if (validTo != null) {
              if (!groupedAttendanceData.containsKey(subject) ||
                  validTo.compareTo(groupedAttendanceData[subject]?['valid_to']  ?? DateTime(0)) > 0) {
                groupedAttendanceData[subject] = attendance!;
              }
            }
          }
        }


        print("groupedAttendanceData");
        print(groupedAttendanceData);
        // Sort the grouped attendance data by valid_to
        final sortedAttendanceData = groupedAttendanceData.values.toList()
          ..sort((a, b) {
            Timestamp timestampA = a['valid_to'];
            Timestamp timestampB = b['valid_to'];
            DateTime dateTimeA = timestampA.toDate(); // Convert Timestamp to DateTime
            DateTime dateTimeB = timestampB.toDate(); // Convert Timestamp to DateTime
            return dateTimeB.compareTo(dateTimeA);
          });


        print("sorted");
        print(sortedAttendanceData);
        QuerySnapshot trainingQuery = await firestore
            .collection('trainingType')
            .get();

        List<String?> trainingNames = trainingQuery.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return data != null ? data['training']?.toString() : null;
        }).toList();

        print("trainingNames");
        print(trainingNames);
        // Create a map with keys from trainingNames and values from sortedAttendanceData
        Map<String?, List<Map<String, dynamic>>> attendanceMap = {};

        for (var attendance in sortedAttendanceData) {
          final subject = attendance['subject'];
          final expiry = attendance['expiry'];

          // Check if the subject is present in trainingNames
          if (trainingNames.contains(subject)) {
            if (!attendanceMap.containsKey(subject)) {
              attendanceMap[subject] = [];
            }
            attendanceMap[subject]!.add({
              'id': attendance['id'],
              'expiry': expiry,
              'subject': subject,
              'valid_to': attendance['valid_to'],
            });
          }
        }

        if(trainingNames.length > attendanceMap.length){
          print("NOT VALID");
          isReady.value = false;
          return false;
        }else{
          print("VALID");
          isReady.value = true;
          await getHistoryData(idCrew, "ALAR / CFIT", 5);
          print("test 2");
          return true;
        }


      } else {
        return false;
      }
    } catch (error) {
      print('Error fetching attendance: $error');
      // Handle the error accordingly
      return false;
    }
  }


  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


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

      print(usersData);
      return usersData;
    } catch (error) {
      print('Error getting profile data: $error');
      return null;
    }
  }

  Future<Uint8List> getPDFTrainingCard(int idCrew) async {
    try {
      final font = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
      final ttf = pw.Font.ttf(font);
      final pdf = pw.Document();

      final List<Map<String, dynamic>> codeDataList = [];

      final Uint8List backgroundImageData = (await rootBundle.load('assets/images/AirAsiaTrainingCards.png')).buffer.asUint8List();
      final Uint8List AirAsiaLogo =
      (await rootBundle.load('assets/images/airasia_logo_circle.png'))
          .buffer
          .asUint8List();
      final pw.ImageProvider backgroundImageProvider = pw.MemoryImage(backgroundImageData);

      List<UserModel>? usersData = await getProfileData(idCrew);

      String userName = "";
      String userLicense = "";
      int userEmp = 0;
      if (usersData != null) {
        // You can now work with the usersData list
        for (UserModel user in usersData) {
          userName = user.name;
          userLicense = user.licenseNo;
          userEmp = user.idNo;
        }
      } else {
        print('No user data found or there was an error.');
      }


      final List<Map<String, dynamic>>? historyDataBasicIndoc = await getHistoryData(idCrew, "BASIC INDOC", 1);
      final List<Map<String, dynamic>>? historyDataLSWB = await getHistoryData(idCrew, "LOAD SHEET / WEIGHT & BALANCE", 1);
      final List<Map<String, dynamic>>? historyDataRVSM = await getHistoryData(idCrew, "RVSM", 1);
      final List<Map<String, dynamic>>? historyDataWNDSHEAR = await getHistoryData(idCrew, "WNDSHEAR", 8);
      final List<Map<String, dynamic>>? historyDataAlarCfit = await getHistoryData(idCrew, "ALAR / CFIT", 4);
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


      // ------------------- PAGE 1 ------------------
      pdf.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            margin: const pw.EdgeInsets.all(16),
            pageFormat: PdfPageFormat.a4.landscape,
          ),
          build: (pw.Context context) {

            return pw.Center(
              child: pw.Padding(
                  padding: pw.EdgeInsets.all(17),
                  child: pw.Column(
                      children: [
                        pw.Expanded(
                            flex: 1,
                            child: pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  // ------------------- PAGE 1 TABEL 1 ------------------
                                  pw.SizedBox(width: 28),
                                  pw.Expanded(
                                    child: pw.Stack(
                                        children: [
                                          pw.Positioned.fill(
                                              child: pw.Center(
                                                  child: pw.Image(
                                                      pw.MemoryImage(
                                                          backgroundImageData
                                                      ),
                                                      fit: pw.BoxFit.cover,
                                                      height: 210,
                                                      width: 210
                                                  )
                                              )
                                          ),
                                          pw.Column(
                                              mainAxisAlignment: pw.MainAxisAlignment.center,
                                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                                              children: [
                                                pw.Table(
                                                  border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                  columnWidths: {
                                                    0: pw.FlexColumnWidth(1),
                                                    1: pw.FlexColumnWidth(1),
                                                    2: pw.FlexColumnWidth(1),
                                                  },
                                                  children: [
                                                    // Header row
                                                    pw.TableRow(
                                                      children: [
                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                            padding: pw.EdgeInsets.all(3),
                                                            child: pw.Center(
                                                                child : pw.Text('TRAINING', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                            )
                                                          ),
                                                        ),

                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                            padding: pw.EdgeInsets.all(3),
                                                            child: pw.Center(
                                                              child : pw.Text('DATE', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                            )
                                                          ),
                                                        ),

                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                            padding: pw.EdgeInsets.all(3),
                                                            child: pw.Center(
                                                              child : pw.Text('VALID TO', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                            )
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 4 * 15,
                                                                child: pw.Center(
                                                                  child: pw.Text("RNP (GNSS)", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(2),
                                                          1: pw.FlexColumnWidth(2),
                                                        },
                                                        children: [
                                                          // Data rows
                                                          for (var item in historyDataRNP!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 4 * 15,
                                                                child: pw.Center(
                                                                  child: pw.Text("LINE CHECK", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(2),
                                                          1: pw.FlexColumnWidth(2),
                                                        },
                                                        children: [
                                                          // Data rows
                                                          for (var item in historyDataLINECHECK!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 2 * 15,
                                                                child: pw.Center(
                                                                  child: pw.Text("LVO", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(2),
                                                          1: pw.FlexColumnWidth(2),
                                                        },
                                                        children: [
                                                          // Data rows
                                                          for (var item in historyDataLVO!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 2 * 15,
                                                                child: pw.Center(
                                                                  child: pw.Text("ETOPS SIM", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(2),
                                                          1: pw.FlexColumnWidth(2),
                                                        },
                                                        children: [
                                                          for (var item in historyDataETOPSSIM!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 2 * 15,
                                                                child: pw.Center(
                                                                  child: pw.Text("ETOPS FLT", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(2),
                                                          1: pw.FlexColumnWidth(2),
                                                        },
                                                        children: [
                                                          for (var item in historyDataETOPSFLT!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Table(
                                                  border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                  columnWidths: {
                                                    0: pw.FlexColumnWidth(1),
                                                    1: pw.FlexColumnWidth(1),
                                                    2: pw.FlexColumnWidth(1),
                                                  },
                                                  children: [
                                                    // Data rows
                                                    for (int i = 0; i < 4; i++)
                                                    pw.TableRow(
                                                      children: [
                                                          TextCard(text: ""),
                                                        TextCard(text: ""),
                                                        TextCard(text: ""),
                                                      ],
                                                    ),

                                                  ],
                                                ),
                                              ]),
                                        ]
                                    ),
                                  ),
                                  pw.SizedBox(width: 25),

                                  // ------------------- PAGE 1 TABEL 2 ------------------
                                  pw.Expanded(
                                    child: pw.Stack(
                                        children: [
                                          pw.Positioned.fill(
                                              child: pw.Center(
                                                  child: pw.Image(
                                                      pw.MemoryImage(
                                                          backgroundImageData
                                                      ),
                                                      fit: pw.BoxFit.cover,
                                                      height: 210,
                                                      width: 210
                                                  )
                                              )
                                          ),
                                          pw.Column(
                                              mainAxisAlignment: pw.MainAxisAlignment.center,
                                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                                              children: [
                                                pw.Table(
                                                  border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                  columnWidths: {
                                                    0: pw.FlexColumnWidth(1),
                                                    1: pw.FlexColumnWidth(2),
                                                  },
                                                  children: [
                                                    // Header row
                                                    pw.TableRow(
                                                      children: [
                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                            padding: pw.EdgeInsets.all(3),
                                                            child: pw.Text('TRAINING CODE', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                          ),
                                                        ),

                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Center(
                                                            child: pw.Padding(
                                                              padding: pw.EdgeInsets.all(3),
                                                              child: pw.Text('REMARK', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.left,),
                                                            ),
                                                          )
                                                        ),
                                                      ],
                                                    ),
                                                    // Data rows
                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: "RVSM"),
                                                        RemarkTextCard(text: "Reduced Vertical Separation Minima")
                                                      ],
                                                    ),

                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: "DGR"),
                                                        RemarkTextCard(text: "Dangerous Goods and Regulations")
                                                      ],
                                                    ),

                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: "AVSEC"),
                                                        RemarkTextCard(text: "Aviation Security")
                                                      ],
                                                    ),

                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: "SMS"),
                                                        RemarkTextCard(text: "Safety Management System")
                                                      ],
                                                    ),

                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: "CRM"),
                                                        RemarkTextCard(text: "Crew Resource Management")
                                                      ],
                                                    ),

                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: "ALAR/CFIT"),
                                                        RemarkTextCard(text: "Approach and Landing Accident Reduction/Controlled Flight Into Terrain")
                                                      ],
                                                    ),
                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: "PBN"),
                                                        RemarkTextCard(text: "Performance Based Navigation")
                                                      ],
                                                    ),

                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: "RGT"),
                                                        RemarkTextCard(text: "Recurrent Ground Training")
                                                      ],
                                                    ),

                                                    pw.TableRow(
                                                      children: [
                                                        pw.Container(
                                                          height: 36,
                                                          child: TextTrainingCodeCard(text: "RNAV (GNSS)"),
                                                        ),
                                                        RemarkTextCard(text: "Required Navigation (GNSS)")
                                                      ],
                                                    ),

                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: "LVO"),
                                                        RemarkTextCard(text: "Low Visibility Operation")
                                                      ],
                                                    ),
                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: "RHS CHECK"),
                                                        RemarkTextCard(text: "Right Hand Seat Check")
                                                      ],
                                                    ),

                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: "UPRT"),
                                                        RemarkTextCard(text: "Upset and Recovery Training")
                                                      ],
                                                    ),
                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: ""),
                                                        RemarkTextCard(text: "")
                                                      ],
                                                    ),
                                                    pw.TableRow(
                                                      children: [
                                                        TextTrainingCodeCard(text: ""),
                                                        RemarkTextCard(text: "")
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                        ]
                                    ),
                                  ),
                                  pw.SizedBox(width: 25),


                                  // ------------------- PAGE 1 TABEL 3 ------------------
                                  pw.Expanded(
                                    child: pw.Stack(
                                        children: [
                                          pw.Column(
                                              mainAxisAlignment: pw.MainAxisAlignment.center,
                                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                                              children: [
                                                pw.Row(
                                                    mainAxisSize: pw.MainAxisSize.min,
                                                    children: [
                                                      pw.Expanded(
                                                          flex: 1,
                                                          child: pw.Image(
                                                              pw.MemoryImage(
                                                                  AirAsiaLogo
                                                              ),
                                                              fit: pw.BoxFit.cover,
                                                              height: 50,
                                                              width: 50
                                                          )
                                                      ),
                                                      pw.Expanded(
                                                          flex : 2,
                                                          child: pw.Column(
                                                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                                                              children: [
                                                                pw.Text(
                                                                  "PILOT TRAINING", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                                                                ),
                                                                pw.Text(
                                                                  "AND" , style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                                                                ),
                                                                pw.Text(
                                                                  "PROFICIENCY CONTROL CARD" , style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                                                                ),
                                                              ]
                                                          )
                                                      )
                                                    ]
                                                ),

                                                pw.SizedBox(height: 10),

                                                pw.Row(
                                                    mainAxisAlignment: pw.MainAxisAlignment.start,
                                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                    mainAxisSize: pw.MainAxisSize.min,
                                                    children: [
                                                      pw.Expanded(
                                                        flex: 1,
                                                        child: pw.Table(
                                                          border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                          columnWidths: {
                                                            0: pw.FlexColumnWidth(1), // Adjust as needed
                                                          },
                                                          children: [
                                                            pw.TableRow(
                                                              children: [
                                                                pw.Container(
                                                                  height: 5 * 18,
                                                                  child: pw.Center(
                                                                    child: pw.Text("", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                                  ),
                                                                ),

                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      pw.SizedBox(width: 10),

                                                      pw.Expanded(
                                                        flex: 2,
                                                        child: pw.Table(
                                                          border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                          columnWidths: {
                                                            0: pw.FlexColumnWidth(1), // Adjust as needed
                                                          },
                                                          children: [
                                                            pw.TableRow(
                                                              children: [
                                                                pw.Container(
                                                                    color: PdfColors.grey300,
                                                                    height: 3 * 16.65,
                                                                    child: pw.Padding(
                                                                      padding: pw.EdgeInsets.all(3),
                                                                      child: pw.Text("This is to ceritify that the holder has conducted the training and/or test in accordance with Indonesia Civil Aviation Safety Regulations", style: pw.TextStyle(fontSize: 7.5), textAlign: pw.TextAlign.right),
                                                                    )
                                                                ),

                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ]
                                                ),

                                                pw.SizedBox(height: 15),

                                                // ------------------- Name --------------------
                                                pw.Row(
                                                    mainAxisAlignment: pw.MainAxisAlignment.start,
                                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                    mainAxisSize: pw.MainAxisSize.min,
                                                    children: [
                                                      pw.Expanded(
                                                        flex: 6,
                                                        child: pw.Text("Name", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 1,
                                                        child: pw.Text(":", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 15,
                                                        child: pw.Text(userName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                                      ),

                                                    ]
                                                ),
                                                pw.SizedBox(height: 10),
                                                // ------------------- License --------------------
                                                pw.Row(
                                                    mainAxisAlignment: pw.MainAxisAlignment.start,
                                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                    mainAxisSize: pw.MainAxisSize.min,
                                                    children: [
                                                      pw.Expanded(
                                                        flex: 6,
                                                        child: pw.Text("License", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 1,
                                                        child: pw.Text(":", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 15,
                                                        child: pw.Text(userLicense, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                                      ),

                                                    ]
                                                ),

                                                pw.SizedBox(height: 10),

                                                // ------------------- Emp No. --------------------
                                                pw.Row(
                                                    mainAxisAlignment: pw.MainAxisAlignment.start,
                                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                    mainAxisSize: pw.MainAxisSize.min,
                                                    children: [
                                                      pw.Expanded(
                                                        flex: 6,
                                                        child: pw.Text("Emp. No", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 1,
                                                        child: pw.Text(":", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 15,
                                                        child: pw.Text(userEmp.toString(), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                                      ),

                                                    ]
                                                ),

                                                pw.SizedBox(height: 15),

                                                pw.Expanded(
                                                  flex: 2,
                                                  child: pw.Table(
                                                    border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                    columnWidths: {
                                                      0: pw.FlexColumnWidth(1), // Adjust as needed
                                                    },
                                                    children: [
                                                      pw.TableRow(
                                                        children: [
                                                          pw.Container(
                                                              height: 3 * 16.65,
                                                              child: pw.Padding(
                                                                padding: pw.EdgeInsets.all(3),
                                                                child: pw.Text("Issued by Flight Operation Departement \n PT. Indonesia AirAsia, Office Management Building \n Jl. Marsekal Suryadharma (M1), No. 1 \n Kelurahan Selapajang Jaya, Kec. Neglasari, \n Kota Tangerang, Provinsi Banten 15217 \n Office: + 62 21 2985 0888, Facsimile: +62 21 2985 0891 ", style: pw.TextStyle(fontSize: 6.5), textAlign: pw.TextAlign.center),
                                                              )
                                                          ),

                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),


                                              ]),
                                        ]
                                    ),
                                  ),
                                  pw.SizedBox(width: 28),
                                ]
                            )
                        ),
                      ]
                  )
              ),
            );
          },
        ),
      );

      // ------------------- PAGE 2 ------------------
      pdf.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            margin: const pw.EdgeInsets.all(16),
            pageFormat: PdfPageFormat.a4.landscape,
          ),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Padding(
                  padding: pw.EdgeInsets.all(17),
                  child: pw.Column(
                      children: [
                        pw.Expanded(
                            flex: 1,
                            child: pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.SizedBox(width: 28),
                                  pw.Expanded(
                                    child: pw.Stack(
                                        children: [
                                          pw.Positioned.fill(
                                              child: pw.Center(
                                                  child: pw.Image(
                                                      pw.MemoryImage(
                                                          backgroundImageData
                                                      ),
                                                      fit: pw.BoxFit.cover,
                                                      height: 210,
                                                      width: 210
                                                  )
                                              )
                                          ),
                                          pw.Column(
                                              mainAxisAlignment: pw.MainAxisAlignment.center,
                                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                                              children: [
                                                pw.Table(
                                                  border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                  columnWidths: {
                                                    0: pw.FlexColumnWidth(1),
                                                    1: pw.FlexColumnWidth(1),
                                                    2: pw.FlexColumnWidth(1),
                                                  },
                                                  children: [
                                                    // Header row
                                                    pw.TableRow(
                                                      children: [
                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                              padding: pw.EdgeInsets.all(3),
                                                              child: pw.Center(
                                                                child : pw.Text('TRAINING', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                              )
                                                          ),
                                                        ),

                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                              padding: pw.EdgeInsets.all(3),
                                                              child: pw.Center(
                                                                child : pw.Text('DATE', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                              )
                                                          ),
                                                        ),

                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                              padding: pw.EdgeInsets.all(3),
                                                              child: pw.Center(
                                                                child : pw.Text('VALID TO', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                              )
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Data rows
                                                    for (var item in historyDataBasicIndoc!)
                                                      pw.TableRow(
                                                        children: [
                                                          pw.Container(
                                                            height: 28,
                                                            child: TextCard(text: "BASIC INDOC"),
                                                          ),
                                                          TextCard(text: item['date'] ?? ''),
                                                          TextCard(text: item['valid_to'] ?? ''),
                                                        ],
                                                      ),

                                                    for (var item in historyDataLSWB!)
                                                      pw.TableRow(
                                                        children: [
                                                          pw.Container(
                                                            height: 47,
                                                            child: TextCard(text: "LOAD SHEET / WEIGHT & BALANCE"),
                                                          ),
                                                          TextCard(text: item['date'] ?? ''),
                                                          TextCard(text: item['valid_to'] ?? ''),
                                                        ],
                                                      ),

                                                    for (var item in historyDataRVSM!)
                                                      pw.TableRow(
                                                        children: [
                                                          TextCard(text: "RVSM"),
                                                          TextCard(text: item['date'] ?? ''),
                                                          TextCard(text: item['valid_to'] ?? ''),
                                                        ],
                                                      ),
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 8 * 15,
                                                                child: pw.Center(
                                                                  child: pw.Text("WNDSHEAR", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(2),
                                                          1: pw.FlexColumnWidth(2),
                                                        },
                                                        children: [
                                                          for (var item in historyDataWNDSHEAR!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 4 * 15,
                                                                child:  pw.Padding(
                                                                  padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                                                                  child: pw.Center(
                                                                      child: pw.Text("ALAR / CFIT", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,)
                                                                  ),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1),
                                                          1: pw.FlexColumnWidth(1),
                                                        },
                                                        children: [
                                                          for (var item in historyDataAlarCfit!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ]),
                                        ]
                                    ),
                                  ),
                                  pw.SizedBox(width: 25),

                                  // ------------------- PAGE 2 TABEL 2 ------------------
                                  pw.Expanded(
                                    child: pw.Stack(
                                        children: [
                                          pw.Positioned.fill(
                                              child: pw.Center(
                                                  child: pw.Image(
                                                      pw.MemoryImage(
                                                          backgroundImageData
                                                      ),
                                                      fit: pw.BoxFit.cover,
                                                      height: 210,
                                                      width: 210
                                                  )
                                              )
                                          ),
                                          pw.Column(
                                              mainAxisAlignment: pw.MainAxisAlignment.center,
                                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                                              children: [
                                                pw.Table(
                                                  border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                  columnWidths: {
                                                    0: pw.FlexColumnWidth(1),
                                                    1: pw.FlexColumnWidth(1),
                                                    2: pw.FlexColumnWidth(1),
                                                  },
                                                  children: [
                                                    // Header row
                                                    pw.TableRow(
                                                      children: [
                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                              padding: pw.EdgeInsets.all(3),
                                                              child: pw.Center(
                                                                child : pw.Text('TRAINING', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                              )
                                                          ),
                                                        ),

                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                              padding: pw.EdgeInsets.all(3),
                                                              child: pw.Center(
                                                                child : pw.Text('DATE', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                              )
                                                          ),
                                                        ),

                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                              padding: pw.EdgeInsets.all(3),
                                                              child: pw.Center(
                                                                child : pw.Text('VALID TO', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                              )
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 4 * 15,
                                                                child: pw.Center(
                                                                  child: pw.Text("SEP", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(2),
                                                          1: pw.FlexColumnWidth(2),
                                                        },
                                                        children: [
                                                          // Data rows
                                                          for (var item in historyDataSEP!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 2 * 15,
                                                                child:  pw.Padding(
                                                                  padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                                                                  child: pw.Center(
                                                                      child: pw.Text("SEP DRILL", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,)
                                                                  ),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1),
                                                          1: pw.FlexColumnWidth(1),
                                                        },
                                                        children: [
                                                          // Data rows
                                                          for (var item in historyDataSEPDRILL!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 2 * 15,
                                                                child:  pw.Padding(
                                                                  padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                                                                  child: pw.Center(
                                                                      child: pw.Text("DGR & AVSEC", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,)
                                                                  ),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1),
                                                          1: pw.FlexColumnWidth(1),
                                                        },
                                                        children: [

                                                            for (var item in historyDataDGR!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 4 * 15,
                                                                child:  pw.Padding(
                                                                  padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                                                                  child: pw.Center(
                                                                      child: pw.Text("SMS", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,)
                                                                  ),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1),
                                                          1: pw.FlexColumnWidth(1),
                                                        },
                                                        children: [
                                                          for (var item in historyDataSMS!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 4 * 15,
                                                                child:  pw.Padding(
                                                                  padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                                                                  child: pw.Center(
                                                                      child: pw.Text("CRM", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,)
                                                                  ),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1),
                                                          1: pw.FlexColumnWidth(1),
                                                        },
                                                        children: [
                                                          for (var item in historyDataCRM!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 2 * 15,
                                                                child:  pw.Padding(
                                                                  padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                                                                  child: pw.Center(
                                                                      child: pw.Text("PBN", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,)
                                                                  ),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1),
                                                          1: pw.FlexColumnWidth(1),
                                                        },
                                                        children: [
                                                          for (var item in historyDataPBN!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ]),
                                        ]
                                    ),
                                  ),
                                  pw.SizedBox(width: 25),
                                  // ------------------- PAGE 2 TABEL 3 ------------------
                                  pw.Expanded(
                                    child: pw.Stack(
                                        children: [
                                          pw.Positioned.fill(
                                              child: pw.Center(
                                                  child: pw.Image(
                                                      pw.MemoryImage(
                                                          backgroundImageData
                                                      ),
                                                      fit: pw.BoxFit.cover,
                                                      height: 210,
                                                      width: 210
                                                  )
                                              )
                                          ),
                                          pw.Column(
                                              mainAxisAlignment: pw.MainAxisAlignment.center,
                                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                                              children: [
                                                pw.Table(
                                                  border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                  columnWidths: {
                                                    0: pw.FlexColumnWidth(1),
                                                    1: pw.FlexColumnWidth(1),
                                                    2: pw.FlexColumnWidth(1),
                                                  },
                                                  children: [
                                                    // Header row
                                                    pw.TableRow(
                                                      children: [
                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                              padding: pw.EdgeInsets.all(3),
                                                              child: pw.Center(
                                                                child : pw.Text('TRAINING', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                              )
                                                          ),
                                                        ),

                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                              padding: pw.EdgeInsets.all(3),
                                                              child: pw.Center(
                                                                child : pw.Text('DATE', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                              )
                                                          ),
                                                        ),

                                                        pw.Container(
                                                          color: PdfColors.grey300,
                                                          height: 30,
                                                          child: pw.Padding(
                                                              padding: pw.EdgeInsets.all(3),
                                                              child: pw.Center(
                                                                child : pw.Text('VALID TO', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                              )
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 8 * 15,
                                                                child: pw.Center(
                                                                  child: pw.Text("RGT", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(2),
                                                          1: pw.FlexColumnWidth(2),
                                                        },
                                                        children: [
                                                          // Data rows
                                                          for (var item in historyDataRGT!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 8 * 15,
                                                                child:  pw.Padding(
                                                                  padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                                                                  child: pw.Center(
                                                                      child: pw.Text("RHS CHECK (SIM)", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,)
                                                                  ),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1),
                                                          1: pw.FlexColumnWidth(1),
                                                        },
                                                        children: [
                                                          // Data rows
                                                          for (var item in historyDataRHS!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1), // Adjust as needed
                                                        },
                                                        children: [
                                                          pw.TableRow(
                                                            children: [
                                                              pw.Container(
                                                                height: 2 * 15,
                                                                child:  pw.Padding(
                                                                  padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                                                                  child: pw.Center(
                                                                      child: pw.Text("UPRT", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center,)
                                                                  ),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Right Table with Data
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child:  pw.Table(
                                                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                                                        columnWidths: {
                                                          0: pw.FlexColumnWidth(1),
                                                          1: pw.FlexColumnWidth(1),
                                                        },
                                                        children: [
                                                          // Data rows
                                                          for (var item in historyDataUPRT!)
                                                            pw.TableRow(
                                                              children: [
                                                                TextCard(text: item['date'] ?? ''),
                                                                TextCard(text: item['valid_to'] ?? ''),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ]),
                                        ]
                                    ),
                                  ),
                                  pw.SizedBox(width: 28),
                                ]
                            )
                        ),
                      ]
                  )
              ),
            );
          },
        ),
      );

      // Save the PDF to a file or perform other actions
      return pdf.save();
    } catch (e) {
      print("Error generating PDF: $e");
      return Future.value();
    }
  }

  Future<void> savePdfFile(Uint8List byteList) async {
    isLoading.value = true;
    userPreferences = getItLocator<UserPreferences>();
    final output = await getTemporaryDirectory();
    var filePath = "${output.path}/training-cards-${userPreferences.getIDNo()}.pdf";
    final file = File(filePath);
    print("step 1");
    await file.writeAsBytes(byteList);
    print("step 2");
    await OpenFile.open(filePath);
    print("stetep 3");
    isLoading.value = false;
  }

}