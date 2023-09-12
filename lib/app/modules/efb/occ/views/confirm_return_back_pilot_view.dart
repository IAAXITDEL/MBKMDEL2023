import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ConfirmReturnBackPilotView extends GetView {
  const ConfirmReturnBackPilotView({Key? key, required String dataId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ConfirmReturnBackPilotView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ConfirmReturnBackPilotView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
