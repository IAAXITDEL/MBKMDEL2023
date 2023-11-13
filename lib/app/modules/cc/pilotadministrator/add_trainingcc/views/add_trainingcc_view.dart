import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:ts_one/presentation/shared_components/TitleText.dart';

import '../../../../../../presentation/shared_components/formtextfield.dart';
import '../../../../../../presentation/theme.dart';
import '../../../../../../util/error_screen.dart';
import '../../../../../../util/loading_screen.dart';
import '../../../../../routes/app_pages.dart';
import '../controllers/add_trainingcc_controller.dart';

class AddTrainingccView extends GetView<AddTrainingccController> {
  AddTrainingccView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var subjectC = TextEditingController();
    var trainingDescriptionC = TextEditingController();

    Future<void> add(String newSubject, String newExpiryDate,
        String newTrainingDescription) async {
      controller
          .addNewSubject(newSubject, newExpiryDate, newTrainingDescription)
          .then((status) async {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Add Training Completed Successfully!',
        );

        Get.offAllNamed(Routes.TRAININGCC);
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: RedTitleText(text: "ADD TRAINING"),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),

                  //-------------------------SUBJECT-----------------------
                  FormTextField(text: "Subject", textController: subjectC),
                  SizedBox(
                    height: 10,
                  ),

                  //--------------------------RECURRENT--------------------------
                  // Row(
                  //   children: [
                  //     Expanded(child: Text("Recurrent")),
                  //   ],
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        child: DropdownMenu<String>(
                          hintText: "Recurrent",
                          width: Get.width / 1.12,
                          onSelected: (String? value) {
                            controller.dropdownValue.value = value!;
                          },
                          dropdownMenuEntries: controller.list
                              .map<DropdownMenuEntry<String>>((String value) {
                            return DropdownMenuEntry<String>(
                              value: value,
                              label: value,
                              style: ButtonStyle(
                                textStyle: MaterialStateProperty.all<TextStyle>(
                                  TextStyle(
                                      fontSize: 11.0), // Set the font size here
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  //-------------------------TRAINING DESCRIPTION-----------------------
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: tsOneColorScheme.secondaryContainer),
                        borderRadius: BorderRadius.circular(5)),
                    child: TextFormField(
                      controller: trainingDescriptionC,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          // Validation Logic
                          return 'Please enter the Training Description';
                        }
                        return null;
                      },
                      decoration: InputDecoration.collapsed(
                          hintText: "Training Description"),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  //-------------------------SUBMIT-----------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate()) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return FutureBuilder<void>(
                                  future: add(
                                      subjectC.text,
                                      controller.dropdownValue.value,
                                      trainingDescriptionC.text),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<void> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return LoadingScreen(); // Show loading screen
                                    }

                                    if (snapshot.hasError) {
                                      // Handle error if needed
                                      return ErrorScreen();
                                    } else {
                                      return Container();
                                    }
                                  },
                                );
                              });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: TsOneColor.greenColor,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text("Make sure every data is selected before pressing the submit button", style: tsOneTextTheme.labelSmall,),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
