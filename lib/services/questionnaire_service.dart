import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/questionnaire_model.dart';

class QuestionnaireService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collections
  static const String questionnaireCollection = 'questionnaire';
  static const String questionnaireResponsesCollection = 'questionnaire_responses';

  // Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  // Get workout questionnaire
  static Future<QuestionnaireModel?> getWorkoutQuestionnaire() async {
    try {
      // Check authentication first
      if (!isAuthenticated) {
        throw Exception('User not authenticated. Please log in first.');
      }

      print('Fetching workout questionnaire for user: ${_auth.currentUser?.uid}');
      
      final doc = await _firestore
          .collection(questionnaireCollection)
          .doc('workout')
          .get();
      
      if (doc.exists) {
        print('Workout questionnaire found');
        return QuestionnaireModel.fromFirestore(doc);
      } else {
        print('Workout questionnaire document does not exist');
        return null;
      }
    } catch (e) {
      print('Error getting workout questionnaire: $e');
      rethrow;
    }
  }

  // Save questionnaire response
  static Future<String?> saveQuestionnaireResponse(QuestionnaireResponse response) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated. Please log in first.');
      }

      final docRef = await _firestore
          .collection(questionnaireResponsesCollection)
          .add(response.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error saving questionnaire response: $e');
      rethrow;
    }
  }

  // Get user's latest questionnaire response
  static Future<QuestionnaireResponse?> getUserLatestResponse(
    String userId, 
    String questionnaireType
  ) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated. Please log in first.');
      }

      final querySnapshot = await _firestore
          .collection(questionnaireResponsesCollection)
          .where('userId', isEqualTo: userId)
          .where('questionnaireType', isEqualTo: questionnaireType)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return QuestionnaireResponse.fromFirestore(querySnapshot.docs.first);
      }
    } catch (e) {
      print('Error getting user latest response: $e');
    }
    return null;
  }

  // Update questionnaire response
  static Future<void> updateQuestionnaireResponse(QuestionnaireResponse response) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated. Please log in first.');
      }

      await _firestore
          .collection(questionnaireResponsesCollection)
          .doc(response.id)
          .update(response.toFirestore());
    } catch (e) {
      print('Error updating questionnaire response: $e');
      rethrow;
    }
  }

  // Get all user responses
  static Future<List<QuestionnaireResponse>> getUserResponses(String userId) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated. Please log in first.');
      }

      final querySnapshot = await _firestore
          .collection(questionnaireResponsesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => QuestionnaireResponse.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user responses: $e');
      return [];
    }
  }

  // Helper method to validate answers
  static bool validateAnswers(QuestionnaireModel questionnaire, Map<int, dynamic> answers) {
    for (final question in questionnaire.questions) {
      if (question.required && !answers.containsKey(question.id)) {
        return false;
      }
      
      // Validate answer format based on question type
      final answer = answers[question.id];
      if (answer != null) {
        switch (question.type) {
          case 'dropdown':
            if (answer is! String || !question.options.contains(answer)) {
              return false;
            }
            break;
          case 'multiple_choice':
            if (answer is! List || 
                !(answer as List).every((item) => question.options.contains(item))) {
              return false;
            }
            break;
          case 'open_ended':
            if (answer is! String) {
              return false;
            }
            break;
        }
      }
    }
    return true;
  }

  // Helper method to check if follow-up is needed
  static bool needsFollowUp(QuestionModel question, dynamic answer) {
    if (question.followUp == null) return false;
    
    final condition = question.followUp!.condition;
    
    // Handle different condition formats
    if (condition.startsWith('Not ')) {
      final excludedValue = condition.substring(5).replaceAll('"', '').replaceAll("'", "");
      return answer != excludedValue;
    } else {
      final requiredValue = condition.replaceAll('"', '').replaceAll("'", "");
      return answer == requiredValue;
    }
  }
}
