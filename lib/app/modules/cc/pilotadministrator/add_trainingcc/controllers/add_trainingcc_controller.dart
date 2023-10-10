import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AddTrainingccController extends GetxController {

  List<String> list = <String>['NONE', '6 MONTH CALENDER', '12 MONTH CALENDER', '24 MONTH CALENDER', '36 MONTH CALENDER', 'LAST MONTH ON THE NEXT YEAR OF THE PREVIOUS TRAINING'];
  late RxString dropdownValue = list.first.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void onInit() {
    super.onInit();
    dropdownValue = RxString(list.first);
  }

  // Add a new subject to Firestore
  Future<void> addNewSubject(String newSubject,
      String newExpiryDate, String newTrainingDescription) async {
    try {
      // Get the count of existing documents in both collections
      QuerySnapshot trainingTypeSnapshot =
      await FirebaseFirestore.instance.collection('trainingType').get();
      int trainingTypeCount = trainingTypeSnapshot.size;

      QuerySnapshot trainingRemarkSnapshot =
      await FirebaseFirestore.instance.collection('trainingRemark').get();
      int trainingRemarkCount = trainingRemarkSnapshot.size;

      // Add a new document to the 'trainingType' collection
      await FirebaseFirestore.instance.collection('trainingType').doc(newSubject).set({
        'id': trainingTypeCount + 1,
        'training': newSubject,
        'recurrent': newExpiryDate,
        'training_description': newTrainingDescription,
        'is_delete' : 0
      });

    } catch (e) {
      print('Error adding subject: $e');
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


}
