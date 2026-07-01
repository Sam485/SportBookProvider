import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  List<SummaryData> summaryData = [
    SummaryData(title: 'Occupied', data: 6, color: Colors.cyan),
    SummaryData(title: 'Available', data: 2, color: Colors.green),
    SummaryData(title: 'Maintenance', data: 1, color: Colors.amber),
    SummaryData(title: 'Total', data: 9, color: Colors.white),
  ];
  List<TodayBooking> todayBooking = [
    TodayBooking(
      time: '09:00',
      duration: '2h',
      name: 'Mouy Lim',
      court: 'Tennis Court 1',
      status: 'Done',
      color: Colors.green,
    ),
    TodayBooking(
      time: '10:00',
      duration: '1h',
      name: 'Sphea Rith',
      court: 'Badminton Court 1',
      status: 'New',
      color: Colors.blue,
    ),
    TodayBooking(
      time: '11:30',
      duration: '1h',
      name: 'Dara Vuth',
      court: 'Tennis Court 1',
      status: 'Next',
      color: Colors.yellow,
    ),
  ];
  List<CourtOccupancy> occupancyData = [
    CourtOccupancy(
      title: 'Court 1',
      category: 'Badminton',
      userName: 'Sophea R.',
      time: '10:00-11:00 Am',
      progress: 30,
      color: Colors.blue,
      status: 'occupy',
    ),
    CourtOccupancy(
      title: 'Court 2',
      category: 'Badminton',
      userName: 'Available now',
      time: '11:30 AM',
      progress: 0,
      color: Colors.green,
      status: 'Available',
    ),
    CourtOccupancy(
      title: 'Court 3',
      category: 'Soccer',
      userName: 'Dara V. +9',
      time: '9:00-11:00 Am',
      progress: 90,
      color: Colors.blue,
      status: 'occupy',
    ),
    CourtOccupancy(
      title: 'Court 4',
      category: 'Tennis',
      userName: '',
      time: '11:00 Am',
      progress: 80,
      color: Colors.amber,
      status: 'Maintenance',
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
            SliverToBoxAdapter(child: _buildSummarySection()),
            SliverToBoxAdapter(child: _buildCourtOccupancy()),
            SliverToBoxAdapter(child: _buildBookingReport()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Monitor', style: AppTheme.tsTitle),
          const Spacer(),
          Container(
            width: 50,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated breathing dot
                AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    return Container(
                      width:
                          5 +
                          (3 *
                              _breathingController
                                  .value), // Expands from 5 to 8
                      height: 5 + (3 * _breathingController.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withValues(
                          alpha:
                              0.5 +
                              (0.5 *
                                  _breathingController.value), // Fades in/out
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 5),
                const Text('Live', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 65,
        child: ListView.builder(
          itemCount: summaryData.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return _buildSummaryCard(summaryData[index]);
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(SummaryData data) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.225,
      margin: const EdgeInsets.only(right: 8),
      decoration: AppTheme.cardDecorationAdaptive(
        context,
      ).copyWith(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.data.toString(),
            style: AppTheme.tsLabel.copyWith(fontSize: 18, color: data.color),
          ),
          Text(data.title, style: AppTheme.tsSubAdaptive(context)),
        ],
      ),
    );
  }

  Widget _buildCourtOccupancy() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Court occupancy', style: AppTheme.tsLabelAdaptive(context)),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 230,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: occupancyData.length,
              itemBuilder: (BuildContext context, int index) {
                return _occupancyCard(occupancyData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _occupancyCard(CourtOccupancy data) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: AppTheme.cardDecorationAdaptive(
        context,
      ).copyWith(border: Border.all(color: data.color.withValues(alpha: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: AppTheme.tsLabelAdaptive(context).copyWith(fontSize: 12),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: data.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Text(data.category, style: AppTheme.tsSubAdaptive(context)),
          Spacer(),
          if (data.status == 'occupy')
            Text(data.userName, style: AppTheme.tsSubAdaptive(context)),
          if (data.status == 'Available')
            Text(
              data.status.toUpperCase(),
              style: AppTheme.tsSubAdaptive(
                context,
              ).copyWith(color: data.color),
            ),
          if (data.status == 'Maintenance')
            Text(
              data.status.toUpperCase(),
              style: AppTheme.tsSubAdaptive(
                context,
              ).copyWith(color: data.color),
            ),

          Text(data.time, style: AppTheme.tsAccent.copyWith(fontSize: 11)),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            borderRadius: BorderRadius.circular(12),
            color: data.color,
            value: data.progress / 100,
            backgroundColor: AppTheme.kBorder,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingReport() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        height: 270,
        decoration: AppTheme.cardDecorationAdaptive(context),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Today's bookings", style: AppTheme.tsBody),
                  const Spacer(),
                  Text('24 total', style: AppTheme.tsAccent),
                ],
              ),
              const SizedBox(height: 10),
              ...List.generate(todayBooking.length, (index) {
                return Column(
                  children: [
                    _bookingData(todayBooking[index]),
                    if (todayBooking[index] != todayBooking.last)
                      _buildDivier(),
                  ],
                );
              }),
            ],
          ),
        ),
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

  Widget _bookingData(TodayBooking data) {
    return SizedBox(
      height: 60, // Increased height for better spacing
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data.time, style: AppTheme.tsAccent),
              Text(data.duration, style: AppTheme.tsBodyAdaptive(context)),
            ],
          ),
          SizedBox(
            height: 45,
            width: 20,
            child: VerticalDivider(color: data.color, thickness: 2),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data.name, style: AppTheme.tsLabelAdaptive(context)),
              Text(data.court, style: AppTheme.tsBodyAdaptive(context)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ), // Reduced vertical padding
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              data.status,
              style: AppTheme.tsLabel.copyWith(
                color: data.color,
                fontSize: 12, // Ensure font size is appropriate
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryData {
  final String title;
  final int data;
  final Color color;
  SummaryData({required this.title, required this.data, required this.color});
}

class TodayBooking {
  final String time;
  final String duration;
  final String name;
  final String court;
  final String status;
  final Color color;
  TodayBooking({
    required this.time,
    required this.duration,
    required this.name,
    required this.court,
    required this.status,
    required this.color,
  });
}

class CourtOccupancy {
  final String title;
  final String category;
  final String userName;
  final String time;
  final int progress;
  final Color color;
  final String status;
  CourtOccupancy({
    required this.title,
    required this.category,
    required this.userName,
    required this.time,
    required this.progress,
    required this.color,
    required this.status,
  });
}
