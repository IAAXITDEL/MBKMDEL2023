import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../../presentation/theme.dart';
import '../../../../../../util/empty_screen.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/pilottraininghistorycc_controller.dart';

class PilottraininghistoryccView
    extends GetView<PilottraininghistoryccController> {
  PilottraininghistoryccView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    var fromC = TextEditingController();
    var toC = TextEditingController();


    Future<bool> onWillPop() async {
      // controller.resetDate();
      return true;
    }
    
    
    return Scaffold(
        appBar: AppBar(
          title: RedTitleText(text: 'TRAINING HISTORY'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //--------------KELAS TRAINING-------------'
                Row(
                  children: [
                    Expanded(flex:4 , child: Container(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: controller.trainingStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return LoadingScreen(); // Placeholder while loading
                          }

                          if (snapshot.hasError) {
                            return ErrorScreen();
                          }

                          var listTraining = snapshot.data!.docs;

                          return Text(
                            listTraining[0]["training"],
                            maxLines: 1,
                            style: tsOneTextTheme.bodyLarge,
                          );
                        },
                      ),
                    ),),
                   Obx(() =>  Expanded(flex: 1, child: Container(
                     padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                     decoration: BoxDecoration(
                       color: controller.expiryC.value == "" ? Colors.white : controller.expiryC.value == "VALID" ? Colors.green : Colors.red,
                       borderRadius: BorderRadius.circular(5),
                     ),
                     child: Center(
                       child: Text(
                         controller.expiryC.value ,
                         style: TextStyle(fontSize: 10, color: Colors.white),
                       ),
                     ),
                   ),),),
                  ],
                ),

                SizedBox(
                  height: 10,
                ),

                Form(
                  key: _formKey,
                  child: Container(
                    child:   Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: fromC,
                            obscureText: false,
                            readOnly: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {   // Validation Logic
                                return 'Please enter the From Date';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                                prefixIcon: const Icon(Icons.calendar_month, color: TsOneColor.primary,),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: TsOneColor.primary,
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: TsOneColor.secondaryContainer)
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.green,
                                  ),
                                ),
                                labelText: "From Date"
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1945), lastDate: DateTime(2300));
                              if(pickedDate != null){
                                String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                fromC.text = formattedDate;
                              }
                            },
                          ),
                        ),
                        Expanded(flex: 1,child: Icon(Icons.compare_arrows_rounded)),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: toC,
                            obscureText: false,
                            readOnly: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {   // Validation Logic
                                return 'Please enter the To Date';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                                prefixIcon: const Icon(Icons.calendar_month, color: TsOneColor.primary,),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: TsOneColor.primary,
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: TsOneColor.secondaryContainer)
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.green,
                                  ),
                                ),
                                labelText: "To Date"
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1945), lastDate: DateTime(2300));
                              if(pickedDate != null){
                                String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                toC.text = formattedDate;
                              }
                            },
                          ),
                        ),
                        Expanded(flex: 1,child:
                        InkWell(
                          onTap: (){
                            DateTime from = DateFormat('dd-MM-yyyy').parse(fromC.text);
                            DateTime to = DateFormat('dd-MM-yyyy').parse(toC.text);

                            if (_formKey.currentState != null && _formKey.currentState!.validate()  != 0) {
                              if (from.isBefore(to)) {
                                controller.from.value = from;
                                controller.to.value = to;
                              } else {

                              }
                            }
                          },
                          child: Icon(Icons.filter_list, color: TsOneColor.primary,),
                        )
                        ),
                      ],
                    ),
                  ),
                ),
                Obx(() =>  StreamBuilder<List<Map<String, dynamic>>>(
                 stream: controller.historyStream( from: controller.from.value, to:controller.to.value),
                 builder: (context, snapshot) {
                   if (snapshot.connectionState == ConnectionState.waiting) {
                     return LoadingScreen(); // Placeholder while loading
                   }

                   if (snapshot.hasError) {
                     print(snapshot.error.toString());
                     return ErrorScreen();
                   }

                   var listAttendance = snapshot.data!;
                   if (listAttendance.isEmpty) {
                     return EmptyScreen();
                   }

                   return Column(
                     children: [
                       SizedBox(height: 10),

                       ListView.builder(
                           shrinkWrap: true,
                           itemCount: listAttendance.length,
                           physics: const NeverScrollableScrollPhysics(),
                           itemBuilder: (context, index) {

                             Timestamp? date = listAttendance[index]["date"];
                             DateTime? dates = date?.toDate();
                             String dateC = DateFormat('dd MMM yyyy').format(dates!);

                             Timestamp? timestamp = listAttendance[index]["valid_to"];
                             DateTime? dateTime = timestamp?.toDate();
                             String validC = DateFormat('dd MMM yyyy').format(dateTime!);
                             print(validC);
                             return InkWell(
                               onTap: () {
                                 Get.toNamed(Routes.PILOTTRAININGHISTORYDETAILCC, arguments: {
                                   "idTrainingType" : controller.idTrainingType.value,
                                   "idAttendance" : listAttendance[index]["id"],
                                   "idTraining" : controller.idTraining.value
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
                                                 dateC,
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
                                                 validC,
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
                           })
                     ],
                   );
                 },
               ))
                // InkWell(
                //   onTap: () {},
                //   child: Container(
                //     margin: EdgeInsets.symmetric(vertical: 5),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(10.0),
                //       color: Colors.white,
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.grey.withOpacity(0.3),
                //           spreadRadius: 2,
                //           blurRadius: 3,
                //           offset: const Offset(0, 2),
                //         ),
                //       ],
                //     ),
                //     child: ListTile(
                //       leading: CircleAvatar(
                //         radius: 15,
                //         child: Text("1"),
                //       ),
                //       title: Row(
                //         children: [
                //           Expanded(
                //               flex: 4,
                //               child: Text(
                //                 "Date",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //           Expanded(
                //               flex: 1,
                //               child: Text(
                //                 ":",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //           Expanded(
                //               flex: 8,
                //               child: Text(
                //                 "31 September 2023",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //         ],
                //       ),
                //       subtitle: Row(
                //         children: [
                //           Expanded(
                //               flex: 4,
                //               child: Text(
                //                 "Valid To",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //           Expanded(
                //               flex: 1,
                //               child: Text(
                //                 ":",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //           Expanded(
                //               flex: 8,
                //               child: Text(
                //                 "31 September 2023",
                //                 style: tsOneTextTheme.labelMedium,
                //               )),
                //         ],
                //       ),
                //       trailing: const Icon(Icons.navigate_next),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ));
  }
}
