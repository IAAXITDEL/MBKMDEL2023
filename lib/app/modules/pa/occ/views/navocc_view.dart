import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ts_one/app/modules/efb/fo/views/main_view_fo.dart';
import 'package:ts_one/app/modules/efb/occ/views/homeocc_view.dart';

import '../../../../../data/users/user_preferences.dart';
import '../../../../../data/users/users.dart';
import '../../../../../di/locator.dart';
import '../../../../../presentation/theme.dart';
import '../../../efb/history_crew/for_crew_history.dart';
import '../../../efb/occ/views/history/history_all_device_view.dart';
import '../../../efb/occ/views/listdevice/listdevice.dart';
import '../../../efb/pilot/views/main_view_pilot.dart';
import '../../../efb/profile/views/profile_view.dart';
import '../../../homecc/views/homecc_view.dart';
import '../../../profilecc/views/profilecc_view.dart';
import '../../../efb/analytics/views/analytics_view.dart';
// import '../../../efb/device/views/device_view.dart';

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
    if (_userPreferences.getPrivileges().contains(UserModel.keyPrivilegeOCC)) {
      _canManageDevice = true;
      _screens = [
        HomeOCCView(),
        ListDevice(),
        // DevicesView(),
        HistoryAllDeviceView(),
        AnalyticsView(),
        ProfileView(),
      ];
    } else if (_userPreferences.getPrivileges().contains(UserModel.keyPilotRequestDevice)) {
      _pilotRequestDevice = true;
      _screens = [
        HomePilotView(),
        HistoryEachCrewView(),
        ProfileView(),
      ];
    } else {
      _screens = [
        HomeFOView(),
        HistoryEachCrewView(),
        ProfileView(),
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
    return Scaffold(
      body: IndexedStack(
        index: _selectedNav,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: _canManageDevice ? const EdgeInsets.symmetric(horizontal: 1.0) : const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
          ],
        ),
        child: GNav(
          rippleColor: CupertinoColors.systemGrey,
          hoverColor: tsOneColorScheme.primary,
          tabBorderRadius: 15,
          haptic: true,
          gap: 8,
          activeColor: Colors.white,
          iconSize: 24,
          //padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          padding: _canManageDevice
              ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
              : const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          duration: const Duration(milliseconds: 200),
          tabBackgroundColor: tsOneColorScheme.primary,
          selectedIndex: _selectedNav,
          onTabChange: _changeSelectedNav,
          tabs: [
            const GButton(
              icon: Icons.home_filled,
              text: 'Home',
            ),
            // const GButton(
            //   icon: Icons.list_alt_rounded,
            //   text: 'Device',
            // ),
            const GButton(
              icon: Icons.list_alt_rounded,
              text: 'Device',
            ),
            if (_canManageDevice)
              GButton(
                icon: Icons.history_toggle_off_outlined,
                text: 'History',
              ),
            if (_canManageDevice)
              const GButton(
                icon: Icons.analytics_outlined,
                text: 'Analytics',
              ),
            const GButton(
              icon: Icons.person_outline_outlined,
              text: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}