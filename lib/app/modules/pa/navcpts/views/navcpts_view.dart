import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:ts_one/app/modules/cc/home_cptscc/views/home_cptscc_view.dart';
import 'package:ts_one/presentation/theme.dart';

import '../../../cc/list_pilotcptscc/views/list_pilotcptscc_view.dart';
import '../../../cc/profilecc/views/profilecc_view.dart';
import '../../../cc/training_cptscc/views/training_cptscc_view.dart';
import '../../../cc/trainingcc/views/trainingcc_view.dart';

class NavcptsView extends StatefulWidget {
  final int initialIndex;
  const NavcptsView({Key? key, required this.initialIndex}) : super(key: key);

  @override
  State<NavcptsView> createState() => _NavcptsState();
}

class _NavcptsState extends State<NavcptsView> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: widget.initialIndex);
  }

  List<Widget> _buildScreens() {
    return [
      HomeCptsccView(),
      const TrainingccView(),
      const TrainingCptsccView(),
      const ListPilotcptsccView(),
      ProfileccView(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.house_alt),
        activeColorPrimary: tsOneColorScheme.primary,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.square_list),
        activeColorPrimary: tsOneColorScheme.primary,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.square_list),
        activeColorPrimary: tsOneColorScheme.primary,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.person_2),
        activeColorPrimary: tsOneColorScheme.primary,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.profile_circled),
        activeColorPrimary: tsOneColorScheme.primary,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle:
      NavBarStyle.style14,
    );
  }
}
