import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../data/users/user_preferences.dart';
import '../../../../data/users/users.dart';
import '../../../../di/locator.dart';
import '../../../../presentation/theme.dart';
import '../../../../util/error_screen.dart';
import '../../../../util/loading_screen.dart';
import '../../../routes/app_pages.dart';
import '../controllers/trainingcc_controller.dart';

class TrainingccView extends GetView<TrainingccController> {
  const TrainingccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const RedTitleText(text :'TRAINING'),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // ------------------------------------ LIST TRAINING ----------------------------------

                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.trainingStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                       return const LoadingScreen(); // Placeholder while loading
                    }

                    if (snapshot.hasError) {
                       return const ErrorScreen();
                    }

                    var listTraining= snapshot.data!.docs;

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        childAspectRatio: 1.5,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listTraining.length,
                      itemBuilder: (context, index) {
                        var trainingData = listTraining[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          child: InkWell(
                            onTap: () {
                              late UserPreferences userPreferences;
                              userPreferences = getItLocator<UserPreferences>();

                              // SEBAGAI INSTRUCTOR
                              if( userPreferences.getInstructor().contains(UserModel.keySubPositionICC)){
                                Get.toNamed(Routes.TRAINING_INSTRUCTORCC, arguments: {
                                "id" : trainingData["id"],
                                "name" : trainingData["training"]
                                });
                              }

                              // SEBAGAI PILOT ADMINISTRATOR
                              else{
                                Get.toNamed(Routes.TRAININGTYPECC, arguments: {
                                  "id" : trainingData["id"],
                                  "name" : trainingData["training"]
                                });
                              }

                            },
                            splashColor: TsOneColor.primary,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                                child: Text( trainingData["training"],),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20,),
                // ------------------------------------ TRAINING REMARK ----------------------------------
                Row(
                  children: const [
                    RedTitleText(text: "TRAINING REMARK"),
                  ],
                ),

                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.trainingRemarkStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingScreen(); // Placeholder while loading
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    var listTrainingRemark = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: listTrainingRemark.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              
                              child: Text(
                                listTrainingRemark[index]["training_code"],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(listTrainingRemark[index]["remark"]),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20,),

              ],
            )
        ),
      ),
    );
  }
}
