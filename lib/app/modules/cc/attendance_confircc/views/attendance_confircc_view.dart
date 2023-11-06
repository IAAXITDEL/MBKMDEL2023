import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../presentation/shared_components/formdatefield.dart';
import '../../../../../presentation/shared_components/formtextfield.dart';
import '../../../../../presentation/theme.dart';
import '../../../../../util/error_screen.dart';
import '../../../../../util/loading_screen.dart';
import '../../../../routes/app_pages.dart';
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
    var loaNoC = TextEditingController();

    int? trainingC = 0;

    var departmentC = TextEditingController();
    var trainingtypeC = TextEditingController();
    var roomC = TextEditingController();

    final GlobalKey<SfSignaturePadState> _signaturePadKey;
    _signaturePadKey = GlobalKey();
    void _clearSignature() {
      _signaturePadKey.currentState?.clear();
    };

    Future<void> confir() async {
      try {
        // Menunggu hingga saveSignature selesai
        Uint8List? signatureData =
            await _signaturePadKey.currentState!.toImage().then((image) async {
          ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          return byteData?.buffer.asUint8List();
        });

        if (signatureData != null) {
          await controller.saveSignature(signatureData);
          controller.confirattendance().then((status) async {
            // Menampilkan QuickAlert setelah saveSignature berhasil
            await QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: 'Confirmation Attendance Completed Successfully!',
            );

            // Navigasi ke halaman lain setelah menampilkan QuickAlert
            Get.offAllNamed(Routes.TRAININGTYPECC, arguments: {
              "id": controller.argumentTrainingType.value,
              "name": controller.argumentname.value
            });
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
                stream: controller.getCombinedAttendanceStream(),
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

                    subjectC.text = listAttendance[0]["subject"] ?? "N/A";
                    dateC.text = DateFormat('dd MMM yyyy').format(dateTime!) ?? "N/A";
                    departmentC.text = listAttendance[0]["department"] ?? "N/A";
                    vanueC.text = listAttendance[0]["vanue"] ?? "N/A";
                    trainingtypeC.text = listAttendance[0]["trainingType"] ?? "N/A";
                    roomC.text = listAttendance[0]["room"] ?? "N/A";
                    instructorC.text = listAttendance[0]["name"] ?? "N/A";
                    loaNoC.text = listAttendance[0]["loano"] ?? "";
                  } else {
                    // Handle the case where the list is empty or null
                    subjectC.text = "No Subject Data Available";
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RedTitleText(text: "ATTENDANCE LIST"),

                          // import pdf jika status sudah done
                          listAttendance[0]["status"] == "done"
                              ? StreamBuilder<int>(
                                  stream: controller.attendanceStream(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      int attendanceCount = snapshot.data ?? 0;
                                      return InkWell(
                                        onTap: () async {
                                          try {
                                            controller.isLoading.value = true;
                                            // Tampilkan LoadingScreen
                                            showDialog(
                                              context: context,
                                              // barrierDismissible:
                                              //     false, // Tidak bisa menutup dialog dengan tap di luar
                                              builder: (BuildContext context) {
                                                return LoadingScreen();
                                              },
                                            );

                                            await controller.savePdfFile(
                                                await controller
                                                    .attendancelist());
                                          } catch (e) {
                                            print('Error: $e');
                                          } finally {
                                            controller.isLoading.value = false;
                                            // Tutup dialog saat selesai
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.blue,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 3,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.picture_as_pdf,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Save PDF",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                )
                              : SizedBox()
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
                                readOnly: true),
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
                              textController: roomC,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FormTextField(text: "LOA NO.", textController: loaNoC),
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
                              listAttendance[0]["name"],
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
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            int attendanceCount = snapshot.data ?? 0;
                            return InkWell(
                              onTap: () {
                                if (controller.jumlah.value > 0) {
                                  Get.toNamed(Routes.LIST_ATTENDANCECC,
                                      arguments: {
                                        "id": controller.argumentid.value,
                                        "status": "confirmation"
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
                                    "Attendance",
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
                      SizedBox(
                        height: 10,
                      ),

                      // Jika status masih konfirmasi
                      ((listAttendance[0]["status"] == "confirmation") &&
                              (controller.role.value == "Pilot Administrator"))
                          ? Column(
                              children: [
                                //-------------------------ABSENT-----------------------
                                Row(
                                  children: [
                                    Text("Absent"),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: TsOneColor.secondaryContainer,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: controller.trainingStream(),
                                    builder: (context, snapshot) {
                                      List<String> userNames = [];

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }

                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }

                                      final users = snapshot.data?.docs.reversed
                                              .toList() ??
                                          [];

                                      userNames.addAll(users.map(
                                          (user) => user['NAME'] as String));

                                      int selectedUserId =
                                          0; // Default selected user ID

                                      return DropdownSearch<String>(
                                        mode: Mode.MENU,
                                        showSelectedItems: true,
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "Training",
                                          border: InputBorder.none,
                                        ),
                                        showSearchBox: true,
                                        searchFieldProps: TextFieldProps(
                                          cursorColor: TsOneColor.primary,
                                        ),
                                        items: userNames,
                                        onChanged: (selectedName) {
                                          // Find the corresponding user ID based on the selected name
                                          final selectedUser = users.firstWhere(
                                              (user) =>
                                                  user['NAME'] == selectedName);

                                          if (selectedUser != null) {
                                            final selectedUserIdValue =
                                                selectedUser['ID NO'] as int;
                                            selectedUserId =
                                                selectedUserIdValue;

                                            controller
                                                .addAbsentForm(selectedUserId);
                                          } else {
                                            selectedUserId = 0;
                                          }

                                          trainingC = selectedUserId;
                                          // Handle user selection here, including the selectedUserId
                                          print(
                                              'Selected name: $selectedName, Selected ID: $selectedUserId');
                                        },
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: controller.absentStream(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return LoadingScreen();
                                    }

                                    if (snapshot.hasError) {
                                      return ErrorScreen();
                                    }

                                    var listAttendance = snapshot.data!;
                                    if (listAttendance.isEmpty) {
                                      return SizedBox();
                                    }

                                    return ListView.builder(
                                        itemCount: listAttendance.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  spreadRadius: 2,
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ListTile(
                                                title: Text(
                                                  listAttendance[index]["name"],
                                                  style: tsOneTextTheme
                                                      .headlineMedium,
                                                ),
                                                // subtitle: Text(
                                                //   listAttendance[index]["name"],
                                                //   style: tsOneTextTheme.headlineMedium,
                                                // ),
                                                trailing: InkWell(
                                                  onTap: () {
                                                    controller.deleteAbsent(
                                                        listAttendance[index]
                                                            ["id"]);
                                                  },
                                                  child: Icon(
                                                    Icons.clear_sharp,
                                                    color: tsOneColorScheme
                                                        .primary,
                                                    size: 20,
                                                  ),
                                                )),
                                          );
                                        });
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Text("Signature"),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
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
                                    backgroundColor:
                                        Colors.grey.withOpacity(0.1),
                                  ),
                                ),
                                Obx(() {
                                  return controller.showText.value
                                      ? Row(
                                          children: [
                                            Text("*Please add your sign here!*",
                                                style: TextStyle(
                                                    color: Colors.red)),
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
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Row(
                                          children: [
                                            Text("Clear",
                                                style: TextStyle(
                                                    color: Colors.white)),
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      List<Path> paths = _signaturePadKey
                                          .currentState!
                                          .toPathList();
                                      if (paths.isNotEmpty) {
                                        controller.showText.value = false;
                                        controller.update();
                                        confir();
                                      } else {
                                        controller.showText.value = true;
                                        controller.update();
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
                            )
                          : Container()
                    ],
                  );
                }),
          ),
        ));
  }
}
