import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../presentation/view_model/attendance_model.dart';

class TrainingtypeccController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List untuk training remark
  Stream<QuerySnapshot<Map<String, dynamic>>> attendanceStream(int id, String status) {
    return firestore
        .collection('attendance')
        .where("idTrainingType", isEqualTo: id)
        .where("status", isEqualTo: status)
        .snapshots();
  }

  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //
  // Future<Map<String, dynamic>> getUsersStream(int Id) async {
  //   try {
  //     final userQuery = await _firestore.collection('users').where("ID NO", isEqualTo: Id).get();
  //     if (userQuery.docs.isNotEmpty) {
  //       final userDoc = userQuery.docs.first;
  //       final userData = userDoc.data() as Map<String, dynamic>;
  //       return userData;
  //     } else {
  //       return {}; // Return an empty map if no matching document is found
  //     }
  //   } catch (e) {
  //     print('Error fetching user data: $e');
  //     return {}; // Return an empty map if an error occurs
  //   }
  // }
  //
  //
  // Stream<List<Map<String, dynamic>>> getAttendanceStream() {
  //   return _firestore.collection('attendance').snapshots().map((querySnapshot) {
  //     return querySnapshot.docs.map((attendanceDoc) => attendanceDoc.data()).toList();
  //   });
  // }
  //
  // Future<void> thisc() async {
  //   final List<Map<String, dynamic>> DataList = [];
  //   final datas = await getAttendanceStream().first;
  //   for (final data in datas) {
  //     final codeId = data['instructor'];
  //     print("code Id ${codeId.toString()} key Attendance ${data["keyAttendance"]}");
  //     final codeData = await getUsersStream(codeId);
  //     DataList.add(codeData);
  //   }
  // }


  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //
  // Future<void> thisc() async {
  //   final List<Map<String, dynamic>> DataList = [];
  //   try {
  //     final attendanceSnapshot = await _firestore.collection('attendance').get();
  //
  //     for (final attendanceDoc in attendanceSnapshot.docs) {
  //       final data = attendanceDoc.data();
  //       final codeId = data['instructor'];
  //
  //       print("code Id ${codeId.toString()} key Attendance ${data["keyAttendance"]}");
  //
  //       final userQuery = await _firestore.collection('users').where("ID NO", isEqualTo: codeId).get();
  //
  //       if (userQuery.docs.isNotEmpty) {
  //         final userDoc = userQuery.docs.first;
  //         final userData = userDoc.data() as Map<String, dynamic>;
  //         DataList.add(userData);
  //       } else {
  //         DataList.add({}); // Add an empty map if no matching user document is found
  //       }
  //     }
  //
  //     print(DataList);
  //
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   }
  // }


  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //
  // Future<List<Map<String, dynamic>>> thisc() async {
  //   try {
  //     final attendanceQuery = await _firestore.collection('attendance').get();
  //     final usersQuery = await _firestore.collection('users').get();
  //
  //     final attendanceData = attendanceQuery.docs.map((doc) => doc.data()).toList();
  //     final usersData = usersQuery.docs.map((doc) => doc.data()).toList();
  //
  //     // Gabungkan data berdasarkan kondisi, misalnya instructor == ID NO
  //     final combinedData = attendanceData.map((attendance) {
  //       final user = usersData.firstWhere((user) => user['ID NO'] == attendance['instructor'], orElse: () => {});
  //       return {
  //         ...attendance,
  //         'NAME': user['NAME'], // Ganti 'nama' dengan nama field yang sesuai
  //       };
  //     }).toList();
  //
  //     print(combinedData);
  //
  //     return combinedData;
  //   } catch (e) {
  //     print('Error fetching combined data: $e');
  //     return [];
  //   }
  // }


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AttendanceModel>> thisc() async {
    try {
      final attendanceQuery = await _firestore.collection('attendance').get();
      final usersQuery = await _firestore.collection('users').get();

      final attendanceData = attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data())).toList();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      // Gabungkan data berdasarkan kondisi, misalnya instructor == ID NO
      for (final attendance in attendanceData) {
        final user = usersData.firstWhere((user) => user['ID NO'] == attendance.instructor, orElse: () => {});
        attendance.name = user['NAME']; // Set 'nama' di dalam model
        attendance.photoURL = user['PHOTOURL'];
      }
      print(attendanceData[0].photoURL);
      return attendanceData;
    } catch (e) {
      print('Error fetching combined data: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(int id, String status) {
    return _firestore.collection('attendance').where("idTrainingType", isEqualTo: id).where("status", isEqualTo: status).snapshots().asyncMap((attendanceQuery) async {
      final usersQuery = await _firestore.collection('users').get();
      final usersData = usersQuery.docs.map((doc) => doc.data()).toList();

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceModel.fromJson(doc.data());
          final user = usersData.firstWhere((user) => user['ID NO'] == attendanceModel.instructor, orElse: () => {});
          attendanceModel.name = user['NAME']; // Set 'nama' di dalam model
          attendanceModel.photoURL = user['PHOTOURL'];
          return attendanceModel.toJson();
        }),
      );

      return attendanceData;
    });
  }

  // Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(int id, String status) {
  //   Stream<QuerySnapshot<Object?>> attendanceStream = _firestore.collection('attendance').snapshots();
  //   Stream<QuerySnapshot<Object?>> usersStream = _firestore.collection('users').snapshots();
  //
  //   return attendanceStream.asyncMap((attendanceQuery) async {
  //     final attendanceData = attendanceQuery.docs.map((doc) => AttendanceModel.fromJson(doc.data())).toList();
  //
  //     // Ambil data pengguna dalam satu pengambilan
  //     final usersQuery = await usersStream.first;
  //     final usersData = usersQuery.docs.map((doc) => doc.data()).toList();
  //
  //     // Gabungkan data berdasarkan kondisi, misalnya instructor == ID NO
  //     for (final attendance in attendanceData) {
  //       final user = usersData.firstWhere((user) => user['ID NO'] == attendance.instructor, orElse: () => {});
  //       attendance.name = user['NAME']; // Set 'nama' di dalam model
  //     }
  //
  //     return attendanceData;
  //   });
  // }

  @override
  void onInit() {
    super.onInit();
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
