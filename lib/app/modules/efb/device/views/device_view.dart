import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:ts_one/presentation/shared_components/TitleText.dart';
import '../../../../../presentation/theme.dart';
import '../controllers/device_controller.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:animations/animations.dart';

class DevicesView extends GetView<DeviceController> {
  const DevicesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics Device',
          style: tsOneTextTheme.headlineLarge,
        ),
      ),
      body: Center(
        child: Text(
          'Testing',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
