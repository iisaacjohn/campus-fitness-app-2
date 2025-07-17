import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionnaireModel {
  final String title;
  final String description;
  final List<QuestionModel> questions;

  QuestionnaireModel({
    required this.title,
    required this.description,
    required this.questions,
  });

  factory QuestionnaireModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuestionnaireModel(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      questions: (data['questions'] as List<dynamic>?)
          ?.map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}

class QuestionModel {
  final int id;
  final String text;
  final String type; // 'dropdown', 'multiple_choice', 'open_ended'
  final List<String> options;
  final bool required;
  final String? placeholder;
  final FollowUpQuestion? followUp;

  QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.required,
    this.placeholder,
    this.followUp,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? 0,
      text: map['text'] ?? '',
      type: map['type'] ?? 'dropdown',
      options: List<String>.from(map['options'] ?? []),
      required: map['required'] ?? false,
      placeholder: map['placeholder'],
      followUp: map['follow_up'] != null 
          ? FollowUpQuestion.fromMap(map['follow_up'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'options': options,
      'required': required,
      'placeholder': placeholder,
      'follow_up': followUp?.toMap(),
    };
  }
}

class FollowUpQuestion {
  final String condition;
  final String text;
  final String type;

  FollowUpQuestion({
    required this.condition,
    required this.text,
    required this.type,
  });

  factory FollowUpQuestion.fromMap(Map<String, dynamic> map) {
    return FollowUpQuestion(
      condition: map['condition'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? 'open_ended',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'condition': condition,
      'text': text,
      'type': type,
    };
  }
}

class QuestionnaireResponse {
  final String id;
  final String userId;
  final String questionnaireType; // 'workout' or 'nutrition'
  final Map<String, dynamic> answers; // Changed from Map<int, dynamic> to Map<String, dynamic>
  final Map<String, String> followUpAnswers; // Changed from Map<int, String> to Map<String, String>
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestionnaireResponse({
    required this.id,
    required this.userId,
    required this.questionnaireType,
    required this.answers,
    required this.followUpAnswers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionnaireResponse.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuestionnaireResponse(
      id: doc.id,
      userId: data['userId'] ?? '',
      questionnaireType: data['questionnaireType'] ?? 'workout',
      answers: Map<String, dynamic>.from(data['answers'] ?? {}),
      followUpAnswers: Map<String, String>.from(data['followUpAnswers'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'questionnaireType': questionnaireType,
      'answers': answers,
      'followUpAnswers': followUpAnswers,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  QuestionnaireResponse copyWith({
    Map<String, dynamic>? answers,
    Map<String, String>? followUpAnswers,
    DateTime? updatedAt,
  }) {
    return QuestionnaireResponse(
      id: id,
      userId: userId,
      questionnaireType: questionnaireType,
      answers: answers ?? this.answers,
      followUpAnswers: followUpAnswers ?? this.followUpAnswers,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper method to convert int keys to string keys
  static QuestionnaireResponse fromIntKeys({
    required String id,
    required String userId,
    required String questionnaireType,
    required Map<int, dynamic> intAnswers,
    required Map<int, String> intFollowUpAnswers,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return QuestionnaireResponse(
      id: id,
      userId: userId,
      questionnaireType: questionnaireType,
      answers: intAnswers.map((key, value) => MapEntry(key.toString(), value)),
      followUpAnswers: intFollowUpAnswers.map((key, value) => MapEntry(key.toString(), value)),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
