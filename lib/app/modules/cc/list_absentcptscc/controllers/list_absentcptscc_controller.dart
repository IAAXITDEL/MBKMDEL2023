import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../di/locator.dart';
import '../../../../../presentation/view_model/attendance_detail_model.dart';

class ListAbsentcptsccController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxString argumentid = "".obs;
  final RxString argumentstatus = "".obs;
  late TextEditingController searchC;
  RxInt jumlah  = 0.obs;
  RxString nameS = "".obs;

  final Rx<List<Map<String, dynamic>>> streamData = Rx<List<Map<String, dynamic>>>([]);
  late UserPreferences userPreferences;

  @override
  void onInit() {
    super.onInit();
    argumentid.value = Get.arguments["id"];
    argumentstatus.value = Get.arguments["status"];
    searchC = TextEditingController();
    attendanceStream();
  }



  // Search dan List data attendance List
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceStream(String name) {
    try{
      userPreferences = getItLocator<UserPreferences>();
      print(userPreferences.getRank());
      //sebagai pilot administrator, menampilkan list dengan status done scoring
      //sudah diberi nilai oleh instructor
      if( userPreferences.getRank().contains("Pilot Administrator")){
        return _firestore
            .collection('attendance-detail')
            .where("idattendance", isEqualTo: argumentid.value)
            .where("status", isEqualTo: "donescoring")
            .snapshots()
            .asyncMap((attendanceQuery) async {
          List<int?> traineeIds = attendanceQuery.docs
              .map<int?>((doc) => doc['idtraining'] as int?)
              .toList();
          final usersData = <Map<String, dynamic>>[];
          if (traineeIds.isNotEmpty) {
            final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: traineeIds).get();
            usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
          } else {
            print("No traineeIds to fetch users' data.");
          }

          final attendanceData = await Future.wait(
            attendanceQuery.docs.map((doc) async {
              final attendanceModel = AttendanceDetailModel.fromJson(doc.data());
              final user = usersData.firstWhere(
                    (user) => user['ID NO'] == attendanceModel.idtraining,
                orElse: () => {},
              );
              attendanceModel.name = user['NAME'];
              return attendanceModel.toJson();
            }),
          );

          if (name.isNotEmpty) {
            final filteredData = attendanceData.where(
                  (item) => item['name'].toString().toLowerCase().startsWith(name.toLowerCase()),
            ).toList();
            streamData.value = filteredData;
          } else {
            streamData.value = attendanceData;
          }

          return streamData.value; // Return the streamData value
        });
      }

      //bukan pilot administrator, menampilkan list dengan status done dan donescoring
      //supaya dapat melakukan penilaian
      return _firestore
          .collection('attendance-detail')
          .where("idattendance", isEqualTo: argumentid.value)
          .where("status", whereIn: ["done", "donescoring"])
          .snapshots()
          .asyncMap((attendanceQuery) async {
        List<int?> traineeIds =
        attendanceQuery.docs.map((doc) => AttendanceDetailModel.fromJson(doc.data()).idtraining).toList();

        final usersData = <Map<String, dynamic>>[];

        if (traineeIds.isNotEmpty) {
          final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: traineeIds).get();
          usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
        }

        final attendanceData = await Future.wait(
          attendanceQuery.docs.map((doc) async {
            final attendanceModel = AttendanceDetailModel.fromJson(doc.data());
            final user = usersData.firstWhere(
                  (user) => user['ID NO'] == attendanceModel.idtraining,
              orElse: () => {},
            );
            attendanceModel.name = user['NAME'];
            return attendanceModel.toJson();
          }),
        );
        if (name.isNotEmpty) {
          // Filter attendanceData by name
          final filteredData = attendanceData.where(
                (item) => item['name'].toString().toLowerCase().startsWith(name.toLowerCase()),
          ).toList();
          streamData.value = filteredData;
        } else {
          streamData.value = attendanceData;
        }

        return streamData.value; // Return the streamData value
      });
    }catch(e){
      print('An error occurred: $e');
      // Handle the error gracefully, you can log the error and return an empty stream or rethrow the error.
      return Stream<List<Map<String, dynamic>>>.empty();
    }
  }

  //baru ku buat
  Stream<List<Map<String, dynamic>>> getAttendanceById(String idattendance) {
    return _firestore
        .collection('attendance-detail')
        .where("idattendance", isEqualTo: idattendance)
        .snapshots()
        .asyncMap((attendanceQuery) async {
      List<int?> traineeIds =
      attendanceQuery.docs.map((doc) => AttendanceDetailModel.fromJson(doc.data()).idtraining).toList();

      final usersData = <Map<String, dynamic>>[];

      if (traineeIds.isNotEmpty) {
        final usersQuery = await _firestore.collection('users').where("ID NO", whereIn: traineeIds).get();
        usersData.addAll(usersQuery.docs.map((doc) => doc.data()));
      }

      final attendanceData = await Future.wait(
        attendanceQuery.docs.map((doc) async {
          final attendanceModel = AttendanceDetailModel.fromJson(doc.data());
          final user = usersData.firstWhere(
                (user) => user['ID NO'] == attendanceModel.idtraining,
            orElse: () => {},
          );
          attendanceModel.name = user['NAME'];
          return attendanceModel.toJson();
        }),
      );
      if (nameS.isNotEmpty) {
        // Filter attendanceData by name
        final filteredData = attendanceData.where(
              (item) => item['name'].toString().toLowerCase().startsWith(nameS.toLowerCase()),
        ).toList();
        streamData.value = filteredData;
      } else {
        streamData.value = attendanceData;
      }

      return streamData.value;
    });
  }

  //mendapatkan panjang list attendance
  Future<int> attendanceStream() async {
    final attendanceQuery = await _firestore
        .collection('attendance-detail')
        .where("status", isEqualTo: "done")
        .where("idattendance", isEqualTo: argumentid.value)
        .get();

    jumlah.value = attendanceQuery.docs.length;
    return attendanceQuery.docs.length;
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