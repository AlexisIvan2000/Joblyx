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

final appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
     path: AppRoutes.onboarding,
     builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
     path: AppRoutes.login,
     builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
     path: AppRoutes.register,
     builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
     path: AppRoutes.settings,
     builder: (_, __) => const SettingsScreen(),
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