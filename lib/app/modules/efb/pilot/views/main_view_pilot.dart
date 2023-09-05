import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../presentation/theme.dart';
import '../../../../../util/util.dart';
import '../controllers/homepilot_controller.dart';

class HomePilotView extends GetView<HomePilotController> {
  const HomePilotView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomePilotController());
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
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text("Request Device",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(vertical: 15, horizontal: 90), // Sesuaikan sesuai kebutuhan
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0), // Sesuaikan border radius sesuai kebutuhan
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.white, // Ganti dengan warna latar belakang yang diinginkan
                      ),
                    ),
                  ),
                ],
              ),
            )
        )
    );
  }
}
