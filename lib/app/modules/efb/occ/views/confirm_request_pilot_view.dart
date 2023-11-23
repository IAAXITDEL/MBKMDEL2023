import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/app/routes/app_pages.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../presentation/theme.dart';
import '../../../../routes/app_pages.dart';

class ConfirmRequestPilotView extends GetView {
  final String dataId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController chargeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ConfirmRequestPilotView({Key? key, required this.dataId}) : super(key: key);

  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'You have successfully confirmed the request',
    ).then((value) {
      Get.offAllNamed(Routes.NAVOCC);
    });
  }

  String getMonthText(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'Desember'
    ];
    return months[month - 1]; // Index 0-11 for Januari-Desember
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No Data';

    DateTime dateTime = timestamp.toDate();
    String formattedDateTime = '${dateTime.day} ${getMonthText(dateTime.month)} ${dateTime.year}'
        ' ; '
        '${dateTime.hour}:${dateTime.minute}';
    return formattedDateTime;
  }

  void confirmInUseCrew(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmation',
            style: tsOneTextTheme.headlineLarge,
          ),
          content: const Text('Are you sure you want to approve the usage of this device? '),
          actions: <Widget>[
            Row(children: [
              Expanded(
                flex: 5,
                child: TextButton(
                  child: const Text('No', style: TextStyle(color: TsOneColor.secondaryContainer)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const Spacer(flex: 1),
              Expanded(
                flex: 5,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: TsOneColor.greenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text('Yes', style: TextStyle(color: TsOneColor.onPrimary)),
                  onPressed: () async {
                    User? user = _auth.currentUser;

                    if (user != null) {
                      QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user.email).get();
                      String userUid = userQuery.docs.first.id;

                      // Get the charger number from the controller
                      String chargerNumber = chargeController.text;

                      DocumentReference pilotDeviceRef = FirebaseFirestore.instance.collection("pilot-device-1").doc(dataId);

                      try {
                        await pilotDeviceRef.update({
                          'statusDevice': 'in-use-pilot',
                          'occ-on-duty': userUid,
                          'charger_no': chargerNumber, // Add charger number to the document
                        });
                        _showQuickAlert(context);
                        print("Data Updated!");
                      } catch (error) {
                        print('Error updating data: $error');
                      }
                    }
                  },
                ),
              )
            ]),
          ],
        );
      },
    );
  }

  String? validateCharge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please Enter Charger Number';
    }

    // Check if the entered value is a valid number
    bool isNumeric(String? s) {
      if (s == null) {
        return false;
      }
      return double.tryParse(s) != null;
    }

    if (!isNumeric(value)) {
      return 'Charger Number must be a valid number';
    }
    return null;
  }

  Future<Map<String, dynamic>> getUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(user.email).get();

        if (userDoc.exists) {
          return userDoc.data() ?? {};
        }
      } catch (e) {
        print('Error getting user data: $e');
      }
    }

    return {};
  }

  // Future<void> _confirmAndProcessData(Map<String, dynamic> userData) async {
  //   try {
  //     // Mendapatkan data dari pilot-device-1
  //     DocumentSnapshot<Map<String, dynamic>> pilotDeviceSnapshot = await FirebaseFirestore.instance.collection("pilot-device-1").doc(dataId).get();

  //     if (!pilotDeviceSnapshot.exists) {
  //       // Handle jika data tidak ditemukan
  //       print('Data not found');
  //       return;
  //     }

  //     Map<String, dynamic> pilotDeviceData = pilotDeviceSnapshot.data()!;

  //     // Validasi chargerno hanya untuk rank FO
  //     if (userData['RANK'] == 'FO') {
  //       if (_formKey.currentState?.validate() ?? false) {
  //         // Panggil fungsi confirmInUseCrew
  //         confirmInUseCrew(context);
  //       }
  //     } else {
  //       // Jika rank bukan FO, langsung proses konfirmasi tanpa validasi
  //       confirmInUseCrew(context);
  //     }
  //   } catch (error) {
  //     print('Error: $error');
  //     // Handle error sesuai kebutuhan
  //   }
  // }

  Future<Map<String, dynamic>> getUserDataFromDevice(String dataId) async {
    try {
      // Mendapatkan data dari pilot-device-1
      DocumentSnapshot<Map<String, dynamic>> pilotDeviceSnapshot = await FirebaseFirestore.instance.collection("pilot-device-1").doc(dataId).get();

      if (!pilotDeviceSnapshot.exists) {
        // Handle jika data tidak ditemukan
        print('Data not found');
        return {};
      }

      // Mendapatkan user_uid dari data pilot-device-1
      String userUid = pilotDeviceSnapshot['user_uid'];

      // Mendapatkan data pengguna dari users berdasarkan user_uid
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance.collection("users").doc(userUid).get();

      if (!userSnapshot.exists) {
        // Handle jika data pengguna tidak ditemukan
        print('User data not found');
        return {};
      }

      // Mendapatkan data pengguna
      Map<String, dynamic> userData = userSnapshot.data()!;
      return userData;
    } catch (error) {
      print('Error: $error');
      // Handle error sesuai kebutuhan
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Confirmation Request',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection("pilot-device-1").doc(dataId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Data not found'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final userUid = data['user_uid'];
            final deviceUid = data['device_uid'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("users").doc(userUid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Center(child: Text('User data not found'));
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection("Device").doc(deviceUid).get(),
                  builder: (context, deviceSnapshot) {
                    if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (deviceSnapshot.hasError) {
                      return Center(child: Text('Error: ${deviceSnapshot.error}'));
                    }

                    //IF DEVICE_NAME NOT FOUND OR NULL VALUE
                    if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                      final deviceUid2 = data['device_uid2'];
                      final deviceUid3 = data['device_uid3'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection("Device").doc(deviceUid2).get(),
                        builder: (context, deviceSnapshot) {
                          if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (deviceSnapshot.hasError) {
                            return Center(child: Text('Error: ${deviceSnapshot.error}'));
                          }

                          if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                            return const Center(child: Text('Device data not found'));
                          }

                          final deviceData2 = deviceSnapshot.data!.data() as Map<String, dynamic>;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection("Device").doc(deviceUid3).get(),
                            builder: (context, deviceSnapshot) {
                              if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (deviceSnapshot.hasError) {
                                return Center(child: Text('Error: ${deviceSnapshot.error}'));
                              }

                              if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                                return const Center(child: Text('Device data not found'));
                              }

                              final deviceData3 = deviceSnapshot.data!.data() as Map<String, dynamic>;

                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
                                      ),
                                      const SizedBox(height: 15.0),
                                      Row(
                                        children: [
                                          const Expanded(flex: 7, child: Text("ID NO")),
                                          const Expanded(child: Text(":")),
                                          Expanded(
                                            flex: 6,
                                            child: Text('${userData['ID NO'] ?? 'No Data'}'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          const Expanded(flex: 7, child: Text("Name")),
                                          const Expanded(child: Text(":")),
                                          Expanded(
                                            flex: 6,
                                            child: Text('${userData['NAME'] ?? 'No Data'}'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          const Expanded(flex: 7, child: Text("Rank")),
                                          const Expanded(child: Text(":")),
                                          Expanded(
                                            flex: 6,
                                            child: Text('${userData['RANK'] ?? 'No Data'}'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15.0),

                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 16.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Divider(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(
                                                'Charger',
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Fill in the following fields to input the charger number.',
                                        style: tsOneTextTheme.bodySmall,
                                      ),
                                      SizedBox(height: 16.0),
                                      Form(
                                        key: _formKey,
                                        child: TextFormField(
                                          controller: chargeController,
                                          autofocus: false,
                                          validator: validateCharge,
                                          decoration: InputDecoration(
                                            labelText: 'Charge No',
                                            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                            labelStyle: tsOneTextTheme.labelMedium,
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 15.0),

                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 16.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Divider(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(
                                                'Device Details',
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Device 2", style: tsOneTextTheme.displaySmall),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Device No",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${data['device_name2'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "IOS Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData2['value']['iosver'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "FlySmart Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData2['value']['flysmart'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Docunet Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData2['value']['docuversion'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Lido mPilot Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData2['value']['lidoversion'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Hub",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData2['value']['hub'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // const SizedBox(height: 5.0),
                                      // Row(
                                      //   children: [
                                      //     Expanded(
                                      //         flex: 7,
                                      //         child: Text(
                                      //           "Condition",
                                      //           style: tsOneTextTheme.bodySmall,
                                      //         )),
                                      //     Expanded(
                                      //         child: Text(
                                      //       ":",
                                      //       style: tsOneTextTheme.bodySmall,
                                      //     )),
                                      //     Expanded(
                                      //       flex: 6,
                                      //       child: Text(
                                      //         '${deviceData2['value']['condition'] ?? 'No Data'}',
                                      //         style: tsOneTextTheme.bodySmall,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),

                                      //Device 3
                                      SizedBox(height: 20.0),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Device 3", style: tsOneTextTheme.displaySmall),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Device No",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${data['device_name3'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "IOS Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData3['value']['iosver'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "FlySmart Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData3['value']['flysmart'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Docunet Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData3['value']['docuversion'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Lido mPilot Version",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData3['value']['lidoversion'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Hub",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                            ":",
                                            style: tsOneTextTheme.bodySmall,
                                          )),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              '${deviceData3['value']['hub'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // const SizedBox(height: 5.0),
                                      // Row(
                                      //   children: [
                                      //     Expanded(
                                      //         flex: 7,
                                      //         child: Text(
                                      //           "Condition",
                                      //           style: tsOneTextTheme.bodySmall,
                                      //         )),
                                      //     Expanded(
                                      //         child: Text(
                                      //       ":",
                                      //       style: tsOneTextTheme.bodySmall,
                                      //     )),
                                      //     Expanded(
                                      //       flex: 6,
                                      //       child: Text(
                                      //         '${deviceData3['value']['condition'] ?? 'No Data'}',
                                      //         style: tsOneTextTheme.bodySmall,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),

                                      const SizedBox(height: 15.0),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 16.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Divider(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(
                                                'Device Condition',
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Device 2 Condition", style: tsOneTextTheme.displaySmall),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Condition Category",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 7,
                                            child: Text(
                                              '${data['initial-condition-category2'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Condition Remarks",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 7,
                                            child: Text(
                                              '${data['initial-condition-remarks2'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Device 3 Condition", style: tsOneTextTheme.displaySmall),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Condition Category",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 7,
                                            child: Text(
                                              '${data['initial-condition-category3'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6.0),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Text(
                                                "Condition Remarks",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                              child: Text(
                                                ":",
                                                style: tsOneTextTheme.bodySmall,
                                              )),
                                          Expanded(
                                            flex: 7,
                                            child: Text(
                                              '${data['initial-condition-remarks3'] ?? 'No Data'}',
                                              style: tsOneTextTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // const SizedBox(height: 15.0),

                                      // const Padding(
                                      //   padding: EdgeInsets.only(bottom: 16.0),
                                      //   child: Row(
                                      //     children: <Widget>[
                                      //       Expanded(
                                      //         child: Divider(
                                      //           color: Colors.grey,
                                      //         ),
                                      //       ),
                                      //       Padding(
                                      //         padding: EdgeInsets.symmetric(horizontal: 8.0),
                                      //         child: Text(
                                      //           'Charge',
                                      //           style: TextStyle(color: Colors.grey),
                                      //         ),
                                      //       ),
                                      //       Expanded(
                                      //         child: Divider(
                                      //           color: Colors.grey,
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // Text(
                                      //   'Fill in the following fields if you also borrowed the charger.',
                                      //   style: tsOneTextTheme.bodySmall,
                                      // ),
                                      // SizedBox(height: 16.0),
                                      // TextFormField(
                                      //   controller: chargeController,
                                      //   autofocus: false,
                                      //   decoration: InputDecoration(
                                      //     labelText: 'Charge No',
                                      //     contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                      //     labelStyle: tsOneTextTheme.labelMedium,
                                      //     border: const OutlineInputBorder(),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }

                    final deviceData = deviceSnapshot.data!.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(_formatTimestamp(data['timestamp']), style: tsOneTextTheme.labelSmall),
                          ),
                          const SizedBox(height: 15.0),
                          Row(
                            children: [
                              const Expanded(flex: 6, child: Text("ID NO")),
                              const Expanded(child: Text(":")),
                              Expanded(
                                flex: 6,
                                child: Text('${userData['ID NO'] ?? 'No Data'}'),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            children: [
                              const Expanded(flex: 6, child: Text("Name")),
                              const Expanded(child: Text(":")),
                              Expanded(
                                flex: 6,
                                child: Text('${userData['NAME'] ?? 'No Data'}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              const Expanded(flex: 6, child: Text("Rank")),
                              const Expanded(child: Text(":")),
                              Expanded(
                                flex: 6,
                                child: Text('${userData['RANK'] ?? 'No Data'}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'Device Details',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Device 1", style: tsOneTextTheme.displaySmall),
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 7,
                                  child: Text(
                                    "Device No",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  child: Text(
                                ":",
                                style: tsOneTextTheme.bodySmall,
                              )),
                              Expanded(
                                flex: 7,
                                child: Text(
                                  '${data['device_name'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "IOS Version",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  child: Text(
                                ":",
                                style: tsOneTextTheme.bodySmall,
                              )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['value']['iosver'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "FlySmart Version",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  child: Text(
                                ":",
                                style: tsOneTextTheme.bodySmall,
                              )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['value']['flysmart'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "Docunet Version",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  child: Text(
                                ":",
                                style: tsOneTextTheme.bodySmall,
                              )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['value']['docuversion'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "Lido mPilot Version",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  child: Text(
                                ":",
                                style: tsOneTextTheme.bodySmall,
                              )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['value']['lidoversion'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "Hub",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  child: Text(
                                ":",
                                style: tsOneTextTheme.bodySmall,
                              )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['value']['hub'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(
                                    "Condition",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  child: Text(
                                ":",
                                style: tsOneTextTheme.bodySmall,
                              )),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '${deviceData['value']['condition'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'Device Condition',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 7,
                                  child: Text(
                                    "Condition Category",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  child: Text(
                                    ":",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                flex: 7,
                                child: Text(
                                  '${data['initial-condition-category'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6.0),
                          Row(
                            children: [
                              Expanded(
                                  flex: 7,
                                  child: Text(
                                    "Condition Remarks",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                  child: Text(
                                    ":",
                                    style: tsOneTextTheme.bodySmall,
                                  )),
                              Expanded(
                                flex: 7,
                                child: Text(
                                  '${data['initial-condition-remarks'] ?? 'No Data'}',
                                  style: tsOneTextTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   surfaceTintColor: tsOneColorScheme.secondary,
      //   child: ElevatedButton(
      //     onPressed: () async {
      //       // confirmInUseCrew(context);
      //       //await _confirmAndProcessData(context);

      //     },
      //     style: ElevatedButton.styleFrom(
      //         backgroundColor: TsOneColor.greenColor,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(4.0),
      //         )),
      //     child: const Text('Confirm', style: TextStyle(color: Colors.white)),
      //   ),
      // ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
        child: FutureBuilder<Map<String, dynamic>>(
          future: getUserDataFromDevice(dataId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Data not found'));
            }

            final userData = snapshot.data!;

            return ElevatedButton(
              onPressed: () async {
                // if (userData['RANK'] == 'FO') {
                //   await _confirmAndProcessData(userData);
                // } else if (userData['RANK'] == 'CAPT'){
                //   await confirmInUseCrew(context);
                // }
                //await _confirmAndProcessData(userData);
                if (userData['RANK'] == 'FO') {
                  //_confirmAndProcessData(userData);
                  if (_formKey.currentState?.validate() ?? false) {
                    confirmInUseCrew(context); // Pass the context to the function
                  }
                } else if (userData['RANK'] == 'CAPT') {
                  confirmInUseCrew(context);
                } else {
                  print("qtryuio");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TsOneColor.greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            );
          },
        ),
      ),
    );
  }
}
