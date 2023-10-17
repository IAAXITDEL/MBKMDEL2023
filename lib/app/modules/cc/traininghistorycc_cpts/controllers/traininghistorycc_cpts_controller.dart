import
'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../presentation/view_model/attendance_model.dart';

class TraininghistoryccCptsController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxInt idTraining = 0.obs;
  RxInt idTrainingType = 0.obs;

  @override
  void onInit() {
    super.onInit();
    idTrainingType.value = Get.arguments["id"];
    getCombinedAttendanceStream();
    print(idTrainingType.value);
  }

  //Mendapatkan data kelas yang diikuti
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream() {
    return firestore.collection('attendance').where("idTrainingType", isEqualTo: idTrainingType.value).snapshots().asyncMap((attendanceQuery) async {
        final usersQuery = await firestore.collection('users').get();
        final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

        final attendanceData = await Future.wait(
          attendanceQuery.docs.map((doc) async {
            final attendanceModel = AttendanceModel.fromJson(doc.data());
            final user = usersData.firstWhere((user) =>
            user['ID NO'] == attendanceModel.instructor, orElse: () => {});
            attendanceModel.name = user['NAME'];
            attendanceModel.photoURL = user['PHOTOURL'];
            return attendanceModel.toJson();
          }),
        );
        print(attendanceData);
        return attendanceData;
    });
  }



  // List Training History
  Stream<List<Map<String, dynamic>>> historyStream() {
    return firestore.collection('attendance').where("idTrainingType", isEqualTo: idTrainingType.value).where("status", isEqualTo: "done").snapshots().asyncMap((attendanceQuery) async {
      final attendanceDetailQuery = await firestore.collection('attendance-detail').get();
      final attendanceDetailData = attendanceDetailQuery.docs.map((doc) => doc.data()).toList();
      if (attendanceDetailData.isEmpty) {
        print("disini");
        return [];
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final attendanceDetail = attendanceDetailData.firstWhere((attendanceDetail) => attendanceDetail['idattendance'] == attendanceModel.id, orElse: () => {});
          return attendanceModel.toJson();
        }),
      );
      print(attendanceData);
      return attendanceData;
    });
  }

/*  var trainings = [
    Training(title: 'Training 1', date: '2023-10-01'),
    Training(title: 'Training 2', date: '2023-10-05'),
    // Tambahkan data pelatihan lainnya sesuai kebutuhan
  ];
  var filteredTrainings = <Training>[].obs;*/

/*  void search(String query) {
    var filteredTrainings;
    filteredTrainings.value = trainings.where((training) {
      // Filter logic - you can customize this based on your requirements
      return training.title.toLowerCase().contains(query.toLowerCase()) ||
          training.date.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }*/

 /* final count = 0.obs;


  @override
  void onInit() {
    super.onInit();
  }*/

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}


/*class Training {
  final String title;
  final String date;

  Training({required this.title, required this.date});
}*/
