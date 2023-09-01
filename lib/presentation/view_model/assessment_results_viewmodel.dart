import 'dart:developer';

import 'package:googleapis/forms/v1.dart';
import 'package:ts_one/data/assessments/assessment_results.dart';
import 'package:ts_one/data/assessments/assessment_variable_results.dart';
import 'package:ts_one/data/assessments/new_assessment.dart';
import 'package:ts_one/domain/assessment_results_repo.dart';
import 'package:ts_one/presentation/view_model/loading_viewmodel.dart';

class AssessmentResultsViewModel extends LoadingViewModel {
  AssessmentResultsViewModel({required this.repo});

  final AssessmentResultsRepo repo;

  bool isAllAssessmentLoaded = false;
  List<AssessmentResults> allAssessmentResults = [];
  AssessmentResults? allLastAssessment;

  bool isMyAssessmentLoaded = false;
  List<AssessmentResults> myAssessmentResults = [];
  AssessmentResults? myLastAssessment;

  Future<List<AssessmentResults>> addAssessmentResults(
      List<AssessmentResults> assessmentResults, NewAssessment newAssessment) async {
    isLoading = true;
    List<AssessmentResults> assessmentResultsList = [];
    try {
      assessmentResultsList = await repo.addAssessmentResults(assessmentResults, newAssessment);
      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on addAssessmentResults: $e");
      isLoading = false;
    }
    return assessmentResultsList;
  }

  Future<List<AssessmentResults>> getAllAssessmentResults() async {
    isLoading = true;
    List<AssessmentResults> assessmentResultsList = [];
    try {
      assessmentResultsList = await repo.getAllAssessmentResults();
      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on getAllAssessmentResults: $e");
      isLoading = false;
    }
    return assessmentResultsList;
  }

  Future<List<AssessmentResults>> getAssessmentResultsLimited(int limit) async {
    isLoading = true;
    List<AssessmentResults> assessmentResultsList = [];
    try{
      assessmentResultsList = await repo.getAssessmentResultsLimited(limit);
      isLoading = false;
    }
    catch(e){
      log("Exception on AssessmentResultsViewModel: $e");
      isLoading = false;
    }
    return assessmentResultsList;
  }

  Future<List<AssessmentResults>> getAssessmentResultsByCurrentUserNotConfirm() async {
    isLoading = true;
    List<AssessmentResults> assessmentResults = [];
    try {
      assessmentResults = await repo.getAssessmentResultsByCurrentUserNotConfirm();
      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on getAssessmentResultsByCurrentUserNotConfirm: $e");
      isLoading = false;
    }
    return assessmentResults;
  }

  Future<List<AssessmentResults>> getAssessmentResultsNotConfirmByCPTS() async {
    isLoading = true;
    List<AssessmentResults> assessmentResults = [];
    try {
      assessmentResults = await repo.getAssessmentResultsNotConfirmByCPTS();
      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on getAssessmentResultsNotConfirmByCPTS: $e");
      isLoading = false;
    }
    return assessmentResults;
  }

  Future<List<AssessmentVariableResults>> getAssessmentVariableResult(String idAssessment) async {
    isLoading = true;
    List<AssessmentVariableResults> assessmentVariableResults = [];
    try {
      assessmentVariableResults = await repo.getAssessmentVariableResult(idAssessment);
      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on getAssessmentVariableResult: $e");
      isLoading = false;
    }
    return assessmentVariableResults;
  }

  Future<void> updateAssessmentResultForExaminee(AssessmentResults assessmentResults) async {
    isLoading = true;
    try {
      await repo.updateAssessmentResultForExaminee(assessmentResults);
      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on updateAssessmentResultForExaminee: $e");
      isLoading = false;
    }
  }

  Future<List<AssessmentResults>> searchAssessmentResultsBasedOnName(String searchName, int searchLimit, bool isAll) async {
    isLoading = true;
    List<AssessmentResults> assessmentResultsList = [];
    try {
      assessmentResultsList = await repo.searchAssessmentResultsBasedOnName(searchName, searchLimit, isAll);
      if (isAll) {
        isAllAssessmentLoaded = false;
      } else {
        isMyAssessmentLoaded = false;
      }
      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on searchAssessmentResultsBasedOnName: $e");
      isLoading = false;
    }
    return assessmentResultsList;
  }

  Future<List<AssessmentResults>> getAllAssessmentResultsPaginated(int limit, String? selectedRankFilter,
      int? selectedMarkerFilter, DateTime? filterDateFrom, DateTime? filterDateTo) async {
    isLoading = true;

    try {
      if (isAllAssessmentLoaded) {
        isLoading = false;
        return allAssessmentResults;
      }

      final List<AssessmentResults> newAssessmentResults = await repo.getAssessmentResultsPaginated(
          limit, true, allLastAssessment, selectedRankFilter, selectedMarkerFilter, filterDateFrom, filterDateTo);

      allAssessmentResults.addAll(newAssessmentResults);

      if (newAssessmentResults.isNotEmpty) {
        allLastAssessment = newAssessmentResults[newAssessmentResults.length - 1];
        if (newAssessmentResults.length < limit) {
          isAllAssessmentLoaded = true;
        }
      } else {
        allLastAssessment = null;
        isAllAssessmentLoaded = true;
      }

      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on getAllAssessmentResultsPaginated: $e");
      isLoading = false;
    }
    return allAssessmentResults;
  }

  Future<List<AssessmentResults>> getSelfAssessmentResultsPaginated() async {
    isLoading = true;
    List<AssessmentResults> assessmentResultsList = [];
    try {
      assessmentResultsList = await repo.getSelfAssessmentResults();
      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on getSelfAssessmentResultsPaginated: $e");
      isLoading = false;
    }
    return assessmentResultsList;
  }

  Future<List<AssessmentResults>> getMyAssessmentResultsPaginated(int limit, String? selectedRankFilter,
      int? selectedMarkerFilter, DateTime? filterDateFrom, DateTime? filterDateTo) async {
    isLoading = true;

    try {
      if (isMyAssessmentLoaded) {
        isLoading = false;
        return myAssessmentResults;
      }

      final List<AssessmentResults> newAssessmentResults = await repo.getAssessmentResultsPaginated(
          limit, false, myLastAssessment, selectedRankFilter, selectedMarkerFilter, filterDateFrom, filterDateTo);

      myAssessmentResults.addAll(newAssessmentResults);

      if (newAssessmentResults.isNotEmpty) {
        myLastAssessment = newAssessmentResults[newAssessmentResults.length - 1];
        if (newAssessmentResults.length < limit) {
          isMyAssessmentLoaded = true;
        }
      } else {
        myLastAssessment = null;
        isMyAssessmentLoaded = true;
      }

      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on getMyAssessmentResultsPaginated: $e");
      isLoading = false;
    }
    return myAssessmentResults;
  }

  Future<Map<String, DateTime>> getInstructorNotes(int examineeId) async {
    isLoading = true;
    Map<String, DateTime> instructorNotes = {};
    try {
      instructorNotes = await repo.getInstructorNotes(examineeId);
      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on getInstructorNotes: $e");
      isLoading = false;
    }
    return instructorNotes;
  }

  Future<String> makePDFSimulator(AssessmentResults assessmentResults) async {
    isLoading = true;
    String message = "";
    try {
      message = await repo.makePDFSimulator(assessmentResults);
      isLoading = false;
    } catch (e) {
      log("Exception in AssessmentResultsViewModel on makePDFSimulator: $e");
      isLoading = false;
    }
    return message;
  }
}
