import 'dart:typed_data';

import 'package:ts_one/data/assessments/assessment_variable_results.dart';
import 'package:ts_one/data/assessments/new_assessment.dart';
import 'package:ts_one/util/util.dart';

class AssessmentResults{
  AssessmentResults({
    this.id = Util.defaultStringIfNull,
    this.overallPerformance = Util.defaultDoubleIfNull,
    this.notes = Util.defaultStringIfNull,
  });

  static const String firebaseCollection = "assessment-results";

  static const String keyId = "id";
  static const String keyTypeOfAssessment = "type-of-assessment";
  static const String keyDate = "date";

  static const String keyExamineeStaffIDNo = "examinee-staff-id-no";
  static const String keyLicenseExpiry = "license-expiry";
  static const String keyLicenseNo = "license-no";
  static const String keySimIdent = "sim-ident";
  static const String keyExamineeSignatureUrl = "examinee-signature-url";
  static const String keyRank = "rank";
  static const String keyConfirmedByExaminer = "confirmed-by-examiner";
  static const String keyNameExaminee = "examinee-name";

  static const String keyOtherStaffIDNo = "other-staff-id-no";
  static const String keyOtherStaffName = "other-staff-name";
  static const String keyOtherStaffRank = "other-staff-rank";

  static const String keyAircraftType = "aircraft-type";
  static const String keyAirportAndRoute = "airport-and-route";
  static const String keySimulationHours = "simulation-hours";
  static const String keySessionDetails = "session-details";
  static const String keyTrainingCheckingDetails = "training-checking-details";

  static const String keyInstructorStaffIDNo = "instructor-staff-id-no";
  static const String keyInstructorSignatureUrl = "instructor-signature-url";
  static const String keyConfirmedByInstructor = "confirmed-by-instructor";
  static const String keyInstructorName = "instructor-name";

  static const String keyPilotAdministratorStaffIDNo = "pilot-administrator-staff-id-no";
  static const String keyPilotAdministratorSignatureUrl = "pilot-administrator-signature-url";
  static const String keyConfirmedByPilotAdministrator = "confirmed-by-pilot-administrator";

  static const String keyCPTSStaffIDNo = "cpts-staff-id-no";
  static const String keyCPTSSignatureUrl = "cpts-signature-url";
  static const String keyConfirmedByCPTS = "confirmed-by-cpts";

  static const String keyOverallPerformance = "overall-performance";
  static const String keyNotes = "notes";
  static const String keyDeclaration = "declaration";
  static const String keyLoaNo = "loa-no";

  static const String keyInstructorRecommendation = "instructor-recommendation";

  Uint8List? signatureBytes;

  String id = Util.defaultStringIfNull;
  String typeOfAssessment = Util.defaultStringIfNull;
  DateTime date = Util.getCurrentDateWithoutTime();

  int examineeStaffIDNo = Util.defaultIntIfNull;
  DateTime licenseExpiry = Util.defaultDateIfNull;
  String licenseNo = Util.defaultStringIfNull;
  String simIdent = Util.defaultStringIfNull;
  String loaNo = Util.defaultStringIfNull;
  String examineeSignatureUrl = Util.defaultStringIfNull;
  String rank = Util.defaultStringIfNull;
  bool confirmedByExaminer = false;
  String examineeName = Util.defaultStringIfNull;

  int otherStaffIDNo = Util.defaultIntIfNull;
  String otherStaffName = Util.defaultStringIfNull;
  String otherStaffRank = Util.defaultStringIfNull;

  String aircraftType = Util.defaultStringIfNull;
  String airportAndRoute = Util.defaultStringIfNull;
  String simulationHours = Util.defaultStringIfNull;
  String sessionDetails = Util.defaultStringIfNull;
  List<String> trainingCheckingDetails = [];

  int instructorStaffIDNo = Util.defaultIntIfNull;
  String instructorSignatureUrl = Util.defaultStringIfNull;
  bool confirmedByInstructor = false;
  String instructorName = Util.defaultStringIfNull;

  int pilotAdministratorStaffIDNo = Util.defaultIntIfNull;
  String pilotAdministratorSignatureUrl = Util.defaultStringIfNull;
  bool confirmedByPilotAdministrator = false;

  int cptsStaffIDNo = Util.defaultIntIfNull;
  String cptsSignatureUrl = Util.defaultStringIfNull;
  bool confirmedByCPTS = false;

