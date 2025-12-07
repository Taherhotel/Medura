import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/medication.dart';

class MedicationScheduleScreen extends StatefulWidget {
  final String userId;
  final bool isCaregiverView;

  const MedicationScheduleScreen({
    super.key,
    required this.userId,
    this.isCaregiverView = false,
  });

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    // Configure TTS for better compatibility
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    // iOS specific settings
    await flutterTts.setSharedInstance(true);
    await flutterTts
        .setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        ]);

    // Add awaiting for completion
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speakMedication(Medication med) async {
    // Ensure stop previous speech
    await flutterTts.stop();

    String textToSpeak = "Take ${med.dosage} of ${med.name} at ${med.time}.";

    if (med.notes.isNotEmpty) {
      textToSpeak += " Note: ${med.notes}";
    }

    await flutterTts.speak(textToSpeak);
  }

  Future<void> _toggleTaken(Medication med) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('medications')
        .doc(med.id)
        .update({'taken': !med.taken});
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Color _getTimeColor(String time) {
    if (time.toLowerCase().contains('am')) {
      // Morning
      return Colors.orangeAccent;
    } else {
      // Afternoon/Evening (PM)
      // Simple heuristic: if it starts with 12, 1, 2, 3, 4 -> Afternoon (Blue)
      // 5, 6, 7, 8, 9, 10, 11 -> Evening (Indigo/Purple)
      // This is a rough estimation since time format is string
      if (time.startsWith('5') ||
          time.startsWith('6') ||
          time.startsWith('7') ||
          time.startsWith('8') ||
          time.startsWith('9') ||
          time.startsWith('10') ||
          time.startsWith('11')) {
        return Colors.indigoAccent;
      }
      return Colors.lightBlueAccent;
    }
  }

  Widget _buildMedicationCard(BuildContext context, Medication med) {
    final timeColor = _getTimeColor(med.time);

    return GestureDetector(
      onTap: () {
        if (!widget.isCaregiverView) {
          _speakMedication(med);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Color Strip
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: med.taken ? Colors.green : timeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (med.taken ? Colors.green : timeColor)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: med.taken ? Colors.green : timeColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  med.time,
                                  style: TextStyle(
                                    color: med.taken ? Colors.green : timeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (med.taken)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'TAKEN',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (!widget.isCaregiverView)
                            Icon(
                              Icons.volume_up_rounded,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.5),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        med.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: med.taken
                              ? Colors.grey
                              : Theme.of(context).colorScheme.onSurface,
                          decoration: med.taken
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.medication,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            med.dosage,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      if (med.notes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
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
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!widget.isCaregiverView && !med.taken) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Reminder set for 10 mins later',
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: const BorderSide(color: Colors.orange),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Snooze'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _toggleTaken(med),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Take'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (med.taken && !widget.isCaregiverView) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _toggleTaken(med),
                            icon: const Icon(Icons.undo, size: 16),
                            label: const Text('Undo'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
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
              return _buildMedicationCard(context, med);
            },
          );
        },
      ),
    );
  }
}
