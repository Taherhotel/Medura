import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class FallDetectionCard extends StatefulWidget {
  const FallDetectionCard({super.key});

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
  
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  double _gyroZ = 0.0;

  // Fall detection thresholds (simplified)
  // In a real app, this would require complex algorithms
  final double _fallThreshold = 30.0; // m/s^2 total acceleration
  bool _possibleFallDetected = false;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    _accelerometerSubscription = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (mounted) {
        setState(() {
          _accelX = event.x;
          _accelY = event.y;
          _accelZ = event.z;

          // Simple magnitude calculation
          double magnitude = (_accelX.abs() + _accelY.abs() + _accelZ.abs());
          
          if (magnitude > _fallThreshold) {
            _possibleFallDetected = true;
            // Auto-reset after 3 seconds for demo purposes
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _possibleFallDetected = false;
                });
              }
            });
          }
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

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            _buildSensorRow('Accelerometer (m/s²)', _accelX, _accelY, _accelZ),
            const Divider(height: 24, color: Colors.white10),
            _buildSensorRow('Gyroscope (rad/s)', _gyroX, _gyroY, _gyroZ),
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
