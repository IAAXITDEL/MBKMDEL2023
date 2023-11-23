import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/app/modules/efb/documentpdf/updateDocFeedback.dart';
import 'package:ts_one/app/modules/efb/documentpdf/updateDocLog.dart';
import 'package:ts_one/presentation/theme.dart';

class documentpdf extends StatefulWidget {
  const documentpdf({super.key});

  @override
  State<documentpdf> createState() => _documentpdfState();
}

class _documentpdfState extends State<documentpdf> {
  static const String firebaseCollection = "efb-document";
  static const String firebaseDocumentLog = "handover-log";
  static const String firebaseDocumentFeedback = "feedback-form";

  String? recNo;
  String? date;
  String? page;
  String? footerLeft;
  String? footerRight;

  Future<void> addDocumentLog() async {
    try {
      final CollectionReference efbDocumentCollection = FirebaseFirestore.instance.collection(firebaseCollection);

      final DocumentSnapshot<Object?> documentSnapshot = await efbDocumentCollection.doc(firebaseDocumentLog).get();
      // await efbDocumentCollection.doc(firebaseDocument).set({
      //   'RecNo': recNo,
      //   'Date': date,
      //   'Page': page,
      //   'FooterLeft': footerLeft,
      //   'FooterRight': footerRight,
      // });
      if (!documentSnapshot.exists) {
        await efbDocumentCollection.doc(firebaseDocumentLog).set({
          'RecNo': recNo,
          'Date': date,
          'Page': page,
          'FooterLeft': footerLeft,
          'FooterRight': footerRight,
        });
        print('Document added successfully');
      } else {
        print('Document already exists. Skipped adding.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> addDocumentFeedback() async {
    try {
      final CollectionReference efbDocumentCollection = FirebaseFirestore.instance.collection(firebaseCollection);

      final DocumentSnapshot<Object?> documentSnapshot = await efbDocumentCollection.doc(firebaseDocumentFeedback).get();
      // await efbDocumentCollection.doc(firebaseDocument).set({
      //   'RecNo': recNo,
      //   'Date': date,
      //   'Page': page,
      //   'FooterLeft': footerLeft,
      //   'FooterRight': footerRight,
      // });
      if (!documentSnapshot.exists) {
        await efbDocumentCollection.doc(firebaseDocumentFeedback).set({
          'RecNo': recNo,
          'Date': date,
          'Page': page,
          'FooterLeft': footerLeft,
          'FooterRight': footerRight,
        });
        print('Document added successfully');
      } else {
        print('Document already exists. Skipped adding.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    addDocumentLog();
    addDocumentFeedback();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'PDF Document',
          style: tsOneTextTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Handover Log',
                    style: tsOneTextTheme.headlineMedium,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => UpdateLog(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decorationColor: TsOneColor.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              _buildContentLog(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Feedback Form',
                    style: tsOneTextTheme.headlineMedium,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => UpdateFeedback(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decorationColor: TsOneColor.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              _buildContentFeedback(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildContentLog() {
  return FutureBuilder(
    future: getDocumentLog(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.0),
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Header',
                style: tsOneTextTheme.headlineSmall,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Expanded(flex: 4, child: Text('Rec No.')),
                  const Expanded(child: Text(':')),
                  Expanded(flex: 6, child: Text('${snapshot.data?['RecNo'] ?? "-"}')),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Expanded(flex: 4, child: Text('Date')),
                  const Expanded(child: Text(':')),
                  Expanded(flex: 6, child: Text('${snapshot.data?['Date'] ?? "-"}')),
                ],
              ),
              // const SizedBox(
              //   height: 8,
              // ),
              // Row(
              //   children: [
              //     const Expanded(flex: 4, child: Text('Page')),
              //     const Expanded(child: Text(':')),
              //     Expanded(flex: 6, child: Text('${snapshot.data?['Page'] ?? "-"}')),
              //   ],
              // ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'Footer',
                style: tsOneTextTheme.headlineSmall,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Expanded(flex: 4, child: Text('Footer Left')),
                  const Expanded(child: Text(':')),
                  Expanded(flex: 6, child: Text('${snapshot.data?['FooterLeft'] ?? "-"}')),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Expanded(flex: 4, child: Text('Footer Right')),
                  const Expanded(child: Text(':')),
                  Expanded(flex: 6, child: Text('${snapshot.data?['FooterRight'] ?? "-"}')),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        );
      }
    },
  );
}

// Future<Map<String, dynamic>> getDocumentLog() async {
//   try {
//     final QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore.instance.collection('efb-document').get();
//
//     if (result.docs.isNotEmpty) {
//       final Map<String, dynamic> data = result.docs.first.data();
//       return data;
//     } else {
//       return {};
//     }
//   } catch (e) {
//     print('Error: $e');
//     throw e;
//   }
// }

Future<Map<String, dynamic>> getDocumentLog() async {
  try {
    final DocumentSnapshot<Map<String, dynamic>> result = await FirebaseFirestore.instance.collection('efb-document').doc('handover-log').get();

    if (result.exists) {
      final Map<String, dynamic> data = result.data() ?? {};
      return data;
    } else {
      return {};
    }
  } catch (e) {
    print('Error: $e');
    throw e;
  }
}

Widget _buildContentFeedback() {
  return FutureBuilder(
    future: getDocumentFeedback(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.0),
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Header',
                style: tsOneTextTheme.headlineSmall,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Expanded(flex: 4, child: Text('Rec No.')),
                  const Expanded(child: Text(':')),
                  Expanded(flex: 6, child: Text('${snapshot.data?['RecNo'] ?? "-"}')),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Expanded(flex: 4, child: Text('Date')),
                  const Expanded(child: Text(':')),
                  Expanded(flex: 6, child: Text('${snapshot.data?['Date'] ?? "-"}')),
                ],
              ),
              // const SizedBox(
              //   height: 8,
              // ),
              // Row(
              //   children: [
              //     const Expanded(flex: 4, child: Text('Page')),
              //     const Expanded(child: Text(':')),
              //     Expanded(flex: 6, child: Text('${snapshot.data?['Page'] ?? "-"}')),
              //   ],
              // ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'Footer',
                style: tsOneTextTheme.headlineSmall,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Expanded(flex: 4, child: Text('Footer Left')),
                  const Expanded(child: Text(':')),
                  Expanded(flex: 6, child: Text('${snapshot.data?['FooterLeft'] ?? "-"}')),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Expanded(flex: 4, child: Text('Footer Right')),
                  const Expanded(child: Text(':')),
                  Expanded(flex: 6, child: Text('${snapshot.data?['FooterRight'] ?? "-"}')),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        );
      }
    },
  );
}

Future<Map<String, dynamic>> getDocumentFeedback() async {
  try {
    final DocumentSnapshot<Map<String, dynamic>> result = await FirebaseFirestore.instance.collection('efb-document').doc('feedback-form').get();

    if (result.exists) {
      final Map<String, dynamic> data = result.data() ?? {};
      return data;
    } else {
      return {};
    }
  } catch (e) {
    print('Error: $e');
    throw e;
  }
}
