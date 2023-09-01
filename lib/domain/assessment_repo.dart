import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_one/data/assessments/assessment_flight_details.dart';
import 'package:ts_one/data/assessments/assessment_period.dart';
import 'package:ts_one/data/assessments/assessment_variables.dart';

abstract class AssessmentRepo {
  // assessment period
  Future<List<AssessmentPeriod>> getAllAssessmentPeriods();

  Future<AssessmentPeriod> getAssessmentPeriodById(String id);

  Future<AssessmentPeriod> getFlightAssessmentPeriodById(String id);

  Future<AssessmentPeriod> getHumanFactorAssessmentPeriodById(String id);

  Future<AssessmentPeriod> addAssessmentPeriod(
      AssessmentPeriod assessmentPeriodModel);

  Future<AssessmentPeriod> updateAssessmentPeriod(
      AssessmentPeriod assessmentPeriodModel);

  Future<void> deleteAssessmentPeriodById(String id);

  // assessment variables
  Future<List<AssessmentVariables>> getAllAssessmentVariables(
      String assessmentPeriodId);

  Future<AssessmentVariables> addAssessmentVariable(
      AssessmentVariables assessmentVariablesModel);

  Future<AssessmentVariables> updateAssessmentVariable(
      AssessmentVariables assessmentVariablesModel);

  Future<void> deleteAssessmentVariable(String id);

  // assessment flight details
  Future<AssessmentFlightDetails> getAllAssessmentFlightDetails();

  Future<AssessmentFlightDetails> addAssessmentFlightDetails(
      AssessmentFlightDetails assessmentFlightDetailsModel);

  Future<AssessmentFlightDetails> updateAssessmentFlightDetails(
      AssessmentFlightDetails assessmentFlightDetailsModel);

  Future<void> deleteAssessmentFlightDetails(String nameFlightDetails);

}

class AssessmentRepoImpl implements AssessmentRepo {
  AssessmentRepoImpl({
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore? _db;

  // assessment period
  @override
  Future<List<AssessmentPeriod>> getAllAssessmentPeriods() async {
    List<AssessmentPeriod> assessmentPeriods = [];

    try {
      // get all assessment periods by sorting from the latest "period" to the oldest
      assessmentPeriods = await _db!
          .collection(AssessmentPeriod.firebaseCollection)
          .orderBy(AssessmentPeriod.keyPeriod, descending: true)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          assessmentPeriods.add(AssessmentPeriod.fromFirebase(
              doc.data() as Map<String, dynamic>));
        }
        return assessmentPeriods;
      });
    } catch (e) {
      log("Exception in AssessmentRepo on getAllAssessmentPeriod: $e");
    }

