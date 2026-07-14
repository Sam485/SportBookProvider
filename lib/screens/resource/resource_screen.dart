import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/routes/app_routes.dart';
import 'package:flutter_application_1/widgets/cards/club_card.dart'; // Adjust path as needed

class ResourceScreen extends StatefulWidget {
  const ResourceScreen({super.key});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  // Sample club data
  final List<Club> clubs = [
    Club(
      name: 'Fitness Center Pro',
      initials: 'FC',
      color: Colors.blue,
      openTime: '6:00 AM',
      closeTime: '10:00 PM',
      location: '123 Main St, Downtown',
      distanceKm: 2.5,
      favoriteCount: 128,
      imageUrls: [
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
      ],
      isCurrentlyOpen: true,
    ),
    Club(
      name: 'Tennis Academy',
      initials: 'TA',
      color: Colors.green,
      openTime: '7:00 AM',
      closeTime: '9:00 PM',
      location: '456 Sports Ave, Uptown',
      distanceKm: 4.8,
      favoriteCount: 89,
      imageUrls: [
        'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=400',
        'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=400',
      ],
      isCurrentlyOpen: true,
    ),
    Club(
      name: 'Swimming Paradise',
      initials: 'SP',
      color: Colors.cyan,
      openTime: '5:30 AM',
      closeTime: '8:00 PM',
      location: '789 Waterfront Blvd, Eastside',
      distanceKm: 6.2,
      favoriteCount: 234,
      imageUrls: [
        'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=400',
        'https://images.unsplash.com/photo-1530023367847-a683933f4172?w=400',
        'https://images.unsplash.com/photo-1518288774672-b94e808873ff?w=400',
      ],
      isCurrentlyOpen: false,
    ),
    Club(
      name: 'Yoga Wellness',
      initials: 'YW',
      color: Colors.purple,
      openTime: '8:00 AM',
      closeTime: '7:00 PM',
      location: '321 Zen Garden, Westside',
      distanceKm: 1.8,
      favoriteCount: 156,
      imageUrls: [
        'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
        'https://images.unsplash.com/photo-1599447292180-45fd84092ef4?w=400',
      ],
      isCurrentlyOpen: true,
    ),
    Club(
      name: 'Gym Elite',
      initials: 'GE',
      color: Colors.red,
      openTime: '4:00 AM',
      closeTime: '11:00 PM',
      location: '555 Power St, Northside',
      distanceKm: 3.4,
      favoriteCount: 312,
      imageUrls: [
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400',
      ],
      isCurrentlyOpen: false,
    ),
    Club(
      name: 'Badminton Arena',
      initials: 'BA',
      color: Colors.orange,
      openTime: '6:00 AM',
      closeTime: '10:00 PM',
      location: '888 Shuttle Rd, Southside',
      distanceKm: 5.1,
      favoriteCount: 67,
      imageUrls: [
        'https://images.unsplash.com/photo-1613918108466-292b78a8ef95?w=400',
        'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=400',
      ],
      isCurrentlyOpen: true,
    ),
  ];

  // Court data
  final List<Map<String, dynamic>> courtData = [
    {'name': 'Tennis Court', 'count': 3, 'price': '\$25/hr'},
    {'name': 'Basketball Court', 'count': 2, 'price': '\$30/hr'},
    {'name': 'Badminton Court', 'count': 3, 'price': '\$20/hr'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildDivider()),

          // ── Sport Clubs Section ────────────────────────────────────────
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

          // ── Clubs List (Fixed) ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
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

  // ── Court Card ──────────────────────────────────────────────────────────
  Widget _buildCourtCard(Map<String, dynamic> court) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.kAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.sports_tennis,
                  color: AppTheme.kAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court['name'],
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.kLightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.kAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${court['count']} courts available',
                      style: TextStyle(
                        color: AppTheme.kAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.kAccent, Color(0xFF00B4D8)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              court['price'],
              style: const TextStyle(
                color: Color(0xFF0A1828),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
