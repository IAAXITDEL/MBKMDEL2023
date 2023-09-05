import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/homepilot_controller.dart';

class HomePilotView extends GetView<HomePilotController> {
  const HomePilotView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home FO View'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Home FO View is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
