import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/di/locator.dart';
import 'package:ts_one/presentation/routes.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view_model/user_viewmodel.dart';

import '../../../data/users/users.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late UserViewModel viewModel;
  String email = "";
  String password = "";
  UserPreferences userPreferences = getItLocator<UserPreferences>();

  @override
  void initState() {
    viewModel = Provider.of<UserViewModel>(context, listen: false);
    super.initState();
  }

  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (_, model, child) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Image(
                    image: AssetImage('assets/images/airasia_logo_circle.png'),
                    width: 200,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Welcome Back',
                      style: tsOneTextTheme.displayMedium,
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
                  //   child: TextField(
                  //     onChanged: (value) {
                  //       email = value;
                  //     },
                  //     decoration: const InputDecoration(
                  //       border: OutlineInputBorder(),
                  //       labelText: 'Email',
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       left: 16.0, right: 16.0, bottom: 16.0),
                  //   child: TextField(
                  //     onChanged: (value) {
                  //       password = value;
                  //     },
                  //     decoration: InputDecoration(
                  //         border: const OutlineInputBorder(),
                  //         labelText: 'Password',
                  //         suffixIcon: IconButton(
                  //           icon: _hidePassword
                  //               ? const Icon(Icons.visibility_off)
                  //               : const Icon(Icons.visibility),
                  //           onPressed: () {
                  //             setState(() {
                  //               _hidePassword = !_hidePassword;
                  //             });
                  //           },
                  //         )),
                  //     obscureText: _hidePassword,
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       left: 16.0, right: 16.0, bottom: 8.0),
                  //   child: ElevatedButton(
                  //     onPressed: () async {
                  //       UserAuth userAuth =
                  //           await viewModel.login(email, password);
                  //
                  //       if (!mounted) return;
                  //
                  //       if (userAuth.userCredential != null &&
                  //           userAuth.userModel != null) {
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           SnackBar(
                  //             content: Text(
                  //                 "Welcome, ${userPreferences.getRank()} ${userPreferences.getName()}"),
                  //             duration: const Duration(milliseconds: 3000),
                  //             action: SnackBarAction(
                  //               label: 'Close',
                  //               onPressed: () {
                  //                 ScaffoldMessenger.of(context)
                  //                     .hideCurrentSnackBar();
                  //               },
                  //             ),
                  //           ),
                  //         );
                  //
                  //         await viewModel.getPDFTemplate();
                  //
                  //         if (!mounted) return;
                  //
                  //         Navigator.pushNamedAndRemoveUntil(
                  //             context, NamedRoute.home, (route) => false);
                  //       }
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: tsOneColorScheme.secondary,
                  //       foregroundColor: tsOneColorScheme.secondaryContainer,
                  //       surfaceTintColor: tsOneColorScheme.secondary,
                  //       minimumSize: const Size.fromHeight(40),
                  //     ),
                  //     child: const Text('Login',
                  //         style: TextStyle(color: Colors.black)),
                  //   ),
                  // ),
                  // divider with text saying "or" in the middle
                  // const Padding(
                  //   padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  //   child: Row(
                  //     children: <Widget>[
                  //       Expanded(
                  //         child: Divider(
                  //           color: Colors.grey,
                  //           height: 36,
                  //         ),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: 8.0),
                  //         child: Text(
                  //           'or',
                  //           style: TextStyle(color: Colors.grey),
                  //         ),
                  //       ),
                  //       Expanded(
                  //         child: Divider(
                  //           color: Colors.grey,
                  //           height: 36,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // or sign in with Google
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 16.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          UserAuth userAuth = await viewModel.loginWithGoogle();

                          if (!mounted) return;

                          if (userAuth.userCredential != null &&
                              userAuth.userModel != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Welcome, ${userPreferences.getRank()} ${userPreferences.getName()}"),
                                duration: const Duration(milliseconds: 3000),
                                action: SnackBarAction(
                                  label: 'Close',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                  },
                                ),
                              ),
                            );

                            await viewModel.getPDFTemplate();

                            if (!mounted) return;

                            Navigator.pushNamedAndRemoveUntil(
                                context, NamedRoute.home, (route) => false);
                          } else {
                            log("Error: ${userAuth.errorMessage}");
                            Fluttertoast.showToast(msg: "Error: ${userAuth.errorMessage}");
                            SnackBar(
                              content: Text(
                                  "Error: ${userAuth.errorMessage}"),
                              duration: const Duration(milliseconds: 3000),
                              action: SnackBarAction(
                                label: 'Close',
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tsOneColorScheme.secondary,
                          foregroundColor: tsOneColorScheme.secondaryContainer,
                          surfaceTintColor: tsOneColorScheme.secondary,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              image:
                                  AssetImage('assets/images/google_logo.png'),
                              width: 24,
                            ),
                            SizedBox(width: 8),
                            Text('Sign in with Google',
                                style: TextStyle(color: Colors.black)),
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: SizedBox(
                      height: 2,
                      child: model.isLoading
                          ? const LinearProgressIndicator()
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
