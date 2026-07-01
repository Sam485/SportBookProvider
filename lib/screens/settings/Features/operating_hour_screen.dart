import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';

class OperatingHourScreen extends StatefulWidget {
  const OperatingHourScreen({super.key});

  @override
  State<OperatingHourScreen> createState() => _OperatingHourScreenState();
}

class _OperatingHourScreenState extends State<OperatingHourScreen> {
  List<WeeklyData> weeklySchedule = [
    WeeklyData(
      title: 'Mon',
      status: true,
      startHour: '6:00 AM',
      endHour: '10:00 PM',
    ),
    WeeklyData(
      title: 'Tue',
      status: true,
      startHour: '6:00 Am',
      endHour: '10:00 PM',
    ),
    WeeklyData(
      title: 'Wed',
      status: true,
      startHour: '6:00 AM',
      endHour: '10:00 PM',
    ),
    WeeklyData(
      title: 'Thu',
      status: true,
      startHour: '6:00 AM',
      endHour: '10:00 PM',
    ),
    WeeklyData(
      title: 'Fri',
      status: true,
      startHour: '6:00 AM',
      endHour: '10:00 PM',
    ),
    WeeklyData(
      title: 'Sat',
      status: true,
      startHour: '6:00 AM',
      endHour: '11:00 PM',
    ),
    WeeklyData(
      title: 'Sun',
      status: false,
      startHour: '6:00 AM',
      endHour: '10:00 PM',
    ),
  ];
  List<SpecialData> specialHours = [
    SpecialData(
      icon: Icons.party_mode,
      title: 'Khmer New Year',
      date: 'Apr 13-15, 2026',
      status: 'Closed',
    ),
    SpecialData(
      icon: Icons.water,
      title: 'Water Festival',
      date: 'Nov 5-7,2026',
      status: '8AM-6PM',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Operating hours')),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: _buildGuiding()),
            SliverToBoxAdapter(child: _buildSchedule()),
            SliverToBoxAdapter(child: _buildSpeicalHour()),
          ],
        ),
      ),
    );
  }

  Widget _buildGuiding() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: AppTheme.cardDecorationAdaptive(context),
        child: Text(
          'Change apply from tomorrow. Customers with existing bookings outside new hours will be notified automatically!',
          style: AppTheme.tsBodyAdaptive(context),
        ),
      ),
    );
  }

  Widget _buildSchedule() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly schedule', style: AppTheme.tsLabelAdaptive(context)),
          const SizedBox(height: 10),
          ...List.generate(
            weeklySchedule.length,
            (index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              margin: EdgeInsets.only(bottom: 10),
              decoration: weeklySchedule[index].status == false
                  ? AppTheme.cardDecorationAdaptive(
                      context,
                    ).copyWith(color: AppTheme.kCard.withValues(alpha: 0.5))
                  : AppTheme.cardDecorationAdaptive(context),
              child: Row(
                children: [
                  Text(
                    weeklySchedule[index].title,
                    style: AppTheme.tsLabelAdaptive(
                      context,
                    ).copyWith(fontSize: 14),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    height: 20,
                    child: Switch(
                      value: weeklySchedule[index].status,
                      onChanged: (value) {
                        setState(() {
                          weeklySchedule[index].status = value;
                        });
                      },
                    ),
                  ),
                  Spacer(),
                  if (weeklySchedule[index].status == true)
                    Container(
                      decoration: AppTheme.cardDecorationAdaptive(context),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(weeklySchedule[index].startHour),
                    ),
                  if (weeklySchedule[index].status == true) SizedBox(width: 5),
                  if (weeklySchedule[index].status == true)
                    SizedBox(
                      width: 10,
                      child: Divider(color: AppTheme.kTextSub),
                    ),
                  if (weeklySchedule[index].status == true) SizedBox(width: 5),

                  if (weeklySchedule[index].status == true)
                    Container(
                      decoration: AppTheme.cardDecorationAdaptive(context),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(weeklySchedule[index].endHour),
                    ),

                  if (weeklySchedule[index].status == false)
                    Text('Closed', style: AppTheme.tsBodyAdaptive(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeicalHour() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Special hours', style: AppTheme.tsLabelAdaptive(context)),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: AppTheme.cardDecorationAdaptive(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(
                  specialHours.length,
                  (index) => SizedBox(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text('NY', style: AppTheme.tsAccent),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Khmer New Year',
                                  style: AppTheme.tsLabelAdaptive(
                                    context,
                                  ).copyWith(fontSize: 14),
                                ),
                                Text(
                                  'Apr 13 - 15,2026',
                                  style: AppTheme.tsBodyAdaptive(context),
                                ),
                              ],
                            ),
                            Spacer(),
                            Text('closed', style: AppTheme.tsAccent),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Divider(
                            color: AppTheme.kTextSub,
                            thickness: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text('Add special hours', style: AppTheme.tsAccent),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: AppTheme.elevatedButtonStyle(),
              child: Text('Save Change'),
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyData {
  final String title;
  bool status;
  final String startHour;
  final String endHour;

  WeeklyData({
    required this.title,
    required this.status,
    required this.startHour,
    required this.endHour,
  });
}

class SpecialData {
  final IconData icon;
  final String title;
  final String date;
  final String status;

  SpecialData({
    required this.icon,
    required this.title,
    required this.date,
    required this.status,
  });
}
