import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ts_one/presentation/theme.dart';

import '../controllers/efb_dokumen_controller.dart';

class EfbDokumenView extends GetView<EfbDokumenController> {
  const EfbDokumenView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'PDF Document',
          style: tsOneTextTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Handover Log',
                    style: tsOneTextTheme.headlineMedium,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Panggil fungsi addDocument dari controller
                      controller.addDocument();
                      // Panggil fungsi getDocument dari controller
                      controller.getDocument();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decorationColor: TsOneColor.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
