import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/assessments/new_assessment.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/data/users/users.dart';
import 'package:ts_one/di/locator.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/shared_components/airport_route_formatter.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view_model/user_viewmodel.dart';
import 'package:ts_one/util/util.dart';

class NewAssessmentCandidate extends StatefulWidget {
  const NewAssessmentCandidate({super.key, required this.newAssessment});

  final NewAssessment newAssessment;

  @override
  State<NewAssessmentCandidate> createState() => _NewAssessmentCandidateState();
}

class _NewAssessmentCandidateState extends State<NewAssessmentCandidate> {
  late NewAssessment _newAssessment;
  late UserViewModel _userViewModel;
  late List<UserModel> _usersSearched;
  late UserPreferences _userPreferences;

  late TextEditingController name1TextController;
  late TextEditingController staffNo1TextController;
  late TextEditingController licenseNo1TextController;
  late TextEditingController licenseExpiry1TextController;

  late bool _flightCrew2Enabled;
  late TextEditingController name2TextController;
  late TextEditingController staffNo2TextController;
  late TextEditingController licenseNo2TextController;
  late TextEditingController licenseExpiry2TextController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _newAssessment = widget.newAssessment;
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _usersSearched = [];
    _userPreferences = getItLocator<UserPreferences>();
    _newAssessment.idNoInstructor = _userPreferences.getIDNo();
    _newAssessment.instructorName = _userPreferences.getName();

    name1TextController = TextEditingController();
    staffNo1TextController = TextEditingController(text: _newAssessment.getIDNo1());
    licenseNo1TextController = TextEditingController();
    licenseExpiry1TextController = TextEditingController();

    if(_newAssessment.typeOfAssessment == NewAssessment.keyTypeOfAssessmentSimulator) {
      _flightCrew2Enabled = true;
    } else {
      _flightCrew2Enabled = false;
    }

    name2TextController = TextEditingController();
    staffNo2TextController = TextEditingController(text: _newAssessment.getIDNo2());
    licenseNo2TextController = TextEditingController();
    licenseExpiry2TextController = TextEditingController();

