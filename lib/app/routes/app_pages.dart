import 'package:get/get.dart';
import 'package:ts_one/app/modules/efb/occ/bindings/device_binding.dart';
import 'package:ts_one/app/modules/pa/occ/bindings/navocc_binding.dart';

import '../../presentation/main_view.dart';
import '../../presentation/view/users/login.dart';
import '../modules/efb/fo/bindings/homefo_binding.dart';
import '../modules/efb/fo/views/main_view_fo.dart';
import '../modules/efb/occ/views/listdevice/listdevice.dart';
import '../modules/efb/pilot/bindings/homepilot_binding.dart';
import '../modules/efb/pilot/views/main_view_pilot.dart';
import '../modules/homecc/bindings/homecc_binding.dart';
import '../modules/homecc/views/homecc_view.dart';
import '../modules/main_home/bindings/main_home_binding.dart';
import '../modules/main_home/views/main_home_view.dart';
import '../modules/pa/navadmin/bindings/navadmin_binding.dart';
import '../modules/pa/navadmin/views/navadmin_view.dart';
import '../modules/profilecc/bindings/profilecc_binding.dart';
import '../modules/profilecc/views/profilecc_view.dart';

import '../modules/pa/occ/views/navocc_view.dart';
import '../modules/efb/occ/bindings/homeocc_binding.dart';
import '../modules/efb/occ/views/homeocc_view.dart';


part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAIN_HOME;

  static final routes = [
    GetPage(
      name: _Paths.MAIN_HOME,
      page: () => const MainHomeView(),
      binding: MainHomeBinding(),
    ),
    GetPage(
      name: _Paths.home,
      page: () => const MainView(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: _Paths.NAVADMIN,
      page: () => NavadminView(initialIndex: 0,),
      binding: NavadminBinding(),
    ),
    GetPage(
      name: _Paths.HOMECC,
      page: () => const HomeccView(),
      binding: HomeccBinding(),
    ),
    GetPage(
      name: _Paths.PROFILECC,
      page: () => const ProfileccView(),
      binding: ProfileccBinding(),
    ),



    //EFB -------------------------------------------------
    GetPage(
      name: _Paths.NAVOCC,
      page: () => NavOCCView(),
      binding: NavOCCBinding(),
    ),
    GetPage(
      name: _Paths.HOMEOCC,
      page: () => const HomeOCCView(),
      binding: HomeOCCBinding(),
    ),
    GetPage(
      name: _Paths.LISTDEVICEOCC,
      page: () => ListDevice(),
      binding: DeviceBinding(),
    ),




    //Pilot EFB
    GetPage(
      name: _Paths.HOMEPILOT,
      page: () => const HomePilotView(),
      binding: HomePilotBinding(),
    ),


    //FO EFB
    GetPage(
      name: _Paths.HOMEFO,
      page: () => const HomeFOView(),
      binding: HomeFOBinding(),
    ),
  ];
}
