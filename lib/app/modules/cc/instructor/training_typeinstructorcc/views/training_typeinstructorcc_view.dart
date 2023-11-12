import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../../presentation/shared_components/TitleText.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../controllers/training_typeinstructorcc_controller.dart';

class TrainingTypeinstructorccView
    extends GetView<TrainingTypeinstructorccController> {
  const TrainingTypeinstructorccView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
          title:RedTitleText(text: 'TRAINING'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text("TRAINER / INSTRUCTOR", style: tsOneTextTheme.labelMedium,),
              // ------------------------------------ LIST TRAINING ----------------------------------

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.trainingStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen(); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return ErrorScreen();
                  }

                  var listTraining = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          side: BorderSide(color: TsOneColor.secondary, width: 1),
                        ),
                        color: TsOneColor.surface,
                        surfaceTintColor: Colors.white,
                        shadowColor: Colors.white,
                        elevation: 5,
                        child: InkWell(
                          onTap: () {
                            controller.argumentid.value = trainingData["id"];
                            controller.argumentname.value =
                            trainingData["training"];
                            controller.update();
                            controller.cekRole();
                          },
                          splashColor: TsOneColor.primary,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 10),
                              child: Text(
                                trainingData["training"], style: TextStyle(color: TsOneColor.secondaryContainer, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              SizedBox(
                height: 20,
              ),

              // ------------------------------------ TRAINING REMARK ----------------------------------
              Row(
                children: [
                  RedTitleText(text: "TRAINING REMARK"),
                ],
              ),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.trainingRemarkStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen(); // Placeholder while loading
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
                            flex: 1,
                            child: Text(
                              listTrainingRemark[index]["training_code"],
                              style: TextStyle(fontWeight: FontWeight.bold),
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
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
