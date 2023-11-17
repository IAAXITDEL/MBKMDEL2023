import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String uid;
  final String deviceno;
  final String iosver;
  final String flysmart;
  final String lidoversion;
  final String docuversion;
  final String hub;
  final String condition;

  Device({
    required this.uid,
    required this.deviceno,
    required this.iosver,
    required this.flysmart,
    required this.lidoversion,
    required this.docuversion,
    required this.hub,
    required this.condition,
  });

  factory Device.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> valueData = data['value'] as Map<String, dynamic>;
    return Device(
      uid: doc.id,
      deviceno: valueData['deviceno'] ?? '',
      iosver: valueData['iosver'] ?? '',
      flysmart: valueData['flysmart'] ?? '',
      lidoversion: valueData['lidoversion'] ?? '',
      docuversion: valueData['docuversion'] ?? '',
      hub: valueData['hub'] ?? '',
      condition: valueData['condition'] ?? '',
    );
  }
}
