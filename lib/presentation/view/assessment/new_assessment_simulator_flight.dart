import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:ts_one/data/assessments/new_assessment.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';

class NewAssessmentSimulatorFlightView extends StatefulWidget {
  const NewAssessmentSimulatorFlightView({super.key});

  @override
  State<NewAssessmentSimulatorFlightView> createState() => _NewAssessmentSimulatorFlightViewState();
}

class _NewAssessmentSimulatorFlightViewState extends State<NewAssessmentSimulatorFlightView> {
  late NewAssessment _newAssessment;

  @override
  void initState() {
    _newAssessment = NewAssessment();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Assessment'),
      ),
      body: FocusDetector(
        onFocusGained: () {
          setState(() {
            _newAssessment = NewAssessment();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Card(
                  surfaceTintColor: TsOneColor.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      _newAssessment.typeOfAssessment = NewAssessment.keyTypeOfAssessmentSimulator;
                      Navigator
                          .pushNamed(
                          context,
                          NamedRoute.newAssessmentCandidate,
                          arguments: _newAssessment
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Icon(
                                  Icons.feed,
                                  size: 64.0,
                                ),
                              ),
                              Text(
                                'Simulator TS-1',
                                style: tsOneTextTheme.bodyLarge
                              ),
                            ],
                          )
                        ),
                      ],
                    )
                  ),
                ),
              ),
              // const SizedBox(
              //   height: 8.0,
              // ),
              // Expanded(
              //   child: Card(
              //     surfaceTintColor: TsOneColor.surface,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(16),
              //     ),
              //     child: InkWell(
              //         onTap: () {
              //           _newAssessment.typeOfAssessment = NewAssessment.keyTypeOfAssessmentFlight;
              //           Navigator
              //               .pushNamed(
              //               context,
              //               NamedRoute.newAssessmentCandidate,
              //               arguments: _newAssessment
              //           );
              //         },
              //         child: Row(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: [
              //             Expanded(
              //                 child: Column(
              //                   mainAxisAlignment: MainAxisAlignment.center,
              //                   children: [
              //                     const Padding(
              //                       padding: EdgeInsets.only(bottom: 8.0),
              //                       child: Icon(
              //                         Icons.airplanemode_active_outlined,
              //                         size: 64.0,
              //                       ),
              //                     ),
              //                     Text(
              //                         'Flight TS-1',
              //                         style: tsOneTextTheme.bodyLarge
              //                     ),
              //                   ],
              //                 )
              //             ),
              //           ],
              //         )
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
