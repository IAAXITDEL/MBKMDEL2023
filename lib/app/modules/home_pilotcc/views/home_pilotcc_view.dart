import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../presentation/theme.dart';
import '../../../../util/util.dart';
import '../controllers/home_pilotcc_controller.dart';

class HomePilotccView extends GetView<HomePilotccController> {
  const HomePilotccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
              ],
            ),
          ),
        )
    );
  }
}