import 'package:flutter/material.dart';
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
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: onTabChange,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.kAccent,
            unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            items: [
              _buildNavItem(
                icon: Icons.dashboard,
                label: 'dashboard'.tr(context),
              ),
              _buildNavItem(icon: Icons.monitor, label: 'monitor'.tr(context)),
              _buildNavItem(
                icon: Icons.list_alt,
                label: 'resource'.tr(context),
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'profile'.tr(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
  }) {
    return BottomNavigationBarItem(icon: Icon(icon, size: 24), label: label);
  }
}
