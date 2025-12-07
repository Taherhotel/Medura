import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/vital_card.dart';
import '../widgets/fall_detection_card.dart';
import '../services/alert_service.dart';
import '../models/alert.dart';

class HomeView extends StatelessWidget {
  final String userName;

  const HomeView({super.key, required this.userName});

  Future<void> _sendSOS(BuildContext context) async {
    final alertService = AlertService();

    // Create a real SOS alert
    final sosAlert = Alert(
      id: '', // Firestore generates this
      patientId: 'current_user_id', // Ideally fetch real ID
      patientName: userName,
      type: AlertType.sos,
      severity: AlertSeverity.critical,
      timestamp: DateTime.now(),
      status: AlertStatus.newAlert,
      message: 'SOS Triggered by $userName! Immediate help needed.',
    );

    try {
      await alertService.createAlert(sosAlert);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS Alert Sent to Caregiver!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SOS: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=11', // Placeholder avatar
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Emergency SOS Section
          GestureDetector(
            onTap: () => _sendSOS(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sos, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Emergency Help',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Press for immediate assistance',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Vitals Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Vitals',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
          const SizedBox(height: 16),

          // Vitals Grid with StreamBuilder
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('devices')
                .doc('esp32_medura_01')
                .collection('readings')
                .orderBy('ts', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              // Default values if no data
              String heartRate = '--';
              String aqi = '--';
              String temperature = '--';
              String spo2 = '--';

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final data =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;
                // Assuming fields: heartRate, gasAQI, temperature, spo2
                heartRate = data['heartRate']?.toString() ?? '--';
                aqi = data['gasAQI']?.toString() ?? '--';
                temperature = data['temperature']?.toString() ?? '--';
                spo2 = data['spo2']?.toString() ?? '--';
              }

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  VitalCard(
                    title: 'Heart Rate',
                    value: heartRate,
                    unit: 'bpm',
                    icon: Icons.favorite_rounded,
                    color: Colors.redAccent,
                  ),
                  VitalCard(
                    title: 'AQI',
                    value: aqi,
                    unit: '',
                    icon: Icons.cloud_outlined,
                    color: Colors.green,
                  ),
                  VitalCard(
                    title: 'Temperature',
                    value: temperature,
                    unit: '°C',
                    icon: Icons.thermostat_rounded,
                    color: Colors.orangeAccent,
                  ),
                  VitalCard(
                    title: 'SpO2',
                    value: spo2,
                    unit: '%',
                    icon: Icons.air_rounded,
                    color: Colors.lightBlueAccent,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Fall Detection Card (New Feature)
          const FallDetectionCard(),
        ],
      ),
    );
  }
}
