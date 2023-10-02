import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../util/empty_screen.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../controllers/list_attendancecc_controller.dart';

class ListAttendanceccViewCopy extends GetView<ListAttendanceccController> {
  const ListAttendanceccViewCopy({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RedTitleText(text: "ATTENDANCE LIST",),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child:  StreamBuilder<List<Map<String, dynamic>>>(
            stream: controller.getCombinedAttendanceStream("All"),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingScreen();
              }

              if (snapshot.hasError) {
                return ErrorScreen();
              }

              var listAttendance= snapshot.data!;
              if(listAttendance.isEmpty){
                return EmptyScreen();
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black
                  ),
                  columnSpacing: 12.0,
                  columns: [
                    DataColumn(label: Text('NO'),  numeric: true,),
                    DataColumn(label: Text('NAME')),
                    DataColumn(label: Text('ID NO.')),
                    DataColumn(label: Text('RANK')),
                    DataColumn(label: Text('LICENSE / FAC NO.')),
                    DataColumn(label: Text('HUB')),
                    DataColumn(label: Text('SIGNATURE')),

                  ],
                  rows: listAttendance.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> list = entry.value;
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                        if (index % 2 == 0) {
                          return Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2);
                        }
                        return null;
                      }),
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(list['name'].toString())),
                        DataCell(Text(list['idpilot'].toString())),
                        DataCell(Text(list['rank'].toString())),
                        DataCell(Text(list['license'].toString())),
                        DataCell(Text(list['license'].toString())),
                        DataCell(Container(
                          width: 80,
                          height: 50,
                          child: Image.network(
                            "${list["signature_url"]}",
                            fit: BoxFit.cover,
                          ),
                        ),),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      )
    );
  }
}
