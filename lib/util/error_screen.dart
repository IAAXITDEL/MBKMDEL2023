import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
class ErrorScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Lottie.asset("assets/lottie/error.json" ,width: Get.width * 0.7, // Set the width you want
      height: Get.width * 0.7,);
  }
}
