import 'package:flutter/material.dart';

/// Helper class to manage asset paths
class AssetHelper {
  // Image paths
  static const String gymBackgroundImage = 'assets/images/gym_background.jpg';
  
  // Icon paths
  static const String dumbbellIcon = 'assets/icons/dumbbell.png';
  static const String nutritionIcon = 'assets/icons/nutrition.png';
  static const String progressIcon = 'assets/icons/progress.png';
  static const String gymIcon = 'assets/icons/gym.png';
  
  // Animation paths
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  
  /// Returns a placeholder image with the specified dimensions
  static String getPlaceholderImage(int width, int height) {
    return 'https://via.placeholder.com/${width}x$height}';
  }
}
