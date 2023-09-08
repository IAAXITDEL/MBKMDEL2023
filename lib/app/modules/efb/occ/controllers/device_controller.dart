import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _Collection = _firestore.collection('Device');

class DeviceController{

  //device record
  static Future<Response> addDevice({
    required String deviceno,
    required String iosver,
    required String flysmart,
    required String lidoversion,
    required String docuversion,
    required String condition,
  }) async {
    Response response = Response();
    QuerySnapshot<Object?> existingDevices = await _Collection.where("deviceno", isEqualTo: deviceno).get();

    if (existingDevices.docs.isEmpty) {
      DocumentReference documentReferencer = await _Collection.add({
        "deviceno": deviceno,
        "iosver": iosver,
        "flysmart": flysmart,
        "lidoversion": lidoversion,
        "docuversion": docuversion,
        "condition": condition,
      });

      response.code = 200;
      response.message = "Successfully added to the database ";
    } else {
      response.code = 400;
      response.message = "Device with the same Device Number already exists.";
    }

    return response;
  }


  //read data
  static Stream<QuerySnapshot> readDevice() {
    CollectionReference notesItemCollection = _Collection;

    return notesItemCollection.snapshots();
  }

  //update data
  static Future<Response> updateDevice({
    required String deviceno,
    required String iosver,
    required String flysmart,
    required String lidoversion,
    required String docuversion,
    required String condition,
    required String uid,
  })async {
    Response response = Response();
    DocumentReference documentReferencer = _Collection.doc(uid);

    Map<String, dynamic> data = <String, dynamic>{
      "deviceno": deviceno,
      "iosver" : iosver,
      "flysmart": flysmart,
      "lidoversion": lidoversion,
      "docuversion": docuversion,
      "condition": condition
    };
    await documentReferencer
        .update(data)
        .whenComplete(() {
      response.code = 200;
      response.message = "Sucessfully updated Device";
    })
        .catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }

  static Future<Response> deleteDevice({
    required String uid,
  }) async {
    Response response = Response();
    DocumentReference documentReferencer = _Collection.doc(uid);

    await documentReferencer
        .delete()
        .whenComplete((){
      response.code = 200;
      response.message = "Sucessfully Deleted Device";
    })
        .catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }
}