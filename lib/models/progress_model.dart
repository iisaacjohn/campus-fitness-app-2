import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String id;
  final String userId;
  final DateTime date;
  final String workoutId;
  final int duration; // in minutes
  final int caloriesBurned;
  final Map<String, dynamic> exerciseData;
  final String notes;
  final DateTime createdAt;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.workoutId,
    required this.duration,
    required this.caloriesBurned,
    required this.exerciseData,
    required this.notes,
    required this.createdAt,
  });

  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProgressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      workoutId: data['workoutId'] ?? '',
      duration: data['duration'] ?? 0,
      caloriesBurned: data['caloriesBurned'] ?? 0,
      exerciseData: data['exerciseData'] ?? {},
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'workoutId': workoutId,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'exerciseData': exerciseData,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
