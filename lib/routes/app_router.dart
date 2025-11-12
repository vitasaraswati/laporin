import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/providers/onboarding_provider.dart';
import 'package:laporin/screens/splash_screen.dart';
import 'package:laporin/screens/onboarding_screen.dart';
import 'package:laporin/screens/login_screen.dart';
import 'package:laporin/screens/register_screen.dart';
import 'package:laporin/screens/home_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: authProvider,
    debugLogDiagnostics: true,
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) async {
      final isAuthenticated = authProvider.isAuthenticated;
      final isOnboardingComplete = await OnboardingProvider.isOnboardingComplete();
      
      // Get current location
      final isGoingToSplash = state.matchedLocation == '/';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';
      final isGoingToHome = state.matchedLocation == '/home';

      // Splash screen logic
      if (isGoingToSplash) {
        return null; // Let splash screen handle navigation
      }

      // If user is authenticated, redirect to home
      if (isAuthenticated) {
        if (!isGoingToHome) {
          return '/home';
        }
        return null;
      }

      // If user is not authenticated and onboarding is not complete
      if (!isOnboardingComplete) {
        if (!isGoingToOnboarding && !isGoingToSplash) {
          return '/onboarding';
        }
        return null;
      }

      // If user is not authenticated and trying to access protected routes
      if (!isAuthenticated && isGoingToHome) {
        return '/login';
      }

      // Default: no redirect
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${state.error}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Kembali ke Login'),
            ),
          ],
        ),
      ),
    ),
  );
}
