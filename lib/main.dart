import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/home_dashboard.dart';
import 'screens/gym_traffic_prediction.dart';
import 'screens/nutrition_fitness_plans.dart';
import 'screens/progress_tracker.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(CampusFitnessApp());
}

class CampusFitnessApp extends StatelessWidget {
  CampusFitnessApp({Key? key}) : super(key: key);

  // Router configuration
  final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final userType = state.uri.queryParameters['userType'] ?? 'Regular User';
          return LoginScreen(userType: userType);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeDashboard(),
      ),
      GoRoute(
        path: '/gym-traffic',
        builder: (context, state) => const GymTrafficPrediction(),
      ),
      GoRoute(
        path: '/nutrition-fitness',
        builder: (context, state) => const NutritionFitnessPlans(),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressTracker(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Fitness App',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
