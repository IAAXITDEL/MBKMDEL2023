import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/users/users.dart';
import 'package:ts_one/presentation/view_model/user_viewmodel.dart';
import 'package:ts_one/util/util.dart';

/// THIS FILE IS DEPRECATED.
/// UPDATE THIS FILE IF YOU ARE GOING TO USE IT.

class UpdateUserView extends StatefulWidget {
  const UpdateUserView ({Key? key, required this.userEmail}) : super(key: key);

  final String userEmail;

  @override
  State<UpdateUserView > createState() => _UpdateUserViewState();
}

class _UpdateUserViewState extends State<UpdateUserView> {
  late UserViewModel viewModel;
  late UserModel userModel;
  late UserModel userModelUpdated;
  late String userEmail;
  final _formKey = GlobalKey<FormState>();
  late Map<String, bool> checkedAndEnabled;

  @override
  void initState() {
    viewModel = Provider.of<UserViewModel>(context, listen: false);
    userModel = UserModel();
    userModelUpdated = UserModel();
    userEmail = widget.userEmail;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserByEmail();
    });

    super.initState();
  }

  getUserByEmail() async {
    userModel = await viewModel.getUserByIDNo(userEmail);
    setState(() {
      // Set the default values for the checkboxes
      checkedAndEnabled = {
        UserModel.keyCPTS: false,
        UserModel.keySubPositionCCP: false,
        UserModel.keySubPositionPGI: false,
        UserModel.keySubPositionFIA: false,
        UserModel.keySubPositionFIS: false,
        UserModel.keySubPositionREG: false,
        UserModel.keySubPositionTRG: false,
        UserModel.keySubPositionUT: false,
        "enabled_${UserModel.keyCPTS}": true,
        "enabled_${UserModel.keySubPositionCCP}": true,
        "enabled_${UserModel.keySubPositionPGI}": true,
        "enabled_${UserModel.keySubPositionFIA}": true,
        "enabled_${UserModel.keySubPositionFIS}": true,
        "enabled_${UserModel.keySubPositionREG}": true,
        "enabled_${UserModel.keySubPositionTRG}": true,
        "enabled_${UserModel.keySubPositionUT}": true,
      };

      if (userModel.instructor.contains(UserModel.keyCPTS)) {
        checkedAndEnabled[UserModel.keyCPTS] = true;

        // disable REG, TRG, UT
        checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;
      }
      if (userModel.instructor.contains(UserModel.keySubPositionCCP)) {
        checkedAndEnabled[UserModel.keySubPositionCCP] = true;

        // disable REG, TRG, UT
        checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;
      }
      if (userModel.instructor.contains(UserModel.keySubPositionPGI)) {
        checkedAndEnabled[UserModel.keySubPositionPGI] = true;

        // disable REG, TRG, UT
        checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;
      }
      if (userModel.instructor.contains(UserModel.keySubPositionFIA)) {
        checkedAndEnabled[UserModel.keySubPositionFIA] = true;

        // disable REG, TRG, UT
        checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;
      }
      if (userModel.instructor.contains(UserModel.keySubPositionFIS)) {
        checkedAndEnabled[UserModel.keySubPositionFIS] = true;

        // disable REG, TRG, UT
        checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;
      }
      if (userModel.instructor.contains(UserModel.keySubPositionREG)) {
        checkedAndEnabled[UserModel.keySubPositionREG] = true;

        // disable CPTS, CCP, PGI, FIA, FIS, TRG, UT
        checkedAndEnabled["enabled_${UserModel.keyCPTS}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionCCP}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionPGI}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionFIA}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionFIS}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;
      }
      if (userModel.instructor.contains(UserModel.keySubPositionTRG)) {
        checkedAndEnabled[UserModel.keySubPositionTRG] = true;

        // disable CPTS, CCP, PGI, FIA, FIS, REG, UT
        checkedAndEnabled["enabled_${UserModel.keyCPTS}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionCCP}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionPGI}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionFIA}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionFIS}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;
      }
      if (userModel.instructor.contains(UserModel.keySubPositionUT)) {
        checkedAndEnabled[UserModel.keySubPositionUT] = true;

        // disable CPTS, CCP, PGI, FIA, FIS, REG, TRG
        checkedAndEnabled["enabled_${UserModel.keyCPTS}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionCCP}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionPGI}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionFIA}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionFIS}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
        checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
      }
    });
  }

  void _selectDateLicenseExpiry(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: userModel.licenseExpiry,
      firstDate: DateTime(2006),
      lastDate: DateTime(2099),
      helpText: "Select license expiry date",
    );
    if (picked != null && picked != userModel.licenseExpiry) {
      setState(() {
        userModel.licenseExpiry = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(builder: (_, model, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Update User"),
        ),
        body: userModel.name == Util.defaultStringIfNull
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              child: Form(
          key: _formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                    ),
                    textInputAction: TextInputAction.next,
                    initialValue: userModel.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      userModel.name = value;
                    },
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Staff No',
                    ),
                    textInputAction: TextInputAction.next,
                    initialValue: userModel.idNo.toString(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter staff number';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      userModel.idNo = int.parse(value);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Position',
                    ),
                    value: userModel.rank,
                    validator: (value) {
                      if (value == null) {
                        return "Position is required";
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    // value: userModel.position,
                    onChanged: (value) {
                      userModel.rank = value!;
                    },
                    items: [
                      DropdownMenuItem(
                        value: UserModel.keyPositionCaptain,
                        child: Text(UserModel.keyPositionCaptain),
                      ),
                      DropdownMenuItem(
                        value: UserModel.keyPositionFirstOfficer,
                        child: Text(UserModel.keyPositionFirstOfficer),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Sub Position"),
                        CheckboxListTile(
                          title: Text(UserModel.keyCPTS),
                          enabled: checkedAndEnabled["enabled_${UserModel.keyCPTS}"]!,
                          value: checkedAndEnabled[UserModel.keyCPTS],
                          onChanged: (value) {
                            setState(() {
                              checkedAndEnabled[UserModel.keyCPTS] = value!;
                              if (checkedAndEnabled[UserModel.keyCPTS]!) {
                                // disable REG, TRG, UT
                                checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;

                                userModel.instructor.add(UserModel.keyCPTS);
                              } else {
                                userModel.instructor.remove(UserModel.keyCPTS);

                                // if no other subPosition is selected, enable REG, TRG, UT
                                if (!userModel.instructor.contains(UserModel.keyCPTS) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionCCP) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionPGI) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionFIA) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionFIS)) {
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = true;
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = true;
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = true;
                                }
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(UserModel.keySubPositionCCP),
                          enabled: checkedAndEnabled["enabled_${UserModel.keySubPositionCCP}"]!,
                          value: checkedAndEnabled[UserModel.keySubPositionCCP],
                          onChanged: (value) {
                            setState(() {
                              checkedAndEnabled[UserModel.keySubPositionCCP] = value!;
                              if (checkedAndEnabled[UserModel.keySubPositionCCP]!) {
                                // disable REG, TRG, UT
                                checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;

                                userModel.instructor.add(UserModel.keySubPositionCCP);
                              } else {
                                userModel.instructor.remove(UserModel.keySubPositionCCP);

                                // if no other subPosition is selected, enable REG, TRG, UT
                                if (!userModel.instructor.contains(UserModel.keyCPTS) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionCCP) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionPGI) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionFIA) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionFIS)) {
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = true;
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = true;
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = true;
                                }
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(UserModel.keySubPositionPGI),
                          enabled: checkedAndEnabled["enabled_${UserModel.keySubPositionPGI}"]!,
                          value: checkedAndEnabled[UserModel.keySubPositionPGI],
                          onChanged: (value) {
                            setState(() {
                              checkedAndEnabled[UserModel.keySubPositionPGI] = value!;
                              if (checkedAndEnabled[UserModel.keySubPositionPGI]!) {
                                // disable REG, TRG, UT
                                checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;

                                userModel.instructor.add(UserModel.keySubPositionPGI);
                              } else {
                                userModel.instructor.remove(UserModel.keySubPositionPGI);

                                // if no other subPosition is selected, enable REG, TRG, UT
                                if (!userModel.instructor.contains(UserModel.keyCPTS) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionCCP) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionPGI) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionFIA) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionFIS)) {
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = true;
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = true;
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = true;
                                }
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(UserModel.keySubPositionFIA),
                          enabled: checkedAndEnabled["enabled_${UserModel.keySubPositionFIA}"]!,
                          value: checkedAndEnabled[UserModel.keySubPositionFIA],
                          onChanged: (value) {
                            setState(() {
                              checkedAndEnabled[UserModel.keySubPositionFIA] = value!;
                              if (checkedAndEnabled[UserModel.keySubPositionFIA]!) {
                                // disable REG, TRG, UT
                                checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;

                                userModel.instructor.add(UserModel.keySubPositionFIA);
                              } else {
                                userModel.instructor.remove(UserModel.keySubPositionFIA);

                                // if no other subPosition is selected, enable REG, TRG, UT
                                if (!userModel.instructor.contains(UserModel.keyCPTS) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionCCP) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionPGI) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionFIA) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionFIS)) {
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = true;
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = true;
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = true;
                                }
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(UserModel.keySubPositionFIS),
                          enabled: checkedAndEnabled["enabled_${UserModel.keySubPositionFIS}"]!,
                          value: checkedAndEnabled[UserModel.keySubPositionFIS],
                          onChanged: (value) {
                            setState(() {
                              checkedAndEnabled[UserModel.keySubPositionFIS] = value!;
                              if (checkedAndEnabled[UserModel.keySubPositionFIS]!) {
                                // disable REG, TRG, UT
                                checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;

                                userModel.instructor.add(UserModel.keySubPositionFIS);
                              } else {
                                userModel.instructor.remove(UserModel.keySubPositionFIS);

                                // if no other subPosition is selected, enable REG, TRG, UT
                                if (!userModel.instructor.contains(UserModel.keyCPTS) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionCCP) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionPGI) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionFIA) &&
                                    !userModel.instructor.contains(UserModel.keySubPositionFIS)) {
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = true;
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = true;
                                  checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = true;
                                }
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(UserModel.keySubPositionREG),
                          enabled: checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"]!,
                          value: checkedAndEnabled[UserModel.keySubPositionREG],
                          onChanged: (value) {
                            setState(() {
                              checkedAndEnabled[UserModel.keySubPositionREG] = value!;
                              if (checkedAndEnabled[UserModel.keySubPositionREG]!) {
                                // disable all other sub position
                                checkedAndEnabled["enabled_${UserModel.keyCPTS}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionCCP}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionPGI}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIA}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIS}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;

                                // uncheck all other sub position
                                checkedAndEnabled[UserModel.keyCPTS] = false;
                                checkedAndEnabled[UserModel.keySubPositionCCP] = false;
                                checkedAndEnabled[UserModel.keySubPositionPGI] = false;
                                checkedAndEnabled[UserModel.keySubPositionFIA] = false;
                                checkedAndEnabled[UserModel.keySubPositionFIS] = false;
                                checkedAndEnabled[UserModel.keySubPositionTRG] = false;
                                checkedAndEnabled[UserModel.keySubPositionUT] = false;

                                // clear all sub position
                                userModel.instructor.clear();

                                // add REG sub position
                                userModel.instructor.add(UserModel.keySubPositionREG);
                              } else {
                                userModel.instructor.remove(UserModel.keySubPositionREG);

                                // enable all other sub position
                                checkedAndEnabled["enabled_${UserModel.keyCPTS}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionCCP}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionPGI}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIA}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIS}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = true;
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(UserModel.keySubPositionTRG),
                          enabled: checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"]!,
                          value: checkedAndEnabled[UserModel.keySubPositionTRG],
                          onChanged: (value) {
                            setState(() {
                              checkedAndEnabled[UserModel.keySubPositionTRG] = value!;
                              if (checkedAndEnabled[UserModel.keySubPositionTRG]!) {
                                // disable all other sub position
                                checkedAndEnabled["enabled_${UserModel.keyCPTS}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionCCP}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionPGI}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIA}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIS}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = false;

                                // uncheck all other sub position
                                checkedAndEnabled[UserModel.keyCPTS] = false;
                                checkedAndEnabled[UserModel.keySubPositionCCP] = false;
                                checkedAndEnabled[UserModel.keySubPositionPGI] = false;
                                checkedAndEnabled[UserModel.keySubPositionFIA] = false;
                                checkedAndEnabled[UserModel.keySubPositionFIS] = false;
                                checkedAndEnabled[UserModel.keySubPositionREG] = false;
                                checkedAndEnabled[UserModel.keySubPositionUT] = false;

                                // clear all sub position
                                userModel.instructor.clear();

                                // add TRG sub position
                                userModel.instructor.add(UserModel.keySubPositionTRG);
                              } else {
                                userModel.instructor.remove(UserModel.keySubPositionTRG);

                                // enable all other sub position
                                checkedAndEnabled["enabled_${UserModel.keyCPTS}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionCCP}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionPGI}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIA}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIS}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"] = true;
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(UserModel.keySubPositionUT),
                          enabled: checkedAndEnabled["enabled_${UserModel.keySubPositionUT}"]!,
                          value: checkedAndEnabled[UserModel.keySubPositionUT],
                          onChanged: (value) {
                            setState(() {
                              checkedAndEnabled[UserModel.keySubPositionUT] = value!;
                              if (checkedAndEnabled[UserModel.keySubPositionUT]!) {
                                // disable all other sub position
                                checkedAndEnabled["enabled_${UserModel.keyCPTS}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionCCP}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionPGI}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIA}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIS}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = false;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = false;

                                // uncheck all other sub position
                                checkedAndEnabled[UserModel.keyCPTS] = false;
                                checkedAndEnabled[UserModel.keySubPositionCCP] = false;
                                checkedAndEnabled[UserModel.keySubPositionPGI] = false;
                                checkedAndEnabled[UserModel.keySubPositionFIA] = false;
                                checkedAndEnabled[UserModel.keySubPositionFIS] = false;
                                checkedAndEnabled[UserModel.keySubPositionREG] = false;
                                checkedAndEnabled[UserModel.keySubPositionTRG] = false;

                                // clear all sub position
                                userModel.instructor.clear();

                                // add UT sub position
                                userModel.instructor.add(UserModel.keySubPositionUT);
                              } else {
                                // remove sub position
                                userModel.instructor.remove(UserModel.keySubPositionUT);

                                // enable all other sub position
                                checkedAndEnabled["enabled_${UserModel.keyCPTS}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionCCP}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionPGI}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIA}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionFIS}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionREG}"] = true;
                                checkedAndEnabled["enabled_${UserModel.keySubPositionTRG}"] = true;
                              }
                            });
                          },
                        ),
                      ],
                    )
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'License No',
                    ),
                    textInputAction: TextInputAction.next,
                    initialValue: userModel.licenseNo,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter license number';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      userModel.licenseNo = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onTap: () {
                            _selectDateLicenseExpiry(context);
                            FocusScope.of(context).unfocus();
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'License Expiry',
                          ),
                          controller: TextEditingController(
                            text: Util.convertDateTimeDisplay(userModel.licenseExpiry.toString()),
                          ),
                          readOnly: true,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _selectDateLicenseExpiry(context);
                          FocusScope.of(context).unfocus();
                        },
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                ),
                /*
                Padding(
                  padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      else if(!EmailValidator.validate(value)) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    initialValue: userModel.email,
                    onChanged: (value) {
                      userModel.email = value;
                    },
                  ),
                ),
                */
                Padding(
                  padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        userModelUpdated = await viewModel.updateUser(userEmail, userModel);
                        if(!mounted) return;

                        if(userModelUpdated.name != Util.defaultStringIfNull){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("User updated successfully"),
                              duration: const Duration(milliseconds: 1000),
                              action: SnackBarAction(
                                label: 'Close',
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("User update failed"),
                              duration: const Duration(milliseconds: 1000),
                              action: SnackBarAction(
                                label: 'Close',
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                    child: const Text('Update User'),
                  ),
                ),
              ],
          ),
        ),
            ),
      );
    });
  }
}