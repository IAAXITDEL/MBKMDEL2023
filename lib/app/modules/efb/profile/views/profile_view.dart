import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/data/users/users.dart';

import '../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../presentation/theme.dart';
import '../../../profilecc/controllers/profilecc_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileccController> {
  // Function to generate a QR code with the AirAsia logo in the center
  Widget generateQRCode() {
    final idNo = controller.userPreferences.getIDNo().toString();

    return QrImageView(
      data: idNo,
      version: QrVersions.auto,
      size: 600.0,
      foregroundColor: Colors.black,
    );
  }

  // Function to add the AirAsia logo to the center of the QR code
  Widget addAirAsiaLogoToQRCode() {
    return Container(
      width: 200.0,
      height: 200.0,
      child: Stack(
        children: [
          generateQRCode(),
          Center(
            child: Image.asset(
              'assets/images/airasia_logo_circle.png',
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getUserHub() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userEmail = user.email;
    if (userEmail == null) return null;

    final userSnapshot = await FirebaseFirestore.instance.collection('users').where('EMAIL', isEqualTo: userEmail).get();

    if (userSnapshot.docs.isNotEmpty) {
      final userDoc = userSnapshot.docs.first;
      return userDoc['HUB'];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 70, left: 20, bottom: 10, right: 20),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const RedTitleText(text: "PROFILE"),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    AvatarGlow(
                      endRadius: 110,
                      glowColor: Colors.black,
                      duration: const Duration(seconds: 2),
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        width: 175,
                        height: 175,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: Image.network(controller.userPreferences.getPhotoURL()),
                        ),
                      ),
                    ),
                    BlackTitleText(
                      text: controller.userPreferences.getName(),
                    ),
                    Text(
                      controller.userPreferences.getRank().toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: TsOneColor.onSurface,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      controller.userPreferences.getIDNo().toString(),
                      style: const TextStyle(
                        color: TsOneColor.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    if (controller.userPreferences.getRank().toString() == "OCC")
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: FutureBuilder<String?>(
                          future: _getUserHub(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              String? userHub = snapshot.data;
                              return GreenTitleText(text: "HUB : ${userHub ?? 'Data tidak tersedia'}");
                            }
                          },
                        ),
                      ),
                    if (controller.userPreferences.getRank().toString() == "CAPT" || controller.userPreferences.getRank().toString() == "FO")
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tsOneColorScheme.secondary,
                          foregroundColor: tsOneColorScheme.secondaryContainer,
                          surfaceTintColor: tsOneColorScheme.secondary,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            //side: BorderSide(color: TsOneColor.onSecondary, width: 1),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SingleChildScrollView(
                                child: Container(
                                  width: Get.width,
                                  padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                    color: TsOneColor.secondary,
                                  ),
                                  child: Column(
                                    children: [
                                      Text("My QR", style: tsOneTextTheme.labelMedium),
                                      SizedBox(height: 5),
                                      RedTitleText(text: "SCAN ME"),
                                      SizedBox(height: 10),
                                      addAirAsiaLogoToQRCode(),
                                      SizedBox(height: 10),
                                      Text(
                                        "${controller.userPreferences.getName()}",
                                        style: tsOneTextTheme.bodyMedium,
                                      ),
                                      Text(
                                        "${controller.userPreferences.getIDNo()}",
                                        style: tsOneTextTheme.bodyMedium,
                                      ),
                                      SizedBox(height: 10),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Close"),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2_rounded,
                                size: 50,
                                color: tsOneColorScheme.onSecondary,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Tap QR",
                                style: TextStyle(color: TsOneColor.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tsOneColorScheme.secondary,
                  foregroundColor: tsOneColorScheme.secondaryContainer,
                  surfaceTintColor: tsOneColorScheme.secondary,
                  minimumSize: const Size.fromHeight(40),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.logout,
                      color: TsOneColor.secondaryContainer,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}