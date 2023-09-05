import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:ts_one/app/modules/efb/fo/views/main_view_fo.dart';
import 'package:ts_one/app/modules/efb/occ/views/homeocc_view.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../data/users/users.dart';
import '../../../../../di/locator.dart';
import '../../../../../presentation/theme.dart';
import '../../../efb/occ/views/listdevice/listdevice.dart';
import '../../../efb/pilot/views/main_view_pilot.dart';
import '../../../homecc/views/homecc_view.dart';
import '../../../profilecc/views/profilecc_view.dart';



class NavOCCView extends StatefulWidget {
  const NavOCCView({super.key});

  @override
  State<NavOCCView> createState() => _NavOCCView();
}

class _NavOCCView extends State<NavOCCView> {
  int _selectedNav = 0;
  late bool _canManageDevice = false;
  late bool _pilotRequestDevice = false;
  late UserPreferences _userPreferences;
  late List<Widget> _screens;

  @override
  void initState() {
    _userPreferences = getItLocator<UserPreferences>();
    if(_userPreferences.getPrivileges().contains(UserModel.keyPrivilegeOCC)) {
      _canManageDevice = true;
      _screens = [
        HomeOCCView(),
        ListDevice(),
        HomeccView(),
        ProfileccView(),
      ];
    }
    else if (_userPreferences.getPrivileges().contains(UserModel.keyPilotRequestDevice)){
      _pilotRequestDevice = true;
      _screens = [
        HomePilotView(),
        HomePilotView(),
        ProfileccView(),
      ];
    }
    else {
      _screens = [
        HomeFOView(),
        HomeFOView(),
        ProfileccView(),
      ];
    }

    super.initState();
  }

  void _changeSelectedNav(int index) {
    setState(() {
      _selectedNav = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    int backPressTime = 0;
    return
      // WillPopScope(
      // onWillPop: () async {
      //   if (backPressTime + 300 > DateTime
      //       .now()
      //       .millisecondsSinceEpoch) {
      //     return true;
      //   }
      //   else {
      //     backPressTime = DateTime
      //         .now()
      //         .millisecondsSinceEpoch;
      //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //       content: Text(
      //         "Press back button again to exit",
      //       ),
      //     ));
      //     return false;
      //   }
      // },
      // child:
      Scaffold(
        body: IndexedStack(
          index: _selectedNav,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            if(_canManageDevice)
              const BottomNavigationBarItem(
                icon: Icon(Icons.analytics_rounded),
                label: 'Analytics',
              ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedNav,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.black,
          showUnselectedLabels: true,
          onTap: _changeSelectedNav,
        ),
      );
    // );
  }
}
