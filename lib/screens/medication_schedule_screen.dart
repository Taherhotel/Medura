import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication.dart';

class MedicationScheduleScreen extends StatelessWidget {
  final String userId;
  final bool isCaregiverView;

  const MedicationScheduleScreen({
    super.key,
    required this.userId,
    this.isCaregiverView = false,
  });

  Future<void> _toggleTaken(Medication med) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('medications')
        .doc(med.id)
        .update({'taken': !med.taken});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('medications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No medications scheduled',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final med = Medication.fromFirestore(snapshot.data!.docs[index]);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: med.taken
                      ? BorderSide(color: Colors.green.withOpacity(0.5))
                      : BorderSide.none,
                ),
                color: med.taken ? Colors.green[50] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med.name,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: med.taken
                                            ? Colors.green[800]
                                            : Colors.black87,
                                        decoration: med.taken
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      med.time,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.medical_services_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      med.dosage,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!isCaregiverView)
                            _buildActionButtons(context, med),
                        ],
                      ),
                      if (med.notes.isNotEmpty) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                med.notes,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Medication med) {
    if (med.taken) {
      return TextButton.icon(
        onPressed: () => _toggleTaken(med),
        icon: const Icon(Icons.undo),
        label: const Text('Undo'),
        style: TextButton.styleFrom(foregroundColor: Colors.green),
      );
    }

    return Row(
      children: [
        IconButton(
          onPressed: () {
            // Remind later logic (could be local notification)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reminder set for 10 mins later')),
            );
          },
          icon: const Icon(Icons.snooze),
          color: Colors.orange,
          tooltip: 'Remind me later',
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _toggleTaken(med),
          icon: const Icon(Icons.check),
          label: const Text('Taken'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
