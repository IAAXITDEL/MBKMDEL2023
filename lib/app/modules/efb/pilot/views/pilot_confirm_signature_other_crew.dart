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

class ConfirmSignatureReturnOtherPilotView extends StatefulWidget {
  final String deviceName;
  final String deviceId;
  final GlobalKey<SfSignaturePadState> _signaturePadKey =
      GlobalKey<SfSignaturePadState>();
  Uint8List? signatureImage;

  ConfirmSignatureReturnOtherPilotView({
    required this.deviceName,
    required this.deviceId,
  });

  @override
  _ConfirmSignatureReturnOtherPilotViewState createState() =>
      _ConfirmSignatureReturnOtherPilotViewState();
}

class _ConfirmSignatureReturnOtherPilotViewState
    extends State<ConfirmSignatureReturnOtherPilotView> {
  final TextEditingController remarksController = TextEditingController();
  File? selectedImage; // File to store the selected image
  final ImagePicker _imagePicker = ImagePicker(); // ImagePicker instance
  String deviceId = "";
  String deviceName = "";
  String OccOnDuty = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<SfSignaturePadState> _signaturePadKey =
      GlobalKey<SfSignaturePadState>();
  bool isSignatureEmpty = true;
  bool agree = false;

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
          deviceId = documentSnapshot['device_uid'];
          deviceName = documentSnapshot['device_name'];
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
    final pickedImageCamera =
        await _imagePicker.pickImage(source: ImageSource.camera);

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
      barrierDismissible:
          false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmation Return',
            style: tsOneTextTheme.headlineLarge,
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to confirm the return of this device and retain this signature?'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextButton(
                    child: const Text('No',
                        style: TextStyle(color: TsOneColor.secondaryContainer)),
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
                    child: const Text('Yes',
                        style: TextStyle(color: TsOneColor.onPrimary)),
                    onPressed: () async {
                      // Show a circular button with "Please Wait" message
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16.0),
                                Text('Please Wait'),
                              ],
                            ),
                          );
                        },
                      );

                      // Delay execution for demonstration purposes (you can remove this in your actual code)
                      await Future.delayed(const Duration(seconds: 2));

                      final remarks = remarksController.text;
                      // Check if the signature is empty

                      // Upload the signature to Firebase Storage
                      final image = await _signaturePadKey.currentState
                          ?.toImage(pixelRatio: 3.0);
                      final ByteData? byteData =
                          await image?.toByteData(format: ImageByteFormat.png);
                      final Uint8List? uint8List =
                          byteData?.buffer.asUint8List();
                      final Reference storageReference = FirebaseStorage
                          .instance
                          .ref()
                          .child('signatures/${DateTime.now()}.png');
                      final UploadTask uploadTask =
                          storageReference.putData(uint8List!);

                      // Upload the selected image to Firebase Storage (if an image is selected)
                      String imageUrl = '';
                      if (selectedImage != null) {
                        final storageRef = FirebaseStorage.instance
                            .ref()
                            .child('images/${widget.deviceId}.jpg');
                        await storageRef.putFile(selectedImage!);
                        imageUrl = await storageRef.getDownloadURL();
                      }

                      if (_signaturePadKey == null) {
                        // Show alert if the signature is empty
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Signature Required',
                                style: tsOneTextTheme.headlineLarge,
                              ),
                              content:
                                  const Text('Please provide your signature.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
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
                        String signatureUrl =
                            await storageReference.getDownloadURL();
                        // Update Firestore
                        await FirebaseFirestore.instance
                            .collection('pilot-device-1')
                            .doc(widget.deviceId)
                            .update({
                          'statusDevice': 'handover-to-other-crew',
                          'remarks': remarks,
                          'prove_image_url': imageUrl,
                          'signature_url_other_crew': signatureUrl,
                        });
                      });

                      User? user = _auth.currentUser;
                      QuerySnapshot userQuery = await _firestore
                          .collection('users')
                          .where('EMAIL', isEqualTo: user?.email)
                          .get();
                      String userUid = userQuery.docs.first.id;

                      String hubField =
                          await getHubFromDeviceName(deviceName) ??
                              "Unknown Hub";

                      // Membuat referensi koleksi 'pilot-device-1' tanpa menambahkan dokumen
                      CollectionReference pilotDeviceCollection =
                          _firestore.collection('pilot-device-1');

                      // Mendapatkan ID dokumen yang baru akan dibuat
                      String newDeviceId = pilotDeviceCollection.doc().id;

                      await pilotDeviceCollection.doc(newDeviceId).set({
                        'user_uid': userUid,
                        'device_uid': deviceId,
                        'device_name': deviceName,
                        'document_id': newDeviceId, // Tambahkan document_id di sini
                        'occ-on-duty': OccOnDuty,
                        'handover-from': '-',
                        'statusDevice': 'in-use-pilot',
                        'timestamp': FieldValue.serverTimestamp(),
                        'remarks': '',
                        'prove_image_url': '',
                        'handover-to-crew': '-',
                        'occ-accepted-device': '-',
                        'field_hub': hubField, // Add 'hub' field
                        'field_hub2': '', // Add 'hub' field
                      });

                      // Call the _showQuickAlert function
                      _showQuickAlert(context);

                      // Return to the previous page

                      print(newDeviceId);
                    },
                  ),
                ),
              ],
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
      return Container(
        width: 330,
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.file(
              selectedImage!,
              width: 330,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Confirmation',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0), // Adjust the padding here
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("pilot-device-1")
                .doc(widget.deviceId)
                .get(),
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

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .doc(data['handover-to-crew'])
                    .get(),
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

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("users")
                        .doc(data['user_uid'])
                        .get(),
                    builder: (context, otheruserSnapshot) {
                      if (otheruserSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (otheruserSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${otheruserSnapshot.error}'));
                      }

                      if (!otheruserSnapshot.hasData ||
                          !otheruserSnapshot.data!.exists) {
                        return const Center(
                            child: Text('Other Crew data not found'));
                      }

                      final otheruserData = otheruserSnapshot.data!.data()
                          as Map<String, dynamic>;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("Device")
                            .doc(data['device_uid'])
                            .get(),
                        builder: (context, device2Snapshot) {
                          if (device2Snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (device2Snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${device2Snapshot.error}'));
                          }

                          if (!device2Snapshot.hasData ||
                              !device2Snapshot.data!.exists) {
                            return const Center(
                                child: Text('Device data 2 not found'));
                          }

                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20.0),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Report Any Damage",
                                    style: tsOneTextTheme.headlineMedium,
                                  ),
                                ),
                                //Text('If something doesn' 't match, please inform us!'),

                                const SizedBox(height: 10.0),

                                // TextField(
                                //   controller: remarksController,
                                //   decoration: InputDecoration(
                                //     labelText: 'Remarks',
                                //     border: OutlineInputBorder(), // Add a border
                                //     hintText: 'Enter your remarks here', // Optional hint text
                                //     contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12), // Adjust vertical padding
                                //   ),
                                //   maxLines: null, // Allows multiple lines of text
                                // ),
                                const SizedBox(height: 5.0),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Remarks",
                                      style: tsOneTextTheme.bodyMedium),
                                ),
                                //Text('If something doesn' 't match, please take pictures of the damage!'),
                                const SizedBox(height: 5.0),
                                TextField(
                                  controller: remarksController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter your remarks',
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        tsOneColorScheme.secondaryContainer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      //side: BorderSide(color: TsOneColor.onSecondary, width: 1),
                                    ),
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: TsOneColor.secondary,
                                        size: 28,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Take a photo of the damage",
                                          style: TextStyle(color: Colors.white))
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10.0),
                                // Display the selected image
                                _buildSelectedImage(),
                                // Add the SignaturePad widget
                                const SizedBox(height: 20.0),
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
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          'Please sign in the provided section',
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
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Signature",
                                    style: tsOneTextTheme.headlineMedium,
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 40,
                                    minWidth: 400,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: tsOneColorScheme.primary,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(25.0),
                                        topRight: Radius.circular(25.0),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text("Draw",
                                          style: TextStyle(
                                              color: tsOneColorScheme.secondary,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      height: 480,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                          bottomLeft: Radius.circular(25.0),
                                          bottomRight: Radius.circular(25.0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: SfSignaturePad(
                                        key: _signaturePadKey,
                                        backgroundColor: Colors.white,
                                        onDrawEnd: () async {
                                          final signatureImageData =
                                              await _signaturePadKey
                                                  .currentState!
                                                  .toImage();
                                          final byteData =
                                              await signatureImageData
                                                  .toByteData(
                                                      format:
                                                          ImageByteFormat.png);
                                          // if (byteData != null) {
                                          //   setState(() {
                                          //     widget.signatureImage = byteData.buffer.asUint8List();
                                          //   });
                                          // }
                                        },
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_outlined,
                                          size: 32,
                                          color: TsOneColor.primary,
                                        ),
                                        onPressed: () {
                                          _clearSignature();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),

                                Row(
                                  children: [
                                    StatefulBuilder(
                                      builder: (context, setState) {
                                        return Checkbox(
                                          value: agree,
                                          onChanged: (value) {
                                            setState(() {
                                              agree = value!;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                    const Text(
                                        'I agree with all of the results',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300)),
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
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: tsOneColorScheme.secondary,
        child: ElevatedButton(
          // onPressed: () {
          //   // Call the function to update status and upload image
          //   _showConfirmationDialog();
          //   print('device name: ' + widget.deviceName);
          // },
          onPressed: () async {
            final signatureData =
                await _signaturePadKey.currentState!.toImage();
            if (!agree) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Please checklist consent"),
                  duration: const Duration(milliseconds: 1000),
                  action: SnackBarAction(
                    label: 'Close',
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            } else if (_signaturePadKey.currentState?.clear == null) {
              //widget._signaturePadKey.currentState!.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Please provide signature"),
                  duration: const Duration(milliseconds: 1000),
                  action: SnackBarAction(
                    label: 'Close',
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            } else {
              _showConfirmationDialog();
              print('device name: ' + widget.deviceName);
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: TsOneColor.greenColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              )),
          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

Future<String> getHubFromDeviceName(String deviceName) async {
  String hub = "Unknown Hub"; // Default value

  try {
    // Fetch the 'hub' field from the 'Device' collection based on deviceName
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Device')
        .where('deviceno', whereIn: [
      deviceName,
    ]).get();

    if (querySnapshot.docs.isNotEmpty) {
      hub = querySnapshot.docs.first['hub'];
    }
  } catch (e) {
    print("Error getting hub from Device: $e");
  }

  return hub;
}
