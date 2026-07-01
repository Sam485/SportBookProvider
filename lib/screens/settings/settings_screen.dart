import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<FeaturesData> accountData = [
    FeaturesData(
      icon: Icons.person,
      title: 'Personal Info',
      des: 'Name, email, phone',
      color: Colors.blue,
      route: AppRoutes.personalInfo,
    ),
    FeaturesData(
      icon: Icons.payment,
      title: 'Payout & Banking',
      des: 'ABA *****4251',
      color: Colors.green,
      route: AppRoutes.payment,
    ),
    FeaturesData(
      icon: Icons.notifications_outlined,
      title: 'Notifications',
      des: 'Booking alerts & reminders',
      color: Colors.amber,
      label: '3 new',
      route: AppRoutes.notifications,
    ),
    FeaturesData(
      icon: Icons.security_outlined,
      title: 'Password & Security',
      des: 'Last changed 2 month ago',
      color: Colors.blue,
      route: AppRoutes.passAndSecurity,
    ),
  ];

  List<FeaturesData> venueData = [
    FeaturesData(
      icon: Icons.work_outline,
      title: 'Operating Hours',
      des: '6:00 AM - 10:00 PM',
      color: Colors.blue,
      route: AppRoutes.operatingHours,
    ),
    FeaturesData(
      icon: Icons.location_city_outlined,
      title: 'Venue Photos',
      des: '14 photos uploaded',
      color: Colors.amber,
      route: AppRoutes.editVenueProfile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTheme.tsTitleAdaptive(context)),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to settings
              Navigator.pushNamed(context, AppRoutes.setting);
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: _buildButtonSection('Account', accountData),
            ),
            SliverToBoxAdapter(child: _buildButtonSection('Venue', venueData)),
            SliverToBoxAdapter(child: _buildButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: AppTheme.cardDecorationAdaptive(context),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.kAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('SL', style: TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SportMate Arena',
                        style: AppTheme.tsLabelAdaptive(context),
                      ),
                      Text(
                        'Phnom Penh, Cambodia',
                        style: AppTheme.tsBodyAdaptive(context),
                      ),
                      Row(
                        children: [
                          Text('4.7', style: AppTheme.tsAccent),
                          const SizedBox(width: 5),
                          Text('(128 reviews)', style: AppTheme.tsBody),
                        ],
                      ),
                      const SizedBox(height: 5),
                      _buildBadge('Verified venue', Colors.green),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: AppTheme.cardDecorationAdaptive(context),
                    child: Column(
                      children: [
                        Text('8', style: AppTheme.tsTitleAdaptive(context)),
                        Text('Courts', style: AppTheme.tsSubAdaptive(context)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: AppTheme.cardDecorationAdaptive(context),
                    child: Column(
                      children: [
                        Text('1.2k', style: AppTheme.tsTitleAdaptive(context)),
                        Text(
                          'Bookings',
                          style: AppTheme.tsSubAdaptive(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: AppTheme.cardDecorationAdaptive(context),
                    child: Column(
                      children: [
                        Text('98%', style: AppTheme.tsTitleAdaptive(context)),
                        Text(
                          'Approval',
                          style: AppTheme.tsSubAdaptive(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to edit venue profile
                  Navigator.pushNamed(context, AppRoutes.editVenueProfile);
                },
                style: AppTheme.elevatedButtonStyle(),
                child: const Text('Edit Venue Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSection(String title, List<FeaturesData> data) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.tsLabelAdaptive(context)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.kCard
                  : AppTheme.kLightCard,
            ),
            child: Column(
              children: List.generate(data.length, (index) {
                return InkWell(
                  onTap: () {
                    // Navigate to the specific route
                    Navigator.pushNamed(context, data[index].route);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: index == 0
                            ? const Radius.circular(12)
                            : Radius.zero,
                        topRight: index == 0
                            ? const Radius.circular(12)
                            : Radius.zero,
                        bottomLeft: index == data.length - 1
                            ? const Radius.circular(12)
                            : Radius.zero,
                        bottomRight: index == data.length - 1
                            ? const Radius.circular(12)
                            : Radius.zero,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: data[index].color.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              data[index].icon,
                              color: data[index].color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data[index].title,
                                style: AppTheme.tsLabelAdaptive(
                                  context,
                                ).copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              Text(data[index].des, style: AppTheme.tsBody),
                            ],
                          ),
                        ),
                        if (data[index].label != null)
                          _buildBadge(data[index].label!, Colors.red),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // Show confirmation dialog before signing out
            _showSignOutDialog();
          },
          style: AppTheme.elevatedButtonStyle(
            backgroundColor: Colors.red.withValues(alpha: 0.3),
            foregroundColor: Colors.red,
          ),
          child: const Text('Sign out'),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform sign out logic
                Navigator.pop(context); // Close dialog
                // Navigate to login screen or clear auth state
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadge(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(title, style: AppTheme.tsBody.copyWith(color: color)),
    );
  }
}

class FeaturesData {
  final IconData icon;
  final String title;
  final String des;
  final String? label;
  final Color color;
  final String route;

  FeaturesData({
    required this.icon,
    required this.title,
    required this.des,
    this.label,
    required this.color,
    required this.route,
  });
}
