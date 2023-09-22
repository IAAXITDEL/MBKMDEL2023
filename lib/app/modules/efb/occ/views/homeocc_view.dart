import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_one/app/modules/efb/occ/views/confirm_request_FO_view.dart';
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


  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter by Hub'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(context, "CGK"),
              _buildFilterOption(context, "SUB"),
              _buildFilterOption(context, "KNO"),
              _buildFilterOption(context, "DPS"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(BuildContext context, String hub) {
    final controller = Get.find<HomeOCCController>();
    return InkWell(
      onTap: () {
        controller.updateSelectedHub(hub);
        controller.isHubSelected.value = true; // Hub is selected
        Navigator.pop(context); // Close the dialog
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(hub),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeOCCController());
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Menampilkan jumlah CGK dengan status in-use-pilot
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("pilot-device-1")
                        .where("statusDevice", isEqualTo: "in-use-pilot")
                        .where("field_hub", isEqualTo: "CGK")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }

                      final count = snapshot.data?.docs.length ?? 0;
                      return Text('CGK: $count');
                    },
                  ),

                  // Menampilkan jumlah SUB dengan status in-use-pilot
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("pilot-device-1")
                        .where("statusDevice", isEqualTo: "in-use-pilot")
                        .where("field_hub", isEqualTo: "SUB")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }

                      final count = snapshot.data?.docs.length ?? 0;
                      return Text('SUB: $count');
                    },
                  ),

                  // Menampilkan jumlah DPS dengan status in-use-pilot
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("pilot-device-1")
                        .where("statusDevice", isEqualTo: "in-use-pilot")
                        .where("field_hub", isEqualTo: "DPS")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }

                      final count = snapshot.data?.docs.length ?? 0;
                      return Text('DPS: $count');
                    },
                  ),

                  // Menampilkan jumlah KNO dengan status in-use-pilot
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("pilot-device-1")
                        .where("statusDevice", isEqualTo: "in-use-pilot")
                        .where("field_hub", isEqualTo: "KNO")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }

                      final count = snapshot.data?.docs.length ?? 0;
                      return Text('KNO: $count');
                    },
                  ),
                ],
              ),
            ),




            Obx(() {
              final selectedHubText = controller.selectedHub?.value ?? 'No hub selected';
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Selected Hub: $selectedHubText'),
              );
            }),


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _showFilterDialog(context);
                },
                child: Text('Choose The Hub'),
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
                  TabBarView(
                    children: [
                      FirebaseDataTab(statuses: ["waiting-confirmation-1"]),
                      FirebaseDataTab(statuses: ["in-use-pilot"]),
                      FirebaseDataTab(statuses: ["need-confirmation-occ"]),
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

class FirebaseDataTab extends StatelessWidget {
  final List<String> statuses;

  FirebaseDataTab({required this.statuses});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeOCCController>();

    if (!controller.isHubSelected.value) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Please select the hub first.',
            style: tsOneTextTheme.labelMedium,
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("pilot-device-1")
          .where("statusDevice", whereIn: statuses)
          .where("field_hub", isEqualTo: controller.selectedHub?.value)
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

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                final userName = userData['NAME'] ?? 'No Name';
                final photoUrl = userData['PHOTOURL'] as String?; // Get the profile photo URL
                final dataId = documents[index].id; // Mendapatkan ID dokumen
                final deviceName = data['device_name'] ?? 'No Data';
                final deviceName2 = data['device_name2'] ?? '';
                final deviceName3 = data['device_name3'] ?? '';

                // Build the widget with the user's name and profile photo
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 3.0, horizontal: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        if (statuses.contains("waiting-confirmation-1")) {
                          // Navigate to ConfirmRequestPilotView with the required data ID
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ConfirmRequestPilotView(dataId: dataId),
                            ),
                          );
                        }
                        if (statuses.contains("need-confirmation-occ")) {
                          // Navigate to ConfirmReturnBackPilotView with the required data ID
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ConfirmReturnBackPilotView(dataId: dataId),
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
                                if (deviceName.isNotEmpty)
                                  Text(
                                    'Device Name: $deviceName',
                                    style: tsOneTextTheme.labelSmall,
                                  ),
                                // Display device_name2 if available
                                if (deviceName2.isNotEmpty && deviceName3.isNotEmpty)
                                  Text(
                                    'Device Name 2: $deviceName2' +  'Device Name 3: $deviceName3',
                                    style: tsOneTextTheme.labelSmall,
                                  ),
                                // Display device_name3 if available
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

