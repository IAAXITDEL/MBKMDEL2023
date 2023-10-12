import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import untuk menggunakan DateFormat
import '../../../../../presentation/theme.dart';
import '../../../../../util/empty_screen.dart';
import '../../../../../util/error_screen.dart';
import '../../../../../util/loading_screen.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/traininghistorycc_cpts_controller.dart';

class TraininghistoryccCptsView extends GetView<TraininghistoryccCptsController> {
  const TraininghistoryccCptsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TRAINING HISTORY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
                TextField(
                  onChanged: (value) {
                    /*controller.search(value);*/
                  },
                  decoration: InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  ),
                ),

              StreamBuilder<List<Map<String, dynamic>>>(
                stream: controller.historyStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen(); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return ErrorScreen();
                  }

                  var listAttendance = snapshot.data!;
                  if (listAttendance.isEmpty) {
                    return EmptyScreen();
                  }

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: listAttendance.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        String dateString = listAttendance[index]["date"];

                        DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);

                        String formattedDate = DateFormat('dd MMMM yyyy').format(date);
                        return InkWell(
                          onTap: () {
                            var idTrainingType = controller.idTrainingType.value;
                            var idAttendance = listAttendance[index]["id"];

                            if (idTrainingType != null && idAttendance != null) {
                              Get.toNamed(Routes.DETAILHISTORYCC_CPTS, arguments: {
                                "idTrainingType": idTrainingType,
                                "idAttendance": idAttendance,
                              });
                            } else {
                              // Handle the case where either idTrainingType or idAttendance is null
                              // You can show an error message or handle it according to your app logic.
                              print("idTrainingType or idAttendance is null");
                            }
                            /*Get.toNamed(Routes.DETAILHISTORYCC_CPTS, arguments: {
                              "idTrainingType" : controller.idTrainingType.value,
                              "idAttendance" : listAttendance[index]["id"]
                            });*/
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    radius: 15,
                                    child: Text("${index+1}"),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                          flex: 4,
                                          child: Text(
                                            "Date",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            ":",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(
                                          flex: 8,
                                          child: Text(
                                            formattedDate,
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Expanded(
                                          flex: 4,
                                          child: Text(
                                            "Valid To",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            ":",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(
                                          flex: 8,
                                          child: Text(
                                            "31 September 2023",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.navigate_next),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
              )


/*                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: controller.historyStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingScreen(); // Placeholder while loading
                    }

                    if (snapshot.hasError) {
                      return ErrorScreen();
                    }

                    var listAttendance = snapshot.data!;
                    if (listAttendance.isEmpty) {
                      return EmptyScreen();
                    }

                    return
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        String dateString = listAttendance[index]["date"];
                        DateTime date = DateFormat('dd-MM-yyyy').parse(
                            dateString);
                        String formattedDate = DateFormat('dd MMMM yyyy')
                            .format(date);
                        return InkWell(
                          onTap: () {
                            Get.toNamed(
                                Routes.DETAILHISTORYCC_CPTS, arguments: {
                              "idTrainingType": controller.idTrainingType.value,
                              "idAttendance": listAttendance[index]["id"]
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    radius: 15,
                                    child: Text("${index + 1}"),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                          flex: 4,
                                          child: Text(
                                            "Date",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            ":",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(
                                          flex: 8,
                                          child: Text(
                                            formattedDate,
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Expanded(
                                          flex: 4,
                                          child: Text(
                                            "Valid To",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            ":",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                      Expanded(
                                          flex: 8,
                                          child: Text(
                                            "31 September 2023",
                                            style: tsOneTextTheme.labelMedium,
                                          )),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.navigate_next),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
    ),*/
    ],
          ),
      ),
    ),
    );
  }
}
