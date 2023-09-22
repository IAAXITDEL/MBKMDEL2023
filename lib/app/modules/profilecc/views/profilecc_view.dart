import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/theme.dart';
import '../controllers/profilecc_controller.dart';

class ProfileccView extends GetView<ProfileccController> {
  const ProfileccView({Key? key}) : super(key: key);

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
      width: 250.0,
      height: 250.0,
      child: Stack(
        children: [
          generateQRCode(), // Display the generated QR code
          Center(
            child: Image.asset(
              'assets/images/airasia_logo_circle.png', // Adjust the path to your logo image
              width: 40, // Set the width of the logo
              height: 40, // Set the height of the logo
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // LOGOUT
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tsOneColorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                controller.logout();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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
                    style: TextStyle(
                      color: TsOneColor.surface,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const RedTitleText(text: "PROFILE"),
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
                  child:
                      Image.network(controller.userPreferences.getPhotoURL()),
                ),
              ),
            ),
            BlackTitleText(
              text: controller.userPreferences.getName(),
            ),
            Text(
              controller.userPreferences.getIDNo().toString(),
              style: TextStyle(color: tsOneColorScheme.secondaryContainer),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0))),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      width: Get.width,
                      padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        //color: Theme.of(context).cardColor,
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
                    Text("My QR"),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 3, child: const Text("Email")),
                      Expanded(flex: 1, child: const Text(":")),
                      Expanded(flex: 6, child: const Text("noel@airasia.com")),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(flex: 3, child: const Text("ID NO")),
                      Expanded(flex: 1, child: const Text(":")),
                      Expanded(flex: 6, child: const Text("1007074")),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(flex: 3, child: const Text("LOA NO")),
                      Expanded(flex: 1, child: const Text(":")),
                      Expanded(
                          flex: 6, child: const Text("2345/KAPEL/VIII/2022")),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
