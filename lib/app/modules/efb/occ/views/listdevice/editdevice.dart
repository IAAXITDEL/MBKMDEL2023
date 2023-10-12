import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/presentation/theme.dart';

import 'package:ts_one/app/modules/efb/occ/model/device.dart';
import 'package:ts_one/app/modules/efb/occ/controllers/device_controller.dart';

class EditDevice extends StatefulWidget {
  final Device? device;
  const EditDevice({super.key, this.device});

  @override
  State<StatefulWidget> createState() {
    return _EditDevice();
  }
}

class _EditDevice extends State<EditDevice> {
  final _deviceno = TextEditingController();
  final _iosver = TextEditingController();
  final _flysmartver = TextEditingController();
  final _lidoversion = TextEditingController();
  final _docuversion = TextEditingController();
  final _uid = TextEditingController();
  String _selectedCondition = "Good";
  String _selectedHub = "CGK";
  RegExp _versionRegex = RegExp(r'^\d+(\.\d+)?$');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _deviceno.text = widget.device?.deviceno.toString() ?? '';
    _iosver.text = widget.device?.iosver.toString() ?? '';
    _flysmartver.text = widget.device?.flysmart.toString() ?? '';
    _lidoversion.text = widget.device?.lidoversion.toString() ?? '';
    _docuversion.text = widget.device?.docuversion.toString() ?? '';
    _selectedCondition = widget.device?.condition ?? 'Good';
    _selectedHub = widget.device?.hub ?? 'CGK';
  }

  @override
  Widget build(BuildContext context) {
    final deviceNoField = TextFormField(
      controller: _deviceno,
      autofocus: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please Enter Device Number';
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Device Number',
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(),
      ),
    );

    final IosVerField = TextFormField(
      controller: _iosver,
      autofocus: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please Enter IOS Version';
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Ios Version',
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(),
      ),
    );

    final flysmarvertField = TextFormField(
      controller: _flysmartver,
      autofocus: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please Enter Fly Smart Version';
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Fly Smart Version',
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(),
      ),
    );

    final lidoField = TextFormField(
      controller: _lidoversion,
      autofocus: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please Enter Lido Version';
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Lido Version',
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(),
      ),
    );

    final docuField = TextFormField(
      controller: _docuversion,
      autofocus: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please Enter Docu Version';
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Docu Version',
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(),
      ),
    );

    final hubDropdown = DropdownButtonFormField<String>(
      value: _selectedHub,
      onChanged: (newValue) {
        setState(() {
          _selectedHub = newValue!;
        });
      },
      items: <String>['CGK', 'DPS', 'KNO', 'SUB'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: 'Device Hub',
        border: OutlineInputBorder(),
      ),
    );

    final conditionDropdown = DropdownButtonFormField<String>(
      value: _selectedCondition,
      onChanged: (newValue) {
        setState(() {
          _selectedCondition = newValue!;
        });
      },
      items: <String>['Good', 'Not Good'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: 'Device Condition',
        border: OutlineInputBorder(),
      ),
    );

    final conditionField = conditionDropdown;

    Future<void> _showQuickAlert(BuildContext context) async {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Device successfully updated',
      );
      Navigator.of(context).pop();
    }

    Future<void> _showConfirmationDialog(BuildContext context) async {
      final bool result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Confirmation',
              style: tsOneTextTheme.headlineLarge,
            ),
            content: Text('Are you sure you want to update this device?'),
            actions: <Widget>[
              Container(
                width: 115,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: TsOneColor.onSecondary),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'No',
                    style: TextStyle(color: TsOneColor.onSecondary),
                  ),
                ),
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
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: TsOneColor.onPrimary),
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (result == true) {
        await _showQuickAlert(context);
      }
    }

    final UpdateButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(4.0),
      color: TsOneColor.primary,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(15.0),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            var response = await DeviceController.updateDevice(
              deviceno: _deviceno.text,
              iosver: _iosver.text,
              flysmart: _flysmartver.text,
              lidoversion: _lidoversion.text,
              docuversion: _docuversion.text,
              condition: _selectedCondition,
              hub: _selectedHub,
              uid: widget.device?.uid.toString() ?? '',
            );

            _showConfirmationDialog(context);
          }
        },
        child: Text(
          "Update",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Device',
          style: tsOneTextTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      deviceNoField,
                      const SizedBox(height: 15.0),
                      IosVerField,
                      const SizedBox(height: 15.0),
                      flysmarvertField,
                      const SizedBox(height: 15.0),
                      lidoField,
                      const SizedBox(height: 15.0),
                      docuField,
                      const SizedBox(height: 15.0),
                      hubDropdown,
                      const SizedBox(height: 15.0),
                      conditionField,
                      const SizedBox(height: 15.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: UpdateButton,
            ),
            // Expanded(
            //   flex: 1,
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(vertical: 10),
            //     child: UpdateButton,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
