import 'package:ts_one/app/modules/efb/occ/views/listdevice/listdevice.dart';
import 'package:ts_one/app/modules/efb/occ/controllers/device_controller.dart';

import 'package:flutter/material.dart';

class AddDevice extends StatefulWidget {
  @override
  State<StatefulWidget> createState(){
    return _AddDevice();
  }
}

class _AddDevice extends State<AddDevice>{
  final _deviceno = TextEditingController();
  final _iosver = TextEditingController();
  final _flysmartver = TextEditingController();
  final _lidoversion = TextEditingController();
  final _docuversion = TextEditingController();
  final _condition = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){
    final deviceNoField = TextFormField(
      controller: _deviceno,
      autofocus: false,
      validator: (value){
        if (value == null || value.trim().isEmpty){
          return 'This Field is Required';
        }
      },
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'Device Number',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))
      ),
    );
    final iosverField = TextFormField(
      controller: _iosver,
      autofocus: false,
      validator: (value){
        if (value == null || value.trim().isEmpty){
          return 'This Field is Required';
        }
      },
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'Ios Version',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))
      ),
    );
    final flysmarvertField = TextFormField(
      controller: _flysmartver,
      autofocus: false,
      validator: (value){
        if (value == null || value.trim().isEmpty){
          return 'This Field is Required';
        }
      },
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'Fly Smart Version',
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
      },
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'Lido Version',
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
      },
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: 'Docu Version',
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
            var response = await DeviceController.addDevice(
                deviceno: _deviceno.text,
                iosver: _iosver.text,
                flysmart: _flysmartver.text,
                lidoversion: _lidoversion.text,
                docuversion: _docuversion.text,
                condition: _condition.text);
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
          "Save",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Center(
            child: Text(
              "Add Device",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          )
      ),
      body: SingleChildScrollView (
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    deviceNoField,
                    const SizedBox(height: 25.0),
                    iosverField,
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
            SizedBox(height: 110.0),
            SaveButon,
          ],
        ),
      ),
    );
  }
}