import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: tsOneColorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  // authC.logout();
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
                    Text("Logout")
                  ],
                )),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text( "PROFILE"),
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
                      child: Image.network(controller.userPreferences.getPhotoURL()))),
            ),
            // Text(
            //   "${authC.user.value.name!}",
            //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            // ),
            Text(
              "847598342385",
              style: TextStyle(color: tsOneColorScheme.secondaryContainer),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 3, child: Text("Email")),
                      Expanded(flex: 1, child: Text(":")),
                      Expanded(flex: 6, child: Text("noel@airasia.com")),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(flex: 3, child: Text("ID NO")),
                      Expanded(flex: 1, child: Text(":")),
                      Expanded(flex: 6, child: Text("1007074")),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(flex: 3, child: Text("LOA NO")),
                      Expanded(flex: 1, child: Text(":")),
                      Expanded(flex: 6, child: Text("2345/KAPEL/VIII/2022")),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
