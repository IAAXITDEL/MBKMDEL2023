  import 'dart:typed_data';
  import 'dart:ui';
  
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:get/get.dart';
  import 'package:image_picker/image_picker.dart'; // For camera feature
  import 'package:firebase_storage/firebase_storage.dart'; // For uploading images to Firebase Storage
  import 'package:quickalert/models/quickalert_type.dart';
  import 'package:quickalert/widgets/quickalert_dialog.dart';
  import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
  import 'package:path/path.dart' as Path;
  
  import 'dart:io'; // For handling selected image file
  
  
  import '../../../../../presentation/theme.dart';
  import '../../../../routes/app_pages.dart';
  
  class ConfirmSignatureReturnOtherFOView extends StatefulWidget {
    final String deviceName2;
    final String deviceName3;
    final String deviceId;
  
    ConfirmSignatureReturnOtherFOView({
      required this.deviceName2,
      required this.deviceName3,
      required this.deviceId,
    });
  
    @override
    _ConfirmSignatureReturnOtherFOViewState createState() => _ConfirmSignatureReturnOtherFOViewState();
  
  }
  
  class _ConfirmSignatureReturnOtherFOViewState extends State<ConfirmSignatureReturnOtherFOView> {
    final TextEditingController remarksController = TextEditingController();
    File? selectedImage; // File to store the selected image
    final ImagePicker _imagePicker = ImagePicker(); // ImagePicker instance
    String deviceId2 = "";
    String deviceId3 = "";
    String deviceName2 = "";
    String deviceName3 = "";
    String OccOnDuty = "";
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();
    bool isSignatureEmpty = true;
  
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
  
    }
  
    // Function to clear the signature
    void _clearSignature() {
      _signaturePadKey.currentState?.clear();
    }
  
  
  
    // Function to update status in Firestore and upload image to Firebase Storage
  
    // Function to open the image picker
    Future<void> _pickImage() async {
      final pickedImageCamera = await _imagePicker.pickImage(source: ImageSource.camera);
  
      if (pickedImageCamera != null) {
        setState(() {
          selectedImage = File(pickedImageCamera.path);
        });
      }
    }
  
    // Function to show a success message using QuickAlert
    Future<void> _showQuickAlert(BuildContext context) async {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'You have successfully added a device',
      );
      Get.offAllNamed(Routes.NAVOCC);
    }
  
    Future<void> _showConfirmationDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Return'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to confirm the return of this device?'),
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
                  final remarks = remarksController.text;


                  // Check if the signature is empty
  
                  // Upload the signature to Firebase Storage
                  final image = await _signaturePadKey.currentState?.toImage(pixelRatio: 3.0);
                  final ByteData? byteData = await image?.toByteData(format: ImageByteFormat.png);
                  final Uint8List? uint8List = byteData?.buffer.asUint8List();
                  final Reference storageReference = FirebaseStorage.instance.ref().child('signatures/${Path.basename(widget.deviceId)}.png');
                  final UploadTask uploadTask = storageReference.putData(uint8List!);

  
  
                  // Upload the selected image to Firebase Storage (if an image is selected)
                  String imageUrl = '';
                  if (selectedImage != null) {
                    final storageRef = FirebaseStorage.instance.ref().child('images/${widget.deviceId}.jpg');
                    await storageRef.putFile(selectedImage!);
                    imageUrl = await storageRef.getDownloadURL();
                  }

                  if (_signaturePadKey == null) {
                    // Show alert if the signature is empty
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Signature Required'),
                          content: Text('Please provide your signature.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                    return; // Do not proceed with confirmation
                  }
                  await uploadTask.whenComplete(() async {
                    String signatureUrl = await storageReference.getDownloadURL();
                    // Update Firestore
                    await FirebaseFirestore.instance.collection(
                        'pilot-device-1').doc(widget.deviceId).update({
                      'statusDevice': 'handover-to-other-crew',
                      'remarks': remarks,
                      'prove_image_url': imageUrl,
                      'signature_url_other_crew': signatureUrl,
                    });
                  });
  
  
                  User? user = _auth.currentUser;
                  QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user?.email).get();
                  String userUid = userQuery.docs.first.id;
  
                  String hubField = await getHubFromDeviceName(deviceName2, deviceName3) ?? "Unknown Hub";

                  // Membuat referensi koleksi 'pilot-device-1' tanpa menambahkan dokumen
                  CollectionReference pilotDeviceCollection =
                  _firestore.collection('pilot-device-1');

                  // Mendapatkan ID dokumen yang baru akan dibuat
                  String newDeviceId = pilotDeviceCollection.doc().id;

                  await pilotDeviceCollection.doc(newDeviceId).set({
                    'user_uid': userUid,
                    'device_uid': '-',
                    'device_name': '-',
                    'document_id': newDeviceId,  // Tambahkan document_id di sini
                    'device_uid2': deviceId2,
                    'device_name2': deviceName2,
                    'device_uid3': deviceId3,
                    'device_name3': deviceName3,
                    'occ-on-duty': OccOnDuty,
                    'handover-from': '-',
                    'statusDevice': 'in-use-pilot',
                    'timestamp': FieldValue.serverTimestamp(),
                    'remarks' : '',
                    'prove_image_url': '',
                    'handover-to-crew': '-',
                    'occ-accepted-device': '-',
                    'field_hub': hubField, // Add 'hub' field
                  });

  
                  // Return to the previous page
                  _showQuickAlert(context);
                  print(newDeviceId);
                },
              ),
            ],
          );
        },
      );
    }
  
  
  
    Widget _buildSelectedImage() {
      if (selectedImage == null) {
        return Container();
      } else {
        return Image.file(
          selectedImage!,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        );
      }
    }
  
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Confirmation'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust the padding here
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("pilot-device-1").doc(widget.deviceId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
  
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
  
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('Data not found'));
                }
  
                final data = snapshot.data!.data() as Map<String, dynamic>;
  
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection("users").doc(data['handover-to-crew']).get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
  
                    if (userSnapshot.hasError) {
                      return Center(child: Text('Error: ${userSnapshot.error}'));
                    }
  
                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return Center(child: Text('User data not found'));
                    }
  
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
  
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection("users").doc(data['user_uid']).get(),
                      builder: (context, otheruserSnapshot) {
                        if (otheruserSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
  
                        if (otheruserSnapshot.hasError) {
                          return Center(child: Text('Error: ${otheruserSnapshot.error}'));
                        }
  
                        if (!otheruserSnapshot.hasData || !otheruserSnapshot.data!.exists) {
                          return Center(child: Text('Other Crew data not found'));
                        }
  
                        final otheruserData = otheruserSnapshot.data!.data() as Map<String, dynamic>;
  
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection("Device").doc(data['device_uid2']).get(),
                          builder: (context, device2Snapshot) {
                            if (device2Snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
  
                            if (device2Snapshot.hasError) {
                              return Center(child: Text('Error: ${device2Snapshot.error}'));
                            }
  
                            if (!device2Snapshot.hasData || !device2Snapshot.data!.exists) {
                              return Center(child: Text('Device data 2 not found'));
                            }
  
                            final deviceData2 = device2Snapshot.data!.data() as Map<String, dynamic>;
  
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection("Device").doc(data['device_uid3']).get(),
                              builder: (context, device3Snapshot) {
                                if (device3Snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }
  
                                if (device3Snapshot.hasError) {
                                  return Center(child: Text('Error: ${device3Snapshot.error}'));
                                }
  
                                if (!device3Snapshot.hasData || !device3Snapshot.data!.exists) {
                                  return Center(child: Text('Device data not found'));
                                }
  
                                final deviceData3 = device3Snapshot.data!.data() as Map<String, dynamic>;
  
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20.0),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "PROOF",
                                          style: tsOneTextTheme.titleLarge,
                                        ),
                                      ),
                                      Text('If something doesn''t match, please inform us!'),
  
  
                                      SizedBox(height: 20.0),
  
                                      TextField(
                                        controller: remarksController,
                                        decoration: InputDecoration(
                                          labelText: 'Remarks',
                                          border: OutlineInputBorder(), // Add a border
                                          hintText: 'Enter your remarks here', // Optional hint text
                                          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12), // Adjust vertical padding
                                        ),
                                        maxLines: null, // Allows multiple lines of text
                                      ),
  
                                      SizedBox(height: 20.0),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "PICK AN IMAGE",
                                          style: tsOneTextTheme.titleLarge,
                                        ),
                                      ),
                                      Text('If something doesn''t match, please take pictures of the damage!'),
                                      SizedBox(height: 5.0),
  
                                      // Button to open the image picker
                                      // Button to open the image picker
                                      ElevatedButton(
                                        onPressed: _pickImage,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          minimumSize: const Size(double.infinity, 50),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt, // Use the camera icon
                                              color: Colors.red, // Set the icon color
                                            ),
                                            SizedBox(width: 8), // Add some space between the icon and text
                                            Text(
                                              'Camera',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
  
                                      SizedBox(height: 7.0),
                                      // Display the selected image
                                      _buildSelectedImage(),
                                      // Add the SignaturePad widget
                                      SizedBox(height: 20.0),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "SIGNATURE",
                                          style: tsOneTextTheme.titleLarge,
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0), // Menambahkan lengkungan pada ujung box
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0, 3), // Mengatur offset bayangan
                                            ),
                                          ],
                                        ),
                                        child: SfSignaturePad(
                                          key: _signaturePadKey,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
  
                                      SizedBox(height: 10.0),
  
                                      // Button to clear the signature
                                      ElevatedButton(
                                        onPressed: _clearSignature,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: TsOneColor.primary,
                                          minimumSize: const Size(double.infinity, 50),
                                        ),
                                        child: const Text('Clear Signature', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          surfaceTintColor: tsOneColorScheme.secondary,
          child: Expanded(
            child: ElevatedButton(
              onPressed: () {

                // Call the function to update status and upload image
                _showConfirmationDialog();
                print('device name: ' + widget.deviceName2);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: TsOneColor.greenColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  )
              ),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      );
    }
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
