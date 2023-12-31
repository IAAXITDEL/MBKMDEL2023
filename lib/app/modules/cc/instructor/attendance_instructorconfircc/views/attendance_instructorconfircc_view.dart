import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;
import '../../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../../presentation/shared_components/formdatefield.dart';
import '../../../../../../presentation/shared_components/formtextfield.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/attendance_instructorconfircc_controller.dart';

class AttendanceInstructorconfirccView
    extends GetView<AttendanceInstructorconfirccController> {
  AttendanceInstructorconfirccView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var subjectC = TextEditingController();
    var venueC = TextEditingController();
    var dateC = TextEditingController();
    var instructorC = TextEditingController();
    var loaNoC = TextEditingController();

    var departmentC = TextEditingController();
    var trainingtypeC = TextEditingController();
    var roomC = TextEditingController();

    var remarksC = TextEditingController();

    final GlobalKey<SfSignaturePadState> _signaturePadKey;
    _signaturePadKey = GlobalKey();
    void _clearSignature() {
      _signaturePadKey.currentState?.clear();
    }

    Future<void> saveSignature() async {
      // Mengambil objek ui.Image dari SfSignaturePad
      ui.Image image = await _signaturePadKey.currentState!.toImage();

      // Mengonversi ui.Image menjadi data gambar
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? uint8List = byteData?.buffer.asUint8List();

      // Membuat referensi untuk Firebase Storage
      final Reference storageReference = FirebaseStorage.instance.ref().child(
          'signature-cc/${controller.argumentid.value}-icc-${DateTime.now()}.png');

      // Mengunggah gambar ke Firebase Storage
      await storageReference.putData(uint8List!);

      // Mendapatkan URL gambar yang diunggah
      final String imageUrl = await storageReference.getDownloadURL();

      // Menyimpan URL gambar di database Firestore
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(controller.argumentid.value.toString())
          .update({'signatureIccUrl': imageUrl});
    }

    Future<void> confir( String loano, String remarks) async {
      try {
        controller
            .confirattendance( loano, remarks)
            .then((status) async {
          // Menunggu hingga saveSignature selesai
          await saveSignature();

          // Menampilkan QuickAlert setelah saveSignature berhasil
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Confirmation Attendance Completed Successfully!',
          );

          // Navigasi ke halaman lain setelah menampilkan QuickAlert
          Get.offAllNamed(Routes.TRAINING_INSTRUCTORCC, arguments: {
            "id": controller.argumentTrainingType.value,
            "name": controller.argumentname.value
          });
        });
      } catch (error) {
        // Penanganan kesalahan jika saveSignature gagal
        print('Error in saveSignature: $error');

        // Menampilkan QuickAlert untuk kesalahan
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'An error occurred while saving the signature.',
        );
      }
    }

    return Scaffold(
        appBar: AppBar(
          title:  RedTitleText(text: "ATTENDANCE LIST"),
          iconTheme: IconThemeData(color: Colors.black),
          // backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: controller.getCombinedAttendanceStream(
                        controller.argumentid.value.toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingScreen(); // Placeholder while loading
                      }

                      if (snapshot.hasError) {
                        return ErrorScreen();
                      }

                      var listAttendance = snapshot.data!;
                      if (listAttendance != null && listAttendance.isNotEmpty) {
                        Timestamp? timestamp = listAttendance[0]["date"];
                        DateTime? dateTime = timestamp?.toDate();

                        subjectC.text = listAttendance[0]["subject"];
                        dateC.text = DateFormat('dd MMM yyyy').format(dateTime!);
                        venueC.text = listAttendance[0]["venue"];
                        instructorC.text = listAttendance[0]["name"];
                        loaNoC.text = listAttendance[0]["loano"] ?? "" ;
                        roomC.text = listAttendance[0]["room"];
                        departmentC.text = listAttendance[0]["department"];
                        trainingtypeC.text = listAttendance[0]["trainingType"];
                        controller.argumentname.value =
                            listAttendance[0]["subject"];
                      } else {
                        // Handle the case where the list is empty or null
                        subjectC.text = "No Subject Data Available";
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Text("REDUCED VERTICAL SEPARATION MINIMA (RVSM)"),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.3)
                                  ),
                                  child: FormTextField(
                                      text: "Subject",
                                      textController: subjectC,
                                      readOnly: true),
                                )
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3)
                                    ),
                                  child: FormDateField(
                                      text: "Date",
                                      textController: dateC,
                                      readOnly: true),
                                )
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.3)
                                  ),
                                  child: FormTextField(
                                      text: "Department",
                                      textController: departmentC,
                                      readOnly: true),
                                ),
                              ),

                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.3)
                                  ),
                                  child: FormTextField(
                                      text: "Venue",
                                      textController: venueC,
                                      readOnly: true),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.3)
                                  ),
                                  child: FormTextField(
                                      text: "Training Type",
                                      textController: trainingtypeC,
                                      readOnly: true),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.3)
                                  ),
                                  child: FormTextField(
                                      text: "Room",
                                      textController: roomC,
                                      readOnly: true),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 20,
                          ),
                          FormTextField(
                              text: "LOA NO.",
                              textController: loaNoC),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: TsOneColor.secondaryContainer,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                title: Text(
                                  "Chair Person/ Instructor",
                                  style: tsOneTextTheme.labelSmall,
                                ),
                                subtitle: Text(
                                  instructorC.text,
                                  style: tsOneTextTheme.headlineMedium,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          StreamBuilder<int>(
                            stream: controller.attendanceStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator(); // Tampilkan indikator loading jika masih dalam proses pengambilan data
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                int attendanceCount = snapshot.data ?? 0;
                                // Lakukan sesuatu dengan nilai attendanceCount, misalnya tampilkan di UI
                                return   InkWell(
                                  onTap: () {
                                    if (controller.jumlah.value > 0) {
                                      Get.toNamed(Routes.LIST_ATTENDANCECC,
                                          arguments: {
                                            "id": controller.argumentid.value,
                                            "status": "pending"
                                          });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: TsOneColor.secondaryContainer,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: ListTile(
                                      title: Text(
                                        "Present Trainees",
                                        style: tsOneTextTheme.labelSmall,
                                      ),
                                      subtitle: Text(
                                        "${attendanceCount} person",
                                        style: tsOneTextTheme.headlineMedium,
                                      ),
                                      trailing: Icon(Icons.navigate_next),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          StreamBuilder<int>(
                            stream: controller.cekScoringStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                int attendanceCount = snapshot.data ?? 0;
                                if(attendanceCount > 0){
                                  controller.cekScoring.value = true;
                                  controller.update();
                                }else{
                                  controller.cekScoring.value = false;
                                  controller.update();
                                }
                                return attendanceCount > 0 ? Row(
                                  children: [
                                    Text("*Please do Scoring!*",
                                        style: TextStyle(color: Colors.red, fontSize: 12)),
                                  ],
                                )
                                    : SizedBox();
                              }
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text("Meeting or Training"),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Obx(
                                    () => Radio<String>(
                                      value: "Meeting",
                                      groupValue:
                                          controller.selectedMeeting.value,
                                      onChanged: (String? newValue) {
                                        controller.selectMeeting(newValue);
                                      },
                                    ),
                                  ),
                                  Text(
                                    "Meeting",
                                    style: tsOneTextTheme.labelSmall,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Obx(
                                    () => Radio<String>(
                                      value: "Training",
                                      groupValue:
                                          controller.selectedMeeting.value,
                                      onChanged: (String? newValue) {
                                        controller.selectMeeting(newValue);
                                      },
                                    ),
                                  ),
                                  Text(
                                    "Training",
                                    style: tsOneTextTheme.labelSmall,
                                  ),
                                ],
                              )
                            ],
                          ),

                          Text("Class Password"),

                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SingleChildScrollView(
                                      child: Container(
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0),
                                          ),
                                          color: Theme.of(context).cardColor,
                                        ),
                                        padding: EdgeInsets.only(
                                            top: 20, left: 20, right: 20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'QR Code',
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30),
                                              child: Text(
                                                'Provide training for those taking classes to take attendance',
                                                style:
                                                    tsOneTextTheme.labelMedium,
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            QrImageView(
                                              data: listAttendance[0]
                                                  ["keyAttendance"],
                                              version: QrVersions.auto,
                                              size: 250,
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              'Scan this QR code',
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                            SizedBox(height: 50),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.qr_code,
                                  size: 25,
                                ),
                                title: Text(
                                  "Open QR Code",
                                  style: tsOneTextTheme.headlineMedium,
                                ),
                                subtitle: RedTitleText(
                                  text: listAttendance[0]["keyAttendance"] ??
                                      "N/A",
                                  size: 16,
                                ),
                                trailing: const Icon(Icons.navigate_next),
                              ),
                            ),
                          ),
                          //--------------------------- ATTANDANCE --------------------
                          SizedBox(
                            height: 10,
                          ),
                          Text("Remarks"),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: tsOneColorScheme
                                        .secondaryContainer),
                                borderRadius:
                                BorderRadius.circular(5)),
                            child: TextFormField(
                              controller: remarksC,
                              maxLines: 4,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration.collapsed(
                                  hintText: "Add remarks"),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Signature"),
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: TsOneColor.secondaryContainer,
                                width: 1,
                              ),
                            ),
                            child: SfSignaturePad(
                              key: _signaturePadKey,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          Obx(() {
                            return controller.showText.value
                                ? Row(
                                    children: [
                                      Text("*Please add your sign here!*",
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  )
                                : SizedBox();
                          }),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  _clearSignature();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: TsOneColor.primary,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Row(
                                    children: [
                                      Text("Clear",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.clear_outlined,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          //-------------------------SUBMIT-----------------------
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                List<Path> paths =
                                    _signaturePadKey.currentState!.toPathList();
                                if (paths.isNotEmpty) {
                                  controller.ceksign.value = true;
                                  controller.showText.value = false;
                                  controller.update();
                                } else {
                                  controller.showText.value = true;
                                  controller.update();
                                }

                                if (_formKey.currentState != null &&
                                    _formKey.currentState!.validate() &&
                                    controller.ceksign.value == true &&
                                    controller.cekScoring.value == false) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return FutureBuilder<void>(
                                          future: confir(loaNoC.text, remarksC.text),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<void> snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return LoadingScreen();
                                            }

                                            if (snapshot.hasError) {
                                              // Handle error if needed
                                              return ErrorScreen();
                                            } else {
                                              return Container();
                                            }
                                          },
                                        );
                                      });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: TsOneColor.greenColor,
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text(
                                'Submit',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              )),
        ));
  }
}