  double overallPerformance = Util.defaultDoubleIfNull;
  String notes = Util.defaultStringIfNull;
  String declaration = Util.defaultStringIfNull;
  String instructorRecommendation = Util.defaultStringIfNull;

  bool isCPTS = false;
  bool isFromHistory = true;

  /// All variables results are stored here
  List<AssessmentVariableResults> variableResults = [];

  AssessmentResults.fromFirebase(Map<String, dynamic> data){
    id = data[keyId];
    date = DateTime.fromMillisecondsSinceEpoch(data[keyDate].seconds * 1000);

    examineeStaffIDNo = data[keyExamineeStaffIDNo];
    licenseExpiry = DateTime.fromMillisecondsSinceEpoch(data[keyLicenseExpiry].seconds * 1000);
    licenseNo = data[keyLicenseNo];
    simIdent = data[keySimIdent];
    examineeSignatureUrl = data[keyExamineeSignatureUrl];
    rank = data[keyRank];
    confirmedByExaminer = data[keyConfirmedByExaminer];
    examineeName = data[keyNameExaminee];

    otherStaffIDNo = data[keyOtherStaffIDNo];
    otherStaffName = data[keyOtherStaffName];
    otherStaffRank = data[keyOtherStaffRank];

    aircraftType = data[keyAircraftType];
    airportAndRoute = data[keyAirportAndRoute];
    simulationHours = data[keySimulationHours];
    sessionDetails = data[keySessionDetails];
    trainingCheckingDetails = (data[keyTrainingCheckingDetails] as List<dynamic>).map(
            (item) => item.toString()
    ).toList();

    instructorStaffIDNo = data[keyInstructorStaffIDNo];
    instructorSignatureUrl = data[keyInstructorSignatureUrl];
    confirmedByInstructor = data[keyConfirmedByInstructor];
    instructorName = data[keyInstructorName];
    instructorRecommendation = data[keyInstructorRecommendation];

    pilotAdministratorStaffIDNo = data[keyPilotAdministratorStaffIDNo];
    pilotAdministratorSignatureUrl = data[keyPilotAdministratorSignatureUrl];
    confirmedByPilotAdministrator = data[keyConfirmedByPilotAdministrator];

    cptsStaffIDNo = data[keyCPTSStaffIDNo];
    cptsSignatureUrl = data[keyCPTSSignatureUrl];
    confirmedByCPTS = data[keyConfirmedByCPTS];

    overallPerformance = data[keyOverallPerformance];
    notes = data[keyNotes];

    declaration = data[keyDeclaration];
    loaNo = data[keyLoaNo];

  }

  Map<String, dynamic> toFirebase() {
    return {
      keyId: id,
      keyDate: date,

      keyExamineeStaffIDNo: examineeStaffIDNo,
      keyLicenseExpiry: licenseExpiry,
      keyLicenseNo: licenseNo,
      keySimIdent: simIdent,
      keyExamineeSignatureUrl: examineeSignatureUrl,
      keyRank: rank,
      keyConfirmedByExaminer: confirmedByExaminer,
      keyNameExaminee: examineeName,

      keyOtherStaffIDNo: otherStaffIDNo,
      keyOtherStaffName: otherStaffName,
      keyOtherStaffRank: otherStaffRank,

      keyAircraftType: aircraftType,
      keyAirportAndRoute: airportAndRoute,
      keySimulationHours: simulationHours,
      keySessionDetails: sessionDetails,
      keyTrainingCheckingDetails: trainingCheckingDetails,

      keyInstructorStaffIDNo: instructorStaffIDNo,
      keyInstructorSignatureUrl: instructorSignatureUrl,
      keyConfirmedByInstructor: confirmedByInstructor,
      keyInstructorName: instructorName,
      keyInstructorRecommendation: instructorRecommendation,

      keyPilotAdministratorStaffIDNo: pilotAdministratorStaffIDNo,
      keyPilotAdministratorSignatureUrl: pilotAdministratorSignatureUrl,
      keyConfirmedByPilotAdministrator: confirmedByPilotAdministrator,

      keyCPTSStaffIDNo: cptsStaffIDNo,
      keyCPTSSignatureUrl: cptsSignatureUrl,
      keyConfirmedByCPTS: confirmedByCPTS,

      keyOverallPerformance: overallPerformance,
      keyNotes: notes,

      keyDeclaration: declaration,
      keyLoaNo: loaNo,
    };
  }

