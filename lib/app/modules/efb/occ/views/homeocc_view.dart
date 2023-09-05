import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/homeocc_controller.dart';

class HomeOCCView extends GetView<HomeOCCController> {
  const HomeOCCView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home OCC View'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Home OCC View is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
