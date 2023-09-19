import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_one/presentation/theme.dart';
import '../../../../presentation/theme.dart';
import '../../../../util/empty_screen.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../../util/util.dart';
import '../../../routes/app_pages.dart';

import '../../list_pilotcptscc/views/list_pilotcptscc_view.dart';
import '../controllers/home_cptscc_controller.dart';

// Import other necessary dependencies

class HomeCptsccView extends GetView<HomeCptsccController> {
  const HomeCptsccView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
        title: Text('Home Page'),),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,),

          child: ElevatedButton(
            onPressed: () {
              // Navigasi ke halaman kedua saat tombol ditekan
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ListPilotcptsccView()),
              );
            },
            child: Text('Go to Second Page'),
          ),

          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     SizedBox(height: 50,),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           "Hi, ${controller.titleToGreet}!",
          //           style: tsOneTextTheme.headlineLarge, // Add your text style
          //         ),
          //       ],
          //     ),
          //     Align(
          //       alignment: Alignment.centerLeft,
          //       child: Text(
          //         'Good ${controller.timeToGreet}',
          //         style: tsOneTextTheme.labelMedium,// Add your text style
          //       ),
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.symmetric(vertical: 20,),
          //       child: Row(
          //         children: [
          //           const Padding(
          //             padding: EdgeInsets.only(right: 4.0),
          //             child: Icon(
          //               Icons.calendar_month_outlined,
          //               color: TsOneColor.onSecondary,// Add your icon properties
          //               size: 40,
          //             ),
          //           ),
          //           Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(
          //                 Util.convertDateTimeDisplay(DateTime.now().toString(), "EEEE"),
          //                 style: tsOneTextTheme.labelSmall,// Add your text style
          //               ),
          //               Text(
          //                 Util.convertDateTimeDisplay(DateTime.now().toString(), "dd MMMM yyyy"),
          //                 style: tsOneTextTheme.labelSmall,// Add your text style
          //               ),
          //             ],
          //           )
          //         ],
          //       ),
          //     ),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           "STATS",
          //           style: tsOneTextTheme.headlineLarge,// Add your text style
          //         ),
          //         //See All
          //       ],
          //     ),
          //     const SizedBox(height: 10,),
          //     StreamBuilder<List<Map<String, dynamic>>>(
          //       stream: controller.getCombinedAttendanceStream(),
          //       builder: (context, snapshot) {
          //         if (snapshot.connectionState == ConnectionState.waiting) {
          //           return LoadingScreen(); // Placeholder while loading
          //         }
          //
          //         if (snapshot.hasError) {
          //           return ErrorScreen();
          //         }
          //
          //         var listAttendance = snapshot.data!;
          //         if (listAttendance.isEmpty) {
          //           return EmptyScreen();
          //         }
          //
          //         return ListView.builder(
          //           shrinkWrap: true, // Important to prevent another overflow
          //           itemCount: listAttendance.length,
          //           itemBuilder: (context, index) {
          //             return InkWell(
          //               onTap: () {
          //                 Get.toNamed(Routes.ATTENDANCE_CONFIRCC, arguments: {
          //                   "id": listAttendance[index]["id"],
          //                 });
          //                 print("ini");
          //               },
          //               child: Container(
          //                 margin: EdgeInsets.symmetric(vertical: 5),
          //                 decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.circular(10.0),
          //                   color: Colors.white,
          //                   boxShadow: [
          //                     BoxShadow(
          //                       color: Colors.grey.withOpacity(0.3),
          //                       spreadRadius: 2,
          //                       blurRadius: 3,
          //                       offset: const Offset(0, 2),
          //                     ),
          //                   ],
          //
          //                 ),
          //                 child: ListTile(
          //                   title: Text(
          //                     listAttendance[index]["subject"],
          //                     style: tsOneTextTheme.headlineMedium,// Add your text style
          //                   ),
          //                   subtitle: Text(
          //                     listAttendance[index]["name"],
          //                     style: tsOneTextTheme.labelSmall,// Add your text style
          //                   ),
          //                   trailing: const Icon(Icons.navigate_next),
          //                 ),
          //               ),
          //             );
          //           },
          //         );
          //       },
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}


