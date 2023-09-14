import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/theme.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../controllers/pilotcrewcc_controller.dart';

class PilotcrewccView extends GetView<PilotcrewccController> {
  const PilotcrewccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const RedTitleText(text: 'PILOT / CABIN CREW',),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextFormField(
                  controller: controller.searchC,
                  onChanged: (value) => controller.nameS.value = value,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear), onPressed: () {
                      controller.searchC.clear();
                    },
                    ),
                  ),
                ),
                const SizedBox(height: 20,),

               Obx(() =>  Expanded(
                 child: SingleChildScrollView(
                   controller: controller.scrollController,
                   child:StreamBuilder<List<Map<String, dynamic>>>(
                       stream: controller.pilotCrewStream(controller.nameS.value),
                       builder: (context, snapshot) {
                         if (snapshot.connectionState == ConnectionState.waiting) {
                           return LoadingScreen(); // Placeholder while loading
                         }

                         if (snapshot.hasError) {
                           return ErrorScreen();
                         }

                         var listAttendance = snapshot.data!;
                         return Column(
                           children: [
                             ListView.builder(
                               shrinkWrap: true,
                               itemCount: listAttendance.length,
                               physics: const NeverScrollableScrollPhysics(),
                               itemBuilder: (context, index) {
                                 return InkWell(
                                   onTap: () {
                                   },
                                   child: Container(
                                     padding: const EdgeInsets.all(5),
                                     margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(10),
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
                                       leading: CircleAvatar(
                                         radius: 20,
                                         backgroundColor: Colors.black26,
                                         child: ClipRRect(
                                           borderRadius: BorderRadius.circular(100),
                                           child : listAttendance[index]["PHOTOURL"] == null ?  Image.asset(
                                             "assets/images/placeholder_person.png",
                                             fit: BoxFit.cover,
                                           ) : Image.network("${listAttendance[index]["PHOTOURL"]}", fit: BoxFit.cover),),
                                       ),
                                       title: Text(listAttendance[index]["NAME"], maxLines: 1, style: tsOneTextTheme.labelSmall,),
                                       subtitle: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           const Text('847598342385'),
                                           Container(
                                             padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                             decoration: BoxDecoration(
                                               color: Colors.green.withOpacity(0.4),
                                               borderRadius: BorderRadius.circular(10),
                                             ),
                                             child: const Text(
                                               "Ready",
                                               style: TextStyle(fontSize: 10, color: Colors.green),
                                             ),
                                           ),
                                         ],
                                       ),
                                       trailing: const Icon(Icons.navigate_next),
                                     ),
                                   ),
                                 );
                               },
                             ),
                             controller.isLoading.value ? Center(
                               child: CircularProgressIndicator(),
                             ) : SizedBox()
                           ],
                         );
                       }),
                 ),
               ),)


              ],
            )
        ),
      ),
    );
  }
}