    super.initState();
  }

  String _formatText(String text) {
    const chunkSize = 3;
    final chunks = <String>[];
    for (var i = 0; i < text.length; i += chunkSize) {
      final chunk = text.substring(i, i + chunkSize);
      chunks.add(chunk);
    }
    return chunks.join('-');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Assessment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: TextFormField(
                        controller: TextEditingController(
                          text: Util.convertDateTimeDisplay(
                              _newAssessment.assessmentDate.toString(),
                              "dd MMM yyyy"),
                        ),
                        onTap: () {
                          _showSelectDatePicker(context);
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Assessment Date',
                          suffixIcon: IconButton(
                            onPressed: () {
                              _showSelectDatePicker(context);
                            },
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                        readOnly: true,
                      ),
                    ),

                    // Flight crew 1
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
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

                    // name
                    Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TypeAheadFormField<UserModel>(
                          hideSuggestionsOnKeyboardHide: false,
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: name1TextController,
                            onTap: () {
                              // clear the text field
                              name1TextController.clear();
                              staffNo1TextController.clear();
                              licenseNo1TextController.clear();
                              licenseExpiry1TextController.clear();
                              // refresh the UI
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Name',
                              suffixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.search),
                              ),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            // wait for the user finish typing
                            Future.delayed(const Duration(milliseconds: 500));
                            if(pattern.isNotEmpty) {
                              _usersSearched = await _userViewModel.getUsersBySearchName(pattern.toTitleCase(), 5);
                              return _usersSearched;
                            } else {
                              return [];
                            }
                          },
                          itemBuilder: (context, UserModel suggestion) {
                            return ListTile(
                              title: Text(suggestion.name),
                            );
                          },
                          noItemsFoundBuilder: (context) {
                            return const SizedBox(
                                height: 100,
                                child: Center(
                                  child: Text(
                                    'No users found.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                            );
                          },
                          onSuggestionSelected: (UserModel? suggestion) {
                            if (suggestion != null) {
                              _newAssessment.idNo1 = suggestion.idNo;
                              _newAssessment.licenseExpiry1 = suggestion.licenseExpiry;
                              _newAssessment.nameExaminee1 = suggestion.name;
                              _newAssessment.rankExaminee1 = suggestion.rank;
                              _newAssessment.nameExaminee1 = suggestion.name;
                              _newAssessment.licenseNo1 = suggestion.licenseNo;

                              name1TextController.text = "${suggestion.rank} ${suggestion.name}";
                              staffNo1TextController.text = suggestion.idNo.toString();
                              licenseNo1TextController.text = suggestion.licenseNo;
                              licenseExpiry1TextController.text = Util.convertDateTimeDisplay(suggestion.licenseExpiry.toString(), "dd MMM yyyy");
                              // refresh the UI
                              setState(() {});
                            }
                          },
                        )
                    ),
                    // staff no
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: staffNo1TextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Staff Number',
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select user by finding name';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (value) {
                          _newAssessment.idNo1 = int.parse(value);
                        },
                        readOnly: true,
                      ),
                    ),
                    // license no
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: licenseNo1TextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'License Number',
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select user by finding name';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (value) {
                          _newAssessment.idNo1 = int.parse(value);
                        },
                        readOnly: true,
                      ),
                    ),
                    // license expiry
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: licenseExpiry1TextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'License Expiry',
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select user by finding name';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (value) {
                          _newAssessment.idNo1 = int.parse(value);
                        },
                        readOnly: true,
                      ),
                    ),

                    _flightCrew2Enabled
                    ? Column(
                      children: [
                        // Flight crew 2
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
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

                        // flight crew 2's name
                        Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TypeAheadFormField<UserModel>(
                              hideSuggestionsOnKeyboardHide: false,
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: name2TextController,
                                onTap: () {
                                  // clear the text field
                                  name2TextController.clear();
                                  staffNo2TextController.clear();
                                  licenseNo2TextController.clear();
                                  licenseExpiry2TextController.clear();
                                  // refresh the UI
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Name',
                                  suffixIcon: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.search),
                                  ),
                                ),
                              ),
                              suggestionsCallback: (pattern) async {
                                // wait for the user finish typing
                                Future.delayed(const Duration(milliseconds: 500));
                                if(pattern.isNotEmpty) {
                                  _usersSearched = await _userViewModel.getUsersBySearchName(pattern.toTitleCase(), 5);
                                  return _usersSearched;
                                } else {
                                  return [];
                                }
                              },
                              itemBuilder: (context, UserModel suggestion) {
                                return ListTile(
                                  title: Text(suggestion.name),
                                );
                              },
                              noItemsFoundBuilder: (context) {
                                return const SizedBox(
                                    height: 100,
                                    child: Center(
                                      child: Text(
                                        'No users found.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )
                                );
                              },
                              onSuggestionSelected: (UserModel? suggestion) {
                                if (suggestion != null) {
                                  _newAssessment.idNo2 = suggestion.idNo;
                                  _newAssessment.licenseExpiry2 = suggestion.licenseExpiry;
                                  _newAssessment.rankExaminee2 = suggestion.rank;
                                  _newAssessment.nameExaminee2 = suggestion.name;
                                  _newAssessment.licenseNo2 = suggestion.licenseNo;

                                  name2TextController.text = "${suggestion.rank} ${suggestion.name}";
                                  staffNo2TextController.text = _newAssessment.idNo2.toString();
                                  licenseNo2TextController.text = suggestion.licenseNo;
                                  licenseExpiry2TextController.text = Util.convertDateTimeDisplay(suggestion.licenseExpiry.toString(), "dd MMM yyyy");
                                  // refresh the UI
                                  setState(() {});
                                }
                              },
                            )
                        ),
                        // other crew member's staff no
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextFormField(
                            controller: staffNo2TextController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Staff Number',
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select user by finding name';
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            readOnly: true,
                          ),
                        ),
                        // license no
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextFormField(
                            controller: licenseNo2TextController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'License Number',
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select user by finding name';
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            onChanged: (value) {
                              _newAssessment.idNo2 = int.parse(value);
                            },
                            readOnly: true,
                          ),
                        ),
                        // license expiry
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextFormField(
                            controller: licenseExpiry2TextController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'License Expiry',
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select user by finding name';
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            onChanged: (value) {
                              _newAssessment.idNo2 = int.parse(value);
                            },
                            readOnly: true,
                          ),
                        ),
                      ],
                    )
                    : Container(),

                    // Other
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
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
                              'Other',
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

                    // aircraft type
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Aircraft Type',
                          // suffixIcon: IconButton(
                          //   onPressed: () {},
                          //   icon: const Icon(Icons.search),
                          // ),
                        ),
                        initialValue: "A320",
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter aircraft type';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (value) {
                          _newAssessment.aircraftType = value;
                        },
                      ),
                    ),

                    // airport & route
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Airport & Route (XXX-YYY-XXX)',
                        ),
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter airport & route';
                          }
                          if (!RegExp(r'^[A-Z]{3}-[A-Z]{3}-[A-Z]{3}$').hasMatch(value)) {
                            return "Enter in the format of XXX-YYY-XXX";
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[A-Z]')),
                          LengthLimitingTextInputFormatter(9),
                          AirportRouteFormatter(),
                        ],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (value) {
                          _newAssessment.airportAndRoute = value;
                        },
                      ),
                    ),

                    // simulation hours
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        // inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$'))],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Simulation Hours (hh:mm)',
                          // suffixIcon: IconButton(
                          //   onPressed: () {},
                          //   icon: const Icon(Icons.search),
                          // ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter simulation hours';
                          }
                          if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
                            return "Enter in the format of hh:mm";
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (value) {
                          _newAssessment.simulationHours = value;
                        },
                      ),
                    ),

                    // simulation identity
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Simulation Identity',
                          // suffixIcon: IconButton(
                          //   onPressed: () {},
                          //   icon: const Icon(Icons.search),
                          // ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter simulation identity';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (value) {
                          _newAssessment.simulationIdentity = value;
                        },
                      ),
                    ),

                    // LOA
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'LOA No.',
                          // suffixIcon: IconButton(
                          //   onPressed: () {},
                          //   icon: const Icon(Icons.search),
                          // ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter LOA No.';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (value) {
                          _newAssessment.loaNo = value;
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushNamed(
                        context,
                        NamedRoute.newAssessmentFlightDetails,
                        arguments: _newAssessment,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TsOneColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 48,
                    child: const Align(
                      alignment: Alignment.center,
                      child: Text("Next",
                          style: TextStyle(color: TsOneColor.onPrimary)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSelectDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      // take only date
      initialDate: _newAssessment.assessmentDate,
      firstDate: DateTime(2006),
      lastDate: Util.getCurrentDateWithoutTime(),
      helpText: "Select assessment date",
    );
    if (picked != null && picked != _newAssessment.assessmentDate) {
      setState(() {
        _newAssessment.assessmentDate = picked;
      });
    }
  }
}
