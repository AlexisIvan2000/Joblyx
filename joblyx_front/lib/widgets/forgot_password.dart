import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/providers/auth_service_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/services/auth/auth_exception.dart';
import 'package:joblyx_front/widgets/app_snackbar.dart';
import 'package:joblyx_front/widgets/reset_password.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void showPasswordResetDialog(
  BuildContext context,
  WidgetRef ref,
  String email,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PasswordResetDialog(ref: ref, initialEmail: email),
  );
}

class _PasswordResetDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String initialEmail;

  const _PasswordResetDialog({required this.ref, required this.initialEmail});

  @override
  ConsumerState<_PasswordResetDialog> createState() =>
      _PasswordResetDialogState();
}

class _PasswordResetDialogState extends ConsumerState<_PasswordResetDialog> {
  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  late final TextEditingController _emailController;
  late final TextEditingController _codeController;

  final _emailFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();

  AutovalidateMode _emailAutovalidateMode = AutovalidateMode.disabled;
  AutovalidateMode _codeAutovalidateMode = AutovalidateMode.disabled;

  bool _isLoading = false;
  bool _isResending = false;
  bool _isEmailSent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// Étape 1: Envoyer l'email de reset
  Future<void> _sendEmail() async {
    final isValid = _emailFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _emailAutovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    TextInput.finishAutofillContext();
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await widget.ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        final t = AppLocalizations.of(context);
        AppSnackBar.showSuccess(
          context,
          t.t('code_verification.send_message'),
          duration: const Duration(seconds: 3),
        );
        setState(() {
          _isEmailSent = true;
          _isLoading = false;
        });
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

  /// Renvoyer le code
  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      await widget.ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        final t = AppLocalizations.of(context);
        AppSnackBar.showSuccess(context, t.t('code_verification.resent'));
      }
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        AppSnackBar.showError(context, t.t('err.unknown_error'));
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  /// Étape 2: Vérifier le code OTP
  Future<void> _verifyCode() async {
    final isValid = _codeFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _codeAutovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await widget.ref.read(authServiceProvider).verifyOTP(
            _emailController.text.trim(),
            _codeController.text.trim(),
            OtpType.recovery,
          );

      if (mounted) {
        Navigator.of(context).pop();
       
        showResetPasswordConfirmDialog(context, widget.ref);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: cs.surface,
      title: Text(
        t.t('login.forgot_password_title'),
        style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurface),
      ),
      contentPadding: EdgeInsets.all(16.w),
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      content: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isEmailSent
            ? _buildCodeStep(theme, cs, t)
            : _buildEmailStep(theme, cs, t),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(t.t('login.cancel')),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: FilledButton(
                onPressed: _isLoading
                    ? null
                    : (_isEmailSent ? _verifyCode : _sendEmail),
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
                        _isEmailSent
                            ? t.t('login.verify')
                            : t.t('login.send'),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Étape 1: Formulaire email
  Widget _buildEmailStep(ThemeData theme, ColorScheme cs, AppLocalizations t) {
    return Form(
      key: _emailFormKey,
      autovalidateMode: _emailAutovalidateMode,
      child: Column(
        key: const ValueKey('email_step'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.t('login.forgot_password_message'),
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _emailController,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            onFieldSubmitted: (_) => _sendEmail(),
            decoration: InputDecoration(
              labelText: t.t('login.email'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.t('login.no_email');
              }
              if (!_emailRegex.hasMatch(value)) {
                return t.t('login.invalid_email');
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Étape 2: Formulaire code OTP
  Widget _buildCodeStep(ThemeData theme, ColorScheme cs, AppLocalizations t) {
    return Form(
      key: _codeFormKey,
      autovalidateMode: _codeAutovalidateMode,
      child: Column(
        key: const ValueKey('code_step'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.t('login.reset_password_message'),
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _codeController,
            enabled: !_isLoading,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onFieldSubmitted: (_) => _verifyCode(),
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
    );
  }
}
