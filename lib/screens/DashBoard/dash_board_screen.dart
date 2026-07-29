import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/routes/app_routes.dart';
import 'package:flutter_application_1/features/Booking/Model/booking_model.dart';
import 'package:flutter_application_1/features/Booking/Service/booking_service.dart';
import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';
import 'package:flutter_application_1/features/SportClub/service/sport_club_service.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/screens/DashBoard/other/booking_status_update_screen.dart';
import 'package:flutter_application_1/translations/app_translations.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final BookingService _bookingService = getIt<BookingService>();
  final SportClubService _sportClubService = getIt<SportClubService>();

  bool _isLoading = false;
  List<BookingModel> _recentBookings = [];
  List<SportClubModel> _sportClubs = [];

  // Filter variables
  int? _selectedSportClubId;
  DateTime? _selectedDate;
  String? _selectedStatus;
  int _currentPage = 1;
  final int _limit = 10;

  // Statistics
  int _totalBookings = 0;
  double _totalRevenue = 0.0;
  int _pendingBookings = 0;
  int _confirmedBookings = 0;

  final List<String> _statusOptions = [
    'All',
    'pending',
    'confirmed',
    'cancelled',
    'completed',
  ];

  @override
  void initState() {
    super.initState();
    _loadSportClubs();
  }

  Future<void> _loadSportClubs() async {
    try {
      final clubs = await _sportClubService.getAllSportClub(1, 100, '');
      if (mounted) {
        setState(() {
          _sportClubs = clubs;
          if (_sportClubs.isNotEmpty) {
            _selectedSportClubId = _sportClubs.first.id;
            _loadRecentBookings();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load sport clubs: ${e.toString()}',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadRecentBookings() async {
    if (_selectedSportClubId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final status = _selectedStatus == 'All' ? null : _selectedStatus;

      String? formattedDate;
      if (_selectedDate != null) {
        formattedDate = _selectedDate!.toIso8601String().split('T').first;
      }

      final bookings = await _bookingService.fetchBookingBySportClub(
        _selectedSportClubId!,
        _currentPage,
        _limit,
        status,
        formattedDate,
      );

      if (mounted) {
        setState(() {
          _recentBookings = bookings;
          _isLoading = false;
          _calculateStatistics(bookings);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load bookings: ${e.toString()}',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _calculateStatistics(List<BookingModel> bookings) {
    _totalBookings = bookings.length;
    _totalRevenue = bookings.fold(
      0.0,
      (sum, booking) => sum + booking.totalAmount,
    );
    _pendingBookings = bookings
        .where((b) => b.status.toLowerCase() == 'pending')
        .length;
    _confirmedBookings = bookings
        .where((b) => b.status.toLowerCase() == 'confirmed')
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRecentBookings,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildFilterSection()),
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildStatCard(_getStatsData()[index]),
                    childCount: _getStatsData().length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildRecentBookingSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'dashboard'.tr(context),
                style: AppTheme.tsTitleAdaptive(context),
              ),
              const SizedBox(height: 4),
              Text(_getFormattedDate(), style: AppTheme.tsSubAdaptive(context)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white : AppTheme.kLightText,
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Section ──────────────────────────────────────────────────────
  Widget _buildFilterSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.cardDecorationAdaptive(context),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildDropdownField(
                  value: _selectedSportClubId,
                  items: _sportClubs.map((club) {
                    return DropdownMenuItem<int>(
                      value: club.id,
                      child: Text(
                        club.name,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: isDark ? Colors.white : AppTheme.kLightText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSportClubId = value;
                      _currentPage = 1;
                    });
                    _loadRecentBookings();
                  },
                  hint: 'select_sport_club'.tr(context),
                  icon: Icons.sports,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildDatePickerButton(isDark)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildDropdownField(
                  value: _selectedStatus ?? 'All',
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: isDark ? Colors.white : AppTheme.kLightText,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value == 'All' ? null : value;
                      _currentPage = 1;
                    });
                    _loadRecentBookings();
                  },
                  hint: 'status'.tr(context),
                  icon: Icons.filter_list,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: Text(
                    'clear_filters'.tr(context),
                    style: const TextStyle(fontFamily: AppTheme.fontFamily),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade300,
                    ),
                    textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String hint,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, color: AppTheme.kAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                hint,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          items: items,
          onChanged: onChanged,
          dropdownColor: isDark ? AppTheme.kBg : Colors.white,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 13,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(bool isDark) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: AppTheme.kAccent,
                  onPrimary: Colors.white,
                  surface: isDark ? AppTheme.kBg : Colors.white,
                  onSurface: isDark ? Colors.white : AppTheme.kLightText,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
            _currentPage = 1;
          });
          _loadRecentBookings();
        }
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.kAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'select_date'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: _selectedDate != null
                      ? (isDark ? Colors.white : AppTheme.kLightText)
                      : (isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub),
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_selectedDate != null)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.close, size: 16, color: Colors.grey.shade400),
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                  });
                  _loadRecentBookings();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedDate = null;
      _currentPage = 1;
    });
    _loadRecentBookings();
  }

  // ── Stat Card ──────────────────────────────────────────────────────────
  List<StatCardData> _getStatsData() {
    return [
      StatCardData(
        title: 'total_bookings'.tr(context),
        value: '$_totalBookings',
        description: 'all_bookings'.tr(context),
        desColor: AppTheme.kAccent,
        icon: Icons.bookmark,
      ),
      StatCardData(
        title: 'revenue'.tr(context),
        value: '\$${_totalRevenue.toStringAsFixed(0)}',
        description: 'total_earned'.tr(context),
        desColor: Colors.green,
        icon: Icons.attach_money,
      ),
      StatCardData(
        title: 'pending'.tr(context),
        value: '$_pendingBookings',
        description: 'waiting_approval'.tr(context),
        desColor: Colors.orange,
        icon: Icons.pending_actions,
      ),
      StatCardData(
        title: 'confirmed'.tr(context),
        value: '$_confirmedBookings',
        description: 'approved_bookings'.tr(context),
        desColor: Colors.blue,
        icon: Icons.check_circle,
      ),
    ];
  }

  Widget _buildStatCard(StatCardData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: AppTheme.cardDecorationAdaptive(context),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.title,
                  style: AppTheme.tsBodyAdaptive(context).copyWith(
                    fontFamily: AppTheme.fontFamily,
                    color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Icon(data.icon, color: data.desColor, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.value,
              style: AppTheme.tsTitleAdaptive(
                context,
              ).copyWith(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              data.description,
              style: AppTheme.tsSubAdaptive(context).copyWith(
                fontFamily: AppTheme.fontFamily,
                color: data.desColor,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent Bookings Section ────────────────────────────────────────────
  Widget _buildRecentBookingSection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecorationAdaptive(context),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'recent_bookings'.tr(context),
                  style: AppTheme.tsLabelAdaptive(context),
                ),
                const Spacer(),
                if (_recentBookings.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      // Navigate to all bookings screen
                      // Navigator.pushNamed(context, AppRoutes.allBookings);
                    },
                    child: Text(
                      'see_all'.tr(context),
                      style: AppTheme.tsAccent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Loading State
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            // Empty State
            else if (_recentBookings.isEmpty)
              _buildEmptyState()
            // Bookings List
            else
              ...List.generate(_recentBookings.length, (index) {
                return Column(
                  children: [
                    _buildBookingItem(_recentBookings[index]),
                    if (index != _recentBookings.length - 1) _buildDivider(),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  // ── Booking Item ──────────────────────────────────────────────────────
  Widget _buildBookingItem(BookingModel booking) {
    final statusColor = _getStatusColor(booking.status);
    final initial = booking.user.fullName.isNotEmpty
        ? booking.user.fullName.split(' ').map((e) => e[0]).join('')
        : 'U';

    return InkWell(
      onTap: () => _showBookingDetailSheet(booking),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: AppTheme.tsLabel.copyWith(
                    fontFamily: AppTheme.fontFamily,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.user.fullName,
                    style: AppTheme.tsTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.slot.name,
                    style: AppTheme.tsSubAdaptive(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatTime(booking.startTime), style: AppTheme.tsAccent),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2.5,
                  ),
                  height: 25,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      booking.status.toUpperCase(),
                      style: AppTheme.tsBody.copyWith(
                        fontFamily: AppTheme.fontFamily,
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Booking Detail Sheet ──────────────────────────────────────────────
  void _showBookingDetailSheet(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingStatusUpdateSheet(
        booking: booking,
        onStatusUpdated: _loadRecentBookings,
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.calendar_today, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'no_bookings_found'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'try_adjusting_filters'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Divider ──────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return SizedBox(
      width: double.infinity,
      child: Divider(
        thickness: 0.5,
        color: AppTheme.kAccent.withValues(alpha: 0.3),
      ),
    );
  }

  // ── Helper Methods ──────────────────────────────────────────────────
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(Duration time) {
    final hours = time.inHours.toString().padLeft(2, '0');
    final minutes = time.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

// ── Stat Card Data Class ──────────────────────────────────────────────────
class StatCardData {
  final String title;
  final String value;
  final String description;
  final Color desColor;
  final IconData icon;

  StatCardData({
    required this.title,
    required this.value,
    required this.description,
    required this.desColor,
    required this.icon,
  });
}
