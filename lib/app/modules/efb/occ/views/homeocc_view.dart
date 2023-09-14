import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/modules/efb/occ/views/confirm_request_pilot_view.dart';
import 'package:ts_one/app/modules/efb/occ/views/confirm_return_back_pilot_view.dart';
import 'package:ts_one/util/error_screen.dart';
import 'package:ts_one/util/loading_screen.dart';
import '../../../../../presentation/theme.dart';
import '../../../../../util/empty_screen_efb.dart';
import '../../../../../util/util.dart';
import '../controllers/homeocc_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeOCCView extends GetView<HomeOCCController> {
  const HomeOCCView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeOCCController());
    bool isContainerClicked = false;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hi, ${controller.titleToGreet!}",
                        style: tsOneTextTheme.headlineLarge,
                      ),
                      Spacer(),
                      Icon(
                        Icons.notifications_active_outlined,
                        color: tsOneColorScheme.onSecondary,
                      )
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Good ${controller.timeToGreet}',
                      style: tsOneTextTheme.labelMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(
                            Icons.calendar_month_outlined,
                            color: TsOneColor.onSecondary,
                            size: 32,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Util.convertDateTimeDisplay(
                                  DateTime.now().toString(), "EEEE"),
                              style: tsOneTextTheme.labelSmall,
                            ),
                            Text(
                              Util.convertDateTimeDisplay(
                                  DateTime.now().toString(), "dd MMMM yyyy"),
                              style: tsOneTextTheme.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                Tab(text: "Confirm"),
                Tab(text: "In Use"),
                Tab(text: "Return"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FirebaseDataTab(status: "waiting-confirmation-1"),
                  FirebaseDataTab(status: "in-use-pilot"),
                  FirebaseDataTab(status: "need-confirmation-occ"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FirebaseDataTab extends StatelessWidget {
  final String status;

  FirebaseDataTab({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("pilot-device-1")
          .where("status-device-1", isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }

        if (snapshot.hasError) {
          return const ErrorScreen();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyScreenEFB();
        }

        final documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final data = documents[index].data() as Map<String, dynamic>;

            // Get the user_uid from the document
            final userUid = data['user_uid'];

            // Get the user's name using a FutureBuilder
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(userUid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (userSnapshot.hasError) {
                  return Text("Error: ${userSnapshot.error}");
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Text("User data not found");
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final userName = userData['NAME'] ?? 'No Name';
                final photoUrl = userData['PHOTOURL']
                    as String?; // Get the profile photo URL
                final dataId = documents[index].id; // Mendapatkan ID dokumen

                // Build the widget with the user's name and profile photo
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 3.0, horizontal: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        if (status == "waiting-confirmation-1") {
                          // Navigasi ke halaman ConfirmRequestPilotView dengan membawa ID data yang diperlukan
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ConfirmRequestPilotView(dataId: dataId),
                            ),
                          );
                        } else if (status == "need-confirmation-occ") {
                          // Navigasi ke halaman ConfirmReturnBackPilotView dengan membawa ID data yang diperlukan
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ConfirmReturnBackPilotView(dataId: dataId),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.all(18.0),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                          Colors.red.withOpacity(0.2),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display the profile image
                          CircleAvatar(
                            backgroundImage: photoUrl != null
                                ? NetworkImage(photoUrl as String)
                                : AssetImage('assets/default_profile_image.png')
                                    as ImageProvider, // You can provide a default image
                            radius: 20.0, // Adjust the radius as needed
                          ),

                          SizedBox(
                              width:
                                  14.0), // Add spacing between the image and text
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double
                                      .infinity, // Set the width to expand to the available space
                                  child: Text(
                                    userName, // Use the user's name
                                    style: tsOneTextTheme.displaySmall,
                                  ),
                                ),
                                Text(
                                  'Device Name: ${data['device_name'] ?? 'No Data'}',
                                  style: tsOneTextTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
