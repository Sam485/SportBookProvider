import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';
import 'package:flutter_application_1/features/SportClub/service/sport_club_service.dart';
import 'package:flutter_application_1/routes/app_routes.dart';
import 'package:flutter_application_1/widgets/cards/club_card.dart';
import 'package:flutter_application_1/widgets/cards/club_card_skeleton.dart';

class ResourceScreen extends StatefulWidget {
  const ResourceScreen({super.key});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  final service = getIt<SportClubService>();
  List<SportClubModel> clubs = [];
  bool _loading = true; // Start with loading true
  String? _error;

  @override
  void initState() {
    super.initState();
    loadingData();
  }

  Future<void> loadingData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await service.getAllSportClub(1, 100, '');
      if (response.isNotEmpty) {
        setState(() {
          clubs = response;
          _loading = false;
        });
      } else {
        setState(() {
          clubs = [];
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: _loading
          ? const ResourceScreenSkeleton() // Show skeleton while loading
          : _error != null
          ? _buildErrorWidget() // Show error if any
          : _buildContent(), // Show actual content
    );
  }

  // ── Content Builder ──────────────────────────────────────────────────────
  Widget _buildContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildDivider()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.sports,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Sport Clubs',
                      style: AppTheme.tsLabelAdaptive(context),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.kAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${clubs.length} clubs',
                    style: TextStyle(
                      color: AppTheme.kAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: clubs.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClubCard(club: clubs[index]),
                    );
                  }, childCount: clubs.length),
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  // ── Error Widget ────────────────────────────────────────────────────────
  Widget _buildErrorWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTheme.tsTitleAdaptive(context),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load clubs',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: loadingData,
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
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State Widget ──────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.sports,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No clubs found',
            style: AppTheme.tsTitleAdaptive(
              context,
            )?.copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the "Add Club" button to create one',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dashboard, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Text('Resources', style: AppTheme.tsTitleAdaptive(context)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.editSportClub);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kAccent,
              foregroundColor: const Color(0xFF0A1828),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text(
              'Add Club',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── Divider ──────────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      color: AppTheme.kAccent.withValues(alpha: 0.3),
    );
  }
}
