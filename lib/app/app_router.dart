import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmanagement_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmanagement_app/features/auth/presentation/screens/login_screen.dart';
import 'package:taskmanagement_app/features/auth/presentation/screens/register_screen.dart';
import 'package:taskmanagement_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:taskmanagement_app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:taskmanagement_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:taskmanagement_app/features/profile/presentation/screens/change_password_screen.dart';
import 'package:taskmanagement_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:taskmanagement_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:taskmanagement_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:taskmanagement_app/features/tasks/presentation/screens/task_details_screen.dart';
import 'package:taskmanagement_app/features/tasks/presentation/screens/task_form_screen.dart';
import 'package:taskmanagement_app/features/tasks/presentation/screens/task_list_screen.dart';
import 'package:taskmanagement_app/shared/widgets/main_shell_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  AppRouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final status = authState.status;

    final isSplash = state.matchedLocation == '/splash';
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    // If still in initial state, remain on splash
    if (status == AuthStatus.initial) {
      return isSplash ? null : '/splash';
    }

    final isAuthenticated = status == AuthStatus.authenticated;

    // When on splash
    if (isSplash) {
      if (status == AuthStatus.loading) {
        return null;
      }
      return isAuthenticated ? '/dashboard' : '/login';
    }

    // Not logged in and trying to access protected route
    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    // Logged in and trying to access login/register
    if (isAuthenticated && isAuthRoute) {
      return '/dashboard';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<AppRouterNotifier>((ref) {
  return AppRouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TaskListScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/tasks/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskDetailsScreen(taskId: id);
        },
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskFormScreen(taskId: id);
        },
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
