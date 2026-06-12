import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C1E34) : AppTheme.kLightCard,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.black12,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: GNav(
              gap: 8,
              activeColor: isDark
                  ? const Color(0xFF0A1828)
                  : AppTheme.kLightText,
              color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              duration: const Duration(milliseconds: 350),
              tabBackgroundColor: AppTheme.kAccent, // Keep accent color same
              selectedIndex: selectedIndex,
              onTabChange: onTabChange,
              tabs: [
                GButton(icon: Icons.dashboard_rounded, text: 'Dashboard'),
                GButton(icon: Icons.monitor_rounded, text: 'Monitor'),
                GButton(icon: Icons.grading_rounded, text: 'Resource'),
                GButton(icon: Icons.person_rounded, text: 'User'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
