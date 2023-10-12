import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../../../presentation/theme.dart';

class ReturnOtherFOView extends StatefulWidget {
  final String documentId;
  final String deviceId;
  final String deviceName2;
  final String deviceName3;
  final String OccOnDuty;

  ReturnOtherFOView({
    required this.documentId,
    required this.deviceId,
    required this.OccOnDuty,
    required this.deviceName2,
    required this.deviceName3,
  });

  @override
  _ReturnOtherFOViewState createState() => _ReturnOtherFOViewState();
}

class _ReturnOtherFOViewState extends State<ReturnOtherFOView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _idController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String deviceId2 = "";
  String deviceId3 = "";
  String deviceName2 = "";
  String deviceName3 = "";
  String OccOnDuty = "";
  DocumentSnapshot? selectedUser;
  Stream<QuerySnapshot>? usersStream;

  @override
  void initState() {
    super.initState();
    // Fetch deviceUid, deviceName, and OCC On Duty from Firestore using widget.deviceId
    FirebaseFirestore.instance
        .collection('pilot-device-1')
        .doc(widget.deviceId)
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          deviceId2 = documentSnapshot['device_uid2'];
          deviceId3 = documentSnapshot['device_uid3'];
          deviceName2 = documentSnapshot['device_name2'];
          deviceName3 = documentSnapshot['device_name3'];
          OccOnDuty = documentSnapshot['occ-on-duty'];
        });
      }
    });

    _idController.addListener(() {
      // Listen to changes in the text field and filter users accordingly
      final searchText = _idController.text.trim();
      if (searchText.isNotEmpty) {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: searchText)
            .where(FieldPath.documentId, isLessThanOrEqualTo: searchText + '\uf8ff')
            .snapshots();
      } else {
        usersStream = null;
      }
      setState(() {});
    });
  }

  Future<void> _fetchUserData(String id) async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();

    if (documentSnapshot.exists) {
      setState(() {
        selectedUser = documentSnapshot;
      });
    } else {
      setState(() {
        selectedUser = null;
      });
      // Show a snackbar with the "No Data In Database" message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No Data In Database')),
      );
    }
  }
  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to confirm this action?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                _showQuickAlert(context);
                Navigator.of(context).pop(); // Close the dialog

                final idNumber = _idController.text.trim();
                if (idNumber.isNotEmpty) {
                  User? user = _auth.currentUser;
                  QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user?.email).get();
                  String userUid = userQuery.docs.first.id;

                  await _fetchUserData(idNumber);

                  FirebaseFirestore.instance
                      .collection('pilot-device-1')
                      .doc(widget.deviceId)
                      .update({
                    'statusDevice': 'waiting-handover-to-other-crew',
                    'handover-to-crew': idNumber,
                  });

                  // Get the hub based on device_name
                  String hubField = await getHubFromDeviceName(deviceName2, deviceName3) ?? "Unknown Hub";

                  // FirebaseFirestore.instance.collection('pilot-device-1').add({
                  //   'user_uid': idNumber,
                  //   'device_uid': '-',
                  //   'device_name': '-',
                  //   'device_uid2': deviceId2,
                  //   'device_name2': deviceName2,
                  //   'device_uid3': deviceId3,
                  //   'device_name3': deviceName3,
                  //   'occ-on-duty': OccOnDuty,
                  //   'handover-from': userUid,
                  //   'statusDevice': 'waiting-confirmation-other-pilot',
                  //   'timestamp': FieldValue.serverTimestamp(),
                  //   'remarks' : '',
                  //   'prove_image_url': '',
                  //   'handover-to-crew': '-',
                  //   'field_hub': hubField, // Add 'hub' field
                  // });

                  Navigator.pop(context); // Close the ReturnOtherPilotView
                } else {
                  // Handle invalid input, show a message, or prevent submission
                }
              },
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
        title: Text('Return Other Pilot'),
        centerTitle: true,
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: 'Enter ID Number',
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      // Trigger barcode scanning
                      String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
                          '#FF0000', 'Cancel', true, ScanMode.BARCODE);

                      if (barcodeScanResult != '-1') {
                        // Update the text field with the scanned result
                        setState(() {
                          _idController.text = barcodeScanResult;
                        });
                        // Fetch user data for the scanned ID
                        await _fetchUserData(barcodeScanResult);
                      }
                    },
                    child: Icon(Icons.qr_code_2),
                  ),
                ],
              ),

              SizedBox(height: 16.0),
              if (usersStream == null && selectedUser == null)
                Center(
                  child: Text('Please select the user'),
                ),
              if (usersStream != null)
                StreamBuilder<QuerySnapshot>(
                  stream: usersStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    final users = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return ListTile(
                          title: Text(user.id), // Display the document ID
                          onTap: () {
                            _idController.text = user.id;
                            _fetchUserData(user.id);
                            setState(() {
                              usersStream = null;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              SizedBox(height: 16.0),
              if (selectedUser != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected User:',
                      style: TextStyle(fontSize: 18),
                    ),
                    Row(
                      children: [
                        Expanded(flex: 6, child: Text("ID NO", style: tsOneTextTheme.bodySmall,)),
                        Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                        Expanded(
                          flex: 6,
                          child: Text(
                            '${selectedUser!['ID NO']}',
                            style: tsOneTextTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      children: [
                        Expanded(flex: 6, child: Text("Name", style: tsOneTextTheme.bodySmall,)),
                        Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                        Expanded(
                          flex: 6,
                          child: Text(
                            '${selectedUser!['NAME']}',
                            style: tsOneTextTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(flex: 6, child: Text("Rank", style: tsOneTextTheme.bodySmall,)),
                        Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                        Expanded(
                          flex: 6,
                          child: Text(
                            '${selectedUser!['RANK']}',
                            style: tsOneTextTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(flex: 6, child: Text("HUB", style: tsOneTextTheme.bodySmall,)),
                        Expanded(flex: 1, child: Text(":",style: tsOneTextTheme.bodySmall,)),
                        Expanded(
                          flex: 6,
                          child: Text(
                            '${selectedUser!['HUB']}',
                            style: tsOneTextTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: () async {
                  // Show the confirmation dialog when the Confirm button is pressed
                  await _showConfirmationDialog();
                },
                child: Text('Confirm'),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }
}

Future<void> _showQuickAlert(BuildContext context) async {
  await QuickAlert.show(
    context: context,
    type: QuickAlertType.success,
    text: 'You have Returned To Other Crew! Thankss Capt!',
  );
  Navigator.of(context).pop();
}

Future<String> getHubFromDeviceName(String deviceName2, String deviceName3) async {
  String hub = "Unknown Hub"; // Default value

  try {
    // Fetch the 'hub' field from the 'Device' collection based on deviceName
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Device')
        .where('deviceno', whereIn: [deviceName2, deviceName3])
        .get();


    if (querySnapshot.docs.isNotEmpty) {
      hub = querySnapshot.docs.first['hub'];
    }
  } catch (e) {
    print("Error getting hub from Device: $e");
  }

  return hub;
}
