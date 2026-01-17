import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/providers/auth_service_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:joblyx_front/services/auth_exception.dart';
import 'package:joblyx_front/widgets/app_snackbar.dart';

void showResetPasswordConfirmDialog(
  BuildContext context,
  WidgetRef ref,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _NewPasswordDialog(ref: ref),
  );
}

class _NewPasswordDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _NewPasswordDialog({required this.ref});

  @override
  ConsumerState<_NewPasswordDialog> createState() => _NewPasswordDialogState();
}

class _NewPasswordDialogState extends ConsumerState<_NewPasswordDialog> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitNewPassword() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await widget.ref
          .read(authServiceProvider)
          .updatePassword(_passwordController.text);

      if (mounted) {
        Navigator.of(context).pop();
        final t = AppLocalizations.of(context);
        AppSnackBar.showSuccess(context, t.t('login.password_updated'));
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
        t.t('login.new_password_title'),
        style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurface),
      ),
      contentPadding: EdgeInsets.all(16.w),
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      content: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: cs.primary,
                size: 48.r,
              ),
              SizedBox(height: 8.h),
              Text(
                t.t('login.code_verified'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _passwordController,
                enabled: !_isLoading,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: t.t('login.new_password'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.t('register.no_password');
                  }
                  if (value.length < 6) {
                    return t.t('register.invalid_password');
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _confirmPasswordController,
                enabled: !_isLoading,
                obscureText: !_isConfirmPasswordVisible,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitNewPassword(),
                decoration: InputDecoration(
                  labelText: t.t('login.confirm_password'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.t('login.no_confirm_password');
                  }
                  if (value != _passwordController.text) {
                    return t.t('login.passwords_not_match');
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
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
                onPressed: _isLoading ? null : _submitNewPassword,
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : Text(t.t('login.confirm')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