  static List<AssessmentResults> extractDataFromNewAssessment(NewAssessment newAssessment) {
    List<AssessmentResults> results = [];

    AssessmentResults assessmentResults1 = AssessmentResults();
    assessmentResults1.typeOfAssessment = newAssessment.typeOfAssessment;
    assessmentResults1.examineeName = newAssessment.nameExaminee1;
    assessmentResults1.date = newAssessment.assessmentDate;
    assessmentResults1.examineeStaffIDNo = newAssessment.idNo1;
    assessmentResults1.licenseExpiry = newAssessment.licenseExpiry1;
    assessmentResults1.licenseNo = newAssessment.licenseNo1;
    assessmentResults1.simIdent = newAssessment.simulationIdentity;
    assessmentResults1.loaNo = newAssessment.loaNo;
    assessmentResults1.otherStaffIDNo = newAssessment.idNo2;
    assessmentResults1.otherStaffName = newAssessment.nameExaminee2;
    assessmentResults1.otherStaffRank = newAssessment.rankExaminee2;
    assessmentResults1.aircraftType = newAssessment.aircraftType;
    assessmentResults1.airportAndRoute = newAssessment.airportAndRoute;
    assessmentResults1.simulationHours = newAssessment.simulationHours;
    assessmentResults1.sessionDetails = newAssessment.sessionDetails1;
    assessmentResults1.trainingCheckingDetails = newAssessment.assessmentFlightDetails1.flightDetails;
    assessmentResults1.instructorStaffIDNo = newAssessment.idNoInstructor;
    assessmentResults1.instructorSignatureUrl = newAssessment.instructorSignatureUrl;
    assessmentResults1.confirmedByInstructor = true;
    assessmentResults1.instructorName = newAssessment.instructorName;
    assessmentResults1.overallPerformance = newAssessment.overallPerformance1;
    assessmentResults1.notes = newAssessment.notes1;
    assessmentResults1.declaration = newAssessment.declaration1;
    assessmentResults1.rank = newAssessment.rankExaminee1;
    assessmentResults1.instructorRecommendation = newAssessment.instructorRecommendation1;
    assessmentResults1.variableResults.addAll(newAssessment.assessmentVariablesFlights1);
    assessmentResults1.variableResults.addAll(newAssessment.assessmentVariablesFlightsHumanFactor1);

    AssessmentResults assessmentResults2 = AssessmentResults();
    assessmentResults2.typeOfAssessment = newAssessment.typeOfAssessment;
    assessmentResults2.examineeName = newAssessment.nameExaminee2;
    assessmentResults2.date = newAssessment.assessmentDate;
    assessmentResults2.examineeStaffIDNo = newAssessment.idNo2;
    assessmentResults2.licenseExpiry = newAssessment.licenseExpiry2;
    assessmentResults2.licenseNo = newAssessment.licenseNo2;
    assessmentResults2.simIdent = newAssessment.simulationIdentity;
    assessmentResults2.loaNo = newAssessment.loaNo;
    assessmentResults2.otherStaffIDNo = newAssessment.idNo1;
    assessmentResults2.otherStaffName = newAssessment.nameExaminee1;
    assessmentResults2.otherStaffRank = newAssessment.rankExaminee1;
    assessmentResults2.aircraftType = newAssessment.aircraftType;
    assessmentResults2.airportAndRoute = newAssessment.airportAndRoute;
    assessmentResults2.simulationHours = newAssessment.simulationHours;
    assessmentResults2.sessionDetails = newAssessment.sessionDetails2;
    assessmentResults2.trainingCheckingDetails = newAssessment.assessmentFlightDetails2.flightDetails;
    assessmentResults2.instructorStaffIDNo = newAssessment.idNoInstructor;
    assessmentResults2.instructorName = newAssessment.instructorName;
    assessmentResults2.instructorSignatureUrl = newAssessment.instructorSignatureUrl;
    assessmentResults2.confirmedByInstructor = true;
    assessmentResults2.overallPerformance = newAssessment.overallPerformance2;
    assessmentResults2.notes = newAssessment.notes2;
    assessmentResults2.declaration = newAssessment.declaration2;
    assessmentResults2.rank = newAssessment.rankExaminee2;
    assessmentResults2.instructorRecommendation = newAssessment.instructorRecommendation2;
    assessmentResults2.variableResults.addAll(newAssessment.assessmentVariablesFlights2);
    assessmentResults2.variableResults.addAll(newAssessment.assessmentVariablesFlightsHumanFactor2);

    results.add(assessmentResults1);
    results.add(assessmentResults2);

    return results;
  }
}
