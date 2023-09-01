import 'dart:core';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:ts_one/data/assessments/assessment_results.dart';
import 'package:ts_one/data/assessments/assessment_variable_results.dart';
import 'package:ts_one/data/assessments/assessment_variables.dart';
import 'package:ts_one/data/assessments/new_assessment.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/util/util.dart';

abstract class AssessmentResultsRepo {
  Future<List<AssessmentResults>> addAssessmentResults(
      List<AssessmentResults> assessmentResults, NewAssessment newAssessment);

  Future<List<AssessmentResults>> getAllAssessmentResults();

  Future<List<AssessmentResults>> getAssessmentResultsLimited(int limit);

  Future<List<AssessmentResults>> getAssessmentResultsByCurrentUserNotConfirm();

  Future<List<AssessmentResults>> getAssessmentResultsNotConfirmByCPTS();

  Future<List<AssessmentVariableResults>> getAssessmentVariableResult(String idAssessment);

  Future<void> updateAssessmentResultForExaminee(AssessmentResults assessmentResults);

  Future<List<AssessmentResults>> searchAssessmentResultsBasedOnName(String searchName, int searchLimit, bool isAll);

  Future<List<AssessmentResults>> getAssessmentResultsPaginated(
      int limit,
      bool isAll,
      AssessmentResults? lastAssessment,
      String? selectedRankFilter,
      int? selectedMarkerFilter,
      DateTime? filterDateFrom,
      DateTime? filterDateTo);

  Future<List<AssessmentResults>> getSelfAssessmentResults();

  Future<Map<String, DateTime>> getInstructorNotes(int examineeId);

  Future<String> makePDFSimulator(AssessmentResults assessmentResults);
}

class AssessmentResultsRepoImpl implements AssessmentResultsRepo {
  AssessmentResultsRepoImpl({FirebaseFirestore? db, UserPreferences? userPreferences})
      : _db = db ?? FirebaseFirestore.instance,
        _userPreferences = userPreferences;

  final FirebaseFirestore? _db;
  final UserPreferences? _userPreferences;

  @override
  Future<List<AssessmentResults>> addAssessmentResults(
      List<AssessmentResults> assessmentResults, NewAssessment newAssessment) async {
    List<AssessmentResults> assessmentResultsList = AssessmentResults.extractDataFromNewAssessment(newAssessment);
    try {
      for (var assessmentResult in assessmentResultsList) {
        assessmentResult.id =
            "assessment-result-${assessmentResult.examineeStaffIDNo}-${Util.convertDateTimeDisplay(assessmentResult.date.toString())}";
        await _db!
            .collection(AssessmentResults.firebaseCollection)
            .doc(assessmentResult.id)
            .set(assessmentResult.toFirebase());

        for (var assessmentVariableResult in assessmentResult.variableResults) {
          assessmentVariableResult.id =
              "assessment-variable-result-${assessmentVariableResult.assessmentVariableId}-${assessmentResult.examineeStaffIDNo}-${Util.convertDateTimeDisplay(assessmentResult.date.toString())}";

          assessmentVariableResult.assessmentResultsId = assessmentResult.id;
          await _db!
              .collection(AssessmentVariableResults.firebaseCollection)
              .doc(assessmentVariableResult.id)
              .set(assessmentVariableResult.toFirebase());
        }
      }
    } catch (e) {
      log("Exception in AssessmentResultsRepo on addAssessmentResults: ${e.toString()}");
    }
    return assessmentResultsList;
  }

  @override
  Future<List<AssessmentResults>> getAllAssessmentResults() async {
    List<AssessmentResults> assessmentResultsList = [];
    try {
      QuerySnapshot querySnapshot = await _db!.collection(AssessmentResults.firebaseCollection).get();

      for (var doc in querySnapshot.docs) {
        AssessmentResults assessmentResults = AssessmentResults.fromFirebase(doc.data() as Map<String, dynamic>);
        QuerySnapshot querySnapshot2 = await _db!
            .collection(AssessmentVariableResults.firebaseCollection)
            .where(AssessmentVariableResults.keyAssessmentResultsId, isEqualTo: assessmentResults.id)
            .get();

        for (var doc2 in querySnapshot2.docs) {
          AssessmentVariableResults assessmentVariableResults =
              AssessmentVariableResults.fromFirebase(doc2.data() as Map<String, dynamic>);
          assessmentResults.variableResults.add(assessmentVariableResults);
        }
        assessmentResultsList.add(assessmentResults);
      }
    } catch (e) {
      log("Exception in AssessmentResultsRepo on getAllAssessmentResults: $e");
    }
    return assessmentResultsList;
  }

