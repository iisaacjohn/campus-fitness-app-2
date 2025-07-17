import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/gym_traffic_model.dart';
import '../models/workout_plan_model.dart';
import '../models/progress_model.dart';
import '../models/questionnaire_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String gymTrafficCollection = 'gym_traffic';
  static const String workoutPlansCollection = 'workout_plans';
  static const String progressCollection = 'progress';
  static const String questionnaireCollection = 'questionnaire';
  static const String questionnaireResponsesCollection = 'questionnaire_responses';

  // User Management
  static Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection(usersCollection).doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  static Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.id).set(user.toFirestore());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  static Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.id).update(user.toFirestore());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Gym Traffic Management
  static Stream<List<GymTrafficModel>> getGymTrafficStream(String dayOfWeek) {
    return _firestore
        .collection(gymTrafficCollection)
        .where('dayOfWeek', isEqualTo: dayOfWeek)
        .orderBy('hour')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GymTrafficModel.fromFirestore(doc))
            .toList());
  }

  static Future<List<GymTrafficModel>> getGymTrafficForDay(String dayOfWeek) async {
    try {
      final querySnapshot = await _firestore
          .collection(gymTrafficCollection)
          .where('dayOfWeek', isEqualTo: dayOfWeek)
          .orderBy('hour')
          .get();

      return querySnapshot.docs
          .map((doc) => GymTrafficModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting gym traffic: $e');
      return [];
    }
  }

  static Future<GymTrafficModel?> getCurrentGymTraffic() async {
    try {
      final now = DateTime.now();
      final dayOfWeek = _getDayOfWeek(now.weekday);
      final hour = now.hour;

      final querySnapshot = await _firestore
          .collection(gymTrafficCollection)
          .where('dayOfWeek', isEqualTo: dayOfWeek)
          .where('hour', isEqualTo: hour)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return GymTrafficModel.fromFirestore(querySnapshot.docs.first);
      }
    } catch (e) {
      print('Error getting current gym traffic: $e');
    }
    return null;
  }

  // Workout Plans Management
  static Future<List<WorkoutPlanModel>> getUserWorkoutPlans(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(workoutPlansCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => WorkoutPlanModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting workout plans: $e');
      return [];
    }
  }

  static Future<String> createWorkoutPlan(WorkoutPlanModel workoutPlan) async {
    try {
      final docRef = await _firestore.collection(workoutPlansCollection).add(workoutPlan.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating workout plan: $e');
      rethrow;
    }
  }

  static Future<void> updateWorkoutPlan(WorkoutPlanModel workoutPlan) async {
    try {
      await _firestore.collection(workoutPlansCollection).doc(workoutPlan.id).update(workoutPlan.toFirestore());
    } catch (e) {
      print('Error updating workout plan: $e');
      rethrow;
    }
  }

  // Progress Management
  static Future<List<ProgressModel>> getUserProgress(String userId, {int? limitDays}) async {
    try {
      Query query = _firestore
          .collection(progressCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true);

      if (limitDays != null) {
        final startDate = DateTime.now().subtract(Duration(days: limitDays));
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ProgressModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user progress: $e');
      return [];
    }
  }

  static Future<void> addProgress(ProgressModel progress) async {
    try {
      await _firestore.collection(progressCollection).add(progress.toFirestore());
    } catch (e) {
      print('Error adding progress: $e');
      rethrow;
    }
  }

  static Stream<List<ProgressModel>> getUserProgressStream(String userId) {
    return _firestore
        .collection(progressCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(30) // Last 30 entries
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProgressModel.fromFirestore(doc))
            .toList());
  }

  // Helper Methods
  static String _getDayOfWeek(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }

  // Analytics Methods
  static Future<Map<String, int>> getWeeklyWorkoutStats(String userId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final querySnapshot = await _firestore
          .collection(progressCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
          .get();

      Map<String, int> stats = {
        'Monday': 0, 'Tuesday': 0, 'Wednesday': 0, 'Thursday': 0,
        'Friday': 0, 'Saturday': 0, 'Sunday': 0
      };

      for (var doc in querySnapshot.docs) {
        final progress = ProgressModel.fromFirestore(doc);
        final dayName = _getDayOfWeek(progress.date.weekday);
        stats[dayName] = (stats[dayName] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Error getting weekly workout stats: $e');
      return {};
    }
  }
}
