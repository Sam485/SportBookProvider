import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final List<StatCardData> _statsData = [
    StatCardData(
      title: "Today's Bookings",
      value: '24',
      description: '+3 vs yesterday',
      desColor: Colors.green,
    ),
    StatCardData(
      title: 'Revenue Today',
      value: '\$480',
      description: '+12%',
      desColor: Colors.green,
    ),
    StatCardData(
      title: 'Active Courts',
      value: '6/8',
      description: '2 available',
      desColor: Colors.orange,
    ),
    StatCardData(
      title: 'Avg. Occupancy',
      value: '78%',
      description: '-5% vs avg',
      desColor: Colors.red,
    ),
  ];

  final List<RecentBooking> _recentBooking = [
    RecentBooking(
      inital: 'SR',
      userName: 'Sophea Rith',
      courtName: 'Badminton Court 3',
      time: '10:00 AM',
      status: 'Confirm',
      statusColor: Colors.green,
    ),
    RecentBooking(
      inital: 'DV',
      userName: 'Dara Vuth',
      courtName: 'Futsal Field 1',
      time: '11:30 AM',
      status: 'Pending',
      statusColor: Colors.amber,
    ),
    RecentBooking(
      inital: 'ML',
      userName: 'Mouy Lim',
      courtName: 'Tennis Court 1',
      time: '9:00 AM',
      status: 'Done',
      statusColor: Colors.grey,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // Header
            SliverToBoxAdapter(child: _buildHeader()),

            // Stats Grid - CORRECTED: SliverGrid directly as a sliver
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildStatCard(_statsData[index]),
                  childCount: _statsData.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
              ),
            ),

            // SliverToBoxAdapter(child: _buildWeeklyBookingsSection()),
            SliverToBoxAdapter(child: _buildWeeklyBooking()),
            SliverToBoxAdapter(child: _buildMonthlyBooking()),
            SliverToBoxAdapter(child: _buildRecentBooking()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              Text(
                'Wednesday, 11 June 2026',
                style: AppTheme.tsSubAdaptive(context),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(StatCardData data) {
    return Container(
      decoration: AppTheme.cardDecorationAdaptive(context),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.title,
              style: AppTheme.tsBodyAdaptive(
                context,
              ).copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              data.value,
              style: AppTheme.tsTitleAdaptive(
                context,
              ).copyWith(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              data.description,
              style: AppTheme.tsSubAdaptive(
                context,
              ).copyWith(color: data.desColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBooking() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: AppTheme.cardDecorationAdaptive(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Bookings',
                    style: AppTheme.tsBodyAdaptive(context),
                  ),
                  Spacer(),
                  Text('June 2026', style: AppTheme.tsBodyAdaptive(context)),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: 65,
                            color: AppTheme.kAccent.withOpacity(0.5),
                            width: 45,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: 80,
                            color: AppTheme.kAccent.withOpacity(0.5),
                            width: 45,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: 45,
                            color: AppTheme.kAccent,
                            width: 45,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            toY: 95,
                            color: AppTheme.kAccent.withOpacity(0.5),
                            width: 45,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 4,
                        barRods: [
                          BarChartRodData(
                            toY: 23,
                            color: AppTheme.kAccent.withOpacity(0.5),
                            width: 45,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 5,
                        barRods: [
                          BarChartRodData(
                            toY: 67,
                            color: AppTheme.kAccent.withOpacity(0.5),
                            width: 45,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun',
                            ];
                            return Text(days[value.toInt()]);
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: false,
                    ), // Removes dotted white lines
                    borderData: FlBorderData(
                      show: false,
                    ), // Removes X and Y axis lines
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyBooking() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: AppTheme.cardDecorationAdaptive(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Bookings', // Changed from 'Weekly Bookings' to 'Monthly Bookings'
                    style: AppTheme.tsBodyAdaptive(context),
                  ),
                  Spacer(),
                  Text(
                    '2026',
                    style: AppTheme.tsBodyAdaptive(context),
                  ), // Changed to show year
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: LineChart(
                    LineChartData(
                      maxY: 100,
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 65), // March
                            FlSpot(1, 80), // April
                            FlSpot(2, 45), // May
                            FlSpot(3, 95), // June
                          ],
                          isCurved: false,
                          color: Colors.blue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.blue,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1, // Force showing every tick
                            getTitlesWidget: (value, meta) {
                              const months = ['March', 'April', 'May', 'June'];
                              // Only show title if value is exactly 0,1,2,3
                              if (value.toInt() >= 0 &&
                                  value.toInt() < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    months[value.toInt()],
                                    style: AppTheme.tsBodyAdaptive(context),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize:
                                40, // Increased to accommodate month names
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(enabled: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBooking() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: AppTheme.cardDecorationAdaptive(context),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Recent Bookings',
                  style: AppTheme.tsLabelAdaptive(context),
                ),
                Spacer(),
                Text('See all', style: AppTheme.tsAccent),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(_recentBooking.length, (index) {
              return Column(
                children: [
                  _buildRecentBody(_recentBooking[index]),
                  if (_recentBooking[index] != _recentBooking.last)
                    _buildDivier(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBody(RecentBooking data) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: data.statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              data.inital,
              style: AppTheme.tsLabel.copyWith(color: data.statusColor),
            ),
          ),
        ),
        SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.userName, style: AppTheme.tsTitle),
            Text(data.courtName, style: AppTheme.tsSubAdaptive(context)),
          ],
        ),
        Spacer(),
        Column(
          children: [
            Text(data.time, style: AppTheme.tsAccent),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              height: 25,
              decoration: BoxDecoration(
                color: data.statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  data.status,
                  style: AppTheme.tsBody.copyWith(color: data.statusColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivier() {
    return SizedBox(
      width: double.infinity,
      child: Divider(thickness: 0.5, color: AppTheme.kAccent.withOpacity(0.6)),
    );
  }
}

class StatCardData {
  final String title;
  final String value;
  final String description;
  final Color desColor;

  StatCardData({
    required this.title,
    required this.value,
    required this.description,
    required this.desColor,
  });
}

class RecentBooking {
  final String inital;
  final String userName;
  final String courtName;
  final String time;
  final String status;
  final Color statusColor;

  RecentBooking({
    required this.inital,
    required this.userName,
    required this.courtName,
    required this.time,
    required this.status,
    required this.statusColor,
  });
}
