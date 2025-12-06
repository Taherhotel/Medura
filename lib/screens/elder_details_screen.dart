import 'package:flutter/material.dart';
import 'profile_screen.dart';
import '../widgets/vital_card.dart';
import 'add_medication_screen.dart';
import 'medication_schedule_screen.dart';
import '../widgets/live_monitor_dashboard.dart';

class ElderDetailsScreen extends StatefulWidget {
  final String elderId;
  final String elderName;

  const ElderDetailsScreen({
    super.key,
    required this.elderId,
    required this.elderName,
  });

  @override
  State<ElderDetailsScreen> createState() => _ElderDetailsScreenState();
}

class _ElderDetailsScreenState extends State<ElderDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  widget.elderName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.grey[50]),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Hero(
                            tag: 'avatar_${widget.elderId}',
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                  'https://i.pravatar.cc/150?img=11',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(icon: Icon(Icons.show_chart_rounded), text: 'Monitor'),
                    Tab(
                      icon: Icon(Icons.monitor_heart_outlined),
                      text: 'Vitals',
                    ),
                    Tab(icon: Icon(Icons.medication_outlined), text: 'Meds'),
                    Tab(icon: Icon(Icons.person_outline), text: 'Profile'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Monitor Tab
            const LiveMonitorDashboard(),
            // Vitals Tab
            _buildVitalsTab(),
            // Medications Tab
            Scaffold(
              backgroundColor: Colors.transparent,
              body: MedicationScheduleScreen(
                userId: widget.elderId,
                isCaregiverView: true,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddMedicationScreen(elderId: widget.elderId),
                    ),
                  );
                },
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              ),
            ),
            // Profile Tab
            ProfileScreen(userId: widget.elderId),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Vitals',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: const [
              VitalCard(
                title: 'Heart Rate',
                value: '72',
                unit: 'bpm',
                icon: Icons.favorite_rounded,
                color: Colors.redAccent,
              ),
              VitalCard(
                title: 'Blood Pressure',
                value: '120/80',
                unit: 'mmHg',
                icon: Icons.water_drop_rounded,
                color: Colors.pinkAccent,
              ),
              VitalCard(
                title: 'Temperature',
                value: '36.6',
                unit: '°C',
                icon: Icons.thermostat_rounded,
                color: Colors.orangeAccent,
              ),
              VitalCard(
                title: 'SpO2',
                value: '98',
                unit: '%',
                icon: Icons.air_rounded,
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
