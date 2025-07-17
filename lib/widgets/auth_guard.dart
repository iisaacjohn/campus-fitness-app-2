import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../widgets/loading_animation.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  
  const AuthGuard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        // Show loading while checking authentication
        if (appProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: LoadingAnimation(),
            ),
          );
        }
        
        // If user is not authenticated, redirect to landing page
        if (appProvider.currentUser == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/');
          });
          return const Scaffold(
            body: Center(
              child: LoadingAnimation(),
            ),
          );
        }
        
        // User is authenticated, show the protected content
        return child;
      },
    );
  }
}
