import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ts_one/app/modules/home_cptscc/controllers/home_cptscc_controller.dart';

import '../../../../presentation/theme.dart';
import '../../../../util/util.dart';

class HomeCptsccView extends GetView<HomeCptsccController> {
  const HomeCptsccView({Key? key}) : super(key: key);

  // Function to create a Card widget with specified content
  Widget buildCard(String imagePath, String count, String title) {
    return Card(
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 48,
            height: 63,
          ),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, ${controller.titleToGreet}!",
                style: tsOneTextTheme.headlineLarge,
              ),
              Text(
                'Good ${controller.timeToGreet}',
                style: tsOneTextTheme.labelMedium,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
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
              SizedBox(height: 20),
              Text(
                'STATS',
                style: tsOneTextTheme.displayMedium,
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          height: 140,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/G1.png',
                                  width: 48,
                                  height: 63,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${controller.trainingCount.value}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Trainings',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 140,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/G2.png',
                                  width: 48,
                                  height: 63,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${controller.instructorCount.value}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Instructors',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 140,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/G3.png',
                                  width: 48,
                                  height: 63,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${controller.pilotCount.value}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Pilots',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          height: 140,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/G1.png',
                                  width: 48,
                                  height: 63,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${controller.ongoingTrainingCount.value}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Ongoing',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  'Trainings',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 140,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/G2.png',
                                  width: 48,
                                  height: 63,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${controller.completedTrainingCount.value}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.red),
                                ),
                                Text(
                                  'Trainings',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 140,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/G3.png',
                                  width: 48,
                                  height: 63,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${controller.traineeCount.value}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Trainee',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
