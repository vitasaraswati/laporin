import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/providers/onboarding_provider.dart';
import 'package:laporin/screens/splash_screen.dart';
import 'package:laporin/screens/onboarding_screen.dart';
import 'package:laporin/screens/login_selection_screen.dart';
import 'package:laporin/screens/user_login_screen.dart';
import 'package:laporin/screens/admin_login_screen.dart';
import 'package:laporin/screens/register_screen.dart';
import 'package:laporin/screens/home_screen.dart';
import 'package:laporin/screens/admin/admin_home_screen.dart';
import 'package:laporin/screens/admin/user_management_screen.dart';
import 'package:laporin/screens/user/user_profile_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: authProvider,
    debugLogDiagnostics: false,
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) async {
      final location = state.matchedLocation;
      final isAuthenticated = authProvider.isAuthenticated;
      final isAdmin = authProvider.isAdmin;
      final isOnboardingComplete = await OnboardingProvider.isOnboardingComplete();

      // Public routes (accessible without authentication)
      final publicRoutes = ['/', '/onboarding', '/login', '/login/user', '/login/admin', '/register'];
      final isPublicRoute = publicRoutes.contains(location);

      // Allow splash screen to handle initial navigation
      if (location == '/') {
        return null;
      }

      // If authenticated, redirect away from auth screens to appropriate home
      if (isAuthenticated && (location == '/login' || location == '/login/user' || location == '/login/admin' || location == '/register')) {
        return isAdmin ? '/admin' : '/home';
      }

      // Admin-only routes protection
      if (location.startsWith('/admin') && !isAdmin) {
        if (isAuthenticated) {
          return '/home'; // Redirect non-admin users to user home
        }
        return '/login/admin'; // Redirect unauthenticated to admin login
      }

      // User-only routes protection
      if (location.startsWith('/home') || location.startsWith('/profile')) {
        if (isAdmin) {
          return '/admin'; // Redirect admin to admin panel
        }
        if (!isAuthenticated) {
          return '/login/user'; // Redirect unauthenticated to user login
        }
      }

      // If authenticated, allow access to protected routes
      if (isAuthenticated) {
        return null;
      }

      // Not authenticated - handle onboarding flow
      if (!isOnboardingComplete && location != '/onboarding') {
        return '/onboarding';
      }

      // Not authenticated - redirect to login for protected routes
      if (!isPublicRoute) {
        return '/login';
      }

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
        builder: (context, state) => const LoginSelectionScreen(),
      ),
      GoRoute(
        path: '/login/user',
        name: 'loginUser',
        builder: (context, state) => const UserLoginScreen(),
      ),
      GoRoute(
        path: '/login/admin',
        name: 'loginAdmin',
        builder: (context, state) => const AdminLoginScreen(),
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
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'adminUsers',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const UserProfileScreen(),
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
