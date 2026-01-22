import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:joblyx_front/providers/auth_service_provider.dart';
import 'package:joblyx_front/providers/supabase_provider.dart';
import 'package:joblyx_front/routers/routes.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/services/auth_exception.dart';
import 'package:joblyx_front/widgets/app_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LinkedInButton extends ConsumerStatefulWidget {
  const LinkedInButton({super.key});

  @override
  ConsumerState<LinkedInButton> createState() => _LinkedInButtonState();
}

class _LinkedInButtonState extends ConsumerState<LinkedInButton> {
  bool _isLoading = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleLinkedInLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Écoute les changements d'auth pour rediriger après OAuth
      _authSubscription?.cancel();
      _authSubscription = ref
          .read(supabaseProvider)
          .auth
          .onAuthStateChange
          .listen((data) {
            if (data.event == AuthChangeEvent.signedIn && mounted) {
              _authSubscription?.cancel();
              context.go(AppRoutes.home);
            }
          });

      await ref.read(authServiceProvider).signInWithLinkedIn();
    } on AuthFailure catch (e) {
      _authSubscription?.cancel();
      if (mounted) {
        AppSnackBar.showError(
          context,
          AppLocalizations.of(context).t('err.${e.code}'),
        );
      }
    } catch (e) {
      _authSubscription?.cancel();
      if (mounted) {
        final t = AppLocalizations.of(context);
        AppSnackBar.showError(context, t.t('err.unknown_error'));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(foregroundColor: cs.onSurface),
        onPressed: _isLoading ? null : _handleLinkedInLogin,
        icon: _isLoading
            ? SizedBox(
                width: 25.r,
                height: 25.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : SvgPicture.asset(
                'assets/images/linkedin_logo.svg',
                width: 24.r,
                height: 24.r,
              ),
        label: Text(
          t.t('login.continue_with_linkedin'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
