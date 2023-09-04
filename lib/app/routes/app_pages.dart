import 'package:get/get.dart';

import '../../presentation/main_view.dart';
import '../../presentation/view/users/login.dart';
import '../modules/homecc/bindings/homecc_binding.dart';
import '../modules/homecc/views/homecc_view.dart';
import '../modules/main_home/bindings/main_home_binding.dart';
import '../modules/main_home/views/main_home_view.dart';
import '../modules/pa/navadmin/bindings/navadmin_binding.dart';
import '../modules/pa/navadmin/views/navadmin_view.dart';
import '../modules/profilecc/bindings/profilecc_binding.dart';
import '../modules/profilecc/views/profilecc_view.dart';

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
  ];
}
