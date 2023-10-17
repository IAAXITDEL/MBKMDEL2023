import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/theme.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../routes/app_pages.dart';
import '../controllers/list_pilotcptscc_controller.dart';

class ListPilotcptsccView extends GetView<ListPilotcptsccController> {
  const ListPilotcptsccView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ListPilotcptsccController());
    return Scaffold(
      appBar: AppBar(
        title: const RedTitleText(
          text: 'PILOT LIST',
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
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

              TextFormField(
                controller: controller.searchC,
                onChanged: (value) => controller.nameS.value = value,
                decoration: InputDecoration(
                  hintText: "Search",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.nameS.value = "";
                      controller.getFilteredStream();
                      controller.searchC.clear();
                    },
                  ),
                ),
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
                                                .toString() ??
                                                "",
                                            style: tsOneTextTheme.labelSmall,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color:
                                              Colors.green.withOpacity(0.4),
                                              borderRadius:
                                              BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              "Ready",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.green,
                                              ),
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
        ),
      ),
    );
  }
}
