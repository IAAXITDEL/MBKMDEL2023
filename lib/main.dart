import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ts_one/app/modules/main_home/controllers/main_home_controller.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/di/locator.dart';
import 'package:ts_one/domain/assessment_repo.dart';
import 'package:ts_one/domain/assessment_results_repo.dart';
import 'package:ts_one/domain/user_repo.dart';
import 'package:ts_one/presentation/theme.dart';
import 'package:ts_one/presentation/view/splash_screen.dart';
import 'package:ts_one/presentation/view_model/assessment_results_viewmodel.dart';
import 'package:ts_one/presentation/view_model/assessment_viewmodel.dart';
import 'package:ts_one/presentation/view_model/user_viewmodel.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';

import 'app/modules/cc/home_cptscc/views/home_cptscc_view.dart';
import 'app/routes/app_pages.dart';

void main() async {
  // ensure that all the widgets are loaded before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // register all the dependencies with GetIt
  setupLocator();


  runApp(
    MaterialApp(
      home: HomeCptsccView(), // Halaman awal aplikasi
    ),
  );

  try {
    // initialize firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // wait for the preferences and other async dependencies to be ready before starting the app
    await getItLocator.allReady().then((value) => "All dependencies are ready");
  } catch (e) {
    log("Something went wrong during initialization");
    log("This is the exception: $e");
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(
        0xFFFDFDFD), // the same as the app's background color in tsOneColorScheme.background
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => UserViewModel(
            repo: getItLocator<UserRepo>(),
            userPreferences: getItLocator<UserPreferences>()),
      ),
      ChangeNotifierProvider(
        create: (_) => AssessmentViewModel(
          repo: getItLocator<AssessmentRepo>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => AssessmentResultsViewModel(
          repo: getItLocator<AssessmentResultsRepo>(),
        ),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: tsOneThemeData,
    //   onGenerateRoute: AppRoutes.generateRoute,
    //   home: const SplashScreenView(title: 'TS1 AirAsia'),
    //   debugShowCheckedModeBanner: false,
    // );

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 0, 0, 0, 0);
    final duration = tomorrow.difference(now);

    // Menjadwalkan eksekusi fungsi cekValidityStream pada pukul 12:00 AM setiap hari
    Timer(duration, () {
      // Memanggil fungsi cekValidityStream
      Get.find<MainHomeController>().cekValidityStream().listen((data) {
        // Lakukan apa pun yang perlu Anda lakukan dengan data
        print('cekValidityStream executed.');
        print('Data: $data');
      });
    });

    return GetMaterialApp(
      title: "Air Asia",
      theme: tsOneThemeData,
      home: const SplashScreenView(title: 'TS1 AirAsia'),
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
