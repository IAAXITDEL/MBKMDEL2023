import 'package:get/get.dart';
import 'package:flutter/material.dart';
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
    // TODO: implement createState
    return _EditDevice();
  }
}

class _EditDevice extends State<EditDevice> {
  final _deviceno = TextEditingController();
  final _iosver = TextEditingController();
  final _flysmartver = TextEditingController();
  final _lidoversion = TextEditingController();
  final _docuversion = TextEditingController();
  final _condition = TextEditingController();
  final _uid = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    _uid.value = TextEditingValue(text: widget.device!.uid.toString());
    _deviceno.value =
        TextEditingValue(text: widget.device!.deviceno.toString());
    _iosver.value =
        TextEditingValue(text: widget.device!.lidoversion.toString());
    _flysmartver.value =
        TextEditingValue(text: widget.device!.flysmart.toString());
    _lidoversion.value =
        TextEditingValue(text: widget.device!.lidoversion.toString());
    _docuversion.value =
        TextEditingValue(text: widget.device!.docuversion.toString());
    _condition.value =
        TextEditingValue(text: widget.device!.condition.toString());
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
        ));
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
        ));
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
    final conditionField = TextFormField(
      controller: _condition,
      autofocus: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please Enter Device Condition';
        }
        return null;
      },
      decoration: const InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: 'Device Condition',
        border: OutlineInputBorder(),
      ),
    );

    Future<void> _showQuickAlert(BuildContext context) async {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Device successfully updated!',
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
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('No'),
              ),
            ],
          );
        },
      );

      if (result == true) {
        //Yes
        await _showQuickAlert(context);
      } else {
        //No
        //Navigator.of(context).pop();
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
                condition: _condition.text,
                uid: _uid.text);

            _showConfirmationDialog(context);

            // if (response.code != 200) {
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
        child: Text(
          "Update",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Edit Device',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
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
        child: Expanded(
          child: UpdateButton,
        ),
      ),
    );
  }
}
