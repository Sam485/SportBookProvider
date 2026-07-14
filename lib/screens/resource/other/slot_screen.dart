import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/routes/app_routes.dart';

class CourtPricing {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String status;
  final String member;
  final String? openDate;
  final String? courtTime;
  final String? priceInHour;

  CourtPricing({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.status,
    required this.member,
    this.openDate,
    this.courtTime,
    this.priceInHour,
  });
}

class SlotScreen extends StatefulWidget {
  const SlotScreen({super.key});

  @override
  State<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends State<SlotScreen> {
  // Sample court data
  final List<CourtPricing> courtData = [
    CourtPricing(
      icon: Icons.sports_tennis,
      color: Colors.blue,
      title: 'Court 1 - Badminton',
      description: 'Indoor, Max 4 players',
      status: 'Open',
      member: '4 players',
      openDate: 'Mon - Sun',
      courtTime: '6:00 - 9:00 AM',
      priceInHour: '\$8/hr',
    ),
    CourtPricing(
      icon: Icons.sports_soccer,
      color: Colors.green,
      title: 'Field 1 - Soccer',
      description: 'Indoor, Max 14 players',
      status: 'Open',
      member: '14 players',
      openDate: 'Mon - Sun',
      courtTime: '6:00 - 9:00 AM',
      priceInHour: '\$20/hr',
    ),
    CourtPricing(
      icon: Icons.sports_tennis,
      color: Colors.orange,
      title: 'Court 3 - Badminton',
      description: 'Indoor, Max 4 players',
      status: 'Maintenance',
      member: '4 players',
    ),
    CourtPricing(
      icon: Icons.sports_basketball,
      color: Colors.purple,
      title: 'Court 2 - Basketball',
      description: 'Indoor, Max 10 players',
      status: 'Open',
      member: '10 players',
      openDate: 'Mon - Sun',
      courtTime: '9:00 - 12:00 AM',
      priceInHour: '\$15/hr',
    ),
    CourtPricing(
      icon: Icons.sports_volleyball,
      color: Colors.red,
      title: 'Court 4 - Volleyball',
      description: 'Indoor, Max 12 players',
      status: 'Closed',
      member: '12 players',
    ),
  ];

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
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(isDark)),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildCourtCard(courtData[index], isDark),
                  childCount: courtData.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Quick add court
          Navigator.pushNamed(context, AppRoutes.adjustSlot);
        },
        backgroundColor: AppTheme.kAccent,
        icon: const Icon(Icons.add, color: Color(0xFF0A1828)),
        label: Text(
          'Add Court',
          style: TextStyle(
            color: const Color(0xFF0A1828),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Header Widget ──────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
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
                      'Manage Courts',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.kLightText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${courtData.length} courts available',
                      style: TextStyle(
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
                  'Total: ${courtData.length}',
                  style: TextStyle(
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
                  'Open',
                  Colors.green,
                  courtData.where((c) => c.status == 'Open').length,
                ),
                _buildStatusChip(
                  'Maintenance',
                  Colors.orange,
                  courtData.where((c) => c.status == 'Maintenance').length,
                ),
                _buildStatusChip(
                  'Closed',
                  Colors.red,
                  courtData.where((c) => c.status == 'Closed').length,
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
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ── Court Card Widget ──────────────────────────────────────────────────
  Widget _buildCourtCard(CourtPricing data, bool isDark) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: AppTheme.cardDecorationAdaptive(context),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Court Heading ─────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: data.color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.kLightText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.description,
                        style: TextStyle(
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
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.adjustSlot);
                      },
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      iconSize: 20,
                      tooltip: 'Edit',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Court'),
                            content: Text(
                              'Are you sure you want to delete "${data.title}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${data.title} deleted'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      iconSize: 20,
                      tooltip: 'Delete',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Status Tags ──────────────────────────────────────────────
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: data.status == "Open"
                        ? Colors.green.withValues(alpha: 0.15)
                        : data.status == "Maintenance"
                        ? Colors.orange.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  child: Text(
                    data.status,
                    style: TextStyle(
                      color: data.status == "Open"
                          ? Colors.green
                          : data.status == "Maintenance"
                          ? Colors.orange
                          : Colors.red,
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
                    data.member,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (data.openDate != null)
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
                      data.openDate!,
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            if (data.openDate != null) ...[
              const SizedBox(height: 12),
              _buildDivider(isDark),
              const SizedBox(height: 10),

              // ── Time & Pricing ──────────────────────────────────────────
              Text(
                'Time slots & pricing',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppTheme.kAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          data.courtTime ?? 'Time not set',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppTheme.kLightText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
                        data.priceInHour ?? 'Price not set',
                        style: const TextStyle(
                          color: Color(0xFF0A1828),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Divider ────────────────────────────────────────────────────────────
  Widget _buildDivider(bool isDark) {
    return Container(
      width: double.infinity,
      height: 1,
      color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
    );
  }
}
