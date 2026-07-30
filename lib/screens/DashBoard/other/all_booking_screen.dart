// lib/features/Booking/screens/all_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/features/Booking/Model/booking_model.dart';
import 'package:flutter_application_1/features/Booking/Service/booking_service.dart';
import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';
import 'package:flutter_application_1/features/SportClub/service/sport_club_service.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/screens/DashBoard/other/booking_status_update_screen.dart';
import 'package:flutter_application_1/translations/app_translations.dart';

class AllBookingsScreen extends StatefulWidget {
  final int? sportClubId;

  const AllBookingsScreen({super.key, this.sportClubId});

  @override
  State<AllBookingsScreen> createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends State<AllBookingsScreen> {
  final BookingService _bookingService = getIt<BookingService>();
  final SportClubService _sportClubService = getIt<SportClubService>();

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<BookingModel> _bookings = [];
  List<BookingModel> _filteredBookings = [];
  List<SportClubModel> _sportClubs = [];

  int _currentPage = 1;
  final int _limit = 15;
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isFirstLoad = true;

  int? _selectedSportClubId;
  DateTime? _selectedDate;
  String? _selectedStatus;
  String _searchQuery = '';

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
    _selectedSportClubId = widget.sportClubId;
    _loadSportClubs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _loadBookings();
      }
    }
  }

  Future<void> _loadSportClubs() async {
    try {
      final clubs = await _sportClubService.getAllSportClub(1, 100, '');
      if (mounted) {
        setState(() {
          _sportClubs = clubs;

          if (_selectedSportClubId != null) {
            final clubExists = _sportClubs.any(
              (club) => club.id == _selectedSportClubId,
            );
            if (clubExists) {
              _loadBookings(reset: true);
            } else if (_sportClubs.isNotEmpty) {
              _selectedSportClubId = _sportClubs.first.id;
              _loadBookings(reset: true);
            }
          } else if (_sportClubs.isNotEmpty) {
            _selectedSportClubId = _sportClubs.first.id;
            _loadBookings(reset: true);
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

  Future<void> _loadBookings({bool reset = false}) async {
    if (_selectedSportClubId == null) return;
    if (_isLoading) return;
    if (!reset && !_hasMoreData) return;

    if (reset) {
      setState(() {
        _currentPage = 1;
        _bookings = [];
        _filteredBookings = [];
        _hasMoreData = true;
        _isFirstLoad = true;
      });
    }

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
          if (reset) {
            _bookings = bookings;
          } else {
            _bookings.addAll(bookings);
          }
          _applySearchFilter();
          _isLoading = false;
          _isFirstLoad = false;
          _hasMoreData = bookings.length >= _limit;
          if (!reset && bookings.isNotEmpty) {
            _currentPage++;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFirstLoad = false;
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

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredBookings = List.from(_bookings);
      });
    } else {
      final query = _searchQuery.toLowerCase();
      setState(() {
        _filteredBookings = _bookings.where((booking) {
          return booking.user.fullName.toLowerCase().contains(query) ||
              booking.slot.name.toLowerCase().contains(query) ||
              booking.status.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedDate = null;
      _searchQuery = '';
      _searchController.clear();
      _currentPage = 1;
    });
    _loadBookings(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'all_bookings'.tr(context),
          style: AppTheme.tsTitleAdaptive(context),
        ),
        backgroundColor: isDark ? AppTheme.kBg : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: Badge(
              isLabelVisible: _selectedStatus != null || _selectedDate != null,
              child: Icon(
                Icons.filter_list,
                color: (_selectedStatus != null || _selectedDate != null)
                    ? AppTheme.kAccent
                    : null,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _loadBookings(reset: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applySearchFilter();
              },
              decoration: InputDecoration(
                hintText: 'search_bookings'.tr(context),
                hintStyle: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 14,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.clear,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
                _applySearchFilter();
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredBookings.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadBookings(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: _filteredBookings.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredBookings.length) {
            return _buildLoadingMore();
          }
          return _buildBookingCard(_filteredBookings[index]);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final statusColor = _getStatusColor(booking.status);
    final initial = booking.user.fullName.isNotEmpty
        ? booking.user.fullName.split(' ').map((e) => e[0]).join('')
        : 'U';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.kCardAlt
          : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showBookingDetailSheet(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                      style: AppTheme.tsTitle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.slot.name,
                      style: AppTheme.tsSubAdaptive(
                        context,
                      ).copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.attach_money,
                          size: 14,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${booking.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'no_bookings_found'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 18,
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all),
            label: Text('clear_filters'.tr(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        sportClubs: _sportClubs,
        selectedSportClubId: _selectedSportClubId,
        selectedStatus: _selectedStatus,
        selectedDate: _selectedDate,
        statusOptions: _statusOptions,
        onApply: (clubId, status, date) {
          setState(() {
            _selectedSportClubId = clubId;
            _selectedStatus = status;
            _selectedDate = date;
            _currentPage = 1;
          });
          _loadBookings(reset: true);
        },
        onClear: _clearFilters,
      ),
    );
  }

  void _showBookingDetailSheet(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingStatusUpdateSheet(
        booking: booking,
        onStatusUpdated: () => _loadBookings(reset: true),
      ),
    );
  }

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
}

// ── Filter Bottom Sheet ──────────────────────────────────────────────────
class _FilterBottomSheet extends StatefulWidget {
  final List<SportClubModel> sportClubs;
  final int? selectedSportClubId;
  final String? selectedStatus;
  final DateTime? selectedDate;
  final List<String> statusOptions;
  final void Function(int?, String?, DateTime?) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.sportClubs,
    required this.selectedSportClubId,
    required this.selectedStatus,
    required this.selectedDate,
    required this.statusOptions,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late int? _selectedSportClubId;
  late String? _selectedStatus;
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedSportClubId = widget.selectedSportClubId;
    _selectedStatus = widget.selectedStatus;
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kBg : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'filter_bookings'.tr(context),
                style: AppTheme.tsTitleAdaptive(
                  context,
                ).copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onClear,
                child: Text(
                  'clear_all'.tr(context),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppTheme.kAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildFilterField(
            label: 'sport_club'.tr(context),
            child: DropdownButtonFormField<int>(
              initialValue: _selectedSportClubId,
              decoration: _buildInputDecoration(
                'select_sport_club'.tr(context),
              ),
              items: widget.sportClubs.map((club) {
                return DropdownMenuItem<int>(
                  value: club.id,
                  child: Text(
                    club.name,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: isDark ? Colors.white : AppTheme.kLightText,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSportClubId = value;
                });
              },
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : AppTheme.kLightText,
              ),
              dropdownColor: isDark ? AppTheme.kBg : Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          _buildFilterField(
            label: 'status'.tr(context),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedStatus ?? 'All',
              decoration: _buildInputDecoration('select_status'.tr(context)),
              items: widget.statusOptions.map((status) {
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
                });
              },
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : AppTheme.kLightText,
              ),
              dropdownColor: isDark ? AppTheme.kBg : Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          _buildFilterField(
            label: 'date'.tr(context),
            child: InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppTheme.kAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'select_date'.tr(context),
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: _selectedDate != null
                              ? (isDark ? Colors.white : AppTheme.kLightText)
                              : (isDark
                                    ? AppTheme.kTextSub
                                    : AppTheme.kLightTextSub),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  _selectedSportClubId,
                  _selectedStatus,
                  _selectedDate,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'apply_filters'.tr(context),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFilterField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.tsLabelAdaptive(
            context,
          ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: AppTheme.fontFamily,
        color: isDark ? Colors.grey[500] : Colors.grey[400],
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.kAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      isDense: true,
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

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
      });
    }
  }
}
