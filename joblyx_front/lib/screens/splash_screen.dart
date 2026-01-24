import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:joblyx_front/models/user_model.dart';
import 'package:joblyx_front/providers/user_provider.dart';
import 'package:joblyx_front/routers/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      // Pas connecté → onboarding
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && !_hasNavigated) {
        _hasNavigated = true;
        context.go(AppRoutes.onboarding);
      }
    }
    // Si connecté, le listener dans build() gère la navigation
  }

  void _navigateToHome() {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      context.go(AppRoutes.home);
    }
  }

  void _navigateToLogin() {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Écoute le userProvider pour naviguer quand les données sont chargées
    ref.listen<AsyncValue<UserModel?>>(userProvider, (previous, next) {
      next.when(
        data: (user) => _navigateToHome(),
        loading: () {}, // Reste sur splash
        error: (_, __) => _navigateToLogin(),
      );
    });

    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joblyx',
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 90.h),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
