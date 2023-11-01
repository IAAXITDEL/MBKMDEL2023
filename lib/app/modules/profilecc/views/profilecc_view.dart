import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/theme.dart';
import '../controllers/profilecc_controller.dart';

class ProfileccView extends GetView<ProfileccController> {
  const ProfileccView({Key? key}) : super(key: key);

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
            // BlackTitleText(
            //   text: controller.userPreferences.getName(),
            // ),
            Text(
              controller.userPreferences.getIDNo().toString(),
              style: TextStyle(color: tsOneColorScheme.secondaryContainer),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 3, child: const Text("Email")),
                      Expanded( child: const Text(":")),
                      Expanded(flex: 6, child: const Text("noel@airasia.com")),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(flex: 3, child: const Text("ID NO")),
                      Expanded( child: const Text(":")),
                      Expanded(flex: 6, child: const Text("1007074")),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(flex: 3, child: const Text("LOA NO")),
                      Expanded( child: const Text(":")),
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
