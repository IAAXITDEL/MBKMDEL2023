import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ts_one/app/modules/efb/occ/views/confirm_request_FO_view.dart';
import 'package:ts_one/app/modules/efb/occ/views/confirm_request_pilot_view.dart';
import 'package:ts_one/app/modules/efb/occ/views/confirm_return_back_pilot_view.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';
import 'package:ts_one/util/error_screen.dart';
import 'package:ts_one/util/loading_screen.dart';
import '../../../../../presentation/theme.dart';
import '../../../../../util/empty_screen_efb.dart';
import '../../../../../util/util.dart';
import '../controllers/homeocc_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeOCCView extends GetView<HomeOCCController> {
  HomeOCCView({Key? key}) : super(key: key);

  String? userHub;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeOCCController());

    return FutureBuilder<String?>(
      future: _getUserHub(),
      builder: (context, snapshot) {
        String? userHub = snapshot.data;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 50, left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Hi, ${controller.titleToGreet}",
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
                                    Util.convertDateTimeDisplay(DateTime.now().toString(), "EEEE"),
                                    style: tsOneTextTheme.labelSmall,
                                  ),
                                  Text(
                                    Util.convertDateTimeDisplay(DateTime.now().toString(), "dd MMMM yyyy"),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: tsOneColorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                          return BlackTitleText(text: "${userHub ?? 'Data tidak tersedia'}");
                                        }
                                      },
                                    ),),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: tsOneColorScheme.primary,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("pilot-device-1")
                                        .where("statusDevice", isEqualTo: "in-use-pilot")
                                        .where("field_hub", isEqualTo: userHub)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }

                                      if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}");
                                      }

                                      final count = snapshot.data?.docs.length ?? 0;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          'Used Device ' + ': $count',
                                          style: tsOneTextTheme.bodySmall,
                                        ),
                                      );
                                    },
                                  ),

                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("pilot-device-1")
                                        .where("statusDevice", isEqualTo: "in-use-pilot")
                                        .where("field_hub2", isEqualTo: userHub) // Using the logged-in userHub
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }

                                      if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}");
                                      }

                                      final count = snapshot.data?.docs.length ?? 0;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text('Used Device 2' + ': $count', style: tsOneTextTheme.bodySmall,),
                                      );
                                    },
                                  ),

                                 StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("pilot-device-1")
                                        .where("statusDevice", isEqualTo: "in-use-pilot")
                                        .where("field_hub", isEqualTo: userHub) // Using the logged-in userHub
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }

                                      if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}");
                                      }
                                      final inUseCount = snapshot.data?.docs.length ?? 0;

                                       return StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection("pilot-device-1")
                                            .where("statusDevice", isEqualTo: "in-use-pilot")
                                            .where("field_hub2", isEqualTo: userHub) // Using the logged-in userHub
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                        }

                                        if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}");
                                        }
                                        final inUseCount2 = snapshot.data?.docs.length ?? 0;


                                      return StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection("Device")
                                            .where("hub", isEqualTo: userHub) // Using the logged-in userHub
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                        }

                                        if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}");
                                        }

                                      return StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance.collection("Device").where("hub", isEqualTo: userHub).snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          }

                                          if (snapshot.hasError) {
                                            return Text("Error: ${snapshot.error}");
                                          }

                                          final totalCount = snapshot.data?.docs.length ?? 0;
                                          final availableCount = totalCount - inUseCount;
                                          final deviceUsed = inUseCount + inUseCount2;

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text('Available Devices: $availableCount Device Used $deviceUsed', style: tsOneTextTheme.bodySmall,),
                                          );
                                        },
                                      );
                                        },
                                      );
                                    },
                                  );
                                    },
                                 ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TabBar(
                    tabs: [
                      Tab(text: "Confirm"),
                      Tab(text: "In Use"),
                      Tab(text: "Return"),
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - kToolbarHeight - 40, // Adjust height as needed
                    child: TabBarView(
                      children: [
                        FirebaseDataTab(
                          statuses: ["waiting-confirmation-1"],
                          userHub: userHub ?? '',
                        ),
                        FirebaseDataTab(
                          statuses: ["in-use-pilot"],
                          userHub: userHub ?? '',
                        ),
                        FirebaseDataTab(
                          statuses: ["need-confirmation-occ"],
                          userHub: userHub ?? '',
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
  }
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

class FirebaseDataTab extends StatelessWidget {
  final List<String> statuses;
  final String userHub; // Hub information for the logged-in user

  FirebaseDataTab({required this.statuses, required this.userHub});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeOCCController>();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("pilot-device-1")
          .where("statusDevice", whereIn: statuses)
          .where("field_hub", isEqualTo: userHub) // Filter based on user's hub
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
              future: FirebaseFirestore.instance.collection("users").doc(userUid).get(),
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
                final userRank = userData['RANK'] ?? 'No Rank';
                final photoUrl = userData['PHOTOURL'] as String?; // Get the profile photo URL
                final dataId = documents[index].id; // Mendapatkan ID dokumen
                final deviceName = data['device_name'] ?? 'No Data';
                final deviceName2 = data['device_name2'] ?? '';
                final deviceName3 = data['device_name3'] ?? '';
                final timestamp = data['timestamp'] ?? '';

                // Build the widget with the user's name and profile photo
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Card(
                        color : tsOneColorScheme.secondary,
                        surfaceTintColor: TsOneColor.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3, // You can adjust the elevation as needed
                        child: InkWell(
                          onTap: () {
                            if (statuses.contains("waiting-confirmation-1")) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ConfirmRequestPilotView(dataId: dataId),
                                ),
                              );
                            }
                            if (statuses.contains("need-confirmation-occ")) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ConfirmReturnBackPilotView(dataId: dataId),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(15.0),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: 8.0),
                                CircleAvatar(
                                  backgroundImage: photoUrl != null
                                      ? NetworkImage(photoUrl as String)
                                      : AssetImage('assets/default_profile_image.png') as ImageProvider,
                                  radius: 25.0,
                                ),
                                SizedBox(width: 17.0),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        child: Text(
                                          userRank + ' ' + userName,
                                          style: tsOneTextTheme.displaySmall,
                                        ),
                                      ),
                                      if (!deviceName.contains('-'))
                                        Text(
                                          '$deviceName',
                                          style: tsOneTextTheme.labelSmall,
                                        ),
                                      if (deviceName2.isNotEmpty && deviceName3.isNotEmpty && deviceName.contains('-'))
                                        Text(
                                          '$deviceName2' + ' & ' + '$deviceName3',
                                          style: tsOneTextTheme.labelSmall,
                                        ),
                                      Text(
                                        '${DateFormat('yyyy-MM-dd HH:mm a').format(timestamp.toDate())}',
                                        style: tsOneTextTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),

                                if (statuses.contains("waiting-confirmation-1") || statuses.contains("need-confirmation-occ"))
                                const Icon(
                                  Icons.chevron_right,
                                  color: TsOneColor.onSecondary,
                                  size: 30,
                                )
                              ],
                            ),
                          ),
                        ),
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
