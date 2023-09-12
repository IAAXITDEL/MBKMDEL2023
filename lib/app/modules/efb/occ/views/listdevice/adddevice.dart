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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _iosverFocus = FocusNode();
  final FocusNode _flysmartverFocus = FocusNode();
  final FocusNode _lidoversionFocus = FocusNode();
  final FocusNode _docuversionFocus = FocusNode();
  final FocusNode _conditionFocus = FocusNode();

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
            .requestFocus(_conditionFocus); // Pindah ke field berikutnya
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

    final SaveButon = Material(
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
                condition: _condition.text);
            if (response.code == 200) {
              //Success
              await QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                text: 'You have succesfully Added a Device',
              );
              Get.offAllNamed(Routes.LISTDEVICEOCC);
            } else {
              //Not successful
              QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  text: 'Failed to add device: ${response.message}');
            }

            // if (response.code == 200) {
            //   showDialog(
            //       context: context,
            //       builder: (context) {
            //         return AlertDialog(
            //           content: Text(response.message.toString()),
            //         );
            //       });
            // } else {
            //   showDialog(
            //       context: context,
            //       builder: (context) {
            //         return AlertDialog(
            //           content: Text(response.message.toString()),
            //         );
            //       });
            // }
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
        //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    conditionField,
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
          child: SaveButon,
        ),
      ),
    );
  }
}
