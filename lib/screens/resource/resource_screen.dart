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

  // Court data (keeping your existing structure)
  final List<Map<String, dynamic>> courtData = [
    {'name': 'Tennis Court', 'count': 3, 'price': '\$25/hr'},
    {'name': 'Basketball Court', 'count': 2, 'price': '\$30/hr'},
    {'name': 'Badminton Court', 'count': 3, 'price': '\$20/hr'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.kBg
          : AppTheme.kLightBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildDivider()),
          // Sport clubs section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sport Clubs',
                        style: AppTheme.tsLabelAdaptive(context),
                      ),
                      Text(
                        '${clubs.length} clubs',
                        style: AppTheme.tsBodyAdaptive(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          // Clubs horizontal list
          SliverToBoxAdapter(
            child: SizedBox(
              height: 320, // Fixed height for club cards
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 10, right: 10),
                itemCount: clubs.length,
                itemBuilder: (context, index) {
                  return ClubCard(club: clubs[index]);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildDivider()),
          // Court pricing section
          SliverToBoxAdapter(child: _courtPricing()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Resources', style: AppTheme.tsTitleAdaptive(context)),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              // Add club functionality
              Navigator.pushNamed(context, AppRoutes.editSportClub);
            },
            style: AppTheme.elevatedButtonStyle(),
            child: const Text('Add Club'),
          ),
        ],
      ),
    );
  }

  Widget _courtPricing() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Court Pricing', style: AppTheme.tsLabelAdaptive(context)),
              const Spacer(),
              Text(
                '${courtData.length} courts',
                style: AppTheme.tsBodyAdaptive(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(
            courtData.length,
            (index) => _buildCourtCard(courtData[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtCard(Map<String, dynamic> court) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(12),
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
              Icon(Icons.sports_tennis, color: AppTheme.kAccent, size: 20),
              const SizedBox(width: 12),
              Text(
                court['name'],
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.kAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${court['count']} courts',
                  style: TextStyle(
                    color: AppTheme.kAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Text(
            court['price'],
            style: TextStyle(
              color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return SizedBox(
      width: double.infinity,
      child: Divider(
        thickness: 0.5,
        color: AppTheme.kAccent.withValues(alpha: 0.6),
      ),
    );
  }
}
