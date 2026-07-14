import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/translations/app_translations.dart';
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
          child: CurvedNavigationBar(
            index: selectedIndex,
            onTap: onTabChange,
            height: 60,
            backgroundColor: Colors.transparent,
            color: AppTheme.kAccent,
            buttonBackgroundColor: AppTheme.kAccent,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 350),
            items: <Widget>[
              _buildNavItem(
                icon: Icons.dashboard,
                label: 'dashboard'.tr(context),
                isActive: selectedIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.monitor,
                label: 'monitor'.tr(context),
                isActive: selectedIndex == 1,
              ),
              _buildNavItem(
                icon: Icons.list_alt,
                label: 'resource'.tr(context),
                isActive: selectedIndex == 2,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'profile'.tr(context),
                isActive: selectedIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: Colors.black),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.black,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
