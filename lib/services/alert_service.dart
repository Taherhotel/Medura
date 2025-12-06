import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert.dart';

class AlertService {
  final CollectionReference _alertsCollection = FirebaseFirestore.instance
      .collection('alerts');

  Stream<List<Alert>> getAlertsForCaregiver() {
    // In a real app, filter by caregiverId or assigned patients
    // For now, return all alerts ordered by timestamp
    return _alertsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Alert.fromFirestore(doc)).toList();
        });
  }

  Future<void> updateAlertStatus(String alertId, AlertStatus status) async {
    await _alertsCollection.doc(alertId).update({
      'status': status.toString().split('.').last,
    });
  }

  Future<void> createAlert(Alert alert) async {
    await _alertsCollection.add(alert.toMap());
  }

  // Helper to seed some data for demo
  Future<void> seedDemoAlerts() async {
    final snapshot = await _alertsCollection.limit(1).get();
    if (snapshot.docs.isEmpty) {
      final List<Alert> demoAlerts = [
        Alert(
          id: '',
          patientId: 'elder1',
          patientName: 'John Doe',
          type: AlertType.sos,
          severity: AlertSeverity.critical,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          status: AlertStatus.newAlert,
          message: 'SOS Button Pressed! Immediate assistance requested.',
        ),
        Alert(
          id: '',
          patientId: 'elder2',
          patientName: 'Jane Smith',
          type: AlertType.fall,
          severity: AlertSeverity.high,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          status: AlertStatus.newAlert,
          message: 'Fall detected in Living Room.',
        ),
        Alert(
          id: '',
          patientId: 'elder1',
          patientName: 'John Doe',
          type: AlertType.abnormalVitals,
          severity: AlertSeverity.medium,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          status: AlertStatus.acknowledged,
          message: 'Heart rate elevated (110 bpm) while resting.',
        ),
        Alert(
          id: '',
          patientId: 'elder3',
          patientName: 'Robert Brown',
          type: AlertType.medicationMissed,
          severity: AlertSeverity.low,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          status: AlertStatus.resolved,
          message: 'Missed afternoon dosage of Metformin.',
        ),
      ];

      for (var alert in demoAlerts) {
        await _alertsCollection.add(alert.toMap());
      }
    }
  }
}
