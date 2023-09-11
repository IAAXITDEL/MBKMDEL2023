import 'dart:typed_data';

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
  AttendanceConfirccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    var subjectC = TextEditingController();
    var vanueC = TextEditingController();
    var dateC = TextEditingController();
    var instructorC = TextEditingController();

    var departmentC = TextEditingController();
    var trainingtypeC = TextEditingController();
    var roomC = TextEditingController();

    final GlobalKey<SfSignaturePadState> _signaturePadKey;
    _signaturePadKey = GlobalKey();
    void _clearSignature() {
      _signaturePadKey.currentState?.clear();
    }
    ;


    Future<void> confir() async {
      try {
        controller.confirattendance().then((status) async {
          // Menunggu hingga saveSignature selesai
          Uint8List? signatureData = await _signaturePadKey.currentState!.toImage().then((image) async {
            ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            return byteData?.buffer.asUint8List();
          });

          if (signatureData != null) {
            await controller.saveSignature(signatureData);

            // Menampilkan QuickAlert setelah saveSignature berhasil
            await QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: 'Confirmation Attendance Completed Successfully!',
            );

            // Navigasi ke halaman lain setelah menampilkan QuickAlert
            Get.offAllNamed(Routes.TRAININGTYPECC, arguments: {
              "id" : controller.argumentid.value,
              "name" : controller.argumentname.value
            });
          } else {
            // Handle jika signatureData null
            print('Error: Signature data is null');
            // Menampilkan QuickAlert untuk kesalahan
            await QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              text: 'An error occurred while saving the signature.',
            );
          }
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
          title: Text('Back', style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(color: Colors.black),
          // backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: controller
                    .getCombinedAttendanceStream(controller.argumentid.value.toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen(); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return ErrorScreen();
                  }

                  var listAttendance = snapshot.data!;


                  if (listAttendance != null && listAttendance.isNotEmpty) {
                    subjectC.text = listAttendance[0]["subject"];
                    dateC.text = listAttendance[0]["date"];
                    departmentC.text = listAttendance[0]["department"];
                    vanueC.text = listAttendance[0]["vanue"];
                    trainingtypeC.text = listAttendance[0]["trainingType"];
                    roomC.text = listAttendance[0]["room"];
                    instructorC.text = listAttendance[0]["name"];
                  } else {
                    // Handle the case where the list is empty or null
                    subjectC.text = "No Subject Data Available";
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RedTitleText(text: "ATTENDANCE LIST"),
                      Text("REDUCED VERTICAL SEPARATION MINIMA (RVSM)"),
                      SizedBox(
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
                          SizedBox(
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
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FormTextField(
                              text: "Department",
                              textController: departmentC,
                                readOnly: true
                            ),
                          ),
                          SizedBox(
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
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FormTextField(
                                text: "Training Type",
                                textController: trainingtypeC,
                                readOnly: true),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: FormTextField(
                              text: "Room",
                              textController: roomC,),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: (){Get.toNamed(Routes.LIST_ATTENDANCECC,arguments: {
                          "id" : controller.argumentid.value,
                        });},
                        child:  Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: TsOneColor.secondaryContainer,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: ListTile(
                            title: Text(
                              "Chair Person/ Instructor",
                              style: tsOneTextTheme.labelSmall,
                            ),
                            subtitle: Text(
                              listAttendance[0]["name"],
                              style: tsOneTextTheme.headlineMedium,
                            ),
                            trailing: Icon(Icons.navigate_next),
                          ),

                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: (){Get.toNamed(Routes.LIST_ATTENDANCECC,arguments: {
                        "id" : controller.argumentid.value,
                        });},
                        child:  Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: TsOneColor.secondaryContainer,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: ListTile(
                            title: Text(
                              "Attendance",
                              style: tsOneTextTheme.labelSmall,
                            ),
                            subtitle: Text(
                              "${controller.jumlah.value.toString()} person",
                              style: tsOneTextTheme.headlineMedium,
                            ),
                            trailing: Icon(Icons.navigate_next),
                          ),

                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text("Attendance"),
                      Row(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Obx(
                                    () => Radio<String>(
                                  value: listAttendance[0]["attendanceType"],
                                  groupValue: controller.selectedMeeting.value,
                                  onChanged: (String? newValue) {
                                    controller.selectMeeting(newValue);
                                  },
                                ),
                              ),
                              Text(
                                listAttendance[0]["attendanceType"],
                                style: tsOneTextTheme.labelSmall,
                              ),
                            ],
                          )

                        ],
                      ),

                      Text("Class Password"),
                      RedTitleText(
                        text: listAttendance[0]["keyAttendance"],
                        size: 16,
                      ),


                      // Jika status masih konfirmasi
                      listAttendance[0]["status"] == "confirmation" ?
                     Column(
                       children: [
                         //--------------------------- ATTANDANCE --------------------
                         SizedBox(
                           height: 10,
                         ),
                         Row(children: [
                           Text("Signature"),
                         ],),
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
                                 BoxDecoration(color: TsOneColor.primary),
                                 child: Row(
                                   children: [
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
                               confir();
                             },
                             style: ElevatedButton.styleFrom(
                               primary: TsOneColor.greenColor,
                               minimumSize: Size(double.infinity, 50),
                             ),
                             child: Text('Submit', style: TextStyle(color: Colors.white),),
                           ),
                         ),
                       ],
                     ) : Container()
                    ],
                  );
                }),
          ),
        ));
  }
}
