import 'package:flutter/cupertino.dart';

class AssessmentVariables with ChangeNotifier {
  AssessmentVariables({
    this.id = "",
    this.assessmentPeriodId = "",
    this.category = "",
    this.name = "",
    this.typeOfAssessment = "",
    this.applicableForFlight = true,
  });

  String id = "";
  String assessmentPeriodId = "";
  String category = "";
  String name = "";
  String typeOfAssessment = "";
  bool applicableForFlight = true;

  // collection name in firebase
  static String firebaseCollection = "assessment-variables";

  // all the keys for the map stored in firebase
  static String keyId = "id";
  static String keyAssessmentPeriodId = "assessment-period-id";
  static String keyCategory = "category";
  static String keyName = "name";
  static String keyTypeOfAssessment = "type-of-assessment";
  static String keyApplicableForFlight = "applicable-for-flight";

  // all the keys for the category
  static const String keyFlightPreparation = "Flight Preparation";
  static const String keyTakeoff = "Takeoff";
  static const String keyFlightManeuversAndProcedure = "Flight Maneuvers and Procedure";
  static const String keyAppAndMissedAppProcedures = "App. & Missed App. Procedures";
  static const String keyLanding = "Landing";
  static const String keyLVOQualificationChecking = "LVO Qualification / Checking";
  static const String keySOPs = "SOP's";
  static const String keyAdvanceManeuvers = "Advance Maneuvers";
  static const String keyTeamworkAndCommunication = "Teamwork & Communication";
  static const String keyLeadershipAndTaskManagement = "Leadership & Task Management";
  static const String keySituationalAwareness = "Situational Awareness";
  static const String keyDecisionMaking = "Decision Making";
  static const String keyCustomerFocus = "Customer Focus";
  static const String keyAbnormalEmergencyProcedure = "Abnormal or Emer.Proc";
  static const String keyAircraftSystemProcedures = "Aircraft System or Procedures";

  // all the keys for satisfactory
  static const String keySatisfactory = "Satisfactory";
  static const String keyUnsatisfactory = "Unsatisfactory";

  static const String keyPFPM = 'PF/PM';

  // all the markers for the assessment
  static const int keyMarkerOne = 1;
  static const int keyMarkerTwo = 2;
  static const int keyMarkerThree = 3;
  static const int keyMarkerFour = 4;
  static const int keyMarkerFive = 5;

  static const flightCategory = [
    keyFlightPreparation,
    keyTakeoff,
    keyFlightManeuversAndProcedure,
    keyAppAndMissedAppProcedures,
    keyLanding,
    keyLVOQualificationChecking,
    keySOPs,
    keyAdvanceManeuvers,
  ];

  static const humanFactorCategory = [
    keyTeamworkAndCommunication,
    keyLeadershipAndTaskManagement,
    keySituationalAwareness,
    keyDecisionMaking,
    keyCustomerFocus,
  ];

  static const aircraftSystemCategory = [
    keyAircraftSystemProcedures,
    keyAbnormalEmergencyProcedure,
  ];

  static const satisfactoryList = [
    keySatisfactory,
    keyUnsatisfactory,
  ];

  static const markerList = [
    keyMarkerOne,
    keyMarkerTwo,
    keyMarkerThree,
    keyMarkerFour,
    keyMarkerFive,
  ];

  static const instructorRecommendation = [
    keyNone,
    keySeniorFirstOfficer,
    keyGroundTrainingInstructor,
    keyCompanyCheckPilot,
    keyCommandUpgrade,
    keyTypeRatingInstructor,
    keyOthers,
  ];

  // Instructor's Recommendation
  static const String keyNone = "None";
  static const String keySeniorFirstOfficer = "Senior First Officer";
  static const String keyGroundTrainingInstructor = "Ground Training Instructor";
  static const String keyCompanyCheckPilot = "Company Check Pilot";
  static const String keyCommandUpgrade = "Command upgrade";
  static const String keyTypeRatingInstructor = "Type Rating Instructor";
  static const String keyOthers = "Others";

  AssessmentVariables.fromFirebase(Map<String, dynamic> map) {
    id = map[keyId];
    assessmentPeriodId = map[keyAssessmentPeriodId];
    category = map[keyCategory];
    name = map[keyName];
    typeOfAssessment = map[keyTypeOfAssessment];
    applicableForFlight = map[keyApplicableForFlight];
  }

  Map<String, dynamic> toFirebase() {
    return {
      keyId: id,
      keyAssessmentPeriodId: assessmentPeriodId,
      keyCategory: category,
      keyName: name,
      keyTypeOfAssessment: typeOfAssessment,
      keyApplicableForFlight: applicableForFlight,
    };
  }

  @override
  String toString() {
    return 'AssessmentVariablesModel{id: $id, assessmentPeriodId: $assessmentPeriodId, category: $category, name: $name, typeOfAssessment: $typeOfAssessment, applicableForFlight: $applicableForFlight},';
  }
}
