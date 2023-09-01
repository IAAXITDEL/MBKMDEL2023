import 'package:flutter/material.dart';
import 'package:ts_one/data/users/user_preferences.dart';
import 'package:ts_one/data/users/users.dart';
import 'package:ts_one/di/locator.dart';
import 'package:ts_one/presentation/view/analytics/analytics_screen.dart';

import 'view/history/history_screen.dart';
import 'view/home/home_screen.dart';
import 'view/profile/profile_screen.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedNav = 0;
  late bool _canViewAllAssessments;
  late UserPreferences _userPreferences;
  late List<Widget> _screens;

  @override
  void initState() {
    _userPreferences = getItLocator<UserPreferences>();

    if(_userPreferences.getPrivileges().contains(UserModel.keyPrivilegeViewAllAssessments)) {
      _canViewAllAssessments = true;
      _screens = [
        const HomeScreen(),
        const HistoryScreen(),
        const AnalyticsScreen(),
        const ProfileScreen()
      ];
    }
    else {
      _canViewAllAssessments = false;
      _screens = [
        const HomeScreen(),
        const HistoryScreen(),
        const ProfileScreen()
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
    return WillPopScope(
      onWillPop: () async {
        if (backPressTime + 300 > DateTime
            .now()
            .millisecondsSinceEpoch) {
          return true;
        } else {
          backPressTime = DateTime
              .now()
              .millisecondsSinceEpoch;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Press back button again to exit",
            ),
          ));
          return false;
        }
      },
      child: Scaffold(
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
            if(_canViewAllAssessments)
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
      ),
    );
  }
}
