import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';
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
      icon: const Icon(
        Icons.more_vert_outlined,
        color: TsOneColor.primary,
      ),
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
              Icon(Icons.edit, color: TsOneColor.orangeColor),
              SizedBox(width: 8),
              Text('Edit Device'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'show',
          child: Row(
            children: [
              Icon(Icons.qr_code, color: Colors.lightBlueAccent),
              SizedBox(width: 8),
              Text('Show QR Code'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Device'),
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
            style: tsOneTextTheme.headlineLarge,
          ),
          content: Text(
            'Are you sure you want to delete this device?',
          ),
          actions: <Widget>[
            Container(
              width: 115,
              child: TextButton(
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: TsOneColor.onSecondary))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No',
                      style: TextStyle(color: TsOneColor.onSecondary))),
            ),
            SizedBox(
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
                  child: Text('Yes',
                      style: TextStyle(color: TsOneColor.onPrimary))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'List of Device',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: Padding(
        //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 155,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: TsOneColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
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
            Container(
              height: 60,
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search Device Number",
                  hintStyle: TextStyle(
                    color: TsOneColor.onSecondary,
                  ),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: collectionReference,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No Device found',
                        style: tsOneTextTheme.labelSmall,
                      ),
                    );
                  }

                  final filteredData = snapshot.data!.docs
                      .where((e) => e["deviceno"]
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();

                  if (filteredData.isEmpty) {
                    return Center(
                      child: Text(
                        'No Device found',
                        style: tsOneTextTheme.labelSmall,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final e = filteredData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 3),
                        child: Container(
                          child: Expanded(
                              child: DecoratedBox(
                            decoration: BoxDecoration(
                                //color: TsOneColor.secondaryContainer,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0),
                                boxShadow: const [
                                  BoxShadow(
                                      color: TsOneColor.surface,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: Offset(1, 1),
                                      blurStyle: BlurStyle.normal)
                                ]),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    "${e["deviceno"]}",
                                    style: tsOneTextTheme.bodyMedium,
                                  ),
                                  trailing: _buildEditDeleteButton(e),
                                ),
                              ],
                            ),
                          )),
                          // child: Card(
                          //   color: TsOneColor.surface,
                          //   child: Column(
                          //     children: [
                          //       ListTile(
                          //         title: Text(
                          //           "${e["deviceno"]}",
                          //           style: tsOneTextTheme.bodyMedium,
                          //         ),
                          //         trailing: _buildEditDeleteButton(e),
                          //       ),
                          //     ],
                          //   ),
                          // ),
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
    );
  }
}
