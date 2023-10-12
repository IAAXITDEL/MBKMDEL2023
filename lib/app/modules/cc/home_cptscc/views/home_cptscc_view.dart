import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ts_one/app/modules/cc/home_cptscc/controllers/home_cptscc_controller.dart';

import '../../../../../presentation/theme.dart';
import '../../../../../util/util.dart';

class HomeCptsccView extends GetView<HomeCptsccController> {
  const HomeCptsccView({Key? key}) : super(key: key);
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
                      "Hi, ${controller.titleToGreet}!",
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
                            Util.convertDateTimeDisplay(DateTime.now().toString(), "EEEE"),
                            style: tsOneTextTheme.labelSmall,
                          ),
                          Text(
                            Util.convertDateTimeDisplay(DateTime.now().toString(), "dd MMMM yyyy"),
                            style: tsOneTextTheme.labelSmall,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'STATS',
                      style: tsOneTextTheme.displayMedium,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Tampilkan dua Card pertama dalam satu baris
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Card(
                                child: Column(
                                  children: List.generate(1, (index) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.all(16),
                                      title: Column(
                                        children: [
                                          Image.asset('assets/images/G1.png', width: 48, height: 63,),
                                          SizedBox(height: 8),
                                          Text('21', style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text('Trainings', style: TextStyle(fontSize: 14, color: Colors.red),),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Card(
                                child: Column(
                                  children: List.generate(1, (index) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.all(16),
                                      title: Column(
                                        children: [
                                          Image.asset('assets/images/G2.png', width: 48, height: 63,),
                                          SizedBox(height: 8),
                                          Text('40', style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text('Instructor', style: TextStyle(fontSize: 13, color: Colors.red),),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Card(
                                child: Column(
                                  children: List.generate(1, (index) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.all(16),
                                      title: Column(
                                        children: [
                                          Image.asset('assets/images/G3.png', width: 48, height: 63,),
                                          SizedBox(height: 8),
                                          Text('410', style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text('Pilots', style: TextStyle(fontSize: 14, color: Colors.red),),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}