    return assessmentPeriods;
  }

  int assessmentVariableCollectionComparator(DocumentSnapshot a,
      DocumentSnapshot b) {
    final idA = int.parse(a.id
        .split('-')[1]); // Extract the numerical part from the ID of document A
    final idB = int.parse(b.id
        .split('-')[1]); // Extract the numerical part from the ID of document B

    return idA.compareTo(idB);
  }

  @override
  Future<AssessmentPeriod> getAssessmentPeriodById(String id) async {
    AssessmentPeriod assessmentPeriod = AssessmentPeriod();
    List<AssessmentVariables> assessmentVariables = [];

    try {
      assessmentPeriod = await _db!
          .collection(AssessmentPeriod.firebaseCollection)
          .doc(id)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        return AssessmentPeriod.fromFirebase(
            documentSnapshot.data() as Map<String, dynamic>);
      });

      final documents = await _db!
          .collection(AssessmentVariables.firebaseCollection)
          .where(AssessmentVariables.keyAssessmentPeriodId,
          isEqualTo: assessmentPeriod.id)
          .get()
          .then((QuerySnapshot querySnapshot) {
        return querySnapshot.docs;
      });

      documents.sort(assessmentVariableCollectionComparator);

      for (var doc in documents) {
        assessmentVariables.add(AssessmentVariables.fromFirebase(
            doc.data() as Map<String, dynamic>));
      }

      assessmentPeriod.assessmentVariables = assessmentVariables;
    } catch (e) {
      log("Exception in AssessmentRepo on getAssessmentPeriodById: $e");
    }
    return assessmentPeriod;
  }

  @override
  Future<AssessmentPeriod> getFlightAssessmentPeriodById(String id) async {
    AssessmentPeriod assessmentPeriod = AssessmentPeriod();
    List<AssessmentVariables> flightAssessmentVariables = [];

    try {
      assessmentPeriod = await _db!
          .collection(AssessmentPeriod.firebaseCollection)
          .doc(id)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        return AssessmentPeriod.fromFirebase(
            documentSnapshot.data() as Map<String, dynamic>);
      });

      final documents = await _db!
          .collection(AssessmentVariables.firebaseCollection)
          .where(AssessmentVariables.keyAssessmentPeriodId,
          isEqualTo: assessmentPeriod.id)
          .where(AssessmentVariables.keyCategory, whereIn: AssessmentVariables.flightCategory)
          .get()
          .then((QuerySnapshot querySnapshot) {
        return querySnapshot.docs;
      });

      documents.sort(assessmentVariableCollectionComparator);

      for (var doc in documents) {
        flightAssessmentVariables.add(AssessmentVariables.fromFirebase(
            doc.data() as Map<String, dynamic>));
      }

      assessmentPeriod.assessmentVariables = flightAssessmentVariables;

    } catch (e) {
      log("Exception in AssessmentRepo on getHumanFactorAssessmentPeriodById: $e");
    }

    return assessmentPeriod;
  }

  @override
  Future<AssessmentPeriod> getHumanFactorAssessmentPeriodById(String id) async {
    AssessmentPeriod assessmentPeriod = AssessmentPeriod();
    List<AssessmentVariables> humanFactorAssessmentVariables = [];

    try {
      assessmentPeriod = await _db!
          .collection(AssessmentPeriod.firebaseCollection)
          .doc(id)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
         return AssessmentPeriod.fromFirebase(
           documentSnapshot.data() as Map<String, dynamic>);
      });

      final documents = await _db!
        .collection(AssessmentVariables.firebaseCollection)
        .where(AssessmentVariables.keyAssessmentPeriodId,
        isEqualTo: assessmentPeriod.id)
        .where(AssessmentVariables.keyCategory, whereIn: AssessmentVariables.humanFactorCategory)
        .get()
        .then((QuerySnapshot querySnapshot) {
          return querySnapshot.docs;
      });

      documents.sort(assessmentVariableCollectionComparator);

      for (var doc in documents) {
        humanFactorAssessmentVariables.add(AssessmentVariables.fromFirebase(
          doc.data() as Map<String, dynamic>));
      }

      assessmentPeriod.assessmentVariables = humanFactorAssessmentVariables;

    } catch (e) {
      log("Exception in AssessmentRepo on getHumanFactorAssessmentPeriodById: $e");
    }

    return assessmentPeriod;
  }

  @override
  Future<AssessmentPeriod> addAssessmentPeriod(
      AssessmentPeriod newAssessmentPeriod) async {
    AssessmentPeriod lastAssessmentPeriod = AssessmentPeriod();
    try {
      /** get the last id of assessment period */
      lastAssessmentPeriod = await _db!
          .collection(AssessmentPeriod.firebaseCollection)
          .orderBy(AssessmentPeriod.keyPeriod, descending: true)
          .limit(1)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          lastAssessmentPeriod =
              AssessmentPeriod.fromFirebase(doc.data() as Map<String, dynamic>);
        }
        return lastAssessmentPeriod;
      });

      /** if the last id is empty, set it to "ap-0" */
      if (lastAssessmentPeriod.id == "") {
        lastAssessmentPeriod.id = "ap-0";
      }

      /** add 1 to the last id */
      String oldId = lastAssessmentPeriod.id;
      // the oldId will always start with "ap-" so we remove it first
      String removeAp = oldId.replaceAll("ap-", "");
      // convert the string to int and add 1
      int newId = int.parse(removeAp) + 1;
      // convert the newId to string and add "ap-" to the beginning
      String newIdString = "ap-$newId";

      /** set the id of the assessment period model */
      newAssessmentPeriod.id = newIdString;

      /** add the assessment period model to firebase */
      await _db!
          .collection(AssessmentPeriod.firebaseCollection)
          .doc(newIdString)
          .set(newAssessmentPeriod.toFirebase());

      /** Counter for assessment variable id */
      int assessmentVariableId = 1;

      for (var assessmentVariable in newAssessmentPeriod.assessmentVariables) {
        assessmentVariable.id =
        "av-$assessmentVariableId-${newAssessmentPeriod.id}";
        assessmentVariable.assessmentPeriodId = newAssessmentPeriod.id;
        assessmentVariableId++;
      }

      log(
          "Message from AssessmentRepo on addAssessmentPeriod: $newAssessmentPeriod");

      /** add the assessment variables to firebase */
      newAssessmentPeriod.assessmentVariables
          .forEach((assessmentVariable) async {
        await _db!
            .collection(AssessmentVariables.firebaseCollection)
            .doc(assessmentVariable.id)
            .set(assessmentVariable.toFirebase());
      });

      /** get the newly added assessment period model */
      newAssessmentPeriod = await _db!
          .collection(AssessmentPeriod.firebaseCollection)
          .doc(newIdString)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        return AssessmentPeriod.fromFirebase(
            documentSnapshot.data() as Map<String, dynamic>);
      });
    } catch (e) {
      log("Exception in AssessmentRepo on addAssessmentPeriod: $e");
    }

    return newAssessmentPeriod;
  }

  @override
  Future<AssessmentPeriod> updateAssessmentPeriod(
      AssessmentPeriod assessmentPeriod) async {
    AssessmentPeriod updatedAssessmentPeriod = AssessmentPeriod();

    bool newAssessmentVariablesAdded = false;
    bool assessmentVariablesRemoved = false;

    AssessmentPeriod currentAssessmentPeriod =
    await getAssessmentPeriodById(assessmentPeriod.id);
    if (currentAssessmentPeriod.assessmentVariables.length <
        assessmentPeriod.assessmentVariables.length) {
      newAssessmentVariablesAdded = true;
    }
    if (currentAssessmentPeriod.assessmentVariables.length >
        assessmentPeriod.assessmentVariables.length) {
      assessmentVariablesRemoved = true;
    }

    try {
      /** update the assessment period model */
      await _db!
          .collection(AssessmentPeriod.firebaseCollection)
          .doc(assessmentPeriod.id)
          .update(assessmentPeriod.toFirebase());

      /** update the assessment variables */
      assessmentPeriod.assessmentVariables.forEach((assessmentVariable) async {
        await _db!
            .collection(AssessmentVariables.firebaseCollection)
            .doc(assessmentVariable.id)
            .update(assessmentVariable.toFirebase());
      });

      /** if new assessment variables are added, add them to firebase */
      if (newAssessmentVariablesAdded) {
        int assessmentVariableId =
            currentAssessmentPeriod.assessmentVariables.length + 1;
        for (var assessmentVariable in assessmentPeriod.assessmentVariables) {
          if (assessmentVariable.id == "") {
            assessmentVariable.id =
            "av-$assessmentVariableId-${assessmentPeriod.id}";
            assessmentVariable.assessmentPeriodId = assessmentPeriod.id;
            assessmentVariableId++;
            await _db!
                .collection(AssessmentVariables.firebaseCollection)
                .doc(assessmentVariable.id)
                .set(assessmentVariable.toFirebase());
          }
        }
      }

      /** if assessment variables are removed, remove them from firebase */
      if (assessmentVariablesRemoved) {
        List<AssessmentVariables> assessmentVariablesToRemove = [];
        Set<String> assessmentVariablesId = assessmentPeriod
            .assessmentVariables
            .map((assessmentVariable) => assessmentVariable.id)
            .toSet();

        // find the variable to remove using set operations
        for (var assessmentVariable in currentAssessmentPeriod.assessmentVariables) {
          if(!assessmentVariablesId.contains(assessmentVariable.id)) {
            assessmentVariablesToRemove.add(assessmentVariable);
          }
        }

        // delete the assessment variables removed from the currentAssessmentPeriod
        for (var assessmentVariable in assessmentVariablesToRemove) {
          await _db!
              .collection(AssessmentVariables.firebaseCollection)
              .doc(assessmentVariable.id)
              .delete();
        }
      }

      /** get the updated assessment period model */
      updatedAssessmentPeriod = await _db!
          .collection(AssessmentPeriod.firebaseCollection)
          .doc(assessmentPeriod.id)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        return AssessmentPeriod.fromFirebase(
            documentSnapshot.data() as Map<String, dynamic>);
      });
    } catch (e) {
      log("Exception in AssessmentRepo on updateAssessmentPeriod: $e");
    }

    return updatedAssessmentPeriod;
  }

  @override
  Future<void> deleteAssessmentPeriodById(String id) async {
    /** delete all the assessment variables that contains the String id first */
    await _db!
        .collection(AssessmentVariables.firebaseCollection)
        .where(AssessmentVariables.keyAssessmentPeriodId, isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        _db!
            .collection(AssessmentVariables.firebaseCollection)
            .doc(doc.id)
            .delete();
      }
    });

    /** delete the assessment period */
    await _db!.collection(AssessmentPeriod.firebaseCollection).doc(id).delete();
  }

  @override
  Future<List<AssessmentVariables>> getAllAssessmentVariables(
      String assessmentPeriodId) {
    // TODO: implement getAllAssessmentVariables
    throw UnimplementedError();
  }

  @override
  Future<AssessmentVariables> addAssessmentVariable(
      AssessmentVariables assessmentVariablesModel) {
    // TODO: implement addAssessmentVariable
    throw UnimplementedError();
  }

  @override
  Future<AssessmentVariables> updateAssessmentVariable(
      AssessmentVariables assessmentVariablesModel) {
    // TODO: implement updateAssessmentVariable
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAssessmentVariable(String id) {
    // TODO: implement deleteAssessmentVariable
    throw UnimplementedError();
  }

  // ==================== Assessment Flight Details ==============================================================

  @override
  Future<AssessmentFlightDetails> getAllAssessmentFlightDetails() async {
    List<String> assessmentFlightDetails = [];
    try {
      await _db!
          .collection(AssessmentFlightDetails.firebaseCollection)
          .doc(AssessmentFlightDetails.firebaseDocument)
          .get()
          .then((value) {
        log("flightdetail: ${value.data()![AssessmentFlightDetails
            .flightDetailsKey]}");
        (value.data()![AssessmentFlightDetails.flightDetailsKey])
            .forEach((element) {
          assessmentFlightDetails.add(element.toString());
        });
      });

      return AssessmentFlightDetails(flightDetails: assessmentFlightDetails);
    } catch (e) {
      log("Exception in AssessmentRepo on getAllAssessmentFlightDetails: $e");
    }

    return AssessmentFlightDetails(flightDetails: assessmentFlightDetails);
  }

  @override
  Future<AssessmentFlightDetails> addAssessmentFlightDetails(
      AssessmentFlightDetails assessmentFlightDetailsModel) {
    // TODO: implement addAssessmentFlightDetails
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAssessmentFlightDetails(String nameFlightDetails) {
    // TODO: implement deleteAssessmentFlightDetails
    throw UnimplementedError();
  }

  @override
  Future<AssessmentFlightDetails> updateAssessmentFlightDetails(
      AssessmentFlightDetails assessmentFlightDetailsModel) {
    // TODO: implement updateAssessmentFlightDetails
    throw UnimplementedError();
  }
}
