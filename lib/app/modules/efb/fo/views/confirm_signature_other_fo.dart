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
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();
  Uint8List? signatureImage;

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
  String charger = "";
  String OccOnDuty = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();
  bool isSignatureEmpty = true;
  bool agree = false;
  String dropdownValue2 = 'Good'; // Default value
  String remarksAccepted2 = '';
  String dropdownValue3 = 'Good'; // Default value
  String remarksAccepted3 = '';

  @override
  void initState() {
    super.initState();
    // Fetch deviceUid, deviceName, and OCC On Duty from Firestore using widget.deviceId
    FirebaseFirestore.instance.collection('pilot-device-1').doc(widget.deviceId).get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          deviceId2 = documentSnapshot['device_uid2'];
          deviceId3 = documentSnapshot['device_uid3'];
          deviceName2 = documentSnapshot['device_name2'];
          deviceName3 = documentSnapshot['device_name3'];
          charger = documentSnapshot['charger_no'];
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
    ).then((value) {
      Get.offAllNamed(Routes.NAVOCC);
    });
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmation Return',
            style: tsOneTextTheme.headlineLarge,
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to confirm the return of this device and retain this signature?'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
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
                      final image = await _signaturePadKey.currentState?.toImage(pixelRatio: 3.0);
                      final ByteData? byteData = await image?.toByteData(format: ImageByteFormat.png);
                      final Uint8List? uint8List = byteData?.buffer.asUint8List();
                      final Reference storageReference = FirebaseStorage.instance.ref().child('signatures/${DateTime.now()}.png');
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
                              title: Text(
                                'Signature Required',
                                style: tsOneTextTheme.headlineLarge,
                              ),
                              content: const Text('Please provide your signature.'),
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
                        String signatureUrl = await storageReference.getDownloadURL();
                        // Update Firestore
                        await FirebaseFirestore.instance.collection('pilot-device-1').doc(widget.deviceId).update({
                          'statusDevice': 'handover-to-other-crew',
                          'remarks': remarks,
                          'prove_image_url': imageUrl,
                          'signature_url_other_crew': signatureUrl,
                          // 'initial-condition-category2': dropdownValue2,
                          // 'initial-condition-remarks2': remarksAccepted2,
                          // 'initial-condition-category3': dropdownValue3,
                          // 'initial-condition-remarks2': remarksAccepted2,
                          'return-condition-category2': dropdownValue2,
                          'return-condition-remarks2': remarksAccepted2,
                          'return-condition-category3': dropdownValue3,
                          'return-condition-remarks3': remarksAccepted3,
                        });
                      });

                      User? user = _auth.currentUser;
                      QuerySnapshot userQuery = await _firestore.collection('users').where('EMAIL', isEqualTo: user?.email).get();
                      String userUid = userQuery.docs.first.id;

                      String hubField = await getHubFromDeviceName2(deviceName2) ?? "Unknown Hub";
                      String hubField2 = await getHubFromDeviceName3(deviceName3) ?? "Unknown Hub";

                      // Membuat referensi koleksi 'pilot-device-1' tanpa menambahkan dokumen
                      CollectionReference pilotDeviceCollection = _firestore.collection('pilot-device-1');

                      // Mendapatkan ID dokumen yang baru akan dibuat
                      String newDeviceId = pilotDeviceCollection.doc().id;

                      await pilotDeviceCollection.doc(newDeviceId).set({
                        'user_uid': userUid,
                        'device_uid': '-',
                        'device_name': '-',
                        'document_id': newDeviceId, // Tambahkan document_id di sini
                        'device_uid2': deviceId2,
                        'device_name2': deviceName2,
                        'device_uid3': deviceId3,
                        'device_name3': deviceName3,
                        'occ-on-duty': OccOnDuty,
                        'handover-from': '-',
                        'statusDevice': 'in-use-pilot',
                        'timestamp': FieldValue.serverTimestamp(),
                        'remarks': '',
                        'prove_image_url': '',
                        'handover-to-crew': '-',
                        'occ-accepted-device': '-',
                        'field_hub': hubField, // Add 'hub' field
                        'charger_no': charger,
                        'field_hub2': hubField2, // Add 'hub' field
                        'initial-condition-category2': dropdownValue2,
                        'initial-condition-remarks2': remarksAccepted2,
                        'initial-condition-category3': dropdownValue3,
                        'initial-condition-remarks2': remarksAccepted2,
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

  // Widget _buildSelectedImage() {
  //   if (selectedImage == null) {
  //     return Container();
  //   } else {
  //     return Image.file(
  //       selectedImage!,
  //       width: 330,
  //       height: 300,
  //       fit: BoxFit.cover,
  //     );
  //   }
  // }

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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("pilot-device-1").doc(widget.deviceId).get(),
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
                future: FirebaseFirestore.instance.collection("users").doc(data['handover-to-crew']).get(),
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
                    future: FirebaseFirestore.instance.collection("users").doc(data['user_uid']).get(),
                    builder: (context, otheruserSnapshot) {
                      if (otheruserSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (otheruserSnapshot.hasError) {
                        return Center(child: Text('Error: ${otheruserSnapshot.error}'));
                      }

                      if (!otheruserSnapshot.hasData || !otheruserSnapshot.data!.exists) {
                        return const Center(child: Text('Other Crew data not found'));
                      }

                      final otheruserData = otheruserSnapshot.data!.data() as Map<String, dynamic>;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection("Device").doc(data['device_uid2']).get(),
                        builder: (context, device2Snapshot) {
                          if (device2Snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (device2Snapshot.hasError) {
                            return Center(child: Text('Error: ${device2Snapshot.error}'));
                          }

                          if (!device2Snapshot.hasData || !device2Snapshot.data!.exists) {
                            return const Center(child: Text('Device data 2 not found'));
                          }

                          final deviceData2 = device2Snapshot.data!.data() as Map<String, dynamic>;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection("Device").doc(data['device_uid3']).get(),
                            builder: (context, device3Snapshot) {
                              if (device3Snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (device3Snapshot.hasError) {
                                return Center(child: Text('Error: ${device3Snapshot.error}'));
                              }

                              if (!device3Snapshot.hasData || !device3Snapshot.data!.exists) {
                                return const Center(child: Text('Device data not found'));
                              }

                              final deviceData3 = device3Snapshot.data!.data() as Map<String, dynamic>;

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
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
                                    Text(
                                      "Here you can explain the condition of the device you received",
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),

                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Device 2",
                                        style: tsOneTextTheme.headlineMedium,
                                      ),
                                    ),
                                    //Text('If something doesn' 't match, please inform us!'),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Row(
                                      children: [
                                        const Expanded(flex: 6, child: Text("Category")),
                                        DropdownButton<String>(
                                          value: dropdownValue2,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              dropdownValue2 = newValue!;
                                            });
                                          },
                                          items: <String>['Good', 'Good With Remarks', 'Unserviceable'].map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16.0),

                                    // Remarks text field
                                    TextField(
                                      onChanged: (value) {
                                        remarksAccepted2 = value;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                        labelText: 'Remarks',
                                        labelStyle: tsOneTextTheme.labelMedium,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),

                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Device 3",
                                        style: tsOneTextTheme.headlineMedium,
                                      ),
                                    ),
                                    //Text('If something doesn' 't match, please inform us!'),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Row(
                                      children: [
                                        const Expanded(flex: 6, child: Text("Category")),
                                        DropdownButton<String>(
                                          value: dropdownValue3,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              dropdownValue3 = newValue!;
                                            });
                                          },
                                          items: <String>['Good', 'Good With Remarks', 'Unserviceable'].map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16.0),

                                    // Remarks text field
                                    TextField(
                                      onChanged: (value) {
                                        remarksAccepted3 = value;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                        labelText: 'Remarks',
                                        labelStyle: tsOneTextTheme.labelMedium,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),

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
                                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Text(
                                              'Report Any Damage',
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
                                    //Text('If something doesn' 't match, please inform us!'),
                                    Text(
                                      "Here you can explain the damage of the device you received",
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),

                                    const SizedBox(height: 10.0),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Remarks", style: tsOneTextTheme.bodyMedium),
                                    ),
                                    const SizedBox(height: 5.0),
                                    // TextField(
                                    //   controller: remarksController,
                                    //   decoration: InputDecoration(
                                    //     labelText: 'Remarks',
                                    //     hintText: 'Enter your remarks here',
                                    //     border: OutlineInputBorder(
                                    //       borderSide: const BorderSide(color: Colors.green),
                                    //     ),
                                    //     contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Adjust vertical padding
                                    //   ),
                                    //   maxLines: null, // Allows multiple lines of text
                                    // ),
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
                                        backgroundColor: tsOneColorScheme.secondaryContainer,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          //side: BorderSide(color: TsOneColor.onSecondary, width: 1),
                                        ),
                                        minimumSize: const Size(double.infinity, 50),
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
                                          Text("Take a photo of the damage", style: TextStyle(color: Colors.white))
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 5.0),
                                    // ElevatedButton(
                                    //   onPressed: _pickImage,
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: tsOneColorScheme.primary,
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius: BorderRadius.circular(8.0),
                                    //       //side: BorderSide(color: TsOneColor.onSecondary, width: 1),
                                    //     ),
                                    //     //minimumSize: const Size(double.infinity, 50),
                                    //   ),
                                    //   child: Row(
                                    //     mainAxisAlignment: MainAxisAlignment.center,
                                    //     children: [
                                    //       Icon(
                                    //         Icons.camera_alt,
                                    //         color: TsOneColor.secondary,
                                    //         size: 28,
                                    //       ),
                                    //       SizedBox(width: 8),
                                    //       Text(
                                    //         'Camera',
                                    //         style: TextStyle(color: TsOneColor.secondary),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
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
                                            padding: EdgeInsets.symmetric(horizontal: 8.0),
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

                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: ConstrainedBox(
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
                                            child: Text("Draw", style: TextStyle(color: tsOneColorScheme.secondary, fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 300,
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
                                                final signatureImageData = await _signaturePadKey.currentState!.toImage();
                                                final byteData = await signatureImageData.toByteData(format: ImageByteFormat.png);
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
                                        Text(
                                          'I agree with all the statements above.',
                                          style: tsOneTextTheme.labelSmall,
                                        )
                                      ],
                                    ),

                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     borderRadius: BorderRadius.circular(10.0), // Menambahkan lengkungan pada ujung box
                                    //     boxShadow: [
                                    //       BoxShadow(
                                    //         color: Colors.grey.withOpacity(0.5),
                                    //         spreadRadius: 5,
                                    //         blurRadius: 8,
                                    //         offset: Offset(0, 3), // Mengatur offset bayangan
                                    //       ),
                                    //     ],
                                    //   ),
                                    //   child: SfSignaturePad(
                                    //     key: _signaturePadKey,
                                    //     backgroundColor: Colors.white,
                                    //   ),
                                    // ),

                                    // SizedBox(height: 10.0),

                                    // // Button to clear the signature
                                    // ElevatedButton(
                                    //   onPressed: _clearSignature,
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: TsOneColor.primary,
                                    //     minimumSize: const Size(double.infinity, 50),
                                    //   ),
                                    //   child: const Text('Clear Signature', style: TextStyle(color: Colors.white)),
                                    // ),
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
            onPressed: () async {
              final signatureData = await _signaturePadKey.currentState!.toImage();
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
                print('device name: ' + widget.deviceName2);
              }
              // _showConfirmationDialog();
              // print('device name: ' + widget.deviceName2);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: TsOneColor.greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                )),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

Future<String> getHubFromDeviceName2(String deviceId) async {
  String hub = "Unknown Hub"; // Nilai default

  try {
    // Fetch the document from the 'Device' collection based on document ID
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('Device').doc(deviceId).get();

    if (documentSnapshot.exists) {
      // Access the data map from the document
      Map<String, dynamic> documentData = documentSnapshot.data() as Map<String, dynamic>;

      // Check if 'value' map exists and contains 'hub' key
      if (documentData.containsKey('value') && documentData['value'] is Map<String, dynamic>) {
        Map<String, dynamic> valueMap = documentData['value'] as Map<String, dynamic>;

        // Check if 'hub' exists in 'value' map
        if (valueMap.containsKey('hub')) {
          // Access the 'hub' field from the 'value' map
          hub = valueMap['hub'] ?? "Unknown Hub";
        }
      }
    }
  } catch (e) {
    print("Error getting hub from Device: $e");
  }

  return hub;
}

Future<String> getHubFromDeviceName3(String deviceId) async {
  String hub = "Unknown Hub"; // Nilai default

  try {
    // Fetch the document from the 'Device' collection based on document ID
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('Device').doc(deviceId).get();

    if (documentSnapshot.exists) {
      // Access the data map from the document
      Map<String, dynamic> documentData = documentSnapshot.data() as Map<String, dynamic>;

      // Check if 'value' map exists and contains 'hub' key
      if (documentData.containsKey('value') && documentData['value'] is Map<String, dynamic>) {
        Map<String, dynamic> valueMap = documentData['value'] as Map<String, dynamic>;

        // Check if 'hub' exists in 'value' map
        if (valueMap.containsKey('hub')) {
          // Access the 'hub' field from the 'value' map
          hub = valueMap['hub'] ?? "Unknown Hub";
        }
      }
    }
  } catch (e) {
    print("Error getting hub from Device: $e");
  }

  return hub;
}
