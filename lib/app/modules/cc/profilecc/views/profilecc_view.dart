import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../presentation/theme.dart';
import '../../../../../util/error_screen.dart';
import '../../../../../util/loading_screen.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/profilecc_controller.dart';

class ProfileccView extends GetView<ProfileccController> {
  const ProfileccView({Key? key}) : super(key: key);

  // Function to show the logout confirmation dialog
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.logout();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var loaNoC = TextEditingController();

    Future<void> add() async {
      String message = '';

      await QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          barrierDismissible: true,
          confirmBtnText: 'Submit',
          title: 'LOA NO.',
          widget: Column(
            children: [
              TextFormField(
                controller: loaNoC,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  hintText: 'Please enter LOA NO.',
                  prefixIcon: Icon(
                    Icons.keyboard,
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
            ],
          ),
          onConfirmBtnTap: () async {
            if (loaNoC.text.length < 5) {
              await QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                text: 'Please input something',
              );
              return;
            }

            controller.addLoaNo(loaNoC.text).then((status) async {
              await  QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                text: "Success change LOA NO.!",
              );
            });

            Navigator.of(context, rootNavigator: true).pop();
          });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          // LOGOUT
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: tsOneColorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _showLogoutConfirmationDialog(
                    context); // Show the confirmation dialog
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Logout",
                    style: const TextStyle(
                      color: TsOneColor.surface,
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              RedTitleText(text: "PROFILE"),
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
                        child: Image.network(
                            controller.userPreferences.getPhotoURL()))),
              ),
              BlackTitleText(
                text: controller.userPreferences.getName(),
              ),
              Text(
                controller.userPreferences.getIDNo().toString(),
                style: TextStyle(color: tsOneColorScheme.secondaryContainer),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
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
                    controller.idTraining.value = documentData["ID NO"];

                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          controller.isAdministrator.value ? SizedBox() :
                          Row(
                            children: [
                              Expanded(flex: 3, child: Text("STATUS")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(flex: 6, child:
                              Obx(() {
                                return Container(
                                  height: 30.0,
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: controller.isReady.value ?  Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  child : Text(
                                    controller.isReady.value ?  "READY": "NOT READY",
                                    textAlign: TextAlign.center,
                                    style: tsOneTextTheme.bodyMedium,
                                  ),
                                );
                              })
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
                              Expanded(
                                  flex: 6,
                                  child: Text(documentData["RANK"] ?? "N/A")),
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
                                  flex: 6,
                                  child: Text(documentData["EMAIL"] ?? "N/A")),
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
                                  flex: 6,
                                  child: Text(
                                      documentData["LICENSE NO."] ?? "N/A")),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          controller.isAdministrator.value == false ?
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(flex: 3, child: Text("HUB")),
                                      Expanded(flex: 1, child: Text(":")),
                                      Expanded(
                                          flex: 6,
                                          child: Text(documentData["HUB"] ?? "N/A")),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ) : SizedBox(),

                          controller.isInstructor.value == true
                              ? Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("INSTRUCTOR")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(
                                      flex: 6,
                                      child: Text(controller.instructorType.value ?? "N/A")),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(flex: 3, child: Text("LOA NO.")),
                                  Expanded(flex: 1, child: Text(":")),
                                  Expanded(
                                      flex: 5,
                                      child: Text(
                                          documentData["LOA NO"] ?? "N/A")),
                                  Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: (){
                                          add();
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                      )),
                                ],
                              )
                            ],
                          )
                              : SizedBox()
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              controller.isTraining.value == true
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("TRAINING", style: tsOneTextTheme.headlineLarge,),
                           Obx(() {
                             return  controller.isReady.value ?
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

                                   await controller.savePdfFile(
                                       await controller
                                           .getPDFTrainingCard(controller.idTrainee.value));
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
                        SizedBox(
                          height: 10,
                        ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: controller.trainingStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                    Get.toNamed(Routes.PILOTTRAININGHISTORYCC,
                                        arguments: {
                                          "idTrainingType": listTraining[index]
                                              ["id"],
                                          "idTraining":
                                              controller.idTraining.value,
                                        });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, ),
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
                                            child: Image.asset(
                                              "assets/images/success.png",
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                      title: Text(
                                        listTraining[index]["training"],
                                        maxLines: 1,
                                        style: tsOneTextTheme.labelMedium,
                                      ),
                                      // subtitle: Column(
                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                      //   children: [
                                      //     Text(listTraining[index]["ID NO"].toString() ?? "", style: tsOneTextTheme.labelSmall,),
                                      //     Container(
                                      //       padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                      //       decoration: BoxDecoration(
                                      //         color: Colors.green.withOpacity(0.4),
                                      //         borderRadius: BorderRadius.circular(10),
                                      //       ),
                                      //       child: const Text(
                                      //         "Ready",
                                      //         style: TextStyle(fontSize: 10, color: Colors.green),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      trailing: const Icon(Icons.navigate_next),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  ProfileInfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis, // Truncate long text
              maxLines: 1, // Display in a single line
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
