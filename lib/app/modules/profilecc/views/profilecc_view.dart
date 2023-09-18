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
      size: 200.0,
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
          generateQRCode(), // Display the generated QR code
          Center(
            child: Image.asset(
              'assets/images/airasia_logo_circle.png', // Adjust the path to your logo image
              width: 30, // Set the width of the logo
              height: 30, // Set the height of the logo
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
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
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
                  child: Image.network(controller.userPreferences.getPhotoURL()),
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
              onPressed: () {
                // Show a dialog with the QR code
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "SCAN ME",
                        style: tsOneTextTheme.titleLarge,
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          addAirAsiaLogoToQRCode(), // Display QR code with AirAsia logo
                          const SizedBox(height: 10),
                          Text(
                            "ID NO: ${controller.userPreferences.getIDNo()}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Close"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("Show QR Code"),
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
                      Expanded(flex: 6, child: const Text("2345/KAPEL/VIII/2022")),
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
