import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/routes/app_routes.dart';
import 'package:flutter_application_1/features/Booking/Model/booking_model.dart';
import 'package:flutter_application_1/features/Booking/Service/booking_service.dart';
import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';
import 'package:flutter_application_1/features/SportClub/service/sport_club_service.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';

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
            content: Text('Failed to load sport clubs: ${e.toString()}'),
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

      // Format date for API if selected
      String? formattedDate;
      if (_selectedDate != null) {
        // Format as YYYY-MM-DD for API
        formattedDate = _selectedDate!.toIso8601String().split('T').first;
      }

      final bookings = await _bookingService.fetchBookingBySportClub(
        _selectedSportClubId!,
        _currentPage,
        _limit,
        status,
        formattedDate, // Pass formatted date string instead of DateTime
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
            content: Text('Failed to load bookings: ${e.toString()}'),
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
              // Header
              SliverToBoxAdapter(child: _buildHeader()),

              // Filter Section
              SliverToBoxAdapter(child: _buildFilterSection()),

              // Stats Grid
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

              // Recent Bookings
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
              Text('Dashboard', style: AppTheme.tsTitleAdaptive(context)),
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
          // Sport Club Dropdown
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
                  hint: 'Select Sport Club',
                  icon: Icons.sports,
                ),
              ),
              const SizedBox(width: 8),
              // Date Picker
              Expanded(child: _buildDatePickerButton(isDark)),
            ],
          ),
          const SizedBox(height: 8),
          // Status Dropdown and Clear Filters
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
                  hint: 'Status',
                  icon: Icons.filter_list,
                ),
              ),
              const SizedBox(width: 8),
              // Clear Filters Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear'),
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
                    : 'Select Date',
                style: TextStyle(
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
        title: "Total Bookings",
        value: '$_totalBookings',
        description: 'All bookings',
        desColor: AppTheme.kAccent,
        icon: Icons.bookmark,
      ),
      StatCardData(
        title: 'Revenue',
        value: '\$${_totalRevenue.toStringAsFixed(0)}',
        description: 'Total revenue',
        desColor: Colors.green,
        icon: Icons.attach_money,
      ),
      StatCardData(
        title: 'Pending',
        value: '$_pendingBookings',
        description: 'Waiting approval',
        desColor: Colors.orange,
        icon: Icons.pending_actions,
      ),
      StatCardData(
        title: 'Confirmed',
        value: '$_confirmedBookings',
        description: 'Approved bookings',
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
                  'Recent Bookings',
                  style: AppTheme.tsLabelAdaptive(context),
                ),
                const Spacer(),
                if (_recentBookings.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      // Navigate to all bookings screen
                      // Navigator.pushNamed(context, AppRoutes.allBookings);
                    },
                    child: Text('See all', style: AppTheme.tsAccent),
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
                  style: AppTheme.tsLabel.copyWith(color: statusColor),
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
      builder: (context) => _BookingDetailSheet(
        booking: booking,
        onStatusUpdated: _loadRecentBookings,
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.calendar_today, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
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

// ── Booking Detail Sheet Widget ────────────────────────────────────────
class _BookingDetailSheet extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback onStatusUpdated;

  const _BookingDetailSheet({
    required this.booking,
    required this.onStatusUpdated,
  });

  @override
  State<_BookingDetailSheet> createState() => _BookingDetailSheetState();
}

class _BookingDetailSheetState extends State<_BookingDetailSheet> {
  final BookingService _bookingService = getIt<BookingService>();
  bool _isUpdating = false;
  String? _selectedStatus;
  String? _selectedPaymentStatus;
  final TextEditingController _noteController = TextEditingController();

  final List<String> _availableStatuses = [
    'pending',
    'confirmed',
    'cancelled',
    'completed',
  ];

  final List<String> _availablePaymentStatuses = [
    'pending',
    'paid',
    'failed',
    'refunded',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.booking.status;
    _selectedPaymentStatus = widget.booking.paymentStatus;
    _noteController.text = widget.booking.note;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kBg : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_calendar,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Details',
                        style: AppTheme.tsTitleAdaptive(context),
                      ),
                      Text(
                        'ID: #${widget.booking.id}',
                        style: AppTheme.tsSubAdaptive(context),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Booking Info Card
            _buildBookingInfoCard(isDark),
            const SizedBox(height: 20),

            // Status Section
            _buildStatusSection(isDark),
            const SizedBox(height: 20),

            // Payment Status Section
            _buildPaymentStatusSection(isDark),
            const SizedBox(height: 20),

            // Note
            _buildNoteSection(isDark),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'Customer',
            widget.booking.user.fullName,
            Icons.person,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Court',
            widget.booking.slot.name,
            Icons.sports,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Date & Time',
            '${_formatDate(widget.booking.bookingDate)} • ${_formatTime(widget.booking.startTime)} - ${_formatTime(widget.booking.endTime)}',
            Icons.calendar_today,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Amount',
            '\$${widget.booking.totalAmount}',
            Icons.attach_money,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Status',
            widget.booking.status.toUpperCase(),
            Icons.circle,
            isDark,
            status: widget.booking.status,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Payment',
            widget.booking.paymentStatus.toUpperCase(),
            Icons.payment,
            isDark,
            paymentStatus: widget.booking.paymentStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    String? status,
    String? paymentStatus,
  }) {
    Color? valueColor;
    if (status != null) {
      valueColor = _getStatusColor(status);
    } else if (paymentStatus != null) {
      valueColor = _getPaymentStatusColor(paymentStatus);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.kAccent, size: 16),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: TextStyle(
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color:
                  valueColor ?? (isDark ? Colors.white : AppTheme.kLightText),
              fontSize: 13,
              fontWeight: valueColor != null
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Update Booking Status', style: AppTheme.tsLabelAdaptive(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableStatuses.map((status) {
            final isSelected = _selectedStatus == status;
            final color = _getStatusColor(status);
            return FilterChip(
              selected: isSelected,
              label: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              backgroundColor: isDark
                  ? AppTheme.kCardAlt
                  : AppTheme.kLightCardAlt,
              selectedColor: color,
              showCheckmark: false,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = status;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? color
                      : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                  width: 1.5,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Update Payment Status', style: AppTheme.tsLabelAdaptive(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availablePaymentStatuses.map((status) {
            final isSelected = _selectedPaymentStatus == status;
            final color = _getPaymentStatusColor(status);
            return FilterChip(
              selected: isSelected,
              label: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              backgroundColor: isDark
                  ? AppTheme.kCardAlt
                  : AppTheme.kLightCardAlt,
              selectedColor: color,
              showCheckmark: false,
              onSelected: (selected) {
                setState(() {
                  _selectedPaymentStatus = status;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? color
                      : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                  width: 1.5,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Note', style: AppTheme.tsLabelAdaptive(context)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
            ),
            decoration: InputDecoration(
              hintText: 'Add a note (optional)',
              hintStyle: TextStyle(
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isUpdating ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white70 : AppTheme.kLightText,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: _isUpdating ? null : _updateBookingStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isUpdating
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Update Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Update Status ──────────────────────────────────────────────────────
  Future<void> _updateBookingStatus() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a status'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _bookingService.updateBookingStatus(widget.booking.id);

      if (mounted) {
        setState(() {
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking #${widget.booking.id} updated to ${_selectedStatus?.toUpperCase()}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
        widget.onStatusUpdated();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(Duration time) {
    final hours = time.inHours.toString().padLeft(2, '0');
    final minutes = time.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
