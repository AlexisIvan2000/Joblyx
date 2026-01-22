import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:joblyx_front/routers/routes.dart';
import 'package:joblyx_front/screens/dashboard.dart';
import 'package:joblyx_front/screens/login.dart';
import 'package:joblyx_front/screens/menu/analysis.dart';
import 'package:joblyx_front/screens/menu/cv.dart';
import 'package:joblyx_front/screens/menu/home.dart';
import 'package:joblyx_front/screens/menu/profil.dart';
import 'package:joblyx_front/screens/onboarding_screen.dart';
import 'package:joblyx_front/screens/register.dart';
import 'package:joblyx_front/screens/settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

CustomTransitionPage<T> slideTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  redirect: (context, state) {
    final location = state.uri.toString();

    // Capture les deep links OAuth (joblyx://auth/callback ou /auth/callback)
    if (location.contains('auth/callback') || location.contains('code=')) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        return AppRoutes.home;
      }
      return AppRoutes.login;
    }
    return null;
  },
  errorBuilder: (context, state) {
    // Redirige vers home si l'utilisateur est connecté, sinon login
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GoRouter.of(context).go(AppRoutes.home);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GoRouter.of(context).go(AppRoutes.login);
      });
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  },
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (context, state) => slideTransition(
        context: context,
        state: state,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => slideTransition(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      pageBuilder: (context, state) => slideTransition(
        context: context,
        state: state,
        child: const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) => slideTransition(
        context: context,
        state: state,
        child: const SettingsScreen(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Dashboard(shell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (_, __) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.analysis,
              builder: (_, __) => const AnalysisScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.cv, builder: (_, __) => const CvScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, __) => const ProfilScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);