import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../../../../../data/users/user_preferences.dart';
import '../../../../../data/users/users.dart';
import '../../../../../di/locator.dart';
import '../../../../../presentation/shared_components/normaltextfieldpdf.dart';
import '../../../../../presentation/shared_components/textfieldpdf.dart';
import '../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../presentation/view_model/attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
        newValue ?? "Training";
  }

  final RxString argumentid = "".obs;
  final RxString argumentname = "".obs;
  final RxInt jumlah = 0.obs;
  final RxInt total = 0.obs;
  final RxBool showText = false.obs;
  final RxInt argumentTrainingType = 0.obs;

  final RxInt idInstructor = 0.obs;

  final RxString role = "".obs;
  final RxBool isLoading = false.obs;

  RxInt idTrainingType = 0.obs;
  Rx<DateTime> date = DateTime.now().obs;

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
    absentList();
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
      List<int?> instructorIds =
      attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data()).instructor).toList();

      final usersData = <Map<String, dynamic>>[];

      if (instructorIds.isNotEmpty) {
        final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: instructorIds).get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere(
              (user) => user['ID NO'] == attendanceModel.instructor,
              orElse: () => {});
          attendanceModel.name = user['NAME'];
          attendanceModel.loano = user['LOA NO'];
          idInstructor.value = attendanceModel.instructor!;

          Timestamp? timestamp = attendanceModel.date;
          date.value = timestamp!.toDate();
          idTrainingType.value = attendanceModel.idTrainingType!;

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

          List<int?> traineIds =
          attendanceQuery.docs.map((doc) => AttendanceDetailModel.fromJson(doc.data()).idtraining).toList();

          final usersData = <Map<String, dynamic>>[];

          if (traineIds.isNotEmpty) {
            final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: traineIds).get();
            usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
          }

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
        .update({
      'signaturePilotAdministratorUrl': imageUrl,
        });
  }

  //confir attendance oleh pilot administrator
  Future<void> confirattendance() async {
    userPreferences = getItLocator<UserPreferences>();
    CollectionReference attendance = _firestore.collection('attendance');

    QuerySnapshot querySnapshot = await _firestore.collection('trainingType')
        .where('id', isEqualTo: idTrainingType.value)
        .get();

    var lastDayOfMonth;
    var dateFormat = DateFormat('dd-MM-yyyy');

    if (querySnapshot.docs.isNotEmpty) {
      for (DocumentSnapshot document in querySnapshot.docs) {
        var dates = date.value;


        var recurrent = (document.data() as Map<String, dynamic>)['recurrent'];
        var nextMonths;

        if(recurrent == "NONE"){
          nextMonths = DateTime(dates.year, dates.month, dates.day);
        }else if(recurrent == "6 MONTH CALENDER"){
           nextMonths = DateTime(dates.year, dates.month + 6, dates.day);
        }else if(recurrent == "12 MONTH CALENDER"){
           nextMonths = DateTime(dates.year, dates.month + 12, dates.day);
        }else if(recurrent == "24 MONTH CALENDER"){
           nextMonths = DateTime(dates.year, dates.month + 24, dates.day);
        }else if(recurrent == "36 MONTH CALENDER"){
          nextMonths = DateTime(dates.year, dates.month + 36, dates.day);
        }else if(recurrent == "LAST MONTH ON THE NEXT YEAR OF THE PREVIOUS TRAINING"){
          nextMonths = DateTime(dates.year + 1, 12, 31);
        }

        // Handling jika bulan melebihi 12 dan 24
        if (nextMonths.month > 12) {
          nextMonths = DateTime(nextMonths.year + (nextMonths.month ~/ 12), nextMonths.month % 12, nextMonths.day);
        }

        // Menghitung tanggal akhir dari bulan
        lastDayOfMonth = DateTime(nextMonths.year, nextMonths.month + 1, 0);
      }
    } else {
      print('No documents found');
    }

    await attendance.doc(argumentid.value.toString()).update({
      "status": "done",
      "valid_to" : lastDayOfMonth,
      "expiry" : "VALID",
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

    try {
      await _firestore.collection("absent").doc("$idtraining-${argumentid.value}").set({
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
      List<int?> traineeIds =
      attendanceQuery.docs.map((doc) => AttendanceDetailModel.fromJson(doc.data()).idtraining).toList();


      final usersData = <Map<String, dynamic>>[];

      if (traineeIds.isNotEmpty) {
        final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: traineeIds).get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

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


  Future<void> absentList() async {
    final absentQuery = await _firestore
        .collection('absent')
        .where("idattendance", isEqualTo: argumentid.value)
        .get();

    total.value = absentQuery.docs.length;
    print("fgcfg");
    print(idAttendance.value);
    print(total.value);
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
      List<int?> instructorIds =
      attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data()).instructor).toList();

      final usersData = <Map<String, dynamic>>[];

      if (instructorIds.isNotEmpty) {
        final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: instructorIds).get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {});
          attendanceModel.name = user['NAME'];
          attendanceModel.loano = user['LOA NO'];
          return attendanceModel.toJson();
        }),
      );
      return attendanceData;
    });
  }

  // List untuk Administrator
  Stream<List<Map<String, dynamic>>> administratorStream() {
    return _firestore.collection('attendance').where("id", isEqualTo: argumentid.value).snapshots().asyncMap((attendanceQuery) async {
      List<int?> adminIds =
      attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data()).idPilotAdministrator).toList();

      final usersData = <Map<String, dynamic>>[];

      if (adminIds.isNotEmpty) {
        final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: adminIds).get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

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
  Future<Uint8List> attendancelist() async {
    try {
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
         await getCombinedAttendanceStream();
      List<Map<String, dynamic>> attendanceDataList =
          await attendanceStream.first;
      List<AttendanceModel> attendanceModels = attendanceDataList.map((data) {
        return AttendanceModel.fromJson(data);
      }).toList();

      // Memanggil Data Attendance Detail (Daftar Training)
      Stream<List<Map<String, dynamic>>> attendanceDetailStream = await getCombinedAttendanceDetailStream();
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
      Stream<List<Map<String, dynamic>>> instructorSt = await instructorStream();
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
      Stream<List<Map<String, dynamic>>> administratorSt = await administratorStream();
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
       // var images = await loadImageFromNetwork(allAttendanceDetailModels[e].signature_url ?? "");

        final Uint8List imageBytes = await _getImageBytes(allAttendanceDetailModels[e].signature_url ?? "");
        // final Uint8List resizedImageBytes = await resizeImage(imageBytes, 50, 50);

        pw.MemoryImage images = pw.MemoryImage(imageBytes);
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

      //menampilkan data instructor
      for (int f = 0; f < instructorModels.length; f++) {
        //var imagesicc = await loadImageFromNetwork(instructorModels[f].signatureIccUrl ?? "");

        final Uint8List imageBytesInstructor = await _getImageBytes(instructorModels[f].signatureIccUrl ?? "");
       // final Uint8List resizedImageBytesInstructor = await resizeImage(imageBytesInstructor, 50, 50); // Adjust dimensions as needed

        pw.MemoryImage imagesicc = pw.MemoryImage(imageBytesInstructor);
        instructorTableRows.add(
          pw.TableRow(
            children: [
              NormalTextFieldPdf(title: "${instructorModels[f].name}"),
              NormalTextFieldPdf(title: "${instructorModels[f].instructor}"),
              NormalTextFieldPdf(title: "${instructorModels[f].loano}"),
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

      //menampilkan data pilot administrator
      for (int g = 0; g < administratorModels.length; g++) {
       // var imagesipa = await loadImageFromNetwork(administratorModels[g].signaturePilotAdministratorUrl ?? "");

        final Uint8List imageBytesAdministrator = await _getImageBytes(administratorModels[g].signaturePilotAdministratorUrl ?? "");
     //   final Uint8List resizedImageBytesAdministrator = await resizeImage(imageBytesAdministrator, 50, 50); // Adjust dimensions as needed

        pw.MemoryImage imagesipa = pw.MemoryImage(imageBytesAdministrator);
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
                        Timestamp? timestamp = attendanceModel.date;
                        DateTime? dateTime = timestamp?.toDate();
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
                                          title: DateFormat('dd MMMM yyyy').format(dateTime!) ?? ''),
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

      return pdf.save();
    } catch (e) {
      print("Error generating PDF: $e");
      return Future.value();
    }
  }

  // Future<void> savePdfFile(Uint8List byteList) async {
  //   isLoading.value = true;
  //   final output = await getTemporaryDirectory();
  //   var filePath = "${output.path}/${argumentid.value}.pdf";
  //   final file = File(filePath);
  //   print("step 1");
  //   await file.writeAsBytes(byteList);
  //   print("step 2");
  //   await OpenFile.open(filePath);
  //   print("stetep 3");
  //   isLoading.value = false;
  // }

  Future<void> savePdfFile(Uint8List byteList) async {
    Directory('/storage/emulated/0/Download/Attendance List/').createSync();
    final output = await getTemporaryDirectory();
    var filePath = "/storage/emulated/0/Download/Attendance List/${argumentid.value}.pdf";
    final file = File(filePath);
    print("step 1");
    await file.writeAsBytes(byteList);
    print("step 2");

    final filePaths = "${output.path}/${argumentid.value}.pdf";
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
