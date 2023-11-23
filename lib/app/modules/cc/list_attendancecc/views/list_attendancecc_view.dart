import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../../presentation/theme.dart';
import '../../../../../../util/empty_screen.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/list_attendancecc_controller.dart';

class ListAttendanceccView extends GetView<ListAttendanceccController> {
  const ListAttendanceccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var nameC = TextEditingController();
    return Scaffold(
        appBar: AppBar(title: RedTitleText(
          text: "ATTENDANCE LIST",
        ),
        centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
             Container(
               decoration: BoxDecoration(
                   border: Border.all(
                     color: TsOneColor.primaryFaded,
                     width: 1,
                   ),
                   borderRadius: BorderRadius.circular(10)),
               child:  Row(
                 children: [
                   Expanded(
                       child: Container(
                         margin: EdgeInsets.symmetric(vertical: 5),
                         padding: EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(5.0),

                           color: Colors.white,
                         ),
                         child:Obx(()=>  Text("Present Trainees : ${controller.jumlah.value.toString()} person")),
                       )
                   )
                 ],
               ),
             ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                          decoration: BoxDecoration(
                              color: TsOneColor.search,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: Colors.white54,
                                width: 0.5,
                              )
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.search,
                              color: Colors.blueGrey,
                              size: 20,
                            ),
                            title: TextField(
                              controller: nameC,
                              onChanged: (value){
                                controller.nameS.value = value;
                                print(controller.nameS.value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Type trainee name...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            trailing: InkWell(
                              onTap: (){
                                controller.nameS.value = "";
                                nameC.clear();
                              },
                              child: Icon(Icons.clear),
                            ),
                          )
                      ),
                    ),
                  ),
                ],
              ),

             Obx(() =>  Expanded(
                 child: SingleChildScrollView(child:
                 StreamBuilder<List<Map<String, dynamic>>>(
                   stream: controller.getCombinedAttendanceStream(controller.nameS.value),
                   builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting) {
                       return LoadingScreen();
                     }

                     if (snapshot.hasError) {
                       print(snapshot.error.toString());
                       return ErrorScreen();
                     }

                     var listAttendance = snapshot.data!;
                     if (listAttendance.isEmpty) {
                       return EmptyScreen();
                     }

                     print(listAttendance);
                     return ListView.builder(
                         itemCount: listAttendance.length,
                         physics: const NeverScrollableScrollPhysics(),
                         shrinkWrap: true,
                         itemBuilder: (context, index) {
                           return InkWell(
                             onTap: () {
                               Get.toNamed(Routes.LIST_ATTENDANCEDETAILCC,
                                   arguments: {
                                     "id": listAttendance[index]["idtraining"],
                                     "status" : controller.argumentstatus.value,
                                     "idattendance" : controller.argumentid.value
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
                               child: ListTile(
                                 title: Text(
                                   listAttendance[index]["name"],
                                   style: tsOneTextTheme.headlineMedium,
                                 ),
                                 subtitle: listAttendance[index]["score"] == null ? SizedBox() : Row(
                                   children: [
                                     Container(
                                       padding: EdgeInsets.symmetric(
                                           vertical: 3, horizontal: 10),
                                       decoration: BoxDecoration(
                                         color: listAttendance[index]["score"] == "PASS" ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.4),
                                         borderRadius: BorderRadius.circular(10),
                                       ),
                                       child: Text(
                                         listAttendance[index]["score"] ?? "",
                                         style: TextStyle(
                                           fontSize: 10, color: listAttendance[index]["score"] == "PASS" ? Colors.green : Colors.red,),
                                       ),
                                     ),

                                     SizedBox(width: 10,),
                                     Container(
                                       padding: EdgeInsets.symmetric(
                                           vertical: 3, horizontal: 10),
                                       decoration: BoxDecoration(
                                         color: Colors.yellow.withOpacity(0.4) ,
                                         borderRadius: BorderRadius.circular(10),
                                       ),
                                       child: Text(
                                         listAttendance[index]["grade"].toString() ?? "0",
                                         style: TextStyle(
                                           fontSize: 10, color: Colors.orange),
                                       ),
                                     ),
                                   ],
                                 ),
                                 trailing: const Icon(Icons.navigate_next),
                               ),
                             ),
                           );
                         }
                     );
                   },
                 ),)))
            ],
          ),
        ));
  }
}
