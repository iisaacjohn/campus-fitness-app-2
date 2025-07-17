import 'package:cloud_firestore/cloud_firestore.dart';

class GymTrafficModel {
  final String id;
  final String gymId;
  final String dayOfWeek;
  final int hour; // 0-23
  final int currentCapacity;
  final int maxCapacity;
  final double trafficLevel; // 0.0 - 1.0
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  GymTrafficModel({
    required this.id,
    required this.gymId,
    required this.dayOfWeek,
    required this.hour,
    required this.currentCapacity,
    required this.maxCapacity,
    required this.trafficLevel,
    required this.timestamp,
    this.metadata,
  });

  factory GymTrafficModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GymTrafficModel(
      id: doc.id,
      gymId: data['gymId'] ?? '',
      dayOfWeek: data['dayOfWeek'] ?? '',
      hour: data['hour'] ?? 0,
      currentCapacity: data['currentCapacity'] ?? 0,
      maxCapacity: data['maxCapacity'] ?? 100,
      trafficLevel: (data['trafficLevel'] ?? 0.0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gymId': gymId,
      'dayOfWeek': dayOfWeek,
      'hour': hour,
      'currentCapacity': currentCapacity,
      'maxCapacity': maxCapacity,
      'trafficLevel': trafficLevel,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  String get trafficLevelText {
    if (trafficLevel < 0.3) return 'Low';
    if (trafficLevel < 0.7) return 'Moderate';
    return 'High';
  }

  String get trafficLevelColor {
    if (trafficLevel < 0.3) return 'green';
    if (trafficLevel < 0.7) return 'orange';
    return 'red';
  }
}
