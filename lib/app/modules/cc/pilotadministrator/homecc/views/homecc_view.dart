import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../instructor/home_instructorcc/views/home_instructorcc_view.dart';
import '../../home_admincc/views/home_admincc_view.dart';
import '../controllers/homecc_controller.dart';


class HomeccView extends GetView<HomeccController> {
  const HomeccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: controller.titleToGreet == 'Captain' ? const HomeInstructorccView() : const HomeAdminccView(),
      ),
    );
  }
}
