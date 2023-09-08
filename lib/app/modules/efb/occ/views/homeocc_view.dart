import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../presentation/theme.dart';
import '../../../../../util/util.dart';
import '../controllers/homeocc_controller.dart';

class HomeOCCView extends GetView<HomeOCCController> {
  const HomeOCCView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeOCCController());
    bool isContainerClicked = false;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi, ${controller.titleToGreet}",
                    style: tsOneTextTheme.headlineLarge,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.notifications_active_outlined,
                    color: tsOneColorScheme.onSecondary,
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Good ${controller.timeToGreet}',
                  style: tsOneTextTheme.labelMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.calendar_month_outlined,
                        color: TsOneColor.onSecondary,
                        size: 32,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Util.convertDateTimeDisplay(
                              DateTime.now().toString(), "EEEE"),
                          style: tsOneTextTheme.labelSmall,
                        ),
                        Text(
                          Util.convertDateTimeDisplay(
                              DateTime.now().toString(), "dd MMMM yyyy"),
                          style: tsOneTextTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      onChanged: (value) {
                        // if (value.isNotEmpty) {
                        //   value = value.toTitleCase();

                        //   setState(() {
                        //     isSearchingAll = true;
                        //   });
                        //   log("searching for $value");
                        //   searchAssessmentBasedOnName(value);
                        // } else {
                        //   getAllAssessments();
                        //   log("EMMTPY");
                        //   setState(() {
                        //     isSearchingAll = false;
                        //   });
                        // }
                      },
                      cursorColor: TsOneColor.primary,
                      decoration: InputDecoration(
                          fillColor: TsOneColor.onPrimary,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                const BorderSide(color: TsOneColor.primary),
                          ),
                          hintText: 'Search...',
                          hintStyle: const TextStyle(
                            color: TsOneColor.onSecondary,
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(16),
                            width: 32,
                            child: const Icon(Icons.search),
                          )),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Need Confirmation',
                  style: tsOneTextTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  //border: Border.all(color: Colors.grey, width: 1.0),
                  border: Border.all(
                    color: isContainerClicked ? Colors.red : Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          controller.userPreferences.getPhotoURL()),
                      radius: 20.0,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Pilot name',
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'IAAICT004573',
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'In Use',
                  style: tsOneTextTheme.displayMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
