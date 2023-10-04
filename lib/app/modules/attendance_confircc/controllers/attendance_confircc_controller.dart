import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/shared_components/normaltextfieldpdf.dart';
import '../../../../presentation/shared_components/textfieldpdf.dart';
import '../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../presentation/view_model/attendance_model.dart';

class AttendanceConfirccController extends GetxController {
  var selectedMeeting = "Training".obs;
  late UserPreferences userPreferences;
  List<AttendanceDetailModel> allAttendanceDetailModels = [];
  List<AttendanceModel> instructorModels = [];
  List<AttendanceModel> administratorModels = [];

  List<pw.TableRow> tableRows = [];
  List<pw.TableRow> instructorTableRows = [];
  List<pw.TableRow> administratorTableRows = [];

  void selectMeeting(String? newValue) {
    selectedMeeting.value =
        newValue ?? "Training"; // Default to "Meeting 1" if newValue is null
  }

  final RxString argumentid = "".obs;
  final RxString argumentname = "".obs;
  final RxInt jumlah = 0.obs;
  final RxBool showText = false.obs;
  final RxInt argumentTrainingType = 0.obs;

  final RxInt idInstructor = 0.obs;

  final RxString role = "".obs;
  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final String id = args["id"];
    argumentid.value = id;
    attendanceStream();
    getCombinedAttendanceStream();
    cekRole();
    instructorStream();
    attendancelist();
  }

  // List untuk asign Training
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where("RANK", whereIn: ["CAPT", "FO"])
        .snapshots();
  }


  // Menampilkan attendance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream() {
    return _firestore
        .collection('attendance')
        .where("id", isEqualTo: argumentid.value)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere(
              (user) => user['ID NO'] == attendanceModel.instructor,
              orElse: () => {});
          attendanceModel.name = user['NAME'];
          attendanceModel.loano = user['LOA NO'];
          idInstructor.value = attendanceModel.instructor!;
          return attendanceModel.toJson();
        }),
      );
      argumentTrainingType.value = attendanceData[0]["idTrainingType"];
      return attendanceData;
    });
  }

  Stream<List<Map<String, dynamic>>> getCombinedAttendanceDetailStream() {
    return _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: argumentid.value)
        .where("status", whereIn: ["done", "donescoring"])
        .snapshots()
        .asyncMap((attendanceQuery) async {
          final usersQuery = await _firestore.collection('users').get();
          final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

          final attendanceData = await Future.wait(
            attendanceQuery.docs.map((doc) async {
              final attendanceModel =
                  AttendanceDetailModel.fromJson(doc.data());
              final user = usersData.firstWhere(
                (user) => user['ID NO'] == attendanceModel.idtraining,
                orElse: () => {},
              );
              attendanceModel.name = user['NAME'];
              attendanceModel.license = user['LICENSE NO.'];
              attendanceModel.rank = user['RANK'];
              attendanceModel.hub = user['HUB'];
              return attendanceModel.toJson();
            }),
          );
          instructorStream();
          return attendanceData;
        });
  }

  Future<void> cekRole() async {
    userPreferences = getItLocator<UserPreferences>();

    // SEBAGAI INSTRUCTOR
    if (userPreferences.getInstructor().contains(UserModel.keySubPositionCCP) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIA) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionFIS) ||
        userPreferences.getInstructor().contains(UserModel.keySubPositionPGI) &&
            userPreferences.getRank().contains(UserModel.keyPositionCaptain) ||
        userPreferences.getRank().contains(UserModel.keyPositionFirstOfficer)) {
      role.value = "ICC";
    }
    // SEBAGAI PILOT ADMINISTRATOR
    else if (userPreferences.getRank().contains("Pilot Administrator")) {
      role.value = "Pilot Administrator";
    }
  }

  Future<void> saveSignature(Uint8List signatureData) async {
    // Membuat referensi untuk Firebase Storage
    final Reference storageReference = FirebaseStorage.instance.ref().child(
        'signature-cc/${argumentid.value}-pilot-administrator-${DateTime.now()}.png');

    // Mengunggah data gambar ke Firebase Storage
    await storageReference.putData(signatureData);

    // Mendapatkan URL gambar yang diunggah
    final String imageUrl = await storageReference.getDownloadURL();

    // Menyimpan URL gambar di database Firestore
    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(argumentid.value)
        .update({'signaturePilotAdministratorUrl': imageUrl});
  }

  //confir attendance oleh pilot administrator
  Future<void> confirattendance() async {
    userPreferences = getItLocator<UserPreferences>();
    CollectionReference attendance = _firestore.collection('attendance');
    await attendance.doc(argumentid.value.toString()).update({
      "status": "done",
      "idPilotAdministrator": userPreferences.getIDNo(),
      "updatedTime": DateTime.now().toIso8601String(),
    });
  }

  //mendapatkan panjang list attendance
  Stream<int> attendanceStream() {
    return _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: argumentid.value)
        .where("status", isEqualTo: "donescoring")
        .snapshots()
        .map((attendanceQuery) {
      jumlah.value = attendanceQuery.docs.length;

      return attendanceQuery.docs.length;
    });
  }

  //Membuat daftar absent
  Future<void> addAbsentForm(int idtraining) async {
    CollectionReference absent = _firestore.collection("absent");

    try {
      await absent.doc("$idtraining-${argumentid.value}").set({
        "id" : "$idtraining-${argumentid.value}",
        "idattendance" : argumentid.value,
        "idtraining": idtraining,
        "creationTime": DateTime.now().toIso8601String(),
        "updatedTime": DateTime.now().toIso8601String(),
      });
    } catch (e) {
    }
  }

  // List daftar Absent
  Stream<List<Map<String, dynamic>>> absentStream() {
    return _firestore.collection('absent').where("idattendance", isEqualTo: argumentid.value).snapshots().asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceDetailModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.idtraining, orElse: () => {});
          attendanceModel.name = user['NAME']; // Set 'nama' di dalam model
          attendanceModel.photoURL = user['PHOTOURL'];
          return attendanceModel.toJson();
        }),
      );
      return attendanceData;
    });
  }

  // Membatalkan daftar absent
  Future<void> deleteAbsent(String id) {
    return _firestore.collection('absent')
        .doc("$id")
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }


  // List untuk Instructor
  Stream<List<Map<String, dynamic>>> instructorStream() {
    return _firestore.collection('attendance').where("id", isEqualTo: argumentid.value).snapshots().asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {});
          attendanceModel.name = user['NAME'];
          attendanceModel.photoURL = user['PHOTOURL'];
          return attendanceModel.toJson();
        }),
      );
      return attendanceData;
    });
  }

  // List untuk Administrator
  Stream<List<Map<String, dynamic>>> administratorStream() {
    return _firestore.collection('attendance').where("id", isEqualTo: argumentid.value).snapshots().asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.idPilotAdministrator, orElse: () => {});
          attendanceModel.name = user['NAME'];
          attendanceModel.photoURL = user['PHOTOURL'];
          return attendanceModel.toJson();
        }),
      );
      return attendanceData;
    });
  }


  Future<pw.MemoryImage> loadImageFromNetwork(String imageUrl) async {
    final imageBytes = await _getImageBytes(imageUrl);
    return pw.MemoryImage(imageBytes);
  }

  Future<Uint8List> _getImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image. Status code: ${response.statusCode}');
    }
  }

  //Import PDF
  Future<void> attendancelist() async {
    try {
      final font = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
      final ttf = pw.Font.ttf(font);

      final fonticon = await rootBundle.load("assets/fonts/materialIcons.ttf");
      final ttficon = pw.Font.ttf(fonticon);
      final pdf = pw.Document();

      final Uint8List backgroundImageData =
          (await rootBundle.load('assets/images/airasia_logo_circle.png'))
              .buffer
              .asUint8List();

      final Uint8List checkedImage =
      (await rootBundle.load('assets/images/check.png'))
          .buffer
          .asUint8List();

      final Uint8List uncheckedImage =
      (await rootBundle.load('assets/images/square.png'))
          .buffer
          .asUint8List();

      // Memanggil Data Attendance
      Stream<List<Map<String, dynamic>>> attendanceStream =
          getCombinedAttendanceStream();
      List<Map<String, dynamic>> attendanceDataList =
          await attendanceStream.first;
      List<AttendanceModel> attendanceModels = attendanceDataList.map((data) {
        return AttendanceModel.fromJson(data);
      }).toList();

      // Memanggil Data Attendance Detail (Daftar Training)
      Stream<List<Map<String, dynamic>>> attendanceDetailStream = getCombinedAttendanceDetailStream();
      attendanceDetailStream
          .listen((List<Map<String, dynamic>> attendanceDetailDataList) {
        allAttendanceDetailModels.clear();

        List<AttendanceDetailModel> currentAttendanceDetailModels =
            attendanceDetailDataList.map((data) {
          return AttendanceDetailModel.fromJson(data);
        }).toList();

        allAttendanceDetailModels.addAll(currentAttendanceDetailModels);
      });

      // Memanggil Data Instructor
      Stream<List<Map<String, dynamic>>> instructorSt = instructorStream();
      instructorSt
          .listen((List<Map<String, dynamic>> attendanceDataList) {
        instructorModels.clear();
        List<AttendanceModel> currentInstructorModels =
        attendanceDataList.map((data) {
          return AttendanceModel.fromJson(data);
        }).toList();
        instructorModels.addAll(currentInstructorModels);
      });


      // Memanggil Data Pilot Administrator
      Stream<List<Map<String, dynamic>>> administratorSt = administratorStream();
      administratorSt
          .listen((List<Map<String, dynamic>> attendanceDataList) {
        administratorModels.clear();
        List<AttendanceModel> currentAdministratorModels =
        attendanceDataList.map((data) {
          return AttendanceModel.fromJson(data);
        }).toList();
        administratorModels.addAll(currentAdministratorModels);
      });


      //menampilkan data training
      for (int e = 0; e < allAttendanceDetailModels.length; e++) {
        final images = await loadImageFromNetwork(allAttendanceDetailModels[e].signature_url ?? "");

        tableRows.add(
          pw.TableRow(
            children: [
              NormalTextFieldPdf(title: "${e+1}"),
              NormalTextFieldPdf(title: "${allAttendanceDetailModels[e].name}"),
              NormalTextFieldPdf(title: "${allAttendanceDetailModels[e].idtraining}"),
              NormalTextFieldPdf(title: "${allAttendanceDetailModels[e].rank}"),
              NormalTextFieldPdf(title: "${allAttendanceDetailModels[e].license}"),
              NormalTextFieldPdf(title: "${allAttendanceDetailModels[e].hub}"),
              pw.Container(
                height: 15,
                padding: pw.EdgeInsets.all(5),
                child: pw.Center(
                  child: pw.Image(
                    images,
                    fit: pw.BoxFit.cover,
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      print("panjangnya instructor ${instructorModels.length}");
      //menampilkan data instructor
      for (int f = 0; f < instructorModels.length; f++) {
        final imagesicc = await loadImageFromNetwork(instructorModels[f].signatureIccUrl ?? "");

        instructorTableRows.add(
          pw.TableRow(
            children: [
              NormalTextFieldPdf(title: "${instructorModels[f].name}"),
              NormalTextFieldPdf(title: "${instructorModels[f].instructor}"),
              NormalTextFieldPdf(title: "${instructorModels[f].name}"),
              pw.Container(
                height: 15,
                padding: pw.EdgeInsets.all(5),
                child: pw.Center(
                  child: pw.Image(
                    imagesicc,
                    fit: pw.BoxFit.cover,
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      print("panjangnya ${administratorModels.length}");
      //menampilkan data pilot administrator
      for (int g = 0; g < administratorModels.length; g++) {
        final imagesipa = await loadImageFromNetwork(administratorModels[g].signaturePilotAdministratorUrl ?? "");

        administratorTableRows.add(
          pw.TableRow(
            children: [
              NormalTextFieldPdf(title: "${administratorModels[g].name}"),
              NormalTextFieldPdf(title: "${administratorModels[g].idPilotAdministrator}"),
              pw.Container(
                height: 15,
                padding: pw.EdgeInsets.all(5),
                child: pw.Center(
                  child: pw.Image(
                    imagesipa,
                    fit: pw.BoxFit.cover,
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // ------------------- PDF ------------------
      pdf.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            margin: const pw.EdgeInsets.only(
              left: 20,
              top: 20,
              right: 20,
              bottom: 0,
            ),
          ),
          build: (pw.Context context) {
            return pw.Center(
                child: pw.Expanded(
                    flex: 1,
                    child: pw.Column(children: [
                      //---------------------------------------SECTION 1 --------------------------------
                      pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Table(
                            border: pw.TableBorder.all(
                                width: 1, color: PdfColors.black),
                            columnWidths: {
                              0: pw.FlexColumnWidth(1), // Adjust as needed
                            },
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    height: 4 * 15,
                                    child: pw.Center(
                                      child: pw.Image(
                                          pw.MemoryImage(backgroundImageData),
                                          fit: pw.BoxFit.cover,
                                          height: 50,
                                          width: 50),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Table(
                            border: pw.TableBorder.all(
                                width: 1, color: PdfColors.black),
                            columnWidths: {
                              0: pw.FlexColumnWidth(1), // Adjust as needed
                            },
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    height: 4 * 15,
                                    child: pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Center(
                                          child: pw.Text("ATTENDANCE LIST",
                                              style: pw.TextStyle(
                                                  fontSize: 20,
                                                  fontWeight:
                                                      pw.FontWeight.bold)),
                                        )),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),

                      pw.SizedBox(height: 10),
                      ...attendanceModels.map((attendanceModel) {
                        return pw.Column(children: [
                          //--------------------------------------- SECTION 2 --------------------------------
                          pw.Container(
                            height: 25,
                            child: pw.Expanded(
                              flex: 1,
                              child: pw.Table(
                                border: pw.TableBorder.all(
                                    width: 1, color: PdfColors.black),
                                columnWidths: {
                                  0: pw.FlexColumnWidth(1), // Adjust as needed
                                },
                                children: [
                                  pw.TableRow(
                                    children: [
                                      pw.Container(
                                          height: 20,
                                          padding: pw.EdgeInsets.all(3),
                                          child: pw.Center(
                                            child: pw.Row(
                                                mainAxisAlignment:
                                                    pw.MainAxisAlignment.center,
                                                children: [
                                                  pw.Center(
                                                    child: pw.Image(
                                                        pw.MemoryImage(attendanceModel.attendanceType == "Meeting" ? checkedImage : uncheckedImage),
                                                        fit: pw.BoxFit.cover,
                                                        height: 10,
                                                        width: 10),
                                                  ),
                                                  pw.Container(
                                                    padding: pw.EdgeInsets.symmetric(vertical: 5),
                                                    child: TextFieldPdf(
                                                        title: "MEETING"),
                                                  ),
                                                  pw.SizedBox(width: 10),
                                                  pw.Center(
                                                    child: pw.Image(
                                                        pw.MemoryImage(attendanceModel.attendanceType == "Training" ? checkedImage : uncheckedImage),
                                                        fit: pw.BoxFit.cover,
                                                        height: 10,
                                                        width: 10),
                                                  ),
                                                  pw.Container(
                                                    padding: pw.EdgeInsets.symmetric(vertical: 5),
                                                    child: TextFieldPdf(
                                                        title: "TRAINING"),
                                                  ),
                                                ]),
                                          ))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
                            pw.Expanded(
                              flex: 2,
                              child: pw.Table(
                                border: pw.TableBorder.all(
                                    width: 1, color: PdfColors.black),
                                columnWidths: {
                                  0: pw.FlexColumnWidth(1),
                                  1: pw.FlexColumnWidth(2),
                                },
                                children: [
                                  // Data rows
                                  pw.TableRow(
                                    children: [
                                      TextFieldPdf(title: "SUBJECT"),
                                      TextFieldPdf(
                                          title: attendanceModel.subject ?? ''),
                                    ],
                                  ),

                                  pw.TableRow(
                                    children: [
                                      TextFieldPdf(title: "DEPARTMENT"),
                                      TextFieldPdf(
                                          title:
                                              attendanceModel.department ?? ''),
                                    ],
                                  ),

                                  pw.TableRow(
                                    children: [
                                      TextFieldPdf(title: "TRAINING TYPE"),
                                      TextFieldPdf(
                                          title: attendanceModel.trainingType ??
                                              ''),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Table(
                                border: pw.TableBorder.all(
                                    width: 1, color: PdfColors.black),
                                columnWidths: {
                                  0: pw.FlexColumnWidth(1),
                                  1: pw.FlexColumnWidth(2),
                                },
                                children: [
                                  // Data rows
                                  pw.TableRow(
                                    children: [
                                      TextFieldPdf(title: "DATE"),
                                      TextFieldPdf(
                                          title: attendanceModel.date ?? ''),
                                    ],
                                  ),

                                  pw.TableRow(
                                    children: [
                                      TextFieldPdf(title: "VANUE"),
                                      TextFieldPdf(
                                          title: attendanceModel.vanue ?? ''),
                                    ],
                                  ),

                                  pw.TableRow(
                                    children: [
                                      TextFieldPdf(title: "ROOM"),
                                      TextFieldPdf(
                                          title: attendanceModel.room ?? ''),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ])
                        ]);
                      }),
                      pw.SizedBox(height: 10),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Table(
                          border: pw.TableBorder.all(
                              width: 1, color: PdfColors.black),
                          columnWidths: {
                            0: pw.FlexColumnWidth(1),
                            1: pw.FlexColumnWidth(4),
                            2: pw.FlexColumnWidth(2),
                            3: pw.FlexColumnWidth(2),
                            4: pw.FlexColumnWidth(2),
                            5: pw.FlexColumnWidth(1.5),
                            6: pw.FlexColumnWidth(3),
                          },
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Container(
                                  height: 28,
                                  color: PdfColors.black,
                                  padding: pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(
                                      'NO \n',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  color: PdfColors.black,
                                  padding: pw.EdgeInsets.all(3),
                                  height: 28,
                                  child: pw.Center(
                                    child: pw.Text(
                                      'NAME \n',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  color: PdfColors.black,
                                  padding: pw.EdgeInsets.all(3),
                                  height: 28,
                                  child: pw.Center(
                                    child: pw.Text(
                                      'ID NO. \n',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  color: PdfColors.black,
                                  padding: pw.EdgeInsets.all(3),
                                  height: 28,
                                  child: pw.Center(
                                    child: pw.Text(
                                      'RANK \n',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  color: PdfColors.black,
                                  padding: pw.EdgeInsets.all(3),
                                  height: 28,
                                  child: pw.Center(
                                    child: pw.Text(
                                      'LICENSE \n /FAC NO.',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  color: PdfColors.black,
                                  padding: pw.EdgeInsets.all(3),
                                  height: 28,
                                  child: pw.Center(
                                    child: pw.Text(
                                      'HUB \n',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  color: PdfColors.black,
                                  padding: pw.EdgeInsets.all(3),
                                  height: 28,
                                  child: pw.Center(
                                    child: pw.Text(
                                      'SIGNATURE \n',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Data rows
                            // for (int d = 0;
                            //     d < allAttendanceDetailModels.length;
                            //     d++)
                            //   pw.TableRow(
                            //     children: [
                            //       NormalTextFieldPdf(title: "$d"),
                            //       NormalTextFieldPdf(
                            //           title:
                            //               "${allAttendanceDetailModels[d].name}"),
                            //       NormalTextFieldPdf(
                            //           title:
                            //               "${allAttendanceDetailModels[d].idtraining}"),
                            //       NormalTextFieldPdf(
                            //           title:
                            //               "${allAttendanceDetailModels[d].rank}"),
                            //       NormalTextFieldPdf(
                            //           title:
                            //               "${allAttendanceDetailModels[d].license}"),
                            //       NormalTextFieldPdf(title: "03-11-22"),
                            //       pw.Container(
                            //         height: 15,
                            //         child: pw.Center(
                            //           child: pw.Image(
                            //             image,
                            //             fit: pw.BoxFit.cover,
                            //             height: 50,
                            //             width: 50,
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            ...tableRows
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Table(
                          border: pw.TableBorder.all(
                              width: 1, color: PdfColors.black),
                          columnWidths: {
                            0: pw.FlexColumnWidth(3),
                            1: pw.FlexColumnWidth(1),
                            2: pw.FlexColumnWidth(2),
                            3: pw.FlexColumnWidth(2),
                          },
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Container(
                                  color: PdfColors.black,
                                  child: pw.Padding(
                                    padding: pw.EdgeInsets.all(3),
                                    child: pw.Text(
                                      'CHAIR PERSON / INSTRUCTOR',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  color: PdfColors.black,
                                  child: pw.Padding(
                                    padding: pw.EdgeInsets.all(3),
                                    child: pw.Text(
                                      'ID NO.',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  color: PdfColors.black,
                                  child: pw.Padding(
                                    padding: pw.EdgeInsets.all(3),
                                    child: pw.Text(
                                      'LOA NO.',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  color: PdfColors.black,
                                  child: pw.Padding(
                                    padding: pw.EdgeInsets.all(3),
                                    child: pw.Text(
                                      'SIGNATURE',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ...instructorTableRows,
                            // Data rows
                            // for (int c = 0; c < 3; c++)
                            //   pw.TableRow(
                            //     children: [
                            //       NormalTextFieldPdf(title: "03-11-22"),
                            //       NormalTextFieldPdf(title: "12-12-22"),
                            //       NormalTextFieldPdf(title: "03-11-22"),
                            //       NormalTextFieldPdf(title: "12-12-22"),
                            //     ],
                            //   ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Table(
                          border: pw.TableBorder.all(
                              width: 1, color: PdfColors.black),
                          columnWidths: {
                            0: pw.FlexColumnWidth(1), // Adjust as needed
                          },
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Container(
                                  height: 20,
                                  child: pw.Padding(
                                      padding: pw.EdgeInsets.all(3),
                                      child: pw.Center(
                                        child: pw.Text("REMARKS",
                                            style: pw.TextStyle(
                                                fontSize: 10,
                                                fontWeight:
                                                    pw.FontWeight.bold)),
                                      )),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Table(
                          border: pw.TableBorder.all(
                              width: 1, color: PdfColors.black),
                          columnWidths: {
                            0: pw.FlexColumnWidth(1), // Adjust as needed
                          },
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Container(
                                    height: 3 * 15,
                                    child: pw.SizedBox(
                                      height: 3 * 15,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Table(
                          border: pw.TableBorder.all(
                              width: 1, color: PdfColors.black),
                          columnWidths: {
                            0: pw.FlexColumnWidth(2),
                            1: pw.FlexColumnWidth(2),
                            2: pw.FlexColumnWidth(1),
                          },
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Container(
                                  color: PdfColors.black,
                                  child: pw.Padding(
                                    padding: pw.EdgeInsets.all(3),
                                    child: pw.Text(
                                      "ADMINISTRATOR'S NAME",
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  color: PdfColors.black,
                                  child: pw.Padding(
                                    padding: pw.EdgeInsets.all(3),
                                    child: pw.Text(
                                      'ID NO.',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  color: PdfColors.black,
                                  child: pw.Padding(
                                    padding: pw.EdgeInsets.all(3),
                                    child: pw.Text(
                                      'SIGNATURE',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#FFFFFF'),
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            ...administratorTableRows,
                            // Data rows
                          ],
                        ),
                      ),
                    ])));
          },
        ),
      );

      // Save the PDF to a file or perform other actions
      // ...
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/attandance57.pdf');

      await file.writeAsBytes(await pdf.save());

      final destinationDirectory = await getTemporaryDirectory();
      final destinationPath = '${destinationDirectory.path}/attandance57.pdf';

      await file.copy(destinationPath);

      file.delete();

      if(allAttendanceDetailModels.length > 0 ){
        await OpenFile.open(destinationPath);
      }

    } catch (e) {
      print('Error: $e');
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
}
