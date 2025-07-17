import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/gym_traffic_model.dart';
import '../models/workout_plan_model.dart';
import '../models/progress_model.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

class AppProvider extends ChangeNotifier {
  UserModel? _currentUser;
  List<GymTrafficModel> _gymTrafficData = [];
  List<WorkoutPlanModel> _workoutPlans = [];
  List<ProgressModel> _progressData = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<GymTrafficModel> get gymTrafficData => _gymTrafficData;
  List<WorkoutPlanModel> get workoutPlans => _workoutPlans;
  List<ProgressModel> get progressData => _progressData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AppProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    AuthService.authStateChanges.listen((User? user) {
      if (user != null) {
        _loadUserData();
      } else {
        _currentUser = null;
        _clearData();
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    _setLoading(true);
    try {
      _currentUser = await FirebaseService.getCurrentUser();
      if (_currentUser != null) {
        await _loadWorkoutPlans();
        await _loadProgressData();
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Don't show error for missing data, just log it
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGymTrafficData(String dayOfWeek) async {
    _setLoading(true);
    try {
      _gymTrafficData = await FirebaseService.getGymTrafficForDay(dayOfWeek);
      
      // If no data found, create mock data
      if (_gymTrafficData.isEmpty) {
        _gymTrafficData = _createMockGymTrafficData(dayOfWeek);
      }
    } catch (e) {
      print('Error loading gym traffic data: $e');
      // Fallback to mock data
      _gymTrafficData = _createMockGymTrafficData(dayOfWeek);
    } finally {
      _setLoading(false);
    }
  }

  List<GymTrafficModel> _createMockGymTrafficData(String dayOfWeek) {
    return List.generate(17, (index) {
      final hour = index + 6; // 6 AM to 10 PM
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
      
      return GymTrafficModel(
        id: 'traffic_${hour}',
        gymId: 'campus_gym_main',
        dayOfWeek: dayOfWeek,
        hour: hour,
        currentCapacity: (trafficLevel * 100).round(),
        maxCapacity: 100,
        trafficLevel: trafficLevel,
        timestamp: DateTime.now(),
      );
    });
  }

  Future<void> _loadWorkoutPlans() async {
    if (_currentUser == null) return;
    
    try {
      _workoutPlans = await FirebaseService.getUserWorkoutPlans(_currentUser!.id);
    } catch (e) {
      print('Error loading workout plans: $e');
      // Don't set error, just log it
    }
  }

  Future<void> _loadProgressData() async {
    if (_currentUser == null) return;
    
    try {
      _progressData = await FirebaseService.getUserProgress(_currentUser!.id, limitDays: 30);
    } catch (e) {
      print('Error loading progress data: $e');
      // Don't set error, just log it
    }
  }

  Future<void> addWorkoutPlan(WorkoutPlanModel workoutPlan) async {
    try {
      await FirebaseService.createWorkoutPlan(workoutPlan);
      await _loadWorkoutPlans();
    } catch (e) {
      _setError('Failed to add workout plan: $e');
    }
  }

  Future<void> addProgress(ProgressModel progress) async {
    try {
      await FirebaseService.addProgress(progress);
      await _loadProgressData();
    } catch (e) {
      _setError('Failed to add progress: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await AuthService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      _setError('Sign in failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, String name, String userType) async {
    _setLoading(true);
    try {
      await AuthService.createUserWithEmailAndPassword(email, password, name, userType);
    } catch (e) {
      _setError('Sign up failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await AuthService.signOut();
    } catch (e) {
      _setError('Sign out failed: $e');
    }
  }

  void _clearData() {
    _gymTrafficData = [];
    _workoutPlans = [];
    _progressData = [];
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
