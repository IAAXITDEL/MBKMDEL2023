
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/shared_components/formdatefield.dart';
import '../../../../presentation/shared_components/formtextfield.dart';
import '../../../../presentation/theme.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../routes/app_pages.dart';
import '../controllers/attendance_confircc_controller.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;

class AttendanceConfirccView extends GetView<AttendanceConfirccController> {
  const AttendanceConfirccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    var subjectC = TextEditingController();
    var vanueC = TextEditingController();
    var dateC = TextEditingController();
    var instructorC = TextEditingController();

    var departementC = TextEditingController();
    var trainingtypeC = TextEditingController();
    var roomC = TextEditingController();

    final GlobalKey<SfSignaturePadState> signaturePadKey;
    signaturePadKey = GlobalKey();
    void _clearSignature() {
      signaturePadKey.currentState?.clear();
    }


    Future<void> saveSignature() async {
      // Mengambil objek ui.Image dari SfSignaturePad
      ui.Image image = await signaturePadKey.currentState!.toImage();

      // Mengonversi ui.Image menjadi data gambar
      ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png);
      Uint8List? uint8List = byteData?.buffer.asUint8List();

      // Membuat referensi untuk Firebase Storage
      final Reference storageReference = FirebaseStorage.instance.ref().child(
          'signature-cc/${controller.argumentid.value}-${DateTime.now()}.png');

      // Mengunggah gambar ke Firebase Storage
      await storageReference.putData(uint8List!);

      // Mendapatkan URL gambar yang diunggah
      final String imageUrl = await storageReference.getDownloadURL();

      // Menyimpan URL gambar di database Firestore
      await FirebaseFirestore.instance.collection('attendance').doc(controller.argumentid.value.toString()).update({
        'signature-icc-url': imageUrl
      });
    }

    Future<void> confir(String departement, String trainingType, String room) async {
      try {
        controller.confirattendance(departement, trainingType, room).then((status) async {
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
          "id" : controller.argumentid.value,
          "name" : controller.argumentname.value
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
          title: const Text('Back', style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
          // backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: controller
                    .getCombinedAttendanceStream(controller.argumentid.value.toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingScreen(); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return const ErrorScreen();
                  }

                  var listAttendance = snapshot.data!;
                  print(listAttendance);
                  if (listAttendance.isNotEmpty) {
                    subjectC.text = listAttendance[0]["subject"];
                    dateC.text = listAttendance[0]["date"];
                    vanueC.text = listAttendance[0]["vanue"];
                    instructorC.text = listAttendance[0]["name"];
                  } else {
                    // Handle the case where the list is empty or null
                    subjectC.text = "No Subject Data Available";
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const RedTitleText(text: "ATTENDANCE LIST"),
                      const Text("REDUCED VERTICAL SEPARATION MINIMA (RVSM)"),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FormTextField(
                                text: "Subject",
                                textController: subjectC,
                                readOnly: true),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: FormDateField(
                                text: "Date",
                                textController: dateC,
                                readOnly: true),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FormTextField(
                                text: "Departement",
                                textController: departementC,),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: FormTextField(
                                text: "Vanue",
                                textController: vanueC,
                                readOnly: true),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FormTextField(
                                text: "Training Type",
                                textController: trainingtypeC),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: FormTextField(
                                text: "Room",
                                textController: roomC,),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FormTextField(
                          text: "Chair Person/ Instructor ",
                          textController: instructorC,
                          readOnly: true),
                      const SizedBox(
                        height: 20,
                      ),
                      FormTextField(
                          text: "Attandance",
                          textController: subjectC,
                          readOnly: true),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text("Attendance"),
                      Row(
                        children: [
                          Row(
                            children: [
                              Obx(
                                    () => Radio<String>(
                                  value: "Meeting",
                                  groupValue: controller.selectedMeeting.value,
                                  onChanged: (String? newValue) {
                                    controller.selectMeeting(newValue);
                                  },
                                ),
                              ),
                              Text(
                                "Meeting",
                                style: tsOneTextTheme.labelSmall,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Obx(
                                    () => Radio<String>(
                                  value: "Training",
                                  groupValue: controller.selectedMeeting.value,
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

                      const Text("Class Password"),
                      RedTitleText(
                        text: listAttendance[0]["keyAttendance"],
                        size: 16,
                      ),

                      //--------------------------- ATTANDANCE --------------------
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Signature"),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: TsOneColor.secondaryContainer,
                            width: 1,
                          ),
                        ),
                        child: SfSignaturePad(
                          key: signaturePadKey,
                          backgroundColor: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                      InkWell(
                        child: const Text("Save As Image"),
                        onTap: () async {
                          // Mengambil objek ui.Image dari SfSignaturePad
                          ui.Image image = await signaturePadKey.currentState!.toImage();

                          // Mengonversi ui.Image menjadi data gambar
                          ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                          Uint8List? uint8List = byteData?.buffer.asUint8List();

                          Future<bool> isSignatureEmpty(Uint8List signatureImageBytes) async {
                            // Membaca gambar referensi tanda tangan kosong
                            final ByteData emptySignatureByteData = await rootBundle.load('assets/images/empty_signature.png');
                            final Uint8List emptySignatureBytes = emptySignatureByteData.buffer.asUint8List();

                            // Membandingkan gambar hasil dengan gambar referensi
                            return const ListEquality().equals(signatureImageBytes, emptySignatureBytes);
                          }

                          // Memeriksa apakah gambar kosong
                          bool isEmpty = await isSignatureEmpty(uint8List!);

                          if (isEmpty) {
                            print("Tanda tangan kosong.");
                          } else {
                            print("Tanda tangan memiliki coretan.");
                          }

                          // Menampilkan gambar menggunakan widget Image.memory
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: const Text("Signature Image"),
                                ),
                                body: Center(
                                  child: Image.memory(uint8List),
                                ),
                              ),
                            ),
                          );
                        },
                      ),


                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _clearSignature,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  TsOneColor.primary),
                            ),
                            child: Container(
                              decoration:
                                  const BoxDecoration(color: TsOneColor.primary),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.clear_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text("Clear", style: TextStyle(color: Colors.white))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      //-------------------------SUBMIT-----------------------
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            confir(departementC.text, trainingtypeC.text, roomC.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TsOneColor.greenColor,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Submit', style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ));
  }
}
