import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/theme.dart';
import '../controllers/list_pilotcptscc_controller.dart';

class ListPilotcptsccView extends GetView<ListPilotcptsccController> {
  const ListPilotcptsccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final currentPageData = controller.getCurrentPageData();
    return Scaffold(
      appBar: AppBar(
        title: const RedTitleText(text: 'INSTRUCTORS',),
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
                  // onChanged: search,
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

                Expanded(
                  child: SingleChildScrollView(
                    child:ListView.builder(
                      shrinkWrap: true,
                      itemCount: currentPageData.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            // Handle item tap
                            // controller.toggleClick;
                            // Get.toNamed(Routes.PILOT_CABIN_CREW_PROFILE);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.8),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Image.asset("assets/images/user.png"),
                              title: Text(currentPageData[index]["NAME"]),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('847598342385'),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Ready",
                                      style: TextStyle(fontSize: 10, color: Colors.white),
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
                  ),
                ),
                // Wrap(
                //   alignment: WrapAlignment.center,
                //   children: List<Widget>.generate(
                //     (controller.data.length / controller.itemsPerPage).ceil(),
                //         (int index) {
                //       final page = index + 1;
                //       return ElevatedButton(
                //
                //         onPressed: () {
                //          controller.goToPage(page);
                //           print("$page");
                //         },
                //         child: Text('$page'),
                //       );
                //     },
                //   ),
                // ),

              ],
            )
        ),
      ),
    );
  }
}




