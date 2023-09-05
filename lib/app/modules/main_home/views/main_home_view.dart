import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';

import '../../../../presentation/theme.dart';
import '../../../../util/util.dart';
import '../../../routes/app_pages.dart';
import '../controllers/main_home_controller.dart';

class MainHomeView extends GetView<MainHomeController> {
  const MainHomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi, ${controller.titleToGreet!}",
                    style: tsOneTextTheme.headlineLarge,
                  ),
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
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: (){
                  Get.offAllNamed(Routes.home);
                },
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        height: 200,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: AssetImage(
                                    "assets/images/Cool Kids Alone Time.png"))),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("TS-1"),
                                    Text("Training Simulator -1")
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              InkWell(
                onTap: (){
                  Get.toNamed(Routes.NAVADMIN);
                },
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        height: 200,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: AssetImage(
                                    "assets/images/Cool Kids Alone Time.png"))),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Control Card"),
                                    Text("Training ")
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  Get.toNamed(Routes.NAVOCC);
                },
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        height: 200,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: AssetImage(
                                    "assets/images/Cool Kids Alone Time.png"))),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Electronic Flight Bag (EFB)"),
                                    Text("EFB Handover ")
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              )

            ],
          ),
        )));
  }
}
