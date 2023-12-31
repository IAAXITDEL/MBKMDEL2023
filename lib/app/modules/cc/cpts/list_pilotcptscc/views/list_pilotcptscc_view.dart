import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/list_pilotcptscc_controller.dart';

class ListPilotcptsccView extends GetView<ListPilotcptsccController> {
  const ListPilotcptsccView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var nameC = TextEditingController();
    Get.put(ListPilotcptsccController());
    return Scaffold(
      appBar: AppBar(title: RedTitleText(
        text: "PILOT LIST",
      ),
      centerTitle: true,
      ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //FILTER DROPDOWN
              // Row(
              //   children: [
              //     DropdownButton<FilterType>(
              //       value: controller.filterType,
              //       onChanged: (FilterType? newValue) {
              //         if (newValue != null) {
              //           controller.setFilterType(newValue);
              //         }
              //       },
              //       items: FilterType.values.map((FilterType type) {
              //         String label;
              //         switch (type) {
              //           case FilterType.none:
              //             label = 'All';
              //             break;
              //           case FilterType.instructor:
              //             label = 'Instructors';
              //             break;
              //           case FilterType.pilot:
              //             label = 'Pilots';
              //             break;
              //         }
              //
              //         return DropdownMenuItem<FilterType>(
              //           value: type,
              //           child: Text(
              //             label,
              //             style: TextStyle(
              //               color: Colors.black, // Text color
              //             ),
              //           ),
              //         );
              //       }).toList(),
              //     ),
              //   ],
              // ),

              SizedBox(height: 10,),

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
                                hintText: 'Type pilot name...',
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

              const SizedBox(
                height: 20,
              ),
              Obx(
                    () => Expanded(
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: controller.getFilteredStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                    Get.toNamed(Routes.PILOTCREWDETAILCC,
                                        arguments: {
                                          "id": listAttendance[index]["ID NO"],
                                        });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 5),
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
                                          borderRadius:
                                          BorderRadius.circular(100),
                                          child: listAttendance[index]
                                          ["PHOTOURL"] ==
                                              null
                                              ? Image.asset(
                                            "assets/images/placeholder_person.png",
                                            fit: BoxFit.cover,
                                          )
                                              : Image.network(
                                              "${listAttendance[index]["PHOTOURL"]}",
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      title: Text(
                                        listAttendance[index]["NAME"],
                                        maxLines: 1,
                                        style: tsOneTextTheme.labelMedium,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            listAttendance[index]["ID NO"]
                                                .toString(),
                                            style: tsOneTextTheme.labelSmall,
                                          ),
                                          Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 3,
                                                horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: listAttendance[index]["STATUS"] == "VALID" ? Colors.green.withOpacity(0.4) :Colors.red.withOpacity(0.4),
                                              borderRadius:
                                              BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              listAttendance[index]["STATUS"] ??
                                                  "",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: listAttendance[index]["STATUS"] == "VALID" ? Colors.green :Colors.red),
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
                            controller.isLoading.value
                                ? Center(
                              child: CircularProgressIndicator(),
                            )
                                : SizedBox(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
      )
    );
  }
}
