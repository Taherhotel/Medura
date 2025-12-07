import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class FallDetectionCard extends StatefulWidget {
  final bool useFirestoreData;

  const FallDetectionCard({super.key, this.useFirestoreData = false});

  @override
  State<FallDetectionCard> createState() => _FallDetectionCardState();
}

class _FallDetectionCardState extends State<FallDetectionCard> {
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // Sensor values
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;
  double _accelG = 0.0;

  double _gyroX = 0.0;
  double _gyroY = 0.0;
  double _gyroZ = 0.0;

  // Fall detection thresholds (simplified)
  final double _fallThreshold = 30.0; // m/s^2 total acceleration
  bool _possibleFallDetected = false;

  @override
  void initState() {
    super.initState();
    if (!widget.useFirestoreData) {
      _initSensors();
    }
  }

  void _initSensors() {
    _accelerometerSubscription = userAccelerometerEvents.listen((
      UserAccelerometerEvent event,
    ) {
      if (mounted) {
        setState(() {
          _accelX = event.x;
          _accelY = event.y;
          _accelZ = event.z;
          _checkFall(_accelX, _accelY, _accelZ);
        });
      }
    });

    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          _gyroX = event.x;
          _gyroY = event.y;
          _gyroZ = event.z;
        });
      }
    });
  }

  void _checkFall(double x, double y, double z) {
    double magnitude = (x.abs() + y.abs() + z.abs());
    if (magnitude > _fallThreshold) {
      _possibleFallDetected = true;
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _possibleFallDetected = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useFirestoreData) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('devices')
            .doc('esp32_medura_01')
            .collection('readings')
            .orderBy('ts', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final data =
                snapshot.data!.docs.first.data() as Map<String, dynamic>;
            _accelX = (data['ax'] ?? 0.0).toDouble();
            _accelY = (data['ay'] ?? 0.0).toDouble();
            _accelZ = (data['az'] ?? 0.0).toDouble();
            _accelG = (data['accelG'] ?? 0.0).toDouble();

            // Use explicit fall detected flag from IoT device
            _possibleFallDetected = data['fallDetected'] ?? false;

            // Clear gyro as it's not provided in IoT data
            _gyroX = 0.0;
            _gyroY = 0.0;
            _gyroZ = 0.0;
          }
          return _buildCardContent();
        },
      );
    }

    return _buildCardContent();
  }

  Widget _buildCardContent() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: _possibleFallDetected
          ? Theme.of(context).colorScheme.error.withOpacity(0.2)
          : Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: _possibleFallDetected
            ? BorderSide(color: Theme.of(context).colorScheme.error, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_run_rounded, // Falling icon metaphor
                      color: _possibleFallDetected
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.secondary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Fall Detection',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                if (_possibleFallDetected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'FALL DETECTED!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.useFirestoreData) ...[
              _buildSensorRow('Accelerometer (Raw)', _accelX, _accelY, _accelZ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Impact Force',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[400]),
                        ),
                        Text(
                          '${_accelG.toStringAsFixed(2)} G',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              _buildSensorRow(
                'Accelerometer (m/s²)',
                _accelX,
                _accelY,
                _accelZ,
              ),
              const Divider(height: 24, color: Colors.white10),
              _buildSensorRow('Gyroscope (rad/s)', _gyroX, _gyroY, _gyroZ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSensorRow(String title, double x, double y, double z) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[400],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildValue('X', x),
            _buildValue('Y', y),
            _buildValue('Z', z),
          ],
        ),
      ],
    );
  }

  Widget _buildValue(String label, double value) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(2),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
