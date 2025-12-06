import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String time; // e.g., "08:00 AM"
  final String recurrence; // e.g., "Daily", "Weekly"
  final String notes;
  final bool taken;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.recurrence,
    required this.notes,
    this.taken = false,
  });

  factory Medication.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Medication(
      id: doc.id,
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      time: data['time'] ?? '',
      recurrence: data['recurrence'] ?? '',
      notes: data['notes'] ?? '',
      taken: data['taken'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'time': time,
      'recurrence': recurrence,
      'notes': notes,
      'taken': taken,
    };
  }
}
