import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../presentation/theme.dart';
import '../../../../util/empty_screen.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../controllers/attendance_pilotcc_controller.dart';
import 'dart:ui' as ui;
class AttendancePilotccView extends GetView<AttendancePilotccController> {
  const AttendancePilotccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final GlobalKey<SfSignaturePadState> _signaturePadKey;
    _signaturePadKey = GlobalKey();

    void _clearSignature() {
      _signaturePadKey.currentState?.clear();
    }

    void saveSignature( _signaturePadKey) {
      controller.saveSignature( _signaturePadKey).then((status) async {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Attendance Completed Successfully!',
        );

        // Get.offAllNamed(Routes.TRAININGTYPECC, arguments: {
        //   "id" : controller.argumentid.value,
        //   "name" : controller.argumentname.value
        // });

        Get.back();
      });
    }


    return Scaffold(
      appBar: AppBar(
        title: const RedTitleText(text: "TRAINING",),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: TsOneColor.surface,
                  ),
                  child:  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: controller.getCombinedAttendanceStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingScreen(); // Placeholder while loading
                      }

                      if (snapshot.hasError) {
                        return ErrorScreen();
                      }

                      var listAttendance= snapshot.data!;
                      if(listAttendance.isEmpty){
                        return EmptyScreen();
                      }

                      return Column(
                        children: [
                          //SUBJECT
                           Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:  Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Subject")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["subject"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //DEPARTEMENT
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:  Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Department")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["department"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //TRAINING TYPE
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:  Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Training Type")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["trainingType"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //DATE
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:   Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Date")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["date"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //VANUE
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:  Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Vanue")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["vanue"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //ROOM
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Room")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["room"] ?? "N/A")),
                              ],
                            ),
                          ),

                          //INSTRUCTOR
                           Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child:   Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text("Instructor")),
                                Expanded(
                                    flex: 1,
                                    child: Text(":")),
                                Expanded(
                                    flex: 4,
                                    child: Text(listAttendance[0]["name"] ?? "N/A")),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // SIGNATURE
                const SizedBox(
                  height: 10,
                ),
                Row(children: [Text("Signature",),],),
                const SizedBox(
                  height: 5,
                ),
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
                      //   confir(departmentC.text, trainingtypeC.text, roomC.text);
                      saveSignature( _signaturePadKey);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: TsOneColor.greenColor,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Attendance', style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
