import 'package:flutter/cupertino.dart';
import 'package:ts_one/data/assessments/assessment_variables.dart';
import 'package:ts_one/util/util.dart';

class AssessmentPeriod with ChangeNotifier{
  AssessmentPeriod({
    this.id = "",
  });

  String id = "";
  DateTime period = Util.defaultDateIfNull;
  List<AssessmentVariables> assessmentVariables = [];

  // collection name in firebase
  static String firebaseCollection = "assessment-periods";

  // all the keys for the map stored in firebase
  static String keyId = "id";
  static String keyPeriod = "period";

  AssessmentPeriod.fromFirebase(Map<String, dynamic> map) {
    id = map[keyId];
    period = DateTime.fromMillisecondsSinceEpoch(map[keyPeriod].seconds * 1000);
  }

  Map<String, dynamic> toFirebase() {
    return {
      keyId: id,
      keyPeriod: period,
    };
  }

  void addAllAssessmentVariables(List<AssessmentVariables> allAssessmentVariables) {
    assessmentVariables.addAll(allAssessmentVariables);
    notifyListeners();
  }

  @override
  String toString() {
    return 'AssessmentPeriodModel{id: $id, period: $period, assessmentVariables: $assessmentVariables}';
  }
}