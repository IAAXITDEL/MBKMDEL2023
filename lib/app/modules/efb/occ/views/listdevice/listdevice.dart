  import 'dart:io';

  import 'package:avatar_glow/avatar_glow.dart';
  import 'package:excel/excel.dart';
  import 'package:firebase_database/firebase_database.dart';
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:get/get.dart';
  import 'package:open_file/open_file.dart';
  import 'package:path_provider/path_provider.dart';
  import 'package:quickalert/quickalert.dart';
  import 'package:ts_one/app/modules/efb/occ/model/device.dart';
  import 'package:ts_one/app/modules/efb/occ/views/listdevice/editdevice.dart';
  import 'package:ts_one/app/modules/efb/occ/views/listdevice/adddevice.dart';
  import 'package:ts_one/app/modules/efb/occ/views/listdevice/showdevice.dart';
  import 'package:ts_one/app/modules/efb/occ/controllers/device_controller.dart';
  import 'package:uuid/uuid.dart';

  import '../../../../../../presentation/theme.dart';
  import '../../../../../../util/empty_screen_efb.dart';
  import '../../../../../routes/app_pages.dart';

  class ListDevice extends StatefulWidget {
    @override
    State<StatefulWidget> createState() {
      return _ListDeviceState();
    }
  }

  class _ListDeviceState extends State<ListDevice> {
    final Stream<QuerySnapshot> collectionReference =
    DeviceController.readDevice();
    String searchQuery = "";
    TextEditingController searchController = TextEditingController();
    final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

    // Widget _buildEditDeleteButton(DocumentSnapshot e) {
    //   return PopupMenuButton(
    //     icon: const Icon(
    //       Icons.more_vert_outlined,
    //       color: TsOneColor.primary,
    //     ),
    //     onSelected: (value) {
    //       if (value == 'edit') {
    //         // Navigate to the EditDevice screen
    //         Navigator.pushAndRemoveUntil<dynamic>(
    //           context,
    //           MaterialPageRoute<dynamic>(
    //             builder: (BuildContext context) => EditDevice(
    //               device: Device(
    //                 uid: e.id,
    //                 deviceno: e["deviceno"],
    //                 iosver: e["iosver"],
    //                 flysmart: e["flysmart"],
    //                 lidoversion: e["lidoversion"],
    //                 docuversion: e["docuversion"],
    //                 hub: e["hub"],
    //                 condition: e["condition"],
    //               ),
    //             ),
    //           ),
    //           (route) => true,
    //         );
    //       } else if (value == 'delete') {
    //         _showDeleteConfirmationDialog(e.id);
    //       } else if (value == 'show') {
    //         Navigator.pushAndRemoveUntil<dynamic>(
    //           context,
    //           MaterialPageRoute<dynamic>(
    //             builder: (BuildContext context) => ShowDevice(
    //               device: Device(
    //                 uid: e.id,
    //                 deviceno: e["deviceno"],
    //                 iosver: e["iosver"],
    //                 flysmart: e["flysmart"],
    //                 lidoversion: e["lidoversion"],
    //                 docuversion: e["docuversion"],
    //                 hub: e["hub"],
    //                 condition: e["condition"],
    //               ),
    //             ),
    //           ),
    //           (route) => true,
    //         );
    //       }
    //     },
    //     itemBuilder: (context) => [
    //       const PopupMenuItem(
    //         value: 'show',
    //         child: Row(
    //           children: [
    //             Icon(Icons.info_outlined, color: Colors.lightBlueAccent),
    //             SizedBox(width: 8),
    //             Text('Device Info - QR'),
    //           ],
    //         ),
    //       ),
    //       const PopupMenuItem(
    //         value: 'edit',
    //         child: Row(
    //           children: [
    //             Icon(Icons.edit, color: TsOneColor.orangeColor),
    //             SizedBox(width: 8),
    //             Text('Edit Device'),
    //           ],
    //         ),
    //       ),
    //       const PopupMenuItem(
    //         value: 'delete',
    //         child: Row(
    //           children: [
    //             Icon(Icons.delete, color: Colors.red),
    //             SizedBox(width: 8),
    //             Text('Delete Device'),
    //           ],
    //         ),
    //       ),
    //     ],
    //   );
    // }

    Future<void> _refreshData() async {
      try {
        // Fetch data from Realtime Database (Sheet1)
        DatabaseEvent event = await firebaseDatabase
            .reference()
            .child('1zRoTlgi_c0z8g6W27FsEr5_uiSxO9gAhrepRZtzPEFA/EFB-Device')
            .once();
        DataSnapshot dataSnapshot = event.snapshot;

        // Convert dynamic map to string mapp
        Map<dynamic, dynamic>? dynamicData =
        dataSnapshot.value as Map<dynamic, dynamic>?;

        if (dynamicData == null) {
          print('Error: No data found in Realtime Database.');
          return;
        }

        Map<String, dynamic> data = Map<String, dynamic>.from(dynamicData);

        // Save data to Firestore in the Device collection
        CollectionReference deviceCollection =
        FirebaseFirestore.instance.collection('Device');

        // Delete all documents in the Device collection
        QuerySnapshot deviceSnapshot = await deviceCollection.get();
        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (QueryDocumentSnapshot doc in deviceSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // Add new data from Realtime Database to Firestore using batch write
        List<String> invalidKeys = [];

        data.forEach((key, value) {
          print('Key: $key, Type: ${key.runtimeType}');
          print('Value: $value, Type: ${value.runtimeType}');

          if (key is String) {
            // Convert the value to Map<String, dynamic> if it's not already
            Map<String, dynamic> convertedValue = value is Map<String, dynamic>
                ? value
                : {'value': value}; // Change this line based on your data structure

            DocumentReference docRef = deviceCollection.doc(key);
            batch.set(docRef, convertedValue);
          } else {
            print('Error: Key is not in the expected format.');
            if (!(key is String)) {
              print('Invalid Key: $key (Not a String)');
              invalidKeys.add(key.toString());
            }
          }
        });

        // Print invalid keys for this iteration
        print(invalidKeys);

        // Check if there are invalid entries before committing the batch
        if (invalidKeys.isEmpty) {
          await batch.commit();
          // Notify the user that data has been refreshed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data refreshed successfully.'),
            ),
          );
        } else {
          print('Error: Invalid keys found. Batch not committed.');
        }
      } on FirebaseException catch (error) {
        // Handle Firebase-related errors
        print('Firebase Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error refreshing data. Please try again.'),
          ),
        );
      } catch (error) {
        // Handle other errors that may occur
        print('Error refreshing data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error refreshing data. Please try again.'),
          ),
        );
      }
    }

    Future<void> exportToExcel(List<Map<String, dynamic>> data) async {
      final CollectionReference deviceCollection =
          FirebaseFirestore.instance.collection('Device');
      QuerySnapshot deviceSnapshot = await deviceCollection.get();
      List<Map<String, dynamic>> data = deviceSnapshot.docs
          .map((DocumentSnapshot document) =>
              document.data() as Map<String, dynamic>)
          .toList();
      // Create an Excel workbook
      final excel = Excel.createExcel();

      // Create a worksheet
      final sheet = excel['Main Data'];

      // Add headers
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
          'Device No';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
          'IOS Version';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
          'Lido mPilot Version';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
          'Flysmart';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
          'Docunet Version';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
          'Hub';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value =
          'Condition';

      // Add data to the worksheet
      for (var i = 0; i < data.length; i++) {
        final device = data[i];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = device['value']['deviceno'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = device['value']['iosver'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
            .value = device['value']['lidoversion'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
            .value = device['value']['flysmart'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
            .value = device['value']['docuversion'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
            .value = device['value']['hub'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1))
            .value = device['value']['condition'];
      }

      // Save the Excel file
      final excelBytes = excel.encode();
      final output = await getTemporaryDirectory();
      final excelFile = File('${output.path}/device-data.xlsx');
      await excelFile.writeAsBytes(excelBytes!);

      // Open the Excel file using a platform-specific API
      // In this example, we'll use the OpenFile package to open the file
      await OpenFile.open(excelFile.path,
          type:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    }

    Future<void> _showDeleteConfirmationDialog(String deviceId) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFFE6E6E6),
            title: Text(
              'Delete Device',
              style: tsOneTextTheme.headlineLarge,
            ),
            content: const Text(
              'Are you sure you want to delete this device?',
            ),
            actions: <Widget>[
              Container(
                width: 115,
                child: TextButton(
                    style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: const BorderSide(color: TsOneColor.onSecondary))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No',
                        style: TextStyle(color: TsOneColor.onSecondary))),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                width: 115,
                child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: TsOneColor.greenColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        )),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      var response =
                          await DeviceController.deleteDevice(uid: deviceId);

                      if (response.code == 200) {
                        await QuickAlert.show(
                            context: context,
                            type: QuickAlertType.success,
                            text: 'Device successfully delete');
                      }
                    },
                    child: const Text('Yes',
                        style: TextStyle(color: TsOneColor.onPrimary))),
              ),
            ],
          );
        },
      );
    }

    Future<List<Map<String, dynamic>>> fetchDataFromFirebase() async {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('your_collection').get();

      List<Map<String, dynamic>> data = [];
      querySnapshot.docs.forEach((doc) {
        data.add(doc.data() as Map<String, dynamic>);
      });

      return data;
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'List Device',
            style: tsOneTextTheme.headlineLarge,
          ),
          centerTitle: true,
          actions: [
            Tooltip(
              message: 'Export to Sheet',
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshData,
              )
              // IconButton(
              //   icon: const Icon(
              //     Icons.table_chart_rounded,
              //   ),
              //   onPressed: () async {
              //     List<Map<String, dynamic>> data = await fetchDataFromFirebase();
              //     await exportToExcel(data);
              //   },
              // ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 60,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Search Device Name",
                    hintStyle: TextStyle(
                      color: TsOneColor.onSecondary,
                    ),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 10),
                child: StreamBuilder<QuerySnapshot>(
                  stream: collectionReference,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final deviceCount =
                        snapshot.hasData ? snapshot.data!.docs.length : 0;

                    return Text('Total Devices: $deviceCount',
                        style: tsOneTextTheme.headlineMedium);
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: collectionReference,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const EmptyScreenEFB();
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const EmptyScreenEFB();
                    }

                    final filteredData = snapshot.data!.docs
                        .where((e) => e["value"]["deviceno"]
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .take(20) // Limit the number of items to 20
                        .toList();

                    if (filteredData.isEmpty) {
                      return const EmptyScreenEFB();
                    }
                    if (filteredData.isEmpty) {
                      return const EmptyScreenEFB();
                    }

                    return ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final e = filteredData[index];
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (BuildContext context) =>
                                        ShowDevice(
                                      device: Device( //
                                        uid: e.id,
                                        deviceno: e["value"]["deviceno"],
                                        iosver: e["value"]["iosver"],
                                        flysmart: e["value"]["flysmart"],
                                        lidoversion: e["value"]["lidoversion"],
                                        docuversion: e["value"]["docuversion"],
                                        hub: e["value"]["hub"],
                                        condition: e["value"]["condition"],
                                      ),
                                    ),
                                  ),
                                  (route) => true,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tsOneColorScheme.secondary,
                                foregroundColor:
                                    tsOneColorScheme.secondaryContainer,
                                surfaceTintColor: tsOneColorScheme.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                          "${e["value"]["deviceno"]}",
                                          style: tsOneTextTheme.bodyMedium,
                                        )
                                    ),
                                    //_buildEditDeleteButton(e),
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
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: AvatarGlow(
          endRadius: 40,
          glowColor: Colors.black,
          duration: const Duration(seconds: 2),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) => const AddDevice()),
              );
            },
            child: const Icon(Icons.add),
            backgroundColor: TsOneColor.primary,
          ),
        ),
      );
    }
  }
