import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/providers/auth_service_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/services/auth/auth_exception.dart';
import 'package:joblyx_front/widgets/app_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void showChangeEmailSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => const ChangeEmailSheet(),
  );
}

class ChangeEmailSheet extends ConsumerStatefulWidget {
  const ChangeEmailSheet({super.key});

  @override
  ConsumerState<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends ConsumerState<ChangeEmailSheet> {
  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  final _emailFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _codeController = TextEditingController();

  AutovalidateMode _emailAutovalidateMode = AutovalidateMode.disabled;
  AutovalidateMode _codeAutovalidateMode = AutovalidateMode.disabled;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isResending = false;
  bool _isCodeStep = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _newEmailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// Étape 1: Envoyer la demande de changement d'email
  Future<void> _submitEmail() async {
    final isValid = _emailFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _emailAutovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    TextInput.finishAutofillContext();
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).changeEmail(
            _passwordController.text,
            _newEmailController.text.trim(),
          );

      if (mounted) {
        final t = AppLocalizations.of(context);
        AppSnackBar.showSuccess(
          context,
          t.t('code_verification.send_message'),
          duration: const Duration(seconds: 3),
        );
        setState(() {
          _isCodeStep = true;
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

  /// Renvoyer le code de confirmation
  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      await ref
          .read(authServiceProvider)
          .resendEmailChangeConfirmation(_newEmailController.text.trim());

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

  /// Étape 2: Vérifier le code OTP
  Future<void> _verifyCode() async {
    final isValid = _codeFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _codeAutovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).verifyOTP(
            _newEmailController.text.trim(),
            _codeController.text.trim(),
            OtpType.emailChange,
          );

      if (mounted) {
        final t = AppLocalizations.of(context);
        AppSnackBar.showSuccess(
          context,
          t.t('code_verification.success_message'),
          duration: const Duration(seconds: 3),
        );
        Navigator.of(context).pop();
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
        left: 16.w,
        right: 16.w,
        top: 16.h,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isCodeStep
            ? _buildCodeStep(theme, cs, t)
            : _buildEmailStep(theme, cs, t),
      ),
    );
  }

  /// Étape 1: Formulaire mot de passe + nouvel email
  Widget _buildEmailStep(ThemeData theme, ColorScheme cs, AppLocalizations t) {
    return Form(
      key: _emailFormKey,
      autovalidateMode: _emailAutovalidateMode,
      child: Column(
        key: const ValueKey('email_step'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.t('profil.change_email_title'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            t.t('profil.change_email_message'),
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            enabled: !_isLoading,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: t.t('profil.your_password'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.t('login.no_password');
              }
              if (value.length < 6) {
                return t.t('login.invalid_password');
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _newEmailController,
            enabled: !_isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitEmail(),
            decoration: InputDecoration(
              labelText: t.t('profil.new_email'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.t('register.no_email');
              }
              if (!_emailRegex.hasMatch(value)) {
                return t.t('register.invalid_email');
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: FilledButton(
              onPressed: _isLoading ? null : _submitEmail,
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
                      t.t('profil.confirm'),
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Étape 2: Formulaire code de vérification
  Widget _buildCodeStep(ThemeData theme, ColorScheme cs, AppLocalizations t) {
    return Form(
      key: _codeFormKey,
      autovalidateMode: _codeAutovalidateMode,
      child: Column(
        key: const ValueKey('code_step'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.t('code_verification.title'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            t.t('code_verification.message'),
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
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
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: FilledButton(
              onPressed: _isLoading ? null : _verifyCode,
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
      ),
    );
  }
}
