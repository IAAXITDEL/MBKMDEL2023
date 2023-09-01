import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:ts_one/data/assessments/assessment_results.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/data/users/user_signatures.dart';
import 'package:ts_one/di/locator.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view_model/assessment_results_viewmodel.dart';
import 'package:ts_one/presentation/view_model/user_viewmodel.dart';

class ResultAssessmentDeclaration extends StatefulWidget {
  const ResultAssessmentDeclaration({Key? key, required this.assessmentResults}) : super(key: key);

  final AssessmentResults assessmentResults;

  @override
  State<ResultAssessmentDeclaration> createState() => _ResultAssessmentDeclarationState();
}

class _ResultAssessmentDeclarationState extends State<ResultAssessmentDeclaration> with SingleTickerProviderStateMixin {
  late UserViewModel _userViewModel;
  late AssessmentResults _assessmentResults;
  late TabController _tabController;
  late SignatureController _signatureController;
  late ImagePicker _imagePicker;
  late UserSignatures _userSignatures;
  bool _isConfirmed = false;
  bool _isCPTS = false;
  late UserPreferences userPreferences;
  Image? imageSignature;

  File? _image;
  XFile? _pickedImage;
  CroppedFile? _croppedImage;

  @override
  void initState() {
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    userPreferences = getItLocator<UserPreferences>();
    _assessmentResults = widget.assessmentResults;
    _tabController = TabController(length: 2, vsync: this);
    _signatureController = SignatureController(
      penStrokeWidth: 5,
      penColor: TsOneColor.onSecondary,
    );
    _imagePicker = ImagePicker();
    _userSignatures = UserSignatures();

    // Check if CPTS
    _isCPTS = _assessmentResults.isCPTS;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSignatureOfCurrentUser();
    });

    super.initState();
  }

  void getSignatureOfCurrentUser() async {
    _userSignatures = await _userViewModel.getSignature(userPreferences.getIDNo());

    var data = await http.get(Uri.parse(_userSignatures.urlSignature)).then((value) => value.bodyBytes);

    // var fileSignatureBytes = await File(_userSignatures.urlSignature).readAsBytes();

    imageSignature = Image.memory(data);
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future getImage() async {
    _pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (_pickedImage == null) return;
    File? imgTemp;

    if (_pickedImage != null) {
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
          WebUiSettings(context: context),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedImage = croppedFile;
          imgTemp = File(_croppedImage!.path);
          _image = imgTemp;
        });
      } else {
        setState(() {
          _pickedImage = null;
          imgTemp = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentResultsViewModel>(builder: (_, assessmentResultsViewModel, child) {
      return Consumer<UserViewModel>(
        builder: (_, userViewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Declaration"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: userViewModel.isLoading || assessmentResultsViewModel.isLoading
                  ? const Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("This will take a while. You will see a confirmation screen when it's done."),
                      ],
                    ))
                  : Column(
                      children: [
                        Expanded(
                            child: Column(
                          children: [
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
                                          controller: _signatureController,
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
                                          _signatureController.clear();
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
                            ListTileTheme(
                              horizontalTitleGap: 0.0,
                              contentPadding: const EdgeInsets.only(bottom: 0),
                              child: CheckboxListTile(
                                value: _isConfirmed,
                                title: const Text("I agree with all of the results above"),
                                dense: true,
                                controlAffinity: ListTileControlAffinity.leading,
                                onChanged: (newValue) {
                                  setState(() {
                                    _isConfirmed = newValue!;
                                  });
                                },
                              ),
                            ),
                          ],
                        )),
                        ElevatedButton(
                          onPressed: () async {
                            if (!_isConfirmed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: const Text("Please confirm the results above"),
                                    duration: const Duration(milliseconds: 2000),
                                    action: SnackBarAction(
                                      label: "Close",
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      },
                                    )),
                              );
                              return;
                            }

                            // Check Signature

                            // Tab draw active
                            if (_tabController.index == 0) {
                              // Check if signature is empty
                              if (_signatureController.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: const Text("Please provide your signature"),
                                      duration: const Duration(milliseconds: 2000),
                                      action: SnackBarAction(
                                        label: "Close",
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        },
                                      )),
                                );
                                return;
                              }

                              // Save signature
                              _assessmentResults.signatureBytes = await _signatureController.toPngBytes();
                            }

                            // Tab image active
                            else {
                              // Check if signature image is empty
                              if (_image == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: const Text("Please provide signature image"),
                                      duration: const Duration(milliseconds: 2000),
                                      action: SnackBarAction(
                                        label: "Close",
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        },
                                      )),
                                );
                                return;
                              }
                              // get image
                              _assessmentResults.signatureBytes = await _image!.readAsBytes();
                            }


                            try {
                              // Check if CPTS
                              if (_isCPTS) {
                                String signatureUrl = await _userViewModel.uploadSignature(
                                    userPreferences.getIDNo(),
                                    _assessmentResults.date,
                                    _assessmentResults.signatureBytes);
                                _assessmentResults.cptsSignatureUrl = signatureUrl;

                                // Store UserSignature in remote to be used later in the app
                                _userSignatures = UserSignatures(
                                  urlSignature: signatureUrl,
                                  staffId: userPreferences.getIDNo(),
                                );
                                _userSignatures = await _userViewModel.addSignature(_userSignatures);

                                _assessmentResults.confirmedByCPTS = true;
                                _assessmentResults.cptsStaffIDNo = userPreferences.getIDNo();

                              } else {
                                String signatureUrl = await _userViewModel.uploadSignature(
                                    _assessmentResults.examineeStaffIDNo,
                                    _assessmentResults.date,
                                    _assessmentResults.signatureBytes);
                                _assessmentResults.examineeSignatureUrl = signatureUrl;

                                // Store UserSignature in remote to be used later in the app
                                _userSignatures = UserSignatures(
                                  urlSignature: signatureUrl,
                                  staffId: _assessmentResults.examineeStaffIDNo,
                                );
                                _userSignatures = await _userViewModel.addSignature(_userSignatures);

                                _assessmentResults.confirmedByExaminer = true;
                              }

                              // Update the data
                              await assessmentResultsViewModel.updateAssessmentResultForExaminee(_assessmentResults);

                              if (!mounted) return;
                              Navigator.pushNamed(context, NamedRoute.newAssessmentSuccess);
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
                                    )),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            backgroundColor: TsOneColor.primary,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Confirm Assessment",
                                style: TextStyle(color: TsOneColor.secondary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      );
    });
  }
}
