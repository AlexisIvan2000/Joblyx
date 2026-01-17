import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:joblyx_front/providers/auth_service_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/auth_exception.dart';
import 'package:joblyx_front/widgets/app_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void showConfirmEmailDialog(BuildContext context, WidgetRef ref, String email) {
  final theme = Theme.of(context);
  final t = AppLocalizations.of(context);
  final cs = theme.colorScheme;
  final controller = TextEditingController();
  final teal300 = const Color(0xFF4DB6AC);

  Future<void> verify() async {
    try {
      await ref
          .read(authServiceProvider)
          .verifyOTP(email, controller.text.trim(), OtpType.signup);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.t('code_verification.success_message'))),
        );
        context.go('/login');
      }
    } catch (e) {
      if (!context.mounted) return;
      if (e is AuthFailure) {
        AppSnackBar.showError(context, t.t('err.${e.code}'));
      } else {
        AppSnackBar.showError(context, t.t('err.unknown_error'));
      }
    }
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          t.t('code_verification.title'),
          style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurface),
        ),
        contentPadding: EdgeInsets.all(16.w),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          Column(
            children: [
              Text(
                t.t('code_verification.message'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: t.t('code_verification.code'),
                  prefixIcon: Icon(Icons.lock_outline, color: teal300),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp, letterSpacing: 8),
              ),
              SizedBox(height: 16.h),
              Center(
                child: TextButton(
                  onPressed: verify,
                  child: Text(
                    t.t('code_verification.verify'),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t.t('code_verification.small_message'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    
                  ),
                  GestureDetector(
                    onTap: () async {
                      await ref
                          .read(authServiceProvider)
                          .resendConfirmationEmail(email);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.t('code_verification.resent')),
                          ),
                        );
                      }
                    },
                    child: Text(
                      ' ${t.t('code_verification.resend_code')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    },
  );
}
