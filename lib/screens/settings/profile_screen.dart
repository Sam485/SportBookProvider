import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/features/Auth/auth_service.dart';
import 'package:flutter_application_1/features/Notification/service/notification_service.dart';
import 'package:flutter_application_1/features/User/Model/user_model.dart';
import 'package:flutter_application_1/features/User/Service/user_service.dart';
import 'package:flutter_application_1/routes/app_routes.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = getIt<AuthService>();
  final UserService userService = getIt<UserService>();
  final NotificationService notificationService = getIt<NotificationService>();

  // Loading states
  bool _isLoading = true;
  bool _isFirstLoad = true;
  bool _isDisposed = false;
  String? _error;
  UserModel? user;
  int newNotification = 0;

  late List<FeaturesData> accountData;
  late List<FeaturesData> venueData;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Listen for user service changes
    userService.addListener(_onUserServiceChanged);
    // Load user data on init
    _loadUserData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    userService.removeListener(_onUserServiceChanged);
    super.dispose();
  }

  void _onUserServiceChanged() {
    if (_isDisposed || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        setState(() {
          // Safe assignment - don't use null check operator
          user = userService.currentUser;
          _isLoading = userService.isLoading;
          _error = userService.error;

          // If user data is loaded and no error, ensure loading is false
          if (user != null && _error == null) {
            _isLoading = false;
          }
        });
      }
    });
  }

  void _initializeData() {
    accountData = [
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
        label: '$newNotification new',
        route: AppRoutes.notifications,
      ),
    ];

    venueData = [
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
  }

  Future<void> _loadUserData() async {
    if (_isDisposed || !mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      int count = 0;
      await userService.getProfile();
      await notificationService.getAllNotification();
      if (notificationService.notifications.isNotEmpty) {
        for (var notification in notificationService.notifications) {
          if (notification.isRead == true) {
            count++;
          }
        }
      }

      // Double-check: if listener didn't fire, update manually
      if (mounted && !_isDisposed) {
        setState(() {
          newNotification = count;
          user = userService.currentUser;
          _isLoading = false;
          _isFirstLoad = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isFirstLoad = false;
        });
        _showErrorSnackbar('Failed to load profile: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (_isDisposed || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _loadUserData,
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTheme.tsTitleAdaptive(context)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.setting);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: AppTheme.kAccent,
        backgroundColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isDisposed) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show error state if there's an error and no user data
    if (_error != null && user == null && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: AppTheme.tsTitleAdaptive(context),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: AppTheme.tsBodyAdaptive(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              style: AppTheme.elevatedButtonStyle(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: CustomScrollView(
        scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
        slivers: [
          SliverToBoxAdapter(
            child: Skeletonizer(
              enabled: _isLoading && _isFirstLoad,
              enableSwitchAnimation: true,
              child: _isLoading && _isFirstLoad
                  ? _buildSkeletonProfile(isDark)
                  : _buildHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Skeletonizer(
              enabled: _isLoading && _isFirstLoad,
              enableSwitchAnimation: true,
              child: _isLoading && _isFirstLoad
                  ? _buildSkeletonButtonSection(isDark, 'Account', 2)
                  : _buildButtonSection('Account', accountData),
            ),
          ),
          SliverToBoxAdapter(
            child: Skeletonizer(
              enabled: _isLoading && _isFirstLoad,
              enableSwitchAnimation: true,
              child: _isLoading && _isFirstLoad
                  ? _buildSkeletonButtonSection(isDark, 'Venue', 2)
                  : _buildButtonSection('Venue', venueData),
            ),
          ),
          SliverToBoxAdapter(
            child: Skeletonizer(
              enabled: _isLoading && _isFirstLoad,
              enableSwitchAnimation: true,
              child: _isLoading && _isFirstLoad
                  ? _buildSkeletonSignOutButton(isDark)
                  : _buildSignOutButton(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // ============================================================
  // SKELETON WIDGETS
  // ============================================================

  Widget _buildSkeletonProfile(bool isDark) {
    final skeletonBaseColor = isDark
        ? const Color(0xFF1E3A5F)
        : const Color(0xFFE0E0E0);
    final skeletonHighlightColor = isDark
        ? const Color(0xFF2A4A6F)
        : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: AppTheme.cardDecorationAdaptive(context),
        child: Skeletonizer(
          enabled: true,
          effect: ShimmerEffect(
            baseColor: skeletonBaseColor,
            highlightColor: skeletonHighlightColor,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.kCardAlt
                          : AppTheme.kLightCardAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 18,
                          width: 120,
                          color: isDark
                              ? AppTheme.kCardAlt
                              : AppTheme.kLightCardAlt,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: 80,
                          color: isDark
                              ? AppTheme.kCardAlt
                              : AppTheme.kLightCardAlt,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: 100,
                          color: isDark
                              ? AppTheme.kCardAlt
                              : AppTheme.kLightCardAlt,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 20,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isDark
                                ? AppTheme.kCardAlt
                                : AppTheme.kLightCardAlt,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.only(right: index < 2 ? 5 : 0),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.kCardAlt
                            : AppTheme.kLightCardAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 14,
                            width: 30,
                            color: isDark
                                ? AppTheme.kCard
                                : AppTheme.kLightCard,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 10,
                            width: 40,
                            color: isDark
                                ? AppTheme.kCard
                                : AppTheme.kLightCard,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.kAccent.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonButtonSection(bool isDark, String title, int itemCount) {
    final skeletonBaseColor = isDark
        ? const Color(0xFF1E3A5F)
        : const Color(0xFFE0E0E0);
    final skeletonHighlightColor = isDark
        ? const Color(0xFF2A4A6F)
        : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 60,
            color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
          ),
          const SizedBox(height: 10),
          Skeletonizer(
            enabled: true,
            effect: ShimmerEffect(
              baseColor: skeletonBaseColor,
              highlightColor: skeletonHighlightColor,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
              ),
              child: Column(
                children: List.generate(
                  itemCount,
                  (index) => Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: index == 0
                            ? const Radius.circular(12)
                            : Radius.zero,
                        topRight: index == 0
                            ? const Radius.circular(12)
                            : Radius.zero,
                        bottomLeft: index == itemCount - 1
                            ? const Radius.circular(12)
                            : Radius.zero,
                        bottomRight: index == itemCount - 1
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
                            color: isDark
                                ? AppTheme.kCardAlt
                                : AppTheme.kLightCardAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14,
                                width: 80,
                                color: isDark
                                    ? AppTheme.kCardAlt
                                    : AppTheme.kLightCardAlt,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 10,
                                width: 120,
                                color: isDark
                                    ? AppTheme.kCardAlt
                                    : AppTheme.kLightCardAlt,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          color: isDark
                              ? AppTheme.kCardAlt
                              : AppTheme.kLightCardAlt,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonSignOutButton(bool isDark) {
    final skeletonBaseColor = isDark
        ? const Color(0xFF1E3A5F)
        : const Color(0xFFE0E0E0);
    final skeletonHighlightColor = isDark
        ? const Color(0xFF2A4A6F)
        : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: skeletonBaseColor,
          highlightColor: skeletonHighlightColor,
        ),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.red.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTUAL WIDGETS
  // ============================================================

  Widget _buildHeader() {
    if (_isDisposed) return const SizedBox.shrink();
    if (user == null && !_isLoading) {
      return const SizedBox.shrink();
    }

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
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadiusDirectional.circular(12),
                      child: _buildAvatar(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'User Name',
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

  Widget _buildAvatar() {
    if (_isDisposed) return const SizedBox.shrink();
    if (user == null) {
      return _buildAvatarFallback('U');
    }

    // Check if avatarUrl exists and is not empty - SAFE NULL HANDLING
    final String? avatarUrl = user?.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildAvatarFallback(getInitials(user?.fullName)),
      );
    }

    // Fallback to initials if no avatar URL
    return _buildAvatarFallback(getInitials(user?.fullName));
  }

  Widget _buildAvatarFallback(String initials) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.kAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildButtonSection(String title, List<FeaturesData> data) {
    if (_isDisposed) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
            ),
            child: Column(
              children: List.generate(data.length, (index) {
                return InkWell(
                  onTap: () {
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

  Widget _buildSignOutButton() {
    if (_isDisposed) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _showSignOutDialog,
          style: AppTheme.elevatedButtonStyle(
            backgroundColor: Colors.red.withValues(alpha: 0.3),
            foregroundColor: Colors.red,
          ),
          child: const Text('Sign Out'),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.kCard
              : AppTheme.kLightCard,
          title: Text(
            'Sign Out',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.kLightText,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.kTextSub
                  : AppTheme.kLightTextSub,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.kTextSub
                      : AppTheme.kLightTextSub,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                try {
                  await authService.logout();
                  // Navigate to login screen
                  if (mounted && !_isDisposed) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                } catch (e) {
                  if (mounted && !_isDisposed) {
                    _showErrorSnackbar('Failed to sign out: $e');
                  }
                }
              },
              style: AppTheme.elevatedButtonStyle(backgroundColor: Colors.red),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadge(String title, Color color) {
    if (_isDisposed) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(title, style: AppTheme.tsBody.copyWith(color: color)),
    );
  }

  String getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'U'; // Default for unknown user
    }

    final trimmedName = fullName.trim();
    final nameParts = trimmedName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (nameParts.isEmpty) {
      return 'U';
    }

    if (nameParts.length == 1) {
      // Only one name part, return first character
      return nameParts.first.substring(0, 1).toUpperCase();
    }

    // Return first character of first and last name parts
    final firstInitial = nameParts.first.substring(0, 1).toUpperCase();
    final lastInitial = nameParts.last.substring(0, 1).toUpperCase();

    return '$firstInitial$lastInitial';
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
