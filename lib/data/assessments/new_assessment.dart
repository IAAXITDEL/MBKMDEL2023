import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ts_one/data/assessments/assessment_flight_details.dart';
import 'package:ts_one/data/assessments/assessment_variable_results.dart';
import 'package:ts_one/data/assessments/assessment_variables.dart';
import 'package:ts_one/util/util.dart';

class NewAssessment with ChangeNotifier {
  NewAssessment({
    this.typeOfAssessment = "",
    this.idNo1 = Util.defaultIntIfNull,
    this.idNo2 = Util.defaultIntIfNull,
    this.sessionDetails1 = "Training",
    this.sessionDetails2 = "Training",
    this.aircraftType = "",
    this.airportAndRoute = "",
    this.simulationHours = "",
    this.simulationIdentity = "",
    this.loaNo = "",
  });

  static const String keyTypeOfAssessmentSimulator = "Simulator";
  static const String keyTypeOfAssessmentFlight = "Flight";

  static const String keySessionDetailsTraining = "Training";
  static const String keySessionDetailsCheck = "Checking";
  static const String keySessionDetailsRetraining = "Re-training";

  static const String keyMessageDeclaration = "I, the undersigned, being a person "
      "authorized by the Company and/or DGCA to conduct such training and or check "
      "as indicated, have supervised the required flight/session in accordance to "
      "the published syllabus and assessed the performance of the candidate as";

  static const String keyForTrainingSatisfactory = "Satisfactory";
  static const String keyForTrainingFurtherTraining = "Further Training Req.";
  static const String keyForClearedForCheck = "Cleared for Check";
  static const String keyStopTraining = "Stop Training, TS7 Rised";

  static const String keyForCheckPass = "Pass";
  static const String keyForCheckFail = "Fail";

  static List<String> forTrainingDeclaration = [
    keyForTrainingSatisfactory,
    keyForTrainingFurtherTraining,
    keyForClearedForCheck,
    keyStopTraining,
  ];

  static List<String> forCheckDeclaration = [
    keyForCheckPass,
    keyForCheckFail,
  ];

  String typeOfAssessment = "";
  DateTime assessmentDate = Util.getCurrentDateWithoutTime();

  // instructor
  int idNoInstructor = Util.defaultIntIfNull;
  Uint8List? signatureBytes;
  String instructorSignatureUrl = Util.defaultStringIfNull;
  String instructorName = Util.defaultStringIfNull;

  // Flight Crew 1
  int idNo1 = Util.defaultIntIfNull;
  DateTime licenseExpiry1 = Util.defaultDateIfNull;
  String licenseNo1 = Util.defaultStringIfNull;
  String sessionDetails1 = "Training";
  AssessmentFlightDetails assessmentFlightDetails1 = AssessmentFlightDetails();
  List<AssessmentVariableResults> assessmentVariablesFlights1 = [];
  List<AssessmentVariableResults> assessmentVariablesFlightsHumanFactor1 = [];
  double overallPerformance1 = 0.0;
  String notes1 = "";
  String declaration1 = "";
  String nameExaminee1 = Util.defaultStringIfNull;
  String rankExaminee1 = Util.defaultStringIfNull;
  String instructorRecommendation1 = AssessmentVariables.keyNone;

  // Flight Crew 2
  int idNo2 = Util.defaultIntIfNull;
  DateTime licenseExpiry2 = Util.defaultDateIfNull;
  String licenseNo2 = Util.defaultStringIfNull;
  String sessionDetails2 = "Training";
  AssessmentFlightDetails assessmentFlightDetails2 = AssessmentFlightDetails();
  List<AssessmentVariableResults> assessmentVariablesFlights2 = [];
  List<AssessmentVariableResults> assessmentVariablesFlightsHumanFactor2 = [];
  double overallPerformance2 = 0.0;
  String notes2 = "";
  String declaration2 = "";
  String nameExaminee2 = Util.defaultStringIfNull;
  String rankExaminee2 = Util.defaultStringIfNull;
  String instructorRecommendation2 = AssessmentVariables.keyNone;

  String aircraftType = "";
  String airportAndRoute = "";
  String simulationHours = "";
  String simulationIdentity = "";
  String loaNo = "";

