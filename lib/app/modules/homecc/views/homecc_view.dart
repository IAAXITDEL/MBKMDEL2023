import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/homecc_controller.dart';

class HomeccView extends GetView<HomeccController> {
  const HomeccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeccView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'HomeccView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
