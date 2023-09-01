import 'package:flutter/cupertino.dart';
import 'package:ts_one/util/util.dart';

class UserSignatures with ChangeNotifier {
  UserSignatures({
    this.urlSignature = Util.defaultStringIfNull,
    this.staffId = Util.defaultIntIfNull,
  });

  static const String firebaseCollection = 'user-signatures';

  static const String keyUrlSignature = 'url-signature';
  static const String keyStaffId = 'staff-id';
  static const String keyDateUploaded = 'date-uploaded';

  String urlSignature = '';
  int staffId = Util.defaultIntIfNull;
  DateTime dateUploaded = DateTime.now();

  UserSignatures.fromFirebase(Map<String, dynamic> map) {
    urlSignature = map[keyUrlSignature];
    staffId = map[keyStaffId];
    // dateUploaded = map[keyDateUploaded];
    dateUploaded = DateTime.fromMillisecondsSinceEpoch(map[keyDateUploaded].seconds * 1000);
  }

  Map<String, dynamic> toFirebase() {
    return {
      keyUrlSignature: urlSignature,
      keyStaffId: staffId,
      keyDateUploaded: dateUploaded,
    };
  }

  @override
  String toString() {
    return "UserSignatures{urlSignature: $urlSignature, staffId: $staffId, dateUploaded: $dateUploaded}";
  }
}