  String getIDNo1() {
    if (idNo1 == Util.defaultIntIfNull) {
      return "";
    } else {
      return idNo1.toString();
    }
  }

  String getIDNo2() {
    if (idNo2 == Util.defaultIntIfNull) {
      return "";
    } else {
      return idNo2.toString();
    }
  }

  double setOverallPerformance1() {
    double totalScore = 0;
    int totalVariablesAssessed = 0;
    for (AssessmentVariableResults assessmentVariableResults in assessmentVariablesFlights1) {
      if(assessmentVariableResults.assessmentMarkers != null) {
        totalScore += assessmentVariableResults.assessmentMarkers!;
        totalVariablesAssessed++;
        continue;
      }
      if(assessmentVariableResults.pilotFlyingMarkers != null && assessmentVariableResults.pilotMonitoringMarkers != null) {
        totalScore += (assessmentVariableResults.pilotFlyingMarkers! + assessmentVariableResults.pilotMonitoringMarkers!) / 2;
        totalVariablesAssessed++;
        continue;
      }
    }
    for (AssessmentVariableResults assessmentVariableResults in assessmentVariablesFlightsHumanFactor1) {
      if(assessmentVariableResults.pilotFlyingMarkers != null && assessmentVariableResults.pilotMonitoringMarkers != null) {
        totalScore += (assessmentVariableResults.pilotFlyingMarkers! + assessmentVariableResults.pilotMonitoringMarkers!) / 2;
        totalVariablesAssessed++;
        continue;
      }
    }
    overallPerformance1 = totalScore / totalVariablesAssessed;
    return overallPerformance1;
  }

  double setOverallPerformance2() {
    double totalScore = 0;
    int totalVariablesAssessed = 0;
    for (AssessmentVariableResults assessmentVariableResults in assessmentVariablesFlights2) {
      if(assessmentVariableResults.assessmentMarkers != null) {
        totalScore += assessmentVariableResults.assessmentMarkers!;
        totalVariablesAssessed++;
        continue;
      }
      if(assessmentVariableResults.pilotFlyingMarkers != null && assessmentVariableResults.pilotMonitoringMarkers != null) {
        totalScore += (assessmentVariableResults.pilotFlyingMarkers! + assessmentVariableResults.pilotMonitoringMarkers!) / 2;
        totalVariablesAssessed++;
        continue;
      }
    }
    for (AssessmentVariableResults assessmentVariableResults in assessmentVariablesFlightsHumanFactor2) {
      if(assessmentVariableResults.pilotFlyingMarkers != null && assessmentVariableResults.pilotMonitoringMarkers != null) {
        totalScore += (assessmentVariableResults.pilotFlyingMarkers! + assessmentVariableResults.pilotMonitoringMarkers!) / 2;
        totalVariablesAssessed++;
        continue;
      }
    }
    overallPerformance2 = totalScore / totalVariablesAssessed;
    return overallPerformance2;
  }

  @override
  String toString() {
    return "NewAssessment: typeOfAssessment: $typeOfAssessment, idNo1: $idNo1, idNo2: $idNo2, aircraftType: $aircraftType, airportAndRoute: $airportAndRoute, simulationHours: $simulationHours"
        ", assessmentDate: $assessmentDate, licenseExpiry1: $licenseExpiry1, licenseExpiry2: $licenseExpiry2, "
        "licenseNo1: $licenseNo1, licenseNo2: $licenseNo2, "
        "sessionDetails1: $sessionDetails1, sessionDetails2: $sessionDetails2, "
        "assessmentFlightDetails1: $assessmentFlightDetails1, assessmentFlightDetails2: $assessmentFlightDetails2, "
        "assessmentVariablesFlights1: $assessmentVariablesFlights1, assessmentVariablesFlights2: $assessmentVariablesFlights2, "
        "assessmentVariablesFlightsHumanFactor1: $assessmentVariablesFlightsHumanFactor1, assessmentVariablesFlightsHumanFactor2: $assessmentVariablesFlightsHumanFactor2, "
        "overallPerformance1: $overallPerformance1, overallPerformance2: $overallPerformance2";
  }
}
