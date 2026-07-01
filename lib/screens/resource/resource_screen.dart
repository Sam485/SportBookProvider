import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';

class ResourceScreen extends StatefulWidget {
  const ResourceScreen({super.key});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  List<CourtPricing> courtData = [
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
      member: '4 players',
      openDate: 'Mon - Sun',
      courtTime: '6:00 - 9:00 AM',
      priceInHour: '\$20/hr',
    ),
    CourtPricing(
      icon: Icons.sports_tennis,
      color: Colors.yellow,
      title: 'Court 3 - Badminton',
      description: 'Indoor, Max 4 players',
      status: 'Maintenance',
      member: '4 players',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _courtPricing()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Resource', style: AppTheme.tsTitleAdaptive(context)),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: AppTheme.elevatedButtonStyle(),
            child: const Text('Add Court'),
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
              Text(
                'Courts & Pricing',
                style: AppTheme.tsLabelAdaptive(context),
              ),
              const Spacer(),
              Text('8 courts', style: AppTheme.tsBodyAdaptive(context)),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(
            courtData.length,
            (index) => _buildCard(courtData[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildDivier() {
    return SizedBox(
      width: double.infinity,
      child: Divider(
        thickness: 0.5,
        color: AppTheme.kAccent.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildCard(CourtPricing data) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: AppTheme.cardDecorationAdaptive(context),
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court Heading
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: data.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: AppTheme.tsTitleAdaptive(context),
                      ),
                      Text(
                        data.description,
                        style: AppTheme.tsBodyAdaptive(context),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: data.status == "Open"
                        ? Colors.green.withValues(alpha: 0.3)
                        : data.status == "Maintenance"
                        ? Colors.yellow.withValues(alpha: 0.3)
                        : Colors.blue.withValues(alpha: 0.3),
                  ),
                  margin: EdgeInsets.only(right: 5),
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 2.5,
                      horizontal: 10,
                    ),
                    child: Text(
                      data.status,
                      style: AppTheme.tsBody.copyWith(
                        color: data.status == "Open"
                            ? Colors.green
                            : data.status == "Maintenance"
                            ? Colors.yellow
                            : Colors.blue,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue.withValues(alpha: 0.3),
                  ),
                  margin: EdgeInsets.only(right: 5),
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 2.5,
                      horizontal: 10,
                    ),
                    child: Text(
                      data.member,
                      style: AppTheme.tsBody.copyWith(color: Colors.blue),
                    ),
                  ),
                ),
                if (data.openDate != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                    margin: EdgeInsets.only(right: 5),
                    child: Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        vertical: 2.5,
                        horizontal: 10,
                      ),
                      child: Text(
                        data.openDate!,
                        style: AppTheme.tsBody.copyWith(color: Colors.blue),
                      ),
                    ),
                  ),
              ],
            ),
            if (data.openDate != null) _buildDivier(),
            if (data.openDate != null)
              Text(
                'Time slots & pricing',
                style: AppTheme.tsSubAdaptive(context),
              ),
            SizedBox(height: 10),
            if (data.openDate != null)
              Row(
                children: [
                  Text(
                    data.courtTime!,
                    style: AppTheme.tsBodyAdaptive(context),
                  ),
                  SizedBox(width: 5),
                  Text(data.priceInHour!, style: AppTheme.tsAccent),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

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
