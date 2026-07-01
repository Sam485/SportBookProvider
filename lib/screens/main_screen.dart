import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/DashBoard/dash_board_screen.dart';
import 'package:flutter_application_1/screens/monitor/monitor_screen.dart';
import 'package:flutter_application_1/screens/resource/resource_screen.dart';
import 'package:flutter_application_1/screens/settings/settings_screen.dart';
import '../widgets/navbar/bottom_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  static const _screens = [
    DashBoardScreen(),
    MonitorScreen(),
    ResourceScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _index,
        onTabChange: (i) => setState(() => _index = i),
      ),
    );
  }
}
