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
      backgroundColor: TsOneColor.primary,
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            children: [
              Center(
                child: Container(
                  child: Image.asset("assets/images/airasia_logo_circle.png",  fit: BoxFit.cover,),
                ),
              ),
              Text(
                "WELCOME",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                "Please select the desired menu",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white
                ),
                child: InkWell(
                  onTap: (){
                    Get.offAllNamed(Routes.home);
                  },
                  child: ListTile(
                    title: Text(
                      "TS -1",
                      style: tsOneTextTheme.headlineLarge,
                    ),
                    subtitle: Text(
                      "Training Simulator",
                      style: tsOneTextTheme.labelSmall,
                    ),
                    trailing: Icon(Icons.navigate_next),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white
                ),
                child: InkWell(
                  onTap: (){
                    controller.cekRole();
                  },
                  child: ListTile(
                    title: Text(
                      "Training Card",
                      style: tsOneTextTheme.headlineLarge,
                    ),
                    subtitle: Text(
                      "Pilot Training and Proficiency Control Card",
                      style: tsOneTextTheme.labelSmall,
                    ),
                    trailing: Icon(Icons.navigate_next),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white
                ),
                child: InkWell(
                  onTap: (){
                    Get.toNamed(Routes.NAVOCC);
                  },
                  child: ListTile(
                    title: Text(
                      "EFB",
                      style: tsOneTextTheme.headlineLarge,
                    ),
                    subtitle: Text(
                      "Electronic Flight Bag (EFB)",
                      style: tsOneTextTheme.labelSmall,
                    ),
                    trailing: Icon(Icons.navigate_next),
                  ),
                ),
              ),

            ],
          ),
        )));
  }
}
