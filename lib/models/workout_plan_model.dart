import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutPlanModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String difficulty; // 'Beginner', 'Intermediate', 'Advanced'
  final String primaryGoal; // From questionnaire
  final int durationWeeks;
  final int workoutsPerWeek;
  final int sessionDurationMinutes;
  final List<WorkoutDay> workoutDays;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? questionnaireResponseId; // Link to questionnaire response

  WorkoutPlanModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.primaryGoal,
    required this.durationWeeks,
    required this.workoutsPerWeek,
    required this.sessionDurationMinutes,
    required this.workoutDays,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.questionnaireResponseId,
  });

  factory WorkoutPlanModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkoutPlanModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      difficulty: data['difficulty'] ?? 'Beginner',
      primaryGoal: data['primaryGoal'] ?? '',
      durationWeeks: data['durationWeeks'] ?? 4,
      workoutsPerWeek: data['workoutsPerWeek'] ?? 3,
      sessionDurationMinutes: data['sessionDurationMinutes'] ?? 30,
      workoutDays: (data['workoutDays'] as List<dynamic>?)
          ?.map((e) => WorkoutDay.fromMap(e))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
      questionnaireResponseId: data['questionnaireResponseId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'primaryGoal': primaryGoal,
      'durationWeeks': durationWeeks,
      'workoutsPerWeek': workoutsPerWeek,
      'sessionDurationMinutes': sessionDurationMinutes,
      'workoutDays': workoutDays.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'questionnaireResponseId': questionnaireResponseId,
    };
  }
}

class WorkoutDay {
  final String dayName; // 'Day 1', 'Day 2', etc.
  final String focus; // 'Upper Body', 'Lower Body', 'Full Body', 'Cardio'
  final List<WorkoutExercise> exercises;
  final int estimatedDuration; // in minutes

  WorkoutDay({
    required this.dayName,
    required this.focus,
    required this.exercises,
    required this.estimatedDuration,
  });

  factory WorkoutDay.fromMap(Map<String, dynamic> map) {
    return WorkoutDay(
      dayName: map['dayName'] ?? '',
      focus: map['focus'] ?? '',
      exercises: (map['exercises'] as List<dynamic>?)
          ?.map((e) => WorkoutExercise.fromMap(e))
          .toList() ?? [],
      estimatedDuration: map['estimatedDuration'] ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayName': dayName,
      'focus': focus,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'estimatedDuration': estimatedDuration,
    };
  }
}

class WorkoutExercise {
  final String name;
  final String description;
  final String category; // 'strength', 'cardio', 'flexibility', 'warm_up', 'cool_down'
  final int? sets;
  final int? reps;
  final int? duration; // in seconds for time-based exercises
  final String? equipment;
  final String? instructions;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'

  WorkoutExercise({
    required this.name,
    required this.description,
    required this.category,
    this.sets,
    this.reps,
    this.duration,
    this.equipment,
    this.instructions,
    required this.difficulty,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'strength',
      sets: map['sets'],
      reps: map['reps'],
      duration: map['duration'],
      equipment: map['equipment'],
      instructions: map['instructions'],
      difficulty: map['difficulty'] ?? 'beginner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'equipment': equipment,
      'instructions': instructions,
      'difficulty': difficulty,
    };
  }

  String get displayText {
    if (sets != null && reps != null) {
      return '$sets sets x $reps reps';
    } else if (duration != null) {
      final minutes = duration! ~/ 60;
      final seconds = duration! % 60;
      if (minutes > 0) {
        return '${minutes}m ${seconds}s';
      } else {
        return '${seconds}s';
      }
    }
    return '';
  }
}
