import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ts_one/app/modules/efb/occ/model/device.dart';
import 'package:ts_one/app/modules/efb/occ/views/listdevice/editdevice.dart';
import 'package:ts_one/app/modules/efb/occ/views/listdevice/adddevice.dart';
import 'package:ts_one/app/modules/efb/occ/views/listdevice/showdevice.dart';
import 'package:ts_one/app/modules/efb/occ/controllers/device_controller.dart';

import '../../../../../../presentation/theme.dart';
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

  Widget _buildEditDeleteButton(DocumentSnapshot e) {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == 'edit') {
          // Navigate to the EditDevice screen
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => EditDevice(
                device: Device(
                  uid: e.id,
                  deviceno: e["deviceno"],
                  iosver: e["iosver"],
                  flysmart: e["flysmart"],
                  lidoversion: e["lidoversion"],
                  docuversion: e["docuversion"],
                  condition: e["condition"],
                ),
              ),
            ),
            (route) => true,
          );
        } else if (value == 'delete') {
          _showDeleteConfirmationDialog(e.id);
        } else if (value == 'show') {
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => ShowDevice(
                device: Device(
                  uid: e.id,
                  deviceno: e["deviceno"],
                  iosver: e["iosver"],
                  flysmart: e["flysmart"],
                  lidoversion: e["lidoversion"],
                  docuversion: e["docuversion"],
                  condition: e["condition"],
                ),
              ),
            ),
            (route) => true,
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.yellowAccent),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'show',
          child: Row(
            children: [
              Icon(Icons.qr_code, color: Colors.lightBlueAccent),
              SizedBox(width: 8),
              Text('Show'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmationDialog(String deviceId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFE6E6E6),
          title: Text(
            'Delete Device',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            'Are you sure you want to delete this device?',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                var response =
                    await DeviceController.deleteDevice(uid: deviceId);
                if (response.code != 200) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(response.message.toString()),
                      );
                    },
                  );
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
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(
          child: Text(
            "List of Device",
            style: tsOneTextTheme.headlineLarge,
          ),
        ),
        backgroundColor: TsOneColor.onPrimary,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 155,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: TsOneColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => AddDevice()),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_box_outlined,
                        color: TsOneColor.onPrimary,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Add Device",
                        style: TextStyle(color: TsOneColor.onPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search Device Number",
                hintStyle: const TextStyle(
                  color: TsOneColor.onSecondary,
                ),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: collectionReference,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final filteredData = snapshot.data!.docs
                        .where((e) => e["deviceno"]
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();

                    if (filteredData.isEmpty) {
                      return Center(
                        child: Text("No Device found",
                            style: tsOneTextTheme.labelSmall),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ListView(
                        children: filteredData.map((e) {
                          return Container(
                            height: 80,
                            child: Card(
                              color: TsOneColor.onPrimary,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      "${e["deviceno"]}",
                                      style: tsOneTextTheme.bodyMedium,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // ... other sub-items ...
                                      ],
                                    ),
                                    trailing: _buildEditDeleteButton(
                                        e), // Pass 'e' here
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }

                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
