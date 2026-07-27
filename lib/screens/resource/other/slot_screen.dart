import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/features/Slot/model/slot_model.dart';
import 'package:flutter_application_1/features/Slot/service/slot_service.dart';
import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';
import 'package:flutter_application_1/routes/app_routes.dart';
import 'package:flutter_application_1/translations/app_translations.dart';

class SlotScreen extends StatefulWidget {
  final SportClubModel club;
  const SlotScreen({super.key, required this.club});

  @override
  State<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends State<SlotScreen> {
  final slotService = getIt<SlotService>();
  List<SlotModel> slots = [];
  bool _loading = true;
  String? _error;
  final int _currentPage = 1;
  final int _limit = 100;
  int? _selectedCategoryId;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    if (!_isRefreshing) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final fetchedSlots = await slotService.fetchSlotBySportClub(
        widget.club.id!,
        _currentPage,
        _limit,
        _selectedCategoryId,
      );

      setState(() {
        slots = fetchedSlots;
        _loading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _isRefreshing = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _refreshSlots() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadSlots();
  }

  Future<void> _navigateToCreateSlot() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.adjustSlot,
      arguments: widget.club,
    );

    if (result == true) {
      _refreshSlots();
    }
  }

  Future<void> _navigateToUpdateSlot(SlotModel slot) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.updateSlot,
      arguments: slot,
    );

    if (result == true) {
      _refreshSlots();
    }
  }

  Future<void> _deleteSlot(int slotId, String slotName) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'delete_confirmation'.tr(context),
          style: const TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        content: Text(
          'delete_confirm_message'.tr(context).replaceAll('{name}', slotName),
          style: const TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr(context),
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            child: Text(
              'delete'.tr(context),
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      setState(() {
        _isRefreshing = true;
      });

      try {
        await slotService.deleteSlot(slotId);
        setState(() {
          slots.removeWhere((slot) => slot.id == slotId);
          _isRefreshing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'slot_deleted_success'
                    .tr(context)
                    .replaceAll('{name}', slotName),
                style: const TextStyle(fontFamily: AppTheme.fontFamily),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isRefreshing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete: ${e.toString()}',
                style: const TextStyle(fontFamily: AppTheme.fontFamily),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
        ),
        title: Text(
          'Court & Pricing',
          style: AppTheme.tsTitleAdaptive(context),
        ),
        actions: [
          IconButton(
            onPressed: _refreshSlots,
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : AppTheme.kLightText,
            ),
            tooltip: 'refresh'.tr(context),
          ),
        ],
      ),
      body: _loading
          ? _buildSkeletonLoader(isDark)
          : _error != null
          ? _buildErrorWidget(isDark)
          : RefreshIndicator(
              onRefresh: _refreshSlots,
              color: AppTheme.kAccent,
              backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
              displacement: 40,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(isDark)),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: slots.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState(isDark))
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _buildSlotCard(slots[index], isDark),
                              childCount: slots.length,
                            ),
                          ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateSlot,
        backgroundColor: AppTheme.kAccent,
        icon: const Icon(Icons.add, color: Color(0xFF0A1828)),
        label: Text(
          'add_court'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: const Color(0xFF0A1828),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecorationAdaptive(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'failed_to_load_courts'.tr(context),
              style: AppTheme.tsTitleAdaptive(context),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSlots,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kAccent,
                foregroundColor: const Color(0xFF0A1828),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(
                'try_again'.tr(context),
                style: const TextStyle(fontFamily: AppTheme.fontFamily),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.sports_tennis,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'no_courts_available'.tr(context),
            style: AppTheme.tsTitleAdaptive(context).copyWith(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'no_courts_message'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final openCount = slots.where((s) => s.isAvailable).length;
    final closedCount = slots.where((s) => !s.isAvailable).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.sports_tennis,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'manage_courts'.tr(context),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isDark ? Colors.white : AppTheme.kLightText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'courts_available'
                          .tr(context)
                          .replaceAll('{count}', '${slots.length}'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.kAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'total_courts'
                      .tr(context)
                      .replaceAll('{count}', '${slots.length}'),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppTheme.kAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip(
                  'available'.tr(context),
                  Colors.green,
                  openCount,
                ),
                _buildStatusChip(
                  'unavailable'.tr(context),
                  Colors.red,
                  closedCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotCard(SlotModel slot, bool isDark) {
    final isAvailable = slot.isAvailable;
    final statusColor = isAvailable ? Colors.green : Colors.red;
    final statusText = isAvailable
        ? 'available'.tr(context)
        : 'unavailable'.tr(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: AppTheme.cardDecorationAdaptive(context),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.kAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildSlotImage(slot),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.name,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: isDark ? Colors.white : AppTheme.kLightText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        slot.description.isNotEmpty
                            ? slot.description
                            : '${slot.category?.name ?? 'category_uncategorized'.tr(context)} court',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: isDark
                              ? AppTheme.kTextSub
                              : AppTheme.kLightTextSub,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _navigateToUpdateSlot(slot),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      iconSize: 20,
                      tooltip: 'edit'.tr(context),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    IconButton(
                      onPressed: () => _deleteSlot(slot.id, slot.name),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      iconSize: 20,
                      tooltip: 'delete'.tr(context),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: statusColor.withValues(alpha: 0.15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue.withValues(alpha: 0.15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  child: Text(
                    '${slot.capacity} ${'players'.tr(context)}',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.purple.withValues(alpha: 0.15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  child: Text(
                    slot.category?.name ?? 'category_uncategorized'.tr(context),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDivider(isDark),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_money, color: AppTheme.kAccent, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'price_per_hour'.tr(context),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${slot.price}/hr',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Color(0xFF0A1828),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

  Widget _buildSlotImage(SlotModel slot) {
    final hasImage = slot.imageUrl.isNotEmpty;

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          slot.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.kAccent,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return _buildDefaultIcon();
    }
  }

  Widget _buildDefaultIcon() {
    return Icon(Icons.sports_tennis, color: AppTheme.kAccent, size: 28);
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: double.infinity,
      height: 1,
      color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
    );
  }
}