  @override
  Future<List<AssessmentResults>> getAssessmentResultsLimited(int limit) async {
    List<AssessmentResults> assessmentResultsList = [];

    try {
      _db!
          .collection(AssessmentResults.firebaseCollection)
          .limit(limit)
          .orderBy(AssessmentResults.keyDate, descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          assessmentResultsList.add(AssessmentResults.fromFirebase(element.data()));
        }
      });
    } catch (e) {
      log("Exception on assessment results repo: ${e.toString()}");
    }

    return assessmentResultsList;
  }

  @override
  Future<List<AssessmentResults>> getAssessmentResultsByCurrentUserNotConfirm() async {
    final userPreferences = _userPreferences;
    final userId = userPreferences!.getIDNo();
    List<AssessmentResults> assessmentResults = [];

    try {
      await _db!
          .collection(AssessmentResults.firebaseCollection)
          .where(AssessmentResults.keyExamineeStaffIDNo, isEqualTo: userId)
          .where(AssessmentResults.keyConfirmedByExaminer, isEqualTo: false)
          .get()
          .then((value) {
        for (var element in value.docs) {
          assessmentResults.add(AssessmentResults.fromFirebase(element.data()));
        }
      });
    } catch (e) {
      log("Exception in AssessmentResultRepo on getAssessmentResultsByCurrentUserNotConfirm: $e");
    }
    return assessmentResults;
  }

  @override
  Future<List<AssessmentResults>> getAssessmentResultsNotConfirmByCPTS() async {
    List<AssessmentResults> assessmentResults = [];

    try {
      await _db!
          .collection(AssessmentResults.firebaseCollection)
          .where(AssessmentResults.keyConfirmedByExaminer, isEqualTo: true)
          .where(AssessmentResults.keyConfirmedByInstructor, isEqualTo: true)
          .where(AssessmentResults.keyConfirmedByCPTS, isEqualTo: false)
          .get()
          .then((value) {
        for (var element in value.docs) {
          assessmentResults.add(AssessmentResults.fromFirebase(element.data()));
        }
      });
    } catch (e) {
      log("Exception in AssessmentResultRepo on getAssessmentResultsNotConfirmByCPTS: $e");
    }

    return assessmentResults;
  }

  int assessmentVariableCollectionComparator(DocumentSnapshot a, DocumentSnapshot b) {
    final idA = int.tryParse(a.id.split('-')[4]); // Extract the numerical part from the ID of document A
    final idB = int.tryParse(b.id.split('-')[4]); // Extract the numerical part from the ID of document B

    if (idA != null && idB != null) {
      return idA.compareTo(idB);
    }
    return 0;
  }

  @override
  Future<List<AssessmentVariableResults>> getAssessmentVariableResult(String idAssessment) async {
    List<AssessmentVariableResults> assessmentVariableResults = [];

    try {
      final documents = await _db!
          .collection(AssessmentVariableResults.firebaseCollection)
          .where(AssessmentVariableResults.keyAssessmentResultsId, isEqualTo: idAssessment)
          .get()
          .then((value) {
        return value.docs;
      });

      documents.sort(assessmentVariableCollectionComparator);

      for (var element in documents) {
        assessmentVariableResults.add(AssessmentVariableResults.fromFirebase(element.data()));
      }
    } catch (e) {
      log("Exception in AssessmentResultRepo on getAssessmentVariableResult: $e");
    }

    return assessmentVariableResults;
  }

  @override
  Future<void> updateAssessmentResultForExaminee(AssessmentResults assessmentResults) async {
    try {
      await _db!
          .collection(AssessmentResults.firebaseCollection)
          .doc(assessmentResults.id)
          .update(assessmentResults.toFirebase());
    } catch (e) {
      log("Exception in AssessmentResultRepo on updateAssessmentResultForExaminee: $e");
    }
  }

  @override
  Future<List<AssessmentResults>> searchAssessmentResultsBasedOnName(
      String searchName, int searchLimit, bool isAll) async {
    List<AssessmentResults> assessmentResultsList = [];
    int idUser = _userPreferences!.getIDNo();

    try {
      Query query = _db!.collection(AssessmentResults.firebaseCollection);

      if (!isAll) {
        query = query.where(AssessmentResults.keyInstructorStaffIDNo, isEqualTo: idUser);
      }

      query = query
          .orderBy(AssessmentResults.keyNameExaminee)
          .limit(searchLimit)
          .startAt([searchName]).endAt(['$searchName\uf8ff']);

      final assessmentData = await query.get();

      assessmentResultsList =
          assessmentData.docs.map((e) => AssessmentResults.fromFirebase(e.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      log("Exception in AssessmentResultRepo on searchAssessmentResultsBasedOnName: $e");
    }

    return assessmentResultsList;
  }

  @override
  Future<List<AssessmentResults>> getAssessmentResultsPaginated(
      int limit,
      bool isAll,
      AssessmentResults? lastAssessment,
      String? selectedRankFilter,
      int? selectedMarkerFilter,
      DateTime? filterDateFrom,
      DateTime? filterDateTo) async {
    int idUser = _userPreferences!.getIDNo();
    List<AssessmentResults> assessmentResultsList = [];

    try {
      Query query;

      query = _db!.collection(AssessmentResults.firebaseCollection);

      if (!isAll) {
        query = query.where(AssessmentResults.keyInstructorStaffIDNo, isEqualTo: idUser);
      }

      if (selectedRankFilter != null) {
        query = query.where(AssessmentResults.keyRank, isEqualTo: selectedRankFilter);
      }

      if (filterDateFrom != null) {
        query = query.where(AssessmentResults.keyDate, isGreaterThanOrEqualTo: Timestamp.fromDate(filterDateFrom));
      }

      if (filterDateTo != null) {
        query = query.where(AssessmentResults.keyDate, isLessThanOrEqualTo: Timestamp.fromDate(filterDateTo));
      }

      query = query.orderBy(AssessmentResults.keyDate, descending: true);

      if (lastAssessment != null) {
        final lastDocumentAssessment =
            await _db!.collection(AssessmentResults.firebaseCollection).doc(lastAssessment.id).get();

        query = query.startAfterDocument(lastDocumentAssessment);
      }

      query = query.limit(limit);

      final assessmentData = await query.get();

      if (selectedMarkerFilter != null) {
        for (var doc in assessmentData.docs) {
          AssessmentResults assessmentResults = AssessmentResults.fromFirebase(doc.data() as Map<String, dynamic>);

          QuerySnapshot querySnapshot = await _db!
              .collection(AssessmentVariableResults.firebaseCollection)
              .where(AssessmentVariableResults.keyAssessmentResultsId, isEqualTo: assessmentResults.id)
              .get();

          for (var docVariable in querySnapshot.docs) {
            AssessmentVariableResults assessmentVariableResults =
                AssessmentVariableResults.fromFirebase(docVariable.data() as Map<String, dynamic>);

            if (assessmentVariableResults.assessmentMarkers == selectedMarkerFilter ||
                assessmentVariableResults.pilotFlyingMarkers == selectedMarkerFilter ||
                assessmentVariableResults.pilotMonitoringMarkers == selectedMarkerFilter) {
              assessmentResultsList.add(assessmentResults);
              break;
            }
          }
        }
      } else {
        for (var element in assessmentData.docs) {
          assessmentResultsList.add(AssessmentResults.fromFirebase(element.data() as Map<String, dynamic>));
        }
      }
    } catch (e) {
      log("Exception in AssessmentResultRepo on getAllAssessmentResultsPaginated: $e");
    }

    return assessmentResultsList;
  }

  @override
  Future<List<AssessmentResults>> getSelfAssessmentResults() async {
    int idUser = _userPreferences!.getIDNo();
    List<AssessmentResults> assessmentResultsList = [];

    try {
      await _db!
          .collection(AssessmentResults.firebaseCollection)
          .where(AssessmentResults.keyExamineeStaffIDNo, isEqualTo: idUser)
          .orderBy(AssessmentResults.keyDate, descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          assessmentResultsList.add(AssessmentResults.fromFirebase(element.data()));
        }
      });
    } catch (e) {
      log("Exception in AssessmentResultRepo on getSelfAssessmentResults: $e");
    }
    return assessmentResultsList;
  }

  @override
  Future<Map<String, DateTime>> getInstructorNotes(int examineeId) async {
    Map<String, DateTime> instructorNotes = {};

    try {
      await _db!
          .collection(AssessmentResults.firebaseCollection)
          .where(AssessmentResults.keyExamineeStaffIDNo, isEqualTo: examineeId)
          .orderBy(AssessmentResults.keyDate, descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          var assessmentResult = AssessmentResults.fromFirebase(element.data());
          instructorNotes.addAll({assessmentResult.notes: assessmentResult.date});
        }
      });
    } catch (e) {
      log("Exception in AssessmentResultRepo on getInstructorNotes: $e");
    }

    return instructorNotes;
  }

  @override
  Future<String> makePDFSimulator(AssessmentResults assessmentResults) async {
    String flightDetails = assessmentResults.sessionDetails;

    try {
      // get temporary directory path
      Directory? tempDir = await getExternalStorageDirectory();

      // Load the existing PDF document.
      PdfDocument document =
          PdfDocument(inputBytes: File('${tempDir?.path}/QZ_TS1_SIM_04JUL2020_rev02.pdf').readAsBytesSync());

      // ============================= FOR CANDIDATE DETAIL ================================================

      List<String> pdfCandidateDetail = [
        "Other Crew Member Rank & Name.",
        "Rank & Name.",
        "License No.",
        "License Expiry",
        "Staff No.",
        "SIM ident.",
        "Aircraft Type.",
        "Airport & Route.",
        "Sim Hours",
        "Date (dd/mm/yyyy)"
      ];

      // For name
      List<MatchedItem> candidateDetailCollection = PdfTextExtractor(document).findText(pdfCandidateDetail);
      bool sameName = false;
      for (var matched in candidateDetailCollection) {
        Rect textbounds = matched.bounds;

        switch (matched.text) {
          case "Other Crew Member Rank & Name.":
            document.pages[0].graphics.drawString(
              "${assessmentResults.otherStaffRank}. ${assessmentResults.otherStaffName}",
              PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textbounds.topLeft.dx, textbounds.topLeft.dy + 8, 300, 50),
            );
            break;

          case "Rank & Name.":
            if (!sameName) {
              document.pages[0].graphics.drawString(
                "${assessmentResults.rank}. ${assessmentResults.examineeName}",
                PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textbounds.topLeft.dx, textbounds.topLeft.dy + 8, 300, 50),
              );
              sameName = true;
            }
            break;

          case "License No.":
            document.pages[0].graphics.drawString(
              assessmentResults.licenseNo,
              PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textbounds.topLeft.dx + 3, textbounds.topLeft.dy + 8, 100, 50),
            );
            break;

          case "License Expiry":
            document.pages[0].graphics.drawString(
              Util.convertDateTimeDisplay(assessmentResults.licenseExpiry.toString(), "dd/MM/yyyy"),
              PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textbounds.topLeft.dx + 3, textbounds.topLeft.dy + 8, 100, 50),
            );
            break;

          case "Staff No.":
            document.pages[0].graphics.drawString(
              assessmentResults.examineeStaffIDNo.toString(),
              PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textbounds.topLeft.dx + 3, textbounds.topLeft.dy + 8, 100, 50),
            );
            break;

          case "SIM ident.":
            document.pages[0].graphics.drawString(
              assessmentResults.simIdent == "" ? "-" : assessmentResults.simIdent.toString(),
              PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textbounds.topLeft.dx + 3, textbounds.topLeft.dy + 8, 100, 50),
            );
            break;

          case "Aircraft Type.":
            document.pages[0].graphics.drawString(
              assessmentResults.aircraftType,
              PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textbounds.topLeft.dx + 3, textbounds.topLeft.dy + 8, 100, 50),
            );
            break;

          case "Airport & Route.":
            document.pages[0].graphics.drawString(
              assessmentResults.airportAndRoute,
              PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textbounds.topLeft.dx + 3, textbounds.topLeft.dy + 8, 100, 50),
            );
            break;

          case "Sim Hours":
            document.pages[0].graphics.drawString(
              assessmentResults.simulationHours,
              PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textbounds.topLeft.dx + 3, textbounds.topLeft.dy + 8, 100, 50),
            );
            break;

          case "Date (dd/mm/yyyy)":
            document.pages[0].graphics.drawString(
              Util.convertDateTimeDisplay(assessmentResults.date.toString(), "dd/MM/yyyy"),
              PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textbounds.topLeft.dx, textbounds.topLeft.dy + 8, 100, 50),
            );
            break;
        }
      }

      // ====================================== FOR TRAINING / CHECKING DETAILS ======================================

      Map<String, String> listOfTrainingCheckingDetails = {};

      for (var element in assessmentResults.trainingCheckingDetails) {
        var splitData = element.split(":");
        if (splitData.length > 1) {
          listOfTrainingCheckingDetails.addAll({splitData[0].trim(): splitData[1].trim()});
        } else {
          listOfTrainingCheckingDetails.addAll({element.trim(): ""});
        }
      }



      //Find the text and get matched items.
      List<MatchedItem> listOfTrainingCheckingDetailsMatchedItemCollection =
          PdfTextExtractor(document).findText(listOfTrainingCheckingDetails.keys.toList(), startPageIndex: 0,endPageIndex: 0);

      // Get the matched item in the collection using index.
      // MatchedItem matchedText = listOfTrainingCheckingDetailsMatchedItemCollection[0];
      // Loop for listOfTrainingCheckingDetailsMatchedItemCollection
      for (var matched in listOfTrainingCheckingDetailsMatchedItemCollection) {
        String textMatched = matched.text;
        Rect textBounds = matched.bounds;

        log("SEMOGA: $textMatched");

        switch (textMatched) {
          case "Line Oriented Simulation (LOS) / SPOT":
            var choice = listOfTrainingCheckingDetails[textMatched];
            String textExtract;

            if (choice == "Line Oriented Simulation (LOS)") {
              textExtract = "SPOT";
            } else {
              textExtract = "Line Oriented Simulation (LOS)";
            }

            List<MatchedItem> lineOriented = PdfTextExtractor(document).findText([textExtract]);

            var bonds = lineOriented[0].bounds;

            if (choice == "Line Oriented Simulation (LOS)") {
              document.pages[0].graphics.drawString(
                "-",
                PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(bonds.topLeft.dx, bonds.topLeft.dy - 18, 100, 37),
              );
            } else {
              document.pages[0].graphics.drawString(
                "--------",
                PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(bonds.topLeft.dx, bonds.topLeft.dy - 18, 100, 37),
              );
            }

            break;

          case "ETOPS / MNPS / RVSM / NATS":
            List<String> listOfEtopsMnpsRvsmNats = ["ETOPS", "MNPS", "NATS", "RVSM"];

            listOfEtopsMnpsRvsmNats
                .removeWhere((element) => element == listOfTrainingCheckingDetails["ETOPS / MNPS / RVSM / NATS"]);

            List<MatchedItem> listOfEtopsMnpsRvsmNatsMatchedItemCollection =
                PdfTextExtractor(document).findText(listOfEtopsMnpsRvsmNats);

            var duplicateRVSM = false;

            for (var item in listOfEtopsMnpsRvsmNatsMatchedItemCollection) {
              Rect textBounds = item.bounds;

              if (duplicateRVSM) {
                continue;
              }

              if (item.text == "RVSM") {
                duplicateRVSM = true;
              }

              document.pages[0].graphics.drawString(
                "-",
                PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textBounds.topLeft.dx, textBounds.topLeft.dy - 18, 32, 37),
              );
            }

            break;

          case "CRP Initial/Recurrent":
            if (listOfTrainingCheckingDetails["CRP Initial/Recurrent"] == "Recurrent") {
              document.pages[0].graphics.drawString(
                "--",
                PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textBounds.topLeft.dx + 12, textBounds.topLeft.dy - 18, 32, 37),
              );
            } else {
              document.pages[0].graphics.drawString(
                "---",
                PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textBounds.topLeft.dx + 28, textBounds.topLeft.dy - 18, 32, 37),
              );
            }

            break;

          case "ZFTT / Flight Base Trng":
            String choice = listOfTrainingCheckingDetails["ZFTT / Flight Base Trng"]!;
            String extractor;
            String hider;

            if (choice == "ZFTT") {
              extractor = "Flight Base Trng";
              hider = "----";
            } else {
              extractor = "ZFTT";
              hider = "-";
            }

            List<MatchedItem> listOfZFTTAndFlightBaseTrng = PdfTextExtractor(document).findText([extractor]);

            var bound = listOfZFTTAndFlightBaseTrng.first.bounds;

            document.pages[0].graphics.drawString(
              hider,
              PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(bound.topLeft.dx, bound.topLeft.dy - 18, 40, 37),
            );

            break;

          case "Fixed Based Simulator/MFTD":
            String choice = listOfTrainingCheckingDetails["Fixed Based Simulator/MFTD"]!;
            String extractor;
            String hider;

            if (choice == "MFTD") {
              extractor = "Fixed Based Simulator";
              hider = "------";
            } else {
              extractor = "MFTD";
              hider = "-";
            }

            List<MatchedItem> listOfFixedBasedSimulatorMFTD = PdfTextExtractor(document).findText([extractor]);

            var bound = listOfFixedBasedSimulatorMFTD.first.bounds;

            document.pages[0].graphics.drawString(
              hider,
              PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(bound.topLeft.dx, bound.topLeft.dy - 18, 60, 37),
            );
            break;

          case "RHS Initial / Recurrent":
            if (listOfTrainingCheckingDetails["RHS Initial / Recurrent"] == "Recurrent") {
              document.pages[0].graphics.drawString(
                "--",
                PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textBounds.topLeft.dx + 12, textBounds.topLeft.dy - 18, 32, 37),
              );
            } else {
              document.pages[0].graphics.drawString(
                "---",
                PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textBounds.topLeft.dx + 28, textBounds.topLeft.dy - 18, 32, 37),
              );
            }
            break;

          case "Instructor's Initial / Renewal":
            if (listOfTrainingCheckingDetails["Instructor's Initial / Renewal"] == "Renewal") {
              document.pages[0].graphics.drawString(
                "--",
                PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textBounds.topLeft.dx + 27, textBounds.topLeft.dy - 18, 32, 37),
              );
            } else {
              document.pages[0].graphics.drawString(
                "--",
                PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textBounds.topLeft.dx + 49, textBounds.topLeft.dy - 18, 32, 37),
              );
            }
            break;

          case "Std Transition / IOE for Rated Flt Crew":
            String choice = listOfTrainingCheckingDetails["Std Transition / IOE for Rated Flt Crew"]!;
            String extractor;
            String hider;

            if (choice == "Std Transition") {
              extractor = "IOE for Rated Flt Crew";
              hider = "------";
            } else {
              extractor = "Std Transition";
              hider = "---";
            }

            List<MatchedItem> listOfStdTransitionAndIoeForRatedFltCrew =
                PdfTextExtractor(document).findText([extractor]);

            var bound = listOfStdTransitionAndIoeForRatedFltCrew.first.bounds;

            document.pages[0].graphics.drawString(
              hider,
              PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(bound.topLeft.dx, bound.topLeft.dy - 18, 60, 37),
            );
            break;

          case "Remedial Trng / Evaluation":
            if (listOfTrainingCheckingDetails["Remedial Trng / Evaluation"] == "Evaluation") {
              document.pages[0].graphics.drawString(
                "-",
                PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textBounds.topLeft.dx + 27, textBounds.topLeft.dy - 18, 32, 37),
              );
            } else {
              document.pages[0].graphics.drawString(
                "--",
                PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textBounds.topLeft.dx + 45, textBounds.topLeft.dy - 18, 32, 37),
              );
            }
            break;

          case "Recurrent ….":
            document.pages[0].graphics.drawString(
              listOfTrainingCheckingDetails["Recurrent …."]!,
              PdfStandardFont(PdfFontFamily.helvetica, 6),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textBounds.topLeft.dx + 30, textBounds.topLeft.dy - 2, 80, 37),
            );
            break;


          case "Other ....":
            document.pages[0].graphics.drawString(
              listOfTrainingCheckingDetails["Other ...."]!,
              PdfStandardFont(PdfFontFamily.helvetica, 6),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textBounds.topLeft.dx + 20, textBounds.topLeft.dy - 2, 70, 37),
            );
            break;
        }

        document.pages[0].graphics.drawString(
            flightDetails.substring(0, 1), PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
            brush: PdfBrushes.black,
            bounds: Rect.fromLTWH(textBounds.topLeft.dx - 14, textBounds.topLeft.dy - 2, 100, 50));
      }

      // ====================================== FOR ASSESSMENT VARIABLES ==============================================
      // get font from asset
      var fontData = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
      List<int>? fontDataList = fontData.buffer.asUint8List(fontData.offsetInBytes, fontData.lengthInBytes);

      List<AssessmentVariableResults> assessmentVariableResults = assessmentResults.variableResults;

      List<String> titleVariableResults =
          assessmentVariableResults.map((e) => e.assessmentVariableName.trim()).toList();

      //Find the text and get matched items.
      List<MatchedItem> flightAssessmentMatchedItemCollection =
          PdfTextExtractor(document).findText(titleVariableResults);

      List<String> uniqueText = [];
      List<MatchedItem> nonDuplicateMatchedItemVariable = [];

      for (MatchedItem item in flightAssessmentMatchedItemCollection) {
        if (!uniqueText.contains(item.text)) {
          uniqueText.add(item.text);
          nonDuplicateMatchedItemVariable.add(item);
        } else {
          if (item.text == "Precision Approaches") {
            nonDuplicateMatchedItemVariable.removeWhere((element) => element.text == item.text);
            nonDuplicateMatchedItemVariable.add(item);
          }
        }
      }

      for (var matchedVariable in nonDuplicateMatchedItemVariable) {
        MatchedItem text = matchedVariable;
        Rect textBounds = text.bounds;

        for (var assessment in assessmentVariableResults) {
          // Check if the assessment variable name is the same with the matched variable text
          if (assessment.assessmentVariableName.trim().toLowerCase() == matchedVariable.text.trim().toLowerCase()) {
            // Assessment Type = Satisfactory
            if (assessment.assessmentType == "Satisfactory") {
              if (assessment.isNotApplicable) {
                document.pages[0].graphics.drawString("√", PdfTrueTypeFont(fontDataList, 10),
                    brush: PdfBrushes.black,
                    bounds: Rect.fromLTWH(textBounds.topLeft.dx + 163, textBounds.topLeft.dy - 4, 100, 50));
              } else {
                // For Satisfactory
                if (assessment.assessmentSatisfactory == "Satisfactory") {
                  document.pages[0].graphics.drawString("√", PdfTrueTypeFont(fontDataList, 10),
                      brush: PdfBrushes.black,
                      bounds: Rect.fromLTWH(textBounds.topLeft.dx + 146, textBounds.topLeft.dy - 4, 100, 50));
                } else {
                  // FOR Unsatisfactory
                  document.pages[0].graphics.drawString("√", PdfTrueTypeFont(fontDataList, 10),
                      brush: PdfBrushes.black,
                      bounds: Rect.fromLTWH(textBounds.topLeft.dx + 128, textBounds.topLeft.dy - 4, 100, 50));
                }

                double additionalFromLeft = 0;
                switch (assessment.assessmentMarkers) {
                  case 1:
                    additionalFromLeft = 180;
                    break;
                  case 2:
                    additionalFromLeft = 200;
                    break;
                  case 3:
                    additionalFromLeft = 220;
                    break;
                  case 4:
                    additionalFromLeft = 235;
                    break;
                  case 5:
                    additionalFromLeft = 255;
                    break;
                }

                // Assessment Markers
                document.pages[0].graphics.drawString("√", PdfTrueTypeFont(fontDataList, 10),
                    brush: PdfBrushes.black,
                    bounds:
                        Rect.fromLTWH(textBounds.topLeft.dx + additionalFromLeft, textBounds.topLeft.dy - 4, 100, 50));
              }

              // Assessment Type = PF/PM ========================================================
            } else if (assessment.assessmentType == "PF/PM") {
              if (assessment.isNotApplicable) {
                document.pages[0].graphics.drawString("√", PdfTrueTypeFont(fontDataList, 10),
                    brush: PdfBrushes.black,
                    bounds: Rect.fromLTWH(textBounds.topLeft.dx + 124, textBounds.topLeft.dy - 4, 100, 50));
              } else {
                double additionalFromLeftForPilotPF = 0;

                switch (assessment.pilotFlyingMarkers) {
                  case 1:
                    additionalFromLeftForPilotPF = 140;
                    break;
                  case 2:
                    additionalFromLeftForPilotPF = 155;
                    break;
                  case 3:
                    additionalFromLeftForPilotPF = 170;
                    break;
                  case 4:
                    additionalFromLeftForPilotPF = 185;
                    break;
                  case 5:
                    additionalFromLeftForPilotPF = 200;
                    break;
                }

                // Value Pilot Flying Markers
                document.pages[0].graphics.drawString("√", PdfTrueTypeFont(fontDataList, 10),
                    brush: PdfBrushes.black,
                    bounds: Rect.fromLTWH(
                        textBounds.topLeft.dx + additionalFromLeftForPilotPF, textBounds.topLeft.dy - 4, 100, 50));

                double additionalFromLeftForPilotPM = 0;

                switch (assessment.pilotMonitoringMarkers) {
                  case 1:
                    additionalFromLeftForPilotPM = 213;
                    break;
                  case 2:
                    additionalFromLeftForPilotPM = 233;
                    break;
                  case 3:
                    additionalFromLeftForPilotPM = 248;
                    break;
                  case 4:
                    additionalFromLeftForPilotPM = 263;
                    break;
                  case 5:
                    additionalFromLeftForPilotPM = 278;
                    break;
                }

                // Value Pilot Monitoring PM
                document.pages[0].graphics.drawString("√", PdfTrueTypeFont(fontDataList, 10),
                    brush: PdfBrushes.black,
                    bounds: Rect.fromLTWH(
                        textBounds.topLeft.dx + additionalFromLeftForPilotPM, textBounds.topLeft.dy - 4, 100, 50));
              }
            }
          }
        }
      }

      // FOR MANUAL ASSESSMENT INPUT ==============================================================================================
      List<AssessmentVariableResults> manualVariableAircraftSystem = [];
      List<AssessmentVariableResults> manualVariableAbnormal = [];

      for (var ele in assessmentVariableResults) {
        if (ele.assessmentVariableCategory == "Aircraft System or Procedures" && ele.assessmentVariableName != "") {
          manualVariableAircraftSystem.add(ele);
        } else if (ele.assessmentVariableCategory == "Abnormal or Emer.Proc" && ele.assessmentVariableName != "") {
          manualVariableAbnormal.add(ele);
        }
      }

      List<String> textManual = ["Aircraft System/Procedures", "Abnormal/Emer.Proc"];

      List<MatchedItem> matchedManual = PdfTextExtractor(document).findText(textManual, startPageIndex: 0);

      for (var value in matchedManual) {
        MatchedItem matchedItem = value;
        Rect textBounds = value.bounds;

        if (matchedItem.text == "Aircraft System/Procedures") {
          var minusBounds = 12;
          for (var manual in manualVariableAircraftSystem) {
            document.pages[0].graphics.drawString(
                manual.assessmentVariableName.toTitleCase(), PdfStandardFont(PdfFontFamily.helvetica, 7),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textBounds.topLeft.dx, textBounds.topLeft.dy + minusBounds, 500, 300),
                format: PdfStringFormat(lineSpacing: 5));

            double additionalFromLeftForPilotPF = 0;

            switch (manual.pilotFlyingMarkers) {
              case 1:
                additionalFromLeftForPilotPF = 130;
                break;
              case 2:
                additionalFromLeftForPilotPF = 145;
                break;
              case 3:
                additionalFromLeftForPilotPF = 160;
                break;
              case 4:
                additionalFromLeftForPilotPF = 175;
                break;
              case 5:
                additionalFromLeftForPilotPF = 190;
                break;
            }

            // Value Pilot Flying Markers
            document.pages[0].graphics.drawString(
              "√",
              PdfTrueTypeFont(fontDataList, 10),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textBounds.topLeft.dx + additionalFromLeftForPilotPF,
                  textBounds.topLeft.dy + minusBounds - 4, 100, 50),
            );

            double additionalFromLeftForPilotPM = 0;

            switch (manual.pilotMonitoringMarkers) {
              case 1:
                additionalFromLeftForPilotPM = 202;
                break;
              case 2:
                additionalFromLeftForPilotPM = 222;
                break;
              case 3:
                additionalFromLeftForPilotPM = 237;
                break;
              case 4:
                additionalFromLeftForPilotPM = 252;
                break;
              case 5:
                additionalFromLeftForPilotPM = 267;
                break;
            }

            // Value Pilot Monitoring PM
            document.pages[0].graphics.drawString(
              "√",
              PdfTrueTypeFont(fontDataList, 10),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textBounds.topLeft.dx + additionalFromLeftForPilotPM,
                  textBounds.topLeft.dy + minusBounds - 4, 100, 50),
            );

            minusBounds += 12;
          }
        } else if (matchedItem.text == "Abnormal/Emer.Proc") {
          var minusBounds = 12;
          for (var manual in manualVariableAbnormal) {
            document.pages[0].graphics.drawString(
              manual.assessmentVariableName.toTitleCase(),
              PdfStandardFont(PdfFontFamily.helvetica, 7),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textBounds.topLeft.dx, textBounds.topLeft.dy + minusBounds, 500, 300),
              format: PdfStringFormat(lineSpacing: 5),
            );

            double additionalFromLeftForPilotPF = 0;

            switch (manual.pilotFlyingMarkers) {
              case 1:
                additionalFromLeftForPilotPF = 128;
                break;
              case 2:
                additionalFromLeftForPilotPF = 143;
                break;
              case 3:
                additionalFromLeftForPilotPF = 158;
                break;
              case 4:
                additionalFromLeftForPilotPF = 173;
                break;
              case 5:
                additionalFromLeftForPilotPF = 188;
                break;
            }

            // Value Pilot Flying Markers
            document.pages[0].graphics.drawString(
              "√",
              PdfTrueTypeFont(fontDataList, 10),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textBounds.topLeft.dx + additionalFromLeftForPilotPF,
                  textBounds.topLeft.dy + minusBounds - 4, 100, 50),
            );

            double additionalFromLeftForPilotPM = 0;

            switch (manual.pilotMonitoringMarkers) {
              case 1:
                additionalFromLeftForPilotPM = 200;
                break;
              case 2:
                additionalFromLeftForPilotPM = 220;
                break;
              case 3:
                additionalFromLeftForPilotPM = 235;
                break;
              case 4:
                additionalFromLeftForPilotPM = 250;
                break;
              case 5:
                additionalFromLeftForPilotPM = 265;
                break;
            }

            // Value Pilot Monitoring PM
            document.pages[0].graphics.drawString(
              "√",
              PdfTrueTypeFont(fontDataList, 10),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textBounds.topLeft.dx + additionalFromLeftForPilotPM,
                  textBounds.topLeft.dy + minusBounds - 4, 100, 50),
            );

            minusBounds += 12;
          }
        }
      }

      // ================================= PAGE 2 =====================================================================

      // Overall Performance

      var overallPerformance = assessmentResults.overallPerformance.round();

      double coordinateFromLeft = 62.1;

      switch (overallPerformance.toString()) {
        case "1":
          coordinateFromLeft = 62.1;
          break;

        case "2":
          coordinateFromLeft = 167.1;
          break;

        case "3":
          coordinateFromLeft = 273.1;
          break;

        case "4":
          coordinateFromLeft = 383.1;
          break;

        case "5":
          coordinateFromLeft = 500.1;
          break;
      }

      // Overall Performance
      document.pages[1].graphics.drawString("O", PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
          brush: PdfBrushes.black, bounds: Rect.fromLTWH(coordinateFromLeft, 46, 100, 50));

      // ======================================== FOR NOTES ====================================================
      List<MatchedItem> notes = PdfTextExtractor(document).findText(["Notes"], startPageIndex: 1);

      for (var matchedVariable in notes) {
        MatchedItem matchedItem = matchedVariable;
        Rect textBounds = matchedItem.bounds;
        switch (matchedItem.text) {
          case "Notes":
            document.pages[1].graphics.drawString(
                assessmentResults.notes, PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(textBounds.topLeft.dx, textBounds.topLeft.dy + 15, 500, 400),
                format: PdfStringFormat(lineSpacing: 6));
            break;
        }
      }

      List<String> signatureText = [
        "only if recommendations is made",
        "Candidate Name:",
        "Name:",
        "Chief Pilot Training & Standards"
      ];
      List<MatchedItem> signatureMatchedItem = PdfTextExtractor(document).findText(signatureText, startPageIndex: 1);
      List<String> uniqueSignature = [];
      List<MatchedItem> nonDuplicateSignatureMatchedItem = [];

      for (var item in signatureMatchedItem) {
        if (!uniqueSignature.contains(item.text)) {
          uniqueSignature.add(item.text);
          nonDuplicateSignatureMatchedItem.add(item);
        }
      }

      for (var item in nonDuplicateSignatureMatchedItem) {
        MatchedItem matchedItem = item;
        Rect textBounds = matchedItem.bounds;

        switch (matchedItem.text) {
          case "only if recommendations is made":
            // Recommendation
            if (assessmentResults.instructorRecommendation != "None") {
              var instructorSignatureUrl = assessmentResults.instructorSignatureUrl;
              var response = await get(Uri.parse(instructorSignatureUrl));
              var data = response.bodyBytes;

              PdfBitmap image = PdfBitmap(data);

              document.pages[1].graphics
                  .drawImage(image, Rect.fromLTWH(textBounds.topLeft.dx, textBounds.center.dy - 50, 70, 50));

              var variableRecommendation = assessmentResults.instructorRecommendation;

              switch (assessmentResults.instructorRecommendation) {
                case AssessmentVariables.keyGroundTrainingInstructor:
                  variableRecommendation = "Ground Training";
                  break;
                case AssessmentVariables.keyTypeRatingInstructor:
                  variableRecommendation = "Type Rating";
                  break;
                case AssessmentVariables.keyCompanyCheckPilot:
                  variableRecommendation = "Company";
                  break;
              }

              List<MatchedItem> instructorRecommendationMatchedItem =
                  PdfTextExtractor(document).findText([variableRecommendation], startPageIndex: 1);

              log("JAJAJAJ ${instructorRecommendationMatchedItem.length} dan $variableRecommendation");
              var instrucItem = instructorRecommendationMatchedItem.first;

              if (variableRecommendation == "Company") {
                instrucItem = instructorRecommendationMatchedItem.last;
              }

              Rect instrucRecomBounds = instrucItem.bounds;

              switch (assessmentResults.instructorRecommendation) {
                case AssessmentVariables.keySeniorFirstOfficer:
                  document.pages[1].graphics.drawString(
                    "√",
                    PdfTrueTypeFont(fontDataList, 15),
                    brush: PdfBrushes.black,
                    bounds:
                        Rect.fromLTWH(instrucRecomBounds.topLeft.dx - 45, instrucRecomBounds.topLeft.dy - 8, 50, 50),
                  );
                  break;

                case AssessmentVariables.keyCommandUpgrade:
                  document.pages[1].graphics.drawString(
                    "√",
                    PdfTrueTypeFont(fontDataList, 15),
                    brush: PdfBrushes.black,
                    bounds:
                        Rect.fromLTWH(instrucRecomBounds.topLeft.dx - 45, instrucRecomBounds.topLeft.dy - 8, 50, 50),
                  );
                  break;

                case AssessmentVariables.keyGroundTrainingInstructor:
                  document.pages[1].graphics.drawString(
                    "√",
                    PdfTrueTypeFont(fontDataList, 15),
                    brush: PdfBrushes.black,
                    bounds:
                        Rect.fromLTWH(instrucRecomBounds.topLeft.dx - 33, instrucRecomBounds.topLeft.dy - 4, 50, 50),
                  );
                  break;

                case AssessmentVariables.keyTypeRatingInstructor:
                  document.pages[1].graphics.drawString(
                    "√",
                    PdfTrueTypeFont(fontDataList, 15),
                    brush: PdfBrushes.black,
                    bounds:
                        Rect.fromLTWH(instrucRecomBounds.topLeft.dx - 33, instrucRecomBounds.topLeft.dy - 4, 50, 50),
                  );
                  break;

                case AssessmentVariables.keyCompanyCheckPilot:
                  document.pages[1].graphics.drawString(
                    "√",
                    PdfTrueTypeFont(fontDataList, 15),
                    brush: PdfBrushes.black,
                    bounds:
                        Rect.fromLTWH(instrucRecomBounds.topLeft.dx - 45, instrucRecomBounds.topLeft.dy - 4, 50, 50),
                  );
                  break;

                case AssessmentVariables.keyOthers:
                  document.pages[1].graphics.drawString(
                    "√",
                    PdfTrueTypeFont(fontDataList, 15),
                    brush: PdfBrushes.black,
                    bounds:
                        Rect.fromLTWH(instrucRecomBounds.topLeft.dx - 50, instrucRecomBounds.topLeft.dy - 7, 50, 50),
                  );
                  break;
              }
            }
            break;

          case "Candidate Name:":
            document.pages[1].graphics.drawString(
              assessmentResults.examineeName,
              PdfStandardFont(PdfFontFamily.helvetica, 10),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textBounds.topLeft.dx + 10, textBounds.topLeft.dy + 8, 200, 50),
            );

            if (assessmentResults.examineeSignatureUrl != "") {
              var instructorSignatureUrl = assessmentResults.examineeSignatureUrl;
              var response = await get(Uri.parse(instructorSignatureUrl));
              var data = response.bodyBytes;

              PdfBitmap image = PdfBitmap(data);
              document.pages[1].graphics.drawImage(
                image,
                Rect.fromLTWH(textBounds.topLeft.dx + 30, textBounds.center.dy - 60, 70, 50),
              );
            }
            break;

          case "Chief Pilot Training & Standards":
            if (assessmentResults.cptsSignatureUrl != "") {
              var instructorSignatureUrl = assessmentResults.cptsSignatureUrl;
              var response = await get(Uri.parse(instructorSignatureUrl));
              var data = response.bodyBytes;

              PdfBitmap image = PdfBitmap(data);
              document.pages[1].graphics.drawImage(
                image,
                Rect.fromLTWH(textBounds.topLeft.dx + 15, textBounds.center.dy + 20, 70, 50),
              );
            }
            break;

          // For Instructor
          case "Name:":
            document.pages[1].graphics.drawString(
              assessmentResults.instructorName.toString(),
              PdfStandardFont(PdfFontFamily.helvetica, 10),
              brush: PdfBrushes.black,
              bounds: Rect.fromLTWH(textBounds.topLeft.dx + 10, textBounds.topLeft.dy + 8, 200, 50),
            );
            break;
        }
      }

      // =========================================== INSTRUCTOR SIGNATURE ==============================================================

      List<String> instructorSignature = ["Signature :"];
      List<MatchedItem> instructorSignatureMatchedItem =
          PdfTextExtractor(document).findText(instructorSignature, startPageIndex: 1);
      var instructorSignatureItem = instructorSignatureMatchedItem.last;
      Rect instructorSignatureBounds = instructorSignatureItem.bounds;

      switch (instructorSignatureItem.text) {
        case "Signature :":
          var instructorSignatureUrl = assessmentResults.instructorSignatureUrl;
          var response = await get(Uri.parse(instructorSignatureUrl));
          var data = response.bodyBytes;

          PdfBitmap image = PdfBitmap(data);

          document.pages[1].graphics.drawImage(
              image,
              Rect.fromLTWH(
                  instructorSignatureBounds.topLeft.dx + 40, instructorSignatureBounds.center.dy - 20, 70, 50));

          break;
      }

      // =========================================== LOA ==============================================================
      List<String> loaText = ["LOA No.:"];
      List<MatchedItem> loaMatchedItem = PdfTextExtractor(document).findText(loaText, startPageIndex: 1);

      var loaNo = loaMatchedItem.first;
      MatchedItem matchedItemLoa = loaNo;
      Rect textBoundsLoa = matchedItemLoa.bounds;

      switch (matchedItemLoa.text) {
        case "LOA No.:":
          document.pages[1].graphics.drawString(
            assessmentResults.loaNo.toString(),
            PdfStandardFont(PdfFontFamily.helvetica, 10),
            brush: PdfBrushes.black,
            bounds: Rect.fromLTWH(textBoundsLoa.topLeft.dx + 28, textBoundsLoa.topLeft.dy - 1, 200, 50),
          );
          break;
      }

      // ======================================== FOR DECLARATION ====================================================
      switch (assessmentResults.sessionDetails) {
        case NewAssessment.keySessionDetailsTraining:

          bool getLastSatisfactory = false;
          List<String> declarationTextTraining = [
            'Satisfactory',
            'Further Training Req.',
            'Cleared for Check',
            'Stop Training, TS7 Rised'
          ];

          List<MatchedItem> declarationMatchedItem = PdfTextExtractor(document)
              .findText(declarationTextTraining, startPageIndex: 1);

          List<String> nonDuplicateDeclaration = [];
          List<MatchedItem> nonDuplicateDeclarationMatchedItem = [];

          for (var item in declarationMatchedItem) {
            if (item.text == "Satisfactory" && !getLastSatisfactory) {
              getLastSatisfactory = true;
              continue;
            }
            if (!nonDuplicateDeclaration.contains(item.text)) {
              nonDuplicateDeclaration.add(item.text);
              nonDuplicateDeclarationMatchedItem.add(item);
            }
          }


          for (var item in nonDuplicateDeclarationMatchedItem) {
            var textDeclaration = item.text;
            var boundsDeclarations = item.bounds;

            log("APA YA: ${assessmentResults.declaration} dan $textDeclaration");
            if (textDeclaration == assessmentResults.declaration) {
              document.pages[1].graphics.drawString(
                "√",
                PdfTrueTypeFont(fontDataList, 15),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(boundsDeclarations.topLeft.dx - 28, boundsDeclarations.topLeft.dy - 5, 100, 50),
              );
            }
          }
          break;

        case NewAssessment.keySessionDetailsCheck:
          List<String> declarationTextCheck = ['PASS', 'FAIL'];
          List<MatchedItem> declarationMatchedItem =
              PdfTextExtractor(document).findText(declarationTextCheck, startPageIndex: 1);

          for (var item in declarationMatchedItem) {
            var textDeclaration = item.text;
            var boundsDeclarations = item.bounds;

            if (textDeclaration.toLowerCase().trim() == assessmentResults.declaration.toLowerCase().trim()) {
              document.pages[1].graphics.drawString(
                "√",
                PdfTrueTypeFont(fontDataList, 15),
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(boundsDeclarations.topLeft.dx - 75, boundsDeclarations.topLeft.dy - 10, 100, 50),
              );
            }
          }
          break;
      }

      // Make Assessment TS1 Folder
      Directory('/storage/emulated/0/Download/Assessment TS1/').createSync();

      // Save into download directory
      // Save and dispose the document.

      String pathSavePDF =
          '/storage/emulated/0/Download/Assessment TS1/TS1-${assessmentResults.examineeName}-${Util.convertDateTimeDisplay(assessmentResults.date.toString())}.pdf';


      String cacheSavePDF =
          '${tempDir?.path}/TS1-${assessmentResults.examineeName}-${Util.convertDateTimeDisplay(assessmentResults.date.toString())}.pdf';


      var bytes = await document.save();

      log("BISA");

      File(pathSavePDF).writeAsBytesSync(bytes);

      log("BISGADWADAWA");

      File(cacheSavePDF).writeAsBytesSync(bytes);
      log("dwadawdawdaw");

      document.dispose();

      return cacheSavePDF;
    } catch (e) {
      log("Exception in AssessmentResultRepo on makePDFSimulator: $e");
    }
    return "Failed";
  }
}
