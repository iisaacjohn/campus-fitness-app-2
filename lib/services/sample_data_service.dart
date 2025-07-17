import 'package:cloud_firestore/cloud_firestore.dart';

class SampleDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates sample questionnaire data in Firestore
  /// This should be run once to populate your database
  static Future<void> createSampleQuestionnaire() async {
    try {
      // Sample workout questionnaire
      final workoutQuestionnaire = {
        'title': 'Workout Plan Questionnaire',
        'description': 'Help us create the perfect workout plan for you by answering a few questions about your fitness goals and preferences.',
        'questions': [
          {
            'id': 1,
            'text': 'What is your primary fitness goal?',
            'type': 'dropdown',
            'options': [
              'Build Muscle',
              'Lose Weight',
              'Improve Cardiovascular Health',
              'Increase Strength',
              'Improve Flexibility',
              'Athletic Performance',
              'General Fitness'
            ],
            'required': true,
          },
          {
            'id': 2,
            'text': 'What is your current fitness level?',
            'type': 'dropdown',
            'options': [
              'Beginner (New to exercise)',
              'Intermediate (6+ months experience)',
              'Advanced (2+ years experience)',
              'Expert (5+ years experience)'
            ],
            'required': true,
          },
          {
            'id': 3,
            'text': 'How many days per week can you commit to working out?',
            'type': 'dropdown',
            'options': [
              '1-2 days',
              '3-4 days',
              '5-6 days',
              '7 days'
            ],
            'required': true,
          },
          {
            'id': 4,
            'text': 'How much time can you dedicate per workout session?',
            'type': 'dropdown',
            'options': [
              '15-30 minutes',
              '30-45 minutes',
              '45-60 minutes',
              '60+ minutes'
            ],
            'required': true,
          },
          {
            'id': 5,
            'text': 'Where do you prefer to work out?',
            'type': 'multiple_choice',
            'options': [
              'Campus Gym',
              'Home/Dorm Room',
              'Outdoors',
              'Local Gym',
              'Group Fitness Classes'
            ],
            'required': true,
          },
          {
            'id': 6,
            'text': 'What equipment do you have access to?',
            'type': 'multiple_choice',
            'options': [
              'No Equipment (Bodyweight only)',
              'Dumbbells',
              'Resistance Bands',
              'Pull-up Bar',
              'Full Gym Equipment',
              'Cardio Machines',
              'Yoga Mat'
            ],
            'required': true,
          },
          {
            'id': 7,
            'text': 'Do you have any injuries or physical limitations?',
            'type': 'dropdown',
            'options': [
              'No',
              'Yes'
            ],
            'required': true,
            'follow_up': {
              'condition': 'Yes',
              'text': 'Please describe your injuries or limitations so we can modify your workout plan accordingly.',
              'type': 'open_ended'
            }
          },
          {
            'id': 8,
            'text': 'What types of exercises do you enjoy most?',
            'type': 'multiple_choice',
            'options': [
              'Weight Training',
              'Cardio (Running, Cycling)',
              'Yoga/Pilates',
              'Sports Activities',
              'High-Intensity Interval Training (HIIT)',
              'Swimming',
              'Dancing',
              'Martial Arts'
            ],
            'required': false,
          },
          {
            'id': 9,
            'text': 'What is your experience with weight training?',
            'type': 'dropdown',
            'options': [
              'Never done it',
              'Some experience',
              'Comfortable with basics',
              'Very experienced'
            ],
            'required': true,
          },
          {
            'id': 10,
            'text': 'Do you prefer structured workouts or flexible routines?',
            'type': 'dropdown',
            'options': [
              'Highly structured (specific exercises, sets, reps)',
              'Somewhat structured (general guidelines)',
              'Flexible (variety and options)',
              'Very flexible (minimal structure)'
            ],
            'required': true,
          }
        ]
      };

      // Create the workout questionnaire document
      await _firestore
          .collection('questionnaire')
          .doc('workout')
          .set(workoutQuestionnaire);

      print('Sample workout questionnaire created successfully!');

      // You can also create a nutrition questionnaire
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
          .collection('questionnaire')
          .doc('nutrition')
          .set(nutritionQuestionnaire);

      print('Sample nutrition questionnaire created successfully!');

    } catch (e) {
      print('Error creating sample questionnaire: $e');
      rethrow;
    }
  }

  /// Creates sample gym traffic data
  static Future<void> createSampleGymTraffic() async {
    try {
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      
      for (String day in days) {
        for (int hour = 6; hour <= 22; hour++) {
          // Create realistic traffic patterns
          double trafficLevel;
          if (hour >= 6 && hour <= 9) {
            trafficLevel = 0.7; // Morning rush
          } else if (hour >= 17 && hour <= 20) {
            trafficLevel = 0.9; // Evening rush
          } else if (hour >= 12 && hour <= 14) {
            trafficLevel = 0.5; // Lunch time
          } else {
            trafficLevel = 0.3; // Off-peak
          }

          // Weekend adjustments
          if (day == 'Saturday' || day == 'Sunday') {
            if (hour >= 10 && hour <= 16) {
              trafficLevel = 0.6; // Weekend afternoon
            } else {
              trafficLevel = 0.2; // Weekend off-peak
            }
          }

          final gymTrafficData = {
            'gymId': 'campus_gym_main',
            'dayOfWeek': day,
            'hour': hour,
            'currentCapacity': (trafficLevel * 100).round(),
            'maxCapacity': 100,
            'trafficLevel': trafficLevel,
            'timestamp': Timestamp.now(),
            'metadata': {
              'location': 'Main Campus Gym',
              'updated_by': 'system'
            }
          };

          await _firestore
              .collection('gym_traffic')
              .add(gymTrafficData);
        }
      }

      print('Sample gym traffic data created successfully!');
    } catch (e) {
      print('Error creating sample gym traffic: $e');
      rethrow;
    }
  }
}
