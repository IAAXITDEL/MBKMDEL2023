import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../presentation/theme.dart';
import '../../../routes/app_pages.dart';
import '../controllers/instructor_main_homecc_controller.dart';

class InstructorMainHomeccView extends GetView<InstructorMainHomeccController> {
  const InstructorMainHomeccView({Key? key}) : super(key: key);
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
                        Get.toNamed(Routes.NAVINSTRUCTOR);
                      },
                      child: ListTile(
                        title: Text(
                          "Instructor",
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
                        Get.toNamed(Routes.NAVCAPTAIN);
                      },
                      child: ListTile(
                        title: Text(
                          "Pilot",
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

                ],
              ),
            )));
  }
}
