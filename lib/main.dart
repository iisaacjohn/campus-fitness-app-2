import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart'; // Import the generated file
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/home_dashboard.dart';
import 'screens/gym_traffic_prediction.dart';
import 'screens/nutrition_fitness_plans.dart';
import 'screens/progress_tracker.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/admin_setup_screen.dart';
import 'widgets/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
          // Use state.uri.queryParameters instead of state.queryParameters
          final userType = state.uri.queryParameters['userType'] ?? 'Regular User';
          return LoginScreen(userType: userType);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const AuthGuard(child: HomeDashboard()),
      ),
      GoRoute(
        path: '/gym-traffic',
        builder: (context, state) => const AuthGuard(child: GymTrafficPrediction()),
      ),
      GoRoute(
        path: '/nutrition-fitness',
        builder: (context, state) => const AuthGuard(child: NutritionFitnessPlans()),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const AuthGuard(child: ProgressTracker()),
      ),
      GoRoute(
        path: '/admin-setup',
        builder: (context, state) => const AdminSetupScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp.router(
        title: 'Campus Fitness App',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
