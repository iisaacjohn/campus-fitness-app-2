import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/questionnaire_model.dart';

class HybridQuestionnaireService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collections
  static const String questionnaireCollection = 'questionnaire';
  static const String questionnaireResponsesCollection = 'questionnaire_responses';

  // Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  // Get workout questionnaire with fallback to test data
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
        print('Workout questionnaire found in Firebase');
        return QuestionnaireModel.fromFirestore(doc);
      } else {
        print('Workout questionnaire document does not exist in Firebase, using test data');
        return _getTestWorkoutQuestionnaire();
      }
    } catch (e) {
      print('Error getting workout questionnaire from Firebase: $e');
      print('Falling back to test questionnaire');
      return _getTestWorkoutQuestionnaire();
    }
  }

  // Test questionnaire data
  static QuestionnaireModel _getTestWorkoutQuestionnaire() {
    return QuestionnaireModel(
      title: 'Workout Plan Questionnaire',
      description: 'Help us create the perfect workout plan for you by answering a few questions about your fitness goals and preferences.',
      questions: [
        QuestionModel(
          id: 1,
          text: 'What is your primary fitness goal?',
          type: 'dropdown',
          options: [
            'Build Muscle',
            'Lose Weight',
            'Improve Cardiovascular Health',
            'Increase Strength',
            'Improve Flexibility',
            'Athletic Performance',
            'General Fitness'
          ],
          required: true,
        ),
        QuestionModel(
          id: 2,
          text: 'What is your current fitness level?',
          type: 'dropdown',
          options: [
            'Beginner (New to exercise)',
            'Intermediate (6+ months experience)',
            'Advanced (2+ years experience)',
            'Expert (5+ years experience)'
          ],
          required: true,
        ),
        QuestionModel(
          id: 3,
          text: 'How many days per week can you commit to working out?',
          type: 'dropdown',
          options: [
            '1-2 days',
            '3-4 days',
            '5-6 days',
            '7 days'
          ],
          required: true,
        ),
        QuestionModel(
          id: 4,
          text: 'How much time can you dedicate per workout session?',
          type: 'dropdown',
          options: [
            '15-30 minutes',
            '30-45 minutes',
            '45-60 minutes',
            '60+ minutes'
          ],
          required: true,
        ),
        QuestionModel(
          id: 5,
          text: 'Where do you prefer to work out?',
          type: 'multiple_choice',
          options: [
            'Campus Gym',
            'Home/Dorm Room',
            'Outdoors',
            'Local Gym',
            'Group Fitness Classes'
          ],
          required: true,
        ),
        QuestionModel(
          id: 6,
          text: 'What equipment do you have access to?',
          type: 'multiple_choice',
          options: [
            'No Equipment (Bodyweight only)',
            'Dumbbells',
            'Resistance Bands',
            'Pull-up Bar',
            'Full Gym Equipment',
            'Cardio Machines',
            'Yoga Mat'
          ],
          required: true,
        ),
        QuestionModel(
          id: 7,
          text: 'Do you have any injuries or physical limitations?',
          type: 'dropdown',
          options: ['No', 'Yes'],
          required: true,
          followUp: FollowUpQuestion(
            condition: 'Yes',
            text: 'Please describe your injuries or limitations so we can modify your workout plan accordingly.',
            type: 'open_ended',
          ),
        ),
        QuestionModel(
          id: 8,
          text: 'What types of exercises do you enjoy most?',
          type: 'multiple_choice',
          options: [
            'Weight Training',
            'Cardio (Running, Cycling)',
            'Yoga/Pilates',
            'Sports Activities',
            'High-Intensity Interval Training (HIIT)',
            'Swimming',
            'Dancing',
            'Martial Arts'
          ],
          required: false,
        ),
        QuestionModel(
          id: 9,
          text: 'What is your experience with weight training?',
          type: 'dropdown',
          options: [
            'Never done it',
            'Some experience',
            'Comfortable with basics',
            'Very experienced'
          ],
          required: true,
        ),
        QuestionModel(
          id: 10,
          text: 'Do you prefer structured workouts or flexible routines?',
          type: 'dropdown',
          options: [
            'Highly structured (specific exercises, sets, reps)',
            'Somewhat structured (general guidelines)',
            'Flexible (variety and options)',
            'Very flexible (minimal structure)'
          ],
          required: true,
        ),
      ],
    );
  }

  // Save questionnaire response with proper key conversion
  static Future<String?> saveQuestionnaireResponse(QuestionnaireResponse response) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated. Please log in first.');
      }

      print('Saving questionnaire response to Firebase...');
      final docRef = await _firestore
          .collection(questionnaireResponsesCollection)
          .add(response.toFirestore());
      
      print('Questionnaire response saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving questionnaire response to Firebase: $e');
      // Return a mock ID for testing
      return 'test_response_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Helper method to convert int-keyed answers to string-keyed for Firestore
  static Future<String?> saveQuestionnaireResponseFromIntKeys(
    String userId,
    String questionnaireType,
    Map<int, dynamic> intAnswers,
    Map<int, String> intFollowUpAnswers,
  ) async {
    final response = QuestionnaireResponse.fromIntKeys(
      id: '', // Will be set by Firestore
      userId: userId,
      questionnaireType: questionnaireType,
      intAnswers: intAnswers,
      intFollowUpAnswers: intFollowUpAnswers,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await saveQuestionnaireResponse(response);
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
      // In test mode, just log the error
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

  // Method to populate Firebase with sample data
  static Future<void> createSampleDataInFirebase() async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated. Please log in first.');
      }

      // Create workout questionnaire
      final workoutQuestionnaire = _getTestWorkoutQuestionnaire();
      await _firestore
          .collection(questionnaireCollection)
          .doc('workout')
          .set(workoutQuestionnaire.toFirestore());

      print('Sample workout questionnaire created in Firebase!');

      // Create nutrition questionnaire
      final nutritionQuestionnaire = {
        'title': 'Nutrition Plan Questionnaire',
        'description': 'Help us create a personalized nutrition plan that fits your lifestyle and dietary preferences.',
        'questions': [
          {
            'id': 1,
            'text': 'What is your primary nutrition goal?',
            'type': 'dropdown',
            'options': [
              'Weight Loss',
              'Weight Gain',
              'Muscle Building',
              'Maintain Current Weight',
              'Improve Energy Levels',
              'Better Overall Health'
            ],
            'required': true,
          },
          {
            'id': 2,
            'text': 'Do you have any dietary restrictions or allergies?',
            'type': 'multiple_choice',
            'options': [
              'None',
              'Vegetarian',
              'Vegan',
              'Gluten-Free',
              'Dairy-Free',
              'Nut Allergies',
              'Shellfish Allergy',
              'Other Food Allergies'
            ],
            'required': true,
          },
          {
            'id': 3,
            'text': 'How many meals do you typically eat per day?',
            'type': 'dropdown',
            'options': [
              '2 meals',
              '3 meals',
              '4-5 small meals',
              '6+ small meals'
            ],
            'required': true,
          },
          {
            'id': 4,
            'text': 'Do you have access to campus dining facilities?',
            'type': 'dropdown',
            'options': [
              'Yes, regularly',
              'Yes, occasionally',
              'No'
            ],
            'required': true,
          },
          {
            'id': 5,
            'text': 'How often do you cook your own meals?',
            'type': 'dropdown',
            'options': [
              'Never',
              'Rarely (1-2 times per week)',
              'Sometimes (3-4 times per week)',
              'Often (5-6 times per week)',
              'Always (daily)'
            ],
            'required': true,
          }
        ]
      };

      await _firestore
          .collection(questionnaireCollection)
          .doc('nutrition')
          .set(nutritionQuestionnaire);

      print('Sample nutrition questionnaire created in Firebase!');

    } catch (e) {
      print('Error creating sample questionnaire in Firebase: $e');
      rethrow;
    }
  }

  // Method to remove sample questionnaire
  static Future<void> removeSampleQuestionnaire(String questionnaireType) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated. Please log in first.');
      }

      await _firestore
          .collection(questionnaireCollection)
          .doc(questionnaireType)
          .delete();

      print('Sample $questionnaireType questionnaire removed from Firebase!');
    } catch (e) {
      print('Error removing sample questionnaire: $e');
      rethrow;
    }
  }

  // Method to remove all sample data
  static Future<void> removeAllSampleData() async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated. Please log in first.');
      }

      // Remove questionnaires
      await removeSampleQuestionnaire('workout');
      await removeSampleQuestionnaire('nutrition');

      print('All sample questionnaires removed from Firebase!');
    } catch (e) {
      print('Error removing all sample data: $e');
      rethrow;
    }
  }
}
