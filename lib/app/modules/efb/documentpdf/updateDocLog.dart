import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/app/modules/efb/documentpdf/showdoc.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateLog extends StatefulWidget {
  const UpdateLog({Key? key}) : super(key: key);

  @override
  _UpdateLogState createState() => _UpdateLogState();
}

//
class _UpdateLogState extends State<UpdateLog> {
  TextEditingController recNoController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController pageController = TextEditingController();
  TextEditingController footerLeftController = TextEditingController();
  TextEditingController footerRightController = TextEditingController();

  final FocusNode _dateFocus = FocusNode();
  final FocusNode _footerLeftFocus = FocusNode();
  final FocusNode _footerRightFocus = FocusNode();

  @override
  void initState() {
    loadExistingData();
    super.initState();
  }

  void loadExistingData() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> result = await FirebaseFirestore.instance.collection('efb-document').doc('handover-log').get();

      if (result.exists) {
        final Map<String, dynamic> data = result.data()!;
        setState(() {
          recNoController.text = data['RecNo'] ?? '';
          dateController.text = data['Date'] ?? '';
          pageController.text = data['Page'] ?? '';
          footerLeftController.text = data['FooterLeft'] ?? '';
          footerRightController.text = data['FooterRight'] ?? '';
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateData() async {
    try {
      final CollectionReference efbDocumentCollection = FirebaseFirestore.instance.collection('efb-document');

      await efbDocumentCollection.doc('handover-log').update({
        'RecNo': recNoController.text,
        'Date': dateController.text,
        'Page': pageController.text,
        'FooterLeft': footerLeftController.text,
        'FooterRight': footerRightController.text,
      });

      print('Data updated successfully');

      _showQuickAlert(context);
    } catch (e) {
      print('Error: $e');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update data. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showQuickAlert(BuildContext context) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'You have successfully updated',
    ).then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => documentpdf(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Update Handover Log',
          style: tsOneTextTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: recNoController,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'RecNo',
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  labelStyle: tsOneTextTheme.labelMedium,
                  border: const OutlineInputBorder(),
                ),
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(_dateFocus);
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: dateController,
                autofocus: false,
                focusNode: _dateFocus,
                decoration: InputDecoration(
                  labelText: 'Date',
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  labelStyle: tsOneTextTheme.labelMedium,
                  border: const OutlineInputBorder(),
                ),
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(_footerLeftFocus);
                },
              ),
              SizedBox(height: 16.0),
              // TextFormField(
              //   controller: pageController,
              //   decoration: InputDecoration(labelText: 'Page'),
              // ),
              // SizedBox(height: 16.0),
              TextFormField(
                controller: footerLeftController,
                autofocus: false,
                focusNode: _footerLeftFocus,
                decoration: InputDecoration(
                  labelText: 'FooterLeft',
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  labelStyle: tsOneTextTheme.labelMedium,
                  border: const OutlineInputBorder(),
                ),
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(_footerRightFocus);
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: footerRightController,
                autofocus: false,
                focusNode: _footerRightFocus,
                decoration: InputDecoration(
                  labelText: 'FooterRight',
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  labelStyle: tsOneTextTheme.labelMedium,
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 25.0),
              ElevatedButton(
                onPressed: () {
                  updateData();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlue,
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Update',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ), //
            ],
          ),
        ),
      ),
    );
  }
}
