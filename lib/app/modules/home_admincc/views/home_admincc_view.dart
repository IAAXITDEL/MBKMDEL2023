import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../presentation/shared_components/TitleText.dart';
import '../../../../presentation/theme.dart';
import '../controllers/home_admincc_controller.dart';

class HomeAdminccView extends GetView<HomeAdminccController> {
  const HomeAdminccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Need Confirmation",
              style: tsOneTextTheme.labelLarge,
            ),
            InkWell(
              child: Text(
                "See All",
                style: tsOneTextTheme.labelMedium,
              ),
            )
          ],
        ),
        SizedBox(height: 10,),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: (){

            },
            child: ListTile(
              title: Text(
                "RVSM",
                style: tsOneTextTheme.headlineMedium,
              ),
              subtitle: Text(
                "Noel Alex",
                style: tsOneTextTheme.labelSmall,
              ),
              trailing: Icon(Icons.navigate_next),
            ),
          ),
        ),
      ],
    );
  }
}
