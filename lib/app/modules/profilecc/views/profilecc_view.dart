import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/theme.dart';
import '../../../../util/empty_screen.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                _showLogoutConfirmationDialog(context); // Show the confirmation dialog
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
      body: Center(
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 20),
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

                    return Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Column(
                        children: [
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
                              Expanded(flex: 3, child: Text("LICENSE NO")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(
                                  flex: 6, child: Text( documentData["LICENSE NO."] ?? "N/A")),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(flex: 3, child: Text("HUB")),
                              Expanded(flex: 1, child: Text(":")),
                              Expanded(
                                  flex: 6, child: Text( documentData["HUB"] ?? "N/A")),
                            ],
                          ),
                        ],
                      ),
                  );
                },
              ),
            ),
          ],
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
