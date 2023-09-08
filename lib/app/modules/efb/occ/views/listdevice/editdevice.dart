import 'package:flutter/material.dart';

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
    _deviceno.value = TextEditingValue(text: widget.device!.deviceno.toString());
    _iosver.value = TextEditingValue(text: widget.device!.lidoversion.toString());
    _flysmartver.value = TextEditingValue(text: widget.device!.flysmart.toString());
    _lidoversion.value = TextEditingValue(text: widget.device!.lidoversion.toString());
    _docuversion.value = TextEditingValue(text: widget.device!.docuversion.toString());
    _condition.value = TextEditingValue(text: widget.device!.condition.toString());

  }

  @override
  Widget build(BuildContext context) {

    final deviceNoField = TextFormField(
        controller: _deviceno,
        autofocus: false,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        decoration: InputDecoration(
            labelText: 'Device Number',
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));
    final IosVerField = TextFormField(
        controller: _iosver,
        autofocus: false,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        decoration: InputDecoration(
            labelText: 'Ios Version',
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));

    final flysmarvertField = TextFormField(
      controller: _flysmartver,
      autofocus: false,
      validator: (value){
        if (value == null || value.trim().isEmpty){
          return 'This Field is Required';
        }
        return null;
      },
      decoration: InputDecoration(
          labelText: 'Fly Smart Version',
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))
      ),
    );
    final lidoField = TextFormField(
      controller: _lidoversion,
      autofocus: false,
      validator: (value){
        if (value == null || value.trim().isEmpty){
          return 'This Field is Required';
        }
        return null;
      },
      decoration: InputDecoration(
          labelText: 'Lido Version',
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))
      ),
    );
    final docuField = TextFormField(
      controller: _docuversion,
      autofocus: false,
      validator: (value){
        if (value == null || value.trim().isEmpty){
          return 'This Field is Required';
        }
        return null;
      },
      decoration: InputDecoration(
          labelText: 'Docu Version',
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))
      ),
    );
    final conditionField = TextFormField(
      controller: _condition,
      autofocus: false,
      validator: (value){
        if (value == null || value.trim().isEmpty){
          return 'This Field is Required';
        }
        return null;
      },
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'Device Condition',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))
      ),
    );

    final SaveButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(15.0),
      color: Colors.red,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
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
            if (response.code != 200) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(response.message.toString()),
                    );
                  });
            } else {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(response.message.toString()),
                    );
                  });
            }
          }
        },
        child: Text(
          "Update",
          style: TextStyle(color: Theme.of(context).primaryColorLight),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Edit Device",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
      body: SingleChildScrollView (
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    deviceNoField,
                    const SizedBox(height: 25.0),
                    IosVerField,
                    const SizedBox(height: 25.0),
                    flysmarvertField,
                    const SizedBox(height: 25.0),
                    lidoField,
                    const SizedBox(height: 25.0),
                    docuField,
                    const SizedBox(height: 25.0),
                    conditionField,
                    const SizedBox(height: 25.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 110.0),
            SaveButon,
          ],
        ),
      ),
    );
  }
}