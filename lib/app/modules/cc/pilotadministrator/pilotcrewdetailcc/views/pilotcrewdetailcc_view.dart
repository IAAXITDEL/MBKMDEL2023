import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../routes/app_pages.dart';
import '../../../profilecc/controllers/profilecc_controller.dart';
import '../../../profilecc/controllers/trainingCardsPdf.dart';
import '../controllers/pilotcrewdetailcc_controller.dart';

class PilotcrewdetailccView extends GetView<PilotcrewdetailccController> {
  const PilotcrewdetailccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        RedTitleText(text: "PROFILE"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: TsOneColor.surface,
                ),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.profileList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingScreen(); // Placeholder while loading
                    }

                    if (snapshot.hasError) {
                      return ErrorScreen();
                    }

                    var listAttendance = snapshot.data!.docs;
                    var documentData = listAttendance[0].data();
                    print(documentData);
                    controller.idTraining.value = documentData["ID NO"];
                    return Column(
                      children: [
                        AvatarGlow(
                          endRadius: 110,
                          glowColor: Colors.black,
                          duration: Duration(seconds: 2),
                          child: Container(
                              margin: EdgeInsets.all(15),
                              width: 175,
                              height: 175,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(200),
                                  child: documentData["PHOTOURL"]  == null ?  Image.asset(
                                    "assets/images/placeholder_person.png",
                                    fit: BoxFit.fitWidth,
                                  ) : Image.network("${documentData["PHOTOURL"]}", fit: BoxFit.cover),)),
                        ),
                        BlackTitleText(
                          text: documentData["NAME"] ,
                        ),
                        Text(
                          documentData["ID NO"].toString(),
                          style: TextStyle(color: tsOneColorScheme.secondaryContainer),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("STATUS")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(flex: 6, child:
                                  Container(
                                    height: 30.0,
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:  documentData["STATUS"] == "VALID" ?  Colors.green : TsOneColor.redColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),

                                    child : Text(
                                      documentData["STATUS"],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),

                                    ),
                                  )
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("RANK")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(flex: 6, child: Text(documentData["RANK"] ?? "N/A")),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("Email")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(
                                      flex: 6, child: Text(documentData["EMAIL"] ?? "N/A")),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("HUB")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(
                                      flex: 6, child: Text( documentData["HUB"] ?? "N/A")),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("LICENSE NO")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(
                                      flex: 6, child: Text( documentData["LICENSE NO."] is Timestamp
                                      ? DateFormat('dd MMM yyyy').format((documentData["LICENSE NO."] as Timestamp).toDate())
                                      : documentData["LICENSE NO."] ?? "N/A")),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("ID NO")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(
                                      flex: 6, child: Text( documentData["ID NO"].toString())),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("TRAINING", style: tsOneTextTheme.headlineLarge,),
                  Obx(() {
                    return  controller.isReady.value && controller.isCPTS.value == false ?
                    InkWell(
                      onTap: () async {
                        try {
                          // Tampilkan LoadingScreen
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return LoadingScreen();
                            },
                          );

                          // await Get.find<ProfileccController>().savePdfFile(
                          //     await Get.find<ProfileccController>()
                          //         .getPDFTrainingCard(controller.argumentid.value));
                          String exportedPDFPath = await eksportPDF(controller.argumentid.value);
                          if (exportedPDFPath.isNotEmpty) {
                            await openExportedPDF(exportedPDFPath);
                          }
                        } catch (e) {
                          print('Error: $e');
                        } finally {
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
                            ),],),) ,
                    ):  SizedBox();
                  })
                ],
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.trainingStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen(); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return ErrorScreen();
                  }

                  var listTraining = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: listTraining.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          print(controller.idTraining.value);
                          Get.toNamed(Routes.PILOTTRAININGHISTORYCC, arguments: {
                            "idTrainingType" : listTraining[index]["id"],
                            "idTraining" : controller.idTraining.value,
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
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
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(100),
                                child: StreamBuilder<String>(
                                  stream: Get.find<ProfileccController>().cekValidationTraining(listTraining[index]['id'], controller.idTraining.value),
                                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      // Menampilkan sesuatu saat data sedang diambil
                                      return Text("Loading...");
                                    } else if (snapshot.hasError) {
                                      // Menampilkan pesan error jika terjadi kesalahan
                                      return Text("Error: ${snapshot.error}");
                                    } else {
                                      // Menampilkan hasil dari Future ketika sudah tersedia
                                      return Image.asset(
                                        snapshot.data == "VALID" ?
                                        "assets/images/Green_check.png" : "assets/images/Red_check.png" ,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                  },
                                ),),
                            ),
                            title: Text(listTraining[index]["training"], maxLines: 1, style: tsOneTextTheme.labelMedium,),
                            subtitle: StreamBuilder<String>(
                              stream: Get.find<ProfileccController>().cekValidationTraining(listTraining[index]['id'], controller.idTraining.value),
                              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // Menampilkan sesuatu saat data sedang diambil
                                  return Text("Loading...");
                                } else if (snapshot.hasError) {
                                  // Menampilkan pesan error jika terjadi kesalahan
                                  return Text("Error: ${snapshot.error}");
                                } else {
                                  // Menampilkan hasil dari Future ketika sudah tersedia
                                  return Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: TsOneColor.secondaryContainer.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(snapshot.data ?? "NOT VALID", style: TextStyle(fontSize: 11)),
                                      )
                                    ],
                                  );
                                }
                              },
                            ),
                            trailing: const Icon(Icons.navigate_next),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

            ],
          ),
        ),
      )
    );
  }
}
