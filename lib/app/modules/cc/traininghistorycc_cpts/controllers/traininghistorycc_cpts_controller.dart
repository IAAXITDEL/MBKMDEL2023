import
'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../../presentation/view_model/attendance_model.dart';

class TraininghistoryccCptsController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxInt idTraining = 0.obs;
  RxInt idTrainingType = 0.obs;

  late final Rx<DateTime> from= DateTime(1900, 1, 1).obs;
  late final Rx<DateTime> to = DateTime.now().add(Duration(days: 4 * 365)).obs;

  final RxString nameS = "".obs;


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
  Stream<List<Map<String, dynamic>>> historyStream(String name, {DateTime? from, DateTime? to}) {
    return firestore
        .collection('attendance')
        .where("idTrainingType", isEqualTo: idTrainingType.value )
        .where("status", isEqualTo: "done")
        .where("is_delete", isEqualTo: 0)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      List<int?> instructorIds = attendanceQuery.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()).instructor)
          .toList();

      final usersData = <Map<String, dynamic>>[];

      if (instructorIds.isNotEmpty) {
        final usersQuery = await firestore
            .collection('users')
            .where("ID NO", whereIn: instructorIds)
            .get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

      final attendanceData = await Future.wait(attendanceQuery.docs
          .map((doc) async {
        final attendanceModel = AttendanceModel.fromJson(doc.data());
        final user = usersData.firstWhere((user) =>
        user['ID NO'] == attendanceModel.instructor,
            orElse: () => {});
        attendanceModel.name = user['NAME'] ?? 'N/A';
        attendanceModel.photoURL = user['PHOTOURL'] ?? 'N/A';
        return attendanceModel.toJson();
      }));

      attendanceData.sort((a, b) => b['date'].compareTo(a['date']));

      if (from != null && to != null) {
        final filteredAttendance = attendanceData.where((attendance) {
          DateTime attendanceDate = attendance["date"].toDate();

          // Compare dates only, ignoring the time component
          DateTime fromDate = DateTime(from.year, from.month, from.day);
          DateTime toDate = DateTime(to.year, to.month, to.day);
          DateTime attendanceDateOnly = DateTime(attendanceDate.year, attendanceDate.month, attendanceDate.day);

          print("this");
          print(attendanceDate);
          return attendanceDateOnly.isAtSameMomentAs(fromDate) ||
              (attendanceDateOnly.isAfter(fromDate) && attendanceDateOnly.isBefore(toDate)) ||
              attendanceDateOnly.isAtSameMomentAs(toDate);
        }).toList();

        if (name.isNotEmpty) {
          final filteredData = filteredAttendance.where((doc) {
            final String attendanceName = doc['name'].toString().toLowerCase();
            print(doc['name'].toString().toLowerCase());
            return attendanceName.startsWith(name.toLowerCase());
          }).toList();
          return filteredData;
        }
        return filteredAttendance;
      }
      return attendanceData;
    });
  }

  void resetDate() {
    from.value  = DateTime(1900, 1, 1);
    to.value  = DateTime.now();
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
