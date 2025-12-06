import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alert.dart';
import '../services/alert_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertService _alertService = AlertService();

  @override
  void initState() {
    super.initState();
    // Seed data if empty (for demo purposes)
    _alertService.seedDemoAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Alert>>(
        stream: _alertService.getAlertsForCaregiver(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No alerts at the moment',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _buildAlertCard(alert);
            },
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(Alert alert) {
    final isNew = alert.status == AlertStatus.newAlert;
    final timeStr = DateFormat('MMM d, h:mm a').format(alert.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isNew ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isNew
            ? BorderSide(color: alert.severityColor.withOpacity(0.5), width: 1.5)
            : BorderSide.none,
      ),
      color: isNew
          ? alert.severityColor.withOpacity(0.05)
          : Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: alert.severityColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(alert.icon, color: alert.severityColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            alert.type.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              color: alert.severityColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Patient: ${alert.patientName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (alert.status != AlertStatus.resolved) ...[
                  if (alert.status == AlertStatus.newAlert)
                    TextButton.icon(
                      onPressed: () {
                        _alertService.updateAlertStatus(
                            alert.id, AlertStatus.acknowledged);
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Acknowledge'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _alertService.updateAlertStatus(
                          alert.id, AlertStatus.resolved);
                    },
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Resolve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.black, // Contrast text
                      elevation: 0,
                    ),
                  ),
                ] else
                  Chip(
                    label: const Text('Resolved'),
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.green, fontSize: 12),
                    side: BorderSide.none,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
