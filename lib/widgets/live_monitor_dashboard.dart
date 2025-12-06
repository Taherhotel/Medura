import 'dart:async';
import 'package:flutter/material.dart';

class LiveMonitorDashboard extends StatefulWidget {
  const LiveMonitorDashboard({super.key});

  @override
  State<LiveMonitorDashboard> createState() => _LiveMonitorDashboardState();
}

class _LiveMonitorDashboardState extends State<LiveMonitorDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _timer;
  int _heartRate = 72;
  double _batteryLevel = 0.85;
  String _lastSynced = 'Just now';
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    // Pulse Animation Setup
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Simulation Timer
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // Fluctuate heart rate slightly
          _heartRate = 70 + (DateTime.now().second % 5);
          // Drain battery slowly
          if (_batteryLevel > 0) _batteryLevel -= 0.001;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Connection Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDeviceIcon(Icons.watch_rounded, 'Device'),
                    _buildConnectionLine(true),
                    _buildDeviceIcon(Icons.smartphone_rounded, 'Phone'),
                    _buildConnectionLine(true),
                    _buildDeviceIcon(Icons.cloud_done_rounded, 'Cloud'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isConnected ? 'System Online' : 'Connection Lost',
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Synced: $_lastSynced',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Live Heart Rate Pulse
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.redAccent.shade100, Colors.redAccent.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 20),
                  const SizedBox(height: 8),
                  Text(
                    '$_heartRate',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'BPM',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Battery & Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Battery',
                '${(_batteryLevel * 100).toInt()}%',
                Icons.battery_std_rounded,
                Colors.green,
                isBattery: true,
              ),
              _buildStatCard(
                'Temperature',
                '36.6 °C',
                Icons.thermostat_rounded,
                Colors.orange,
              ),
              _buildStatCard(
                'Steps',
                '2,431',
                Icons.directions_walk_rounded,
                Colors.blue,
              ),
              _buildStatCard(
                'Sleep',
                '7h 12m',
                Icons.bedtime_rounded,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildConnectionLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? Colors.green : Colors.grey[300],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isBattery = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              if (isBattery)
                Icon(
                  Icons.circle,
                  size: 8,
                  color: _batteryLevel > 0.2 ? Colors.green : Colors.red,
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
