import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AlertType {
  fall,
  sos,
  abnormalVitals,
  medicationMissed,
  general
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical
}

enum AlertStatus {
  newAlert, // 'new' is a reserved keyword
  acknowledged,
  resolved
}

class Alert {
  final String id;
  final String patientId;
  final String patientName;
  final AlertType type;
  final AlertSeverity severity;
  final DateTime timestamp;
  final AlertStatus status;
  final String message;

  Alert({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.type,
    required this.severity,
    required this.timestamp,
    required this.status,
    required this.message,
  });

  factory Alert.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Alert(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? 'Unknown Patient',
      type: _parseType(data['type']),
      severity: _parseSeverity(data['severity']),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: _parseStatus(data['status']),
      message: data['message'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'type': type.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status.toString().split('.').last,
      'message': message,
    };
  }

  static AlertType _parseType(String? type) {
    return AlertType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => AlertType.general,
    );
  }

  static AlertSeverity _parseSeverity(String? severity) {
    return AlertSeverity.values.firstWhere(
      (e) => e.toString().split('.').last == severity,
      orElse: () => AlertSeverity.low,
    );
  }

  static AlertStatus _parseStatus(String? status) {
    return AlertStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => AlertStatus.newAlert,
    );
  }

  Color get severityColor {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.high:
        return Colors.orange;
      case AlertSeverity.medium:
        return Colors.amber;
      case AlertSeverity.low:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (type) {
      case AlertType.fall:
        return Icons.personal_injury;
      case AlertType.sos:
        return Icons.sos;
      case AlertType.abnormalVitals:
        return Icons.monitor_heart;
      case AlertType.medicationMissed:
        return Icons.medication_liquid;
      default:
        return Icons.notifications;
    }
  }
}
