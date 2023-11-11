import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../presentation/view_model/attendance_detail_model.dart';
import '../../../../../presentation/view_model/attendance_model.dart';

class DetailhistoryccCptsController extends GetxController {
  final RxString argument = "".obs;
  final RxInt jumlah = 0.obs;
  final RxInt total = 0.obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxInt idTrainingType = 0.obs;
  RxString idAttendance = "".obs;
  RxString trainingName = "".obs;

  @override
  void onInit() {
    super.onInit();
    idTrainingType.value = Get.arguments["idTrainingType"];
    idAttendance.value = Get.arguments["idAttendance"];
    print(idAttendance.value);
    getCombinedAttendance();
    getFeedbackDataList();
    /* final String id = (Get.arguments as Map<String, dynamic>)["id"];
    argument.value = id;*/
    attendanceStream();
    print(jumlah.value);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(String id) {
    return _firestore
        .collection('attendance')
        .where("id", isEqualTo: id)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      List<int?> instructorIds = attendanceQuery.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()).instructor)
          .toList();

      final usersData = <Map<String, dynamic>>[];

      if (instructorIds.isNotEmpty) {
        final usersQuery = await _firestore
            .collection('users')
            .where("ID NO", whereIn: instructorIds)
            .get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere(
              (user) => user['ID NO'] == attendanceModel.instructor,
              orElse: () => {});
          attendanceModel.name = user['NAME'];
          return attendanceModel.toJson();
        }),
      );
      return attendanceData;
    });
  }

  Future<List<AttendanceDetailModel>> attendanceStream() async {
    final attendanceQuery = await _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: idAttendance.value)
        .where("status", isEqualTo: "donescoring")
        .get();

    final absentQuery = await _firestore
        .collection('absent')
        .where("idattendance", isEqualTo: idAttendance.value)
        .get();

    total.value = absentQuery.docs.length;

    List<AttendanceDetailModel> attendanceList = [];

    attendanceQuery.docs.forEach((attendanceDoc) {
      AttendanceDetailModel attendance = AttendanceDetailModel(
        idattendance: attendanceDoc['idattendance'] as String,
        status: attendanceDoc['status'] as String,
      );
      attendanceList.add(attendance);
    });

    jumlah.value = attendanceList.length;

    return attendanceList;
  }

  //Mendapatkan Training
  Stream<QuerySnapshot<Map<String, dynamic>>> trainingStream() {
    return firestore
        .collection('trainingType')
        .where("id", isEqualTo: idTrainingType.value)
        .snapshots();
  }

  //Mendapatkan data kelas yang diikuti
  Future<List<Map<String, dynamic>>> getCombinedAttendance() async {
    final attendanceQuery = await firestore
        .collection('attendance')
        .where("id", isEqualTo: idAttendance.value)
        .get();

    final attendanceDetailQuery = await firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: idAttendance.value)
        .get();

    List<Map<String, dynamic>> attendanceData = [];

    for (var doc in attendanceQuery.docs) {
      final attendanceDetailModel = AttendanceDetailModel.fromJson(doc.data());

      for (var doc in attendanceQuery.docs) {
        final attendanceModel = AttendanceModel.fromJson(doc.data());

        // Ambil informasi pengguna hanya untuk trainer yang terkait
        final trainersQuery = await firestore
            .collection('users')
            .where("ID NO", isEqualTo: attendanceModel.instructor)
            .get();

        // Ambil informasi pengguna hanya untuk trainee yang terkait
        final traineesQuery = await firestore
            .collection('users')
            .where("ID NO", isEqualTo: attendanceDetailModel.idtraining)
            .get();

        // Ambil informasi pengguna hanya untuk trainee yang terkait
        final attendanceDetailsQuery = await firestore
            .collection('attendance-detail')
            .where("idattendance", isEqualTo: attendanceModel.id)
            .get();
        if (trainersQuery.docs.isNotEmpty) {
          final trainerData = trainersQuery.docs[0].data();
          final traineeData = traineesQuery.docs[0].data();
          final attendanceDetailData = attendanceDetailsQuery.docs[0].data();

          // Ambil informasi yang diperlukan dari dokumen attendance
          Map<String, dynamic> data = {
            'subject': attendanceModel.subject,
            'date': attendanceModel.date,
            'trainer-name': trainerData['NAME'],
            'trainee-name': traineeData['NAME'],
            'department': attendanceModel.department,
            'trainingType': attendanceModel.trainingType,
            'vanue': attendanceModel.vanue,
            'room': attendanceModel.room,
            'feedback-from-trainer': attendanceDetailData['feedback'],
            'feedback-from-trainee':
                attendanceDetailData['feedbackforinstructor'],
          };

          // Tambahkan data ke list
          attendanceData.add(data);
        }

        trainingName.value = attendanceModel.subject!;
      }
    }

    return attendanceData;
  }

  Future<List<Map<String, dynamic>?>> getFeedbackDataList() async {
    final attendanceDetailQuery = await firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: idAttendance.value)
        .get();

    List<int?> traineeIds =
    attendanceDetailQuery.docs.map((doc) => AttendanceDetailModel.fromJson(doc.data()).idtraining).toList();

    final usersData = <Map<String, dynamic>>[];

    if (traineeIds.isNotEmpty) {
      final usersQuery = await firestore.collection('users').where("ID NO", whereIn: traineeIds).get();
      usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
    }


    final attendanceDetailData = await Future.wait(
      attendanceDetailQuery.docs.map((doc) async {
        final attendanceDetailModel = AttendanceDetailModel.fromJson(doc.data());
        final user = usersData.firstWhere(
              (user) => user['ID NO'] == attendanceDetailModel.idtraining,
          orElse: () => {},
        );

        attendanceDetailModel.name = user['NAME'];
        attendanceDetailModel.photoURL = user['PHOTOURL'];
        return attendanceDetailModel.toJson();
      }),
    );

    return attendanceDetailData;
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
