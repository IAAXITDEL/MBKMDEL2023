import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/app/modules/efb/occ/controllers/device_controller.dart';

import 'package:flutter/material.dart';
import 'package:ts_one/app/routes/app_pages.dart';
import 'package:ts_one/presentation/theme.dart';

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddDevice();
  }
}

class _AddDevice extends State<AddDevice> {
  final _deviceno = TextEditingController();
  final _iosver = TextEditingController();
  final _flysmartver = TextEditingController();
  final _lidoversion = TextEditingController();
  final _docuversion = TextEditingController();
  final _condition = TextEditingController();
  String _selectedHub = 'CGK'; // Default value
  String _selectedCondition = 'Good'; // Default value
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _iosverFocus = FocusNode();
  final FocusNode _flysmartverFocus = FocusNode();
  final FocusNode _lidoversionFocus = FocusNode();
  final FocusNode _docuversionFocus = FocusNode();
  final FocusNode _hubversionFocus = FocusNode();
  final FocusNode _conditionFocus = FocusNode();
  // RegExp _versionRegex = RegExp(r'^\d+(\.\d+)?$');

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
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: 'Device Number',
        labelStyle: tsOneTextTheme.labelMedium,
        border: OutlineInputBorder(),
      ),
      onEditingComplete: () {
        FocusScope.of(context)
            .requestFocus(_iosverFocus); // Pindah ke field berikutnya
      },
    );
    final iosverField = TextFormField(
      controller: _iosver,
      focusNode: _iosverFocus,
      autofocus: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please Enter IOS Version';
        }
        // if (!_versionRegex.hasMatch(value)) {
        //   return 'Invalid format. Use numbers and optional decimal point (e.g., 1.0)'; //hanya menampung angka
        // }
        return null;
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: 'IOS Version',
        labelStyle: tsOneTextTheme.labelMedium,
        border: OutlineInputBorder(),
      ),
      onEditingComplete: () {
        FocusScope.of(context)
            .requestFocus(_flysmartverFocus); // Pindah ke field berikutnya
      },
    );
    final flysmarvertField = TextFormField(
      controller: _flysmartver,
      focusNode: _flysmartverFocus,
      autofocus: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please Enter Fly Smart Version';
        }
        // if (!_versionRegex.hasMatch(value)) {
        //   return 'Invalid format. Use numbers and optional decimal point (e.g., 1.0)';
        // }
        return null;
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: 'Fly Smart Version',
        labelStyle: tsOneTextTheme.labelMedium,
        border: OutlineInputBorder(),
      ),
      onEditingComplete: () {
        FocusScope.of(context)
            .requestFocus(_lidoversionFocus); // Pindah ke field berikutnya
      },
    );
    final lidoField = TextFormField(
      controller: _lidoversion,
      focusNode: _lidoversionFocus,
      autofocus: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please Enter Lido Version';
        }
        // if (!_versionRegex.hasMatch(value)) {
        //   return 'Invalid format. Use numbers and optional decimal point (e.g., 1.0)';
        // }
        return null;
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: 'Lido Version',
        labelStyle: tsOneTextTheme.labelMedium,
        border: OutlineInputBorder(),
      ),
      onEditingComplete: () {
        FocusScope.of(context)
            .requestFocus(_docuversionFocus); // Pindah ke field berikutnya
      },
    );
    final docuField = TextFormField(
      controller: _docuversion,
      focusNode: _docuversionFocus,
      autofocus: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please Enter Docu Version';
        }
        // if (!_versionRegex.hasMatch(value)) {
        //   return 'Invalid format. Use numbers and optional decimal point (e.g., 1.0)';
        // }
        return null;
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: 'Docu Version',
        labelStyle: tsOneTextTheme.labelMedium,
        border: OutlineInputBorder(),
      ),
      onEditingComplete: () {
        FocusScope.of(context)
            .requestFocus(_lidoversionFocus); // Pindah ke field berikutnya
      },
    );


    final conditionField = TextFormField(
      controller: _condition,
      focusNode: _conditionFocus,
      autofocus: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please Select Device Condition';
        }
        return null;
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: 'Device Condition',
        labelStyle: tsOneTextTheme.labelMedium,
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
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: 'Device Condition',
        labelStyle: tsOneTextTheme.labelMedium,
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
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: 'Device HUB',
        labelStyle: tsOneTextTheme.labelMedium,
        border: OutlineInputBorder(),
      ),
    );



    Future<void> _showQuickAlert(BuildContext context) async {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'You have succesfully Added a Device',
      );
      Navigator.of(context).pop();
    }

    final SaveButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(4.0),
      color: TsOneColor.primary,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(15.0),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            var response = await DeviceController.addDevice(
              deviceno: _deviceno.text,
              iosver: _iosver.text,
              flysmart: _flysmartver.text,
              lidoversion: _lidoversion.text,
              docuversion: _docuversion.text,
              hub: _selectedHub,
              condition: _selectedCondition, // Menggunakan nilai yang dipilih dari dropdown

            );
            if (response.code == 200) {
              //Success
              _showQuickAlert(context);
            } else {
              //Not successful
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                text: 'Failed to add device: ${response.message}',
              );
            }
          }
        },
        child: const Text(
          "Save",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Add Device',
            style: tsOneTextTheme.headlineLarge,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      deviceNoField,
                      const SizedBox(height: 15.0),
                      iosverField,
                      const SizedBox(height: 15.0),
                      flysmarvertField,
                      const SizedBox(height: 15.0),
                      lidoField,
                      const SizedBox(height: 15.0),
                      docuField,
                      const SizedBox(height: 15.0),
                      hubDropdown,
                      const SizedBox(height: 15.0),
                      conditionDropdown,
                      const SizedBox(height: 15.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Container(
              child: SaveButton,
            ),
            ),
        );
}
}