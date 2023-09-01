import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/di/locator.dart';
import 'package:ts_one/presentation/routes.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key, required this.title});

  final String title;

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  bool isLogin = false;
  UserPreferences userPreferences = getItLocator<UserPreferences>();

  @override
  void initState() {
    super.initState();
    isLogin = userPreferences.isLogin();
    return checkLogin();
  }

  void checkLogin() {
    var duration = const Duration(milliseconds: 1500);
    Timer(duration, () {
      if (!isLogin) {
        Navigator.pushNamedAndRemoveUntil(
            context, NamedRoute.login, (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, NamedRoute.home, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      /*
      appBar: AppBar(
        backgroundColor: tsOneColorScheme.secondary,
        // title: Text(widget.title),
      ),
       */
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/images/airasia_logo_circle.png'),
              width: 300,
            ),
          ],
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Something',
        child: const Icon(Icons.add),
      ),
       */
    );
  }
}
