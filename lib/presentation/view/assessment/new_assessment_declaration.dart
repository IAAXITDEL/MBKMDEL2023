import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:ts_one/data/assessments/assessment_results.dart';
import 'package:ts_one/data/assessments/new_assessment.dart';
import 'package:ts_one/data/users/user_signatures.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view_model/assessment_results_viewmodel.dart';
import 'package:ts_one/presentation/view_model/user_viewmodel.dart';

class NewAssessmentDeclaration extends StatefulWidget {
  const NewAssessmentDeclaration
      ({super.key, required this.newAssessment});

  final NewAssessment newAssessment;

  @override
  State<NewAssessmentDeclaration> createState() => _NewAssessmentDeclarationState();
}

class _NewAssessmentDeclarationState extends State<NewAssessmentDeclaration> with SingleTickerProviderStateMixin {
  bool _isConfirmed = false;
  late UserViewModel _userViewModel;
  late UserSignatures _userSignatures;
  late NewAssessment _newAssessment;
  late SignatureController signatureController;
  late TabController _tabController;
  late ImagePicker imagePicker;
  late HandSignatureControl handSignatureControl;
  late List<AssessmentResults> _assessmentResults;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  XFile? _pickedImage;
  File? _image;
  CroppedFile? _croppedImage;

  @override
  void initState() {
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    // _assessmentResults = widget.newAssessment;
    signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: tsOneColorScheme.onSecondary,
    );
    _newAssessment = widget.newAssessment;
    _tabController = TabController(length: 2, vsync: this);
    imagePicker = ImagePicker();
    _assessmentResults = [];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future getImage() async {
    _pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (_pickedImage == null) return;
    File? imgTemp;

    if(_pickedImage != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedImage!.path,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 100,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
            statusBarColor: tsOneColorScheme.onSecondary,
            toolbarTitle: "Crop Image",
            toolbarColor: tsOneColorScheme.secondary,
            toolbarWidgetColor: tsOneColorScheme.onSurface,
            initAspectRatio: CropAspectRatioPreset.square,
            activeControlsWidgetColor: tsOneColorScheme.primary,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: "Crop Image",
          ),
          WebUiSettings(
              context: context
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedImage = croppedFile;
          imgTemp = File(_croppedImage!.path);
          _image = imgTemp;
        });
      }
      else{
        setState(() {
          _pickedImage = null;
          imgTemp = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("dataCandidate: ${widget.newAssessment}");

    return Consumer<AssessmentResultsViewModel>(
      builder: (_, assessmentResultsViewModel, child) {
        return Consumer<UserViewModel>(
          builder: (_, userViewModel, child) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Declaration"),
              ),
              resizeToAvoidBottomInset: false,
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: userViewModel.isLoading || assessmentResultsViewModel.isLoading
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("This will take a while. You will see a confirmation screen when it's done."),
                        ],
                      )
                    )
                    : Column(
                    children: [
                      ListTileTheme(
                        horizontalTitleGap: 0.0,
                        contentPadding: const EdgeInsets.only(bottom: 0),
                        child: CheckboxListTile(
                          value: _isConfirmed,
                          title: const Text("I hereby declare that I have filled in the data correctly"),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (newValue) {
                            setState(() {
                              _isConfirmed = newValue!;
                            });
                          },
                        ),
                      ),
                      // Flight crew 1
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Flight Crew 1',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _newAssessment.sessionDetails1 == NewAssessment.keySessionDetailsTraining
                          ? DropdownButtonFormField(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select one of the options';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (newValue) {
                          setState(() {
                            _newAssessment.declaration1 = newValue.toString();
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintMaxLines: 1,
                            label: Text(
                              "For TRAINING",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            )
                        ),
                        items: NewAssessment.forTrainingDeclaration.map((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      )
                          : DropdownButtonFormField(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select one of the options';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (newValue) {
                          setState(() {
                            _newAssessment.declaration1 = newValue.toString();
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintMaxLines: 1,
                            label: Text(
                              "For CHECK",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            )
                        ),
                        items: NewAssessment.forCheckDeclaration.map((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                      // Flight crew 2
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Flight Crew 2',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _newAssessment.sessionDetails2 == NewAssessment.keySessionDetailsTraining
                          ? DropdownButtonFormField(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select one of the options';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (newValue) {
                          setState(() {
                            _newAssessment.declaration2 = newValue.toString();
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintMaxLines: 1,
                            label: Text(
                              "For TRAINING",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            )
                        ),
                        items: NewAssessment.forTrainingDeclaration.map((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      )
                          : DropdownButtonFormField(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select one of the options';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (newValue) {
                          setState(() {
                            _newAssessment.declaration2 = newValue.toString();
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintMaxLines: 1,
                            label: Text(
                              "For CHECK",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            )
                        ),
                        items: NewAssessment.forCheckDeclaration.map((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Signature"),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        height: 45,
                        width: 400,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: TsOneColor.primary,
                          ),
                          padding: EdgeInsets.zero,
                          labelColor: TsOneColor.secondary,
                          unselectedLabelColor: TsOneColor.primary,
                          tabs: const [
                            SizedBox.expand(child: Center(child: Text("Draw"))),
                            SizedBox.expand(child: Center(child: Text("Image"))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _tabController,
                          children: [
                            Stack(children: <Widget>[
                              ClipRRect(
                                child: SizedBox(
                                  child:
                                  Signature(
                                    controller: signatureController,
                                    backgroundColor: TsOneColor.primaryFaded,
                                  ),
                                  /*
                              Container(
                                constraints: BoxConstraints.expand(),
                                color: Colors.white,
                                child: HandSignature(
                                  control: handSignatureControl,
                                  type: SignatureDrawType.shape,
                                ),
                              )
                              */
                                ),
                              ),
                              Container(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_outlined,
                                    size: 32,
                                    color: TsOneColor.primary,
                                  ),
                                  onPressed: () {
                                    signatureController.clear();
                                    // handSignatureControl.clear();
                                  },
                                ),
                              ),
                            ]),
                            if (_image == null)
                              InkWell(
                                onTap: () {
                                  getImage();
                                },
                                child: Ink(
                                  color: TsOneColor.primaryFaded.withOpacity(0.5),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 72,
                                          color: TsOneColor.primaryFaded,
                                        ),
                                        Text("Signature")
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Center(
                                  child: InkWell(
                                    onTap: () {
                                      getImage();
                                    },
                                    child: Ink(
                                      color: TsOneColor.primaryFaded.withOpacity(0.5),
                                      child: Image(
                                        image: FileImage(_image!),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            // check dropdowns
                            _formKey.currentState!.validate();

                            // check confirmation
                            if(!_isConfirmed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Please confirm the declaration"),
                                  duration: const Duration(milliseconds: 2000),
                                  action: SnackBarAction(
                                    label: 'Close',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                    },
                                  ),
                                ),
                              );
                              return;
                            }

                            // check signature
                            // tab draw active
                            if (_tabController.index == 0) {
                              // check if signature is empty
                              if(signatureController.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Please provide signature"),
                                    duration: const Duration(milliseconds: 2000),
                                    action: SnackBarAction(
                                      label: 'Close',
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                      },
                                    ),
                                  ),
                                );
                                return;
                              }
                              // get signature
                              _newAssessment.signatureBytes = await signatureController.toPngBytes();
                            }
                            // tab image active
                            else {
                              // check if signature image is empty
                              if(_image == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Please provide signature image"),
                                    duration: const Duration(milliseconds: 2000),
                                    action: SnackBarAction(
                                      label: 'Close',
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                      },
                                    ),
                                  ),
                                );
                                return;
                              }
                              // get image
                              _newAssessment.signatureBytes = await _image!.readAsBytes();
                            }

                            log(_newAssessment.signatureBytes.toString());

                            if(_formKey.currentState!.validate()) {
                              try {
                                String signatureUrl = await _userViewModel.uploadSignature(
                                    _newAssessment.idNoInstructor,
                                    _newAssessment.assessmentDate,
                                    _newAssessment.signatureBytes);
                                _newAssessment.instructorSignatureUrl = signatureUrl;

                                // store UserSignatures in remote to be used later in the app
                                _userSignatures = UserSignatures(
                                  urlSignature: signatureUrl,
                                  staffId: _newAssessment.idNoInstructor,
                                );
                                _userSignatures = await _userViewModel.addSignature(_userSignatures);


                                /// push the data to the database
                                await assessmentResultsViewModel.addAssessmentResults(_assessmentResults, _newAssessment);

                                if (!mounted) return;
                                // push to success screen
                                toSuccessScreen(context);
                              } catch (e) {
                                log(e.toString());
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: const Text("Failed to confirm your assessment"),
                                        duration: const Duration(milliseconds: 2000),
                                        action: SnackBarAction(
                                          label: "Close",
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          },
                                        ))
                                );
                              }

                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor: TsOneColor.primary,
                            foregroundColor: TsOneColor.primaryContainer,
                            surfaceTintColor: TsOneColor.primaryContainer,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Submit",
                                style: TextStyle(color: TsOneColor.secondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }

  void toSuccessScreen(BuildContext context) {
    Navigator.pushNamed(context, NamedRoute.newAssessmentSuccess);
  }
}
