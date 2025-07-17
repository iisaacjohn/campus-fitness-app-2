import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class NavigationHelper {
  /// Navigate to login with user type
  static void goToLogin(BuildContext context, String userType) {
    context.go('/login?userType=${Uri.encodeQueryComponent(userType)}');
  }
  
  /// Navigate to home dashboard
  static void goToHome(BuildContext context) {
    context.go('/home');
  }
  
  /// Navigate to gym traffic prediction
  static void goToGymTraffic(BuildContext context) {
    context.go('/gym-traffic');
  }
  
  /// Navigate to nutrition and fitness plans
  static void goToNutritionFitness(BuildContext context) {
    context.go('/nutrition-fitness');
  }
  
  /// Navigate to progress tracker
  static void goToProgress(BuildContext context) {
    context.go('/progress');
  }
  
  /// Go back to previous screen or home if no previous screen
  static void goBackOrHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }
  
  /// Extract query parameter from GoRouterState
  static String getQueryParameter(GoRouterState state, String key, [String defaultValue = '']) {
    return state.uri.queryParameters[key] ?? defaultValue;
  }
}
