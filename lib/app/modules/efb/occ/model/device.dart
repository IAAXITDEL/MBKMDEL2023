
import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String uid;
  final    deviceno;
  final String iosver;
  final String flysmart;
  final String lidoversion;
  final String docuversion;
  final String condition;

  Device({
    required this.uid,
    required this.deviceno,
    required this.iosver,
    required this.flysmart,
    required this.lidoversion,
    required this.docuversion,
    required this.condition,
  });

  factory Device.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Device(
      uid: doc.id,
      deviceno: data['deviceno'] ?? '',
      iosver: data['iosver'] ?? '',
      flysmart: data['flysmart'] ?? '',
      lidoversion: data['lidoversion'] ?? '',
      docuversion: data['docuversion'] ?? '',
      condition: data['condition'] ?? '',
    );
  }

}















