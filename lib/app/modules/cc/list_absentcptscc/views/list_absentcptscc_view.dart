import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../presentation/shared_components/TitleText.dart';
import '../controllers/list_absentcptscc_controller.dart';

class ListAbsentcptsccView extends GetView<ListAbsentcptsccController> {
  const ListAbsentcptsccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Back")),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RedTitleText(
                text: "ABSENT LIST",
              ),
              // Row(
              //   children: [
              //     Expanded(
              //         child: Container(
              //           margin: EdgeInsets.symmetric(vertical: 5),
              //           padding: EdgeInsets.all(8),
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(5.0),
              //
              //             color: Colors.white,
              //           ),
              //           child:Obx(()=>  Text("Attendance : ${controller.jumlah.value.toString()} person")),
              //         )
              //     )
              //   ],
              // ),
          ]
    ),
    )
    );
  }
}
