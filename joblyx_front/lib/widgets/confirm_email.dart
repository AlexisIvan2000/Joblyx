import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:joblyx_front/providers/auth_service_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/services/auth_exception.dart';
import 'package:joblyx_front/widgets/app_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void showConfirmEmailDialog(BuildContext context, WidgetRef ref, String email) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ConfirmEmailDialog(ref: ref, email: email),
  );
}

class _ConfirmEmailDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String email;

  const _ConfirmEmailDialog({required this.ref, required this.email});

  @override
  ConsumerState<_ConfirmEmailDialog> createState() => _ConfirmEmailDialogState();
}

class _ConfirmEmailDialogState extends ConsumerState<_ConfirmEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await widget.ref.read(authServiceProvider).verifyOTP(
            widget.email,
            _codeController.text.trim(),
            OtpType.signup,
          );

      if (mounted) {
        final t = AppLocalizations.of(context);
        Navigator.of(context).pop();
        AppSnackBar.showSuccess(
          context,
          t.t('code_verification.success_message'),
          duration: const Duration(seconds: 3),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        if (e is AuthFailure) {
          AppSnackBar.showError(context, t.t('err.${e.code}'));
        } else {
          AppSnackBar.showError(context, t.t('err.unknown_error'));
        }
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      await widget.ref
          .read(authServiceProvider)
          .resendConfirmationEmail(widget.email);

      if (mounted) {
        final t = AppLocalizations.of(context);
        AppSnackBar.showSuccess(context, t.t('code_verification.resent'));
      }
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        if (e is AuthFailure) {
          AppSnackBar.showError(context, t.t('err.${e.code}'));
        } else {
          AppSnackBar.showError(context, t.t('err.unknown_error'));
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: cs.surface,
      title: Text(
        t.t('code_verification.title'),
        style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurface),
      ),
      contentPadding: EdgeInsets.all(16.w),
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      content: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.t('code_verification.message'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _codeController,
              enabled: !_isLoading,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onFieldSubmitted: (_) => _verify(),
              decoration: InputDecoration(
                labelText: t.t('code_verification.code'),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.t('code_verification.no_code');
                }
                if (value.length != 6) {
                  return t.t('code_verification.invalid_code');
                }
                return null;
              },
            ),
            SizedBox(height: 12.h),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  t.t('code_verification.small_message'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: (_isResending || _isLoading) ? null : _resendCode,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: _isResending
                      ? SizedBox(
                          height: 12.h,
                          width: 12.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        )
                      : Text(
                          t.t('code_verification.resend_code'),
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
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: FilledButton(
            onPressed: _isLoading ? null : _verify,
            child: _isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onPrimary,
                    ),
                  )
                : Text(
                    t.t('code_verification.verify'),
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }
}
