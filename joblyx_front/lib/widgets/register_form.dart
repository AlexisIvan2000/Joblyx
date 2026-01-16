import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/providers/auth_service_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/services/auth_exception.dart';
import 'package:joblyx_front/widgets/confirm_email.dart';
import 'app_snackbar.dart';


class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
 
  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    TextInput.finishAutofillContext();
    FocusScope.of(context).unfocus();
    try{
      setState(() {
        _isLoading = true;
      });
      await ref.read(authServiceProvider).registerUser(
        _emailController.text.trim(),
        _passwordController.text,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );
      if (!mounted) return;
      showConfirmEmailDialog(context, ref, _emailController.text.trim());
    } catch (e) {
      final t = AppLocalizations.of(context);
      if (e is AuthFailure) {
        AppSnackBar.showError(context, t.t('err.${e.code}'));
      } else {
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
    final cs = Theme.of(context).colorScheme;

    return AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          children: [
            TextFormField(
              controller: _firstNameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.givenName],
              decoration: InputDecoration(
                labelText: t.t('register.first_name'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0.r)),
                ),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? t.t('register.no_first_name')
                  : null,
            ),
            SizedBox(height: 13.h),
            TextFormField(
              controller: _lastNameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.familyName],
              decoration: InputDecoration(
                labelText: t.t('register.last_name'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0.r)),
                ),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? t.t('register.no_last_name')
                  : null,
            ),
            SizedBox(height: 13.h),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                labelText: t.t('register.email'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0.r)),
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
            SizedBox(height: 13.h),
            TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: t.t('register.password'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0.r)),
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
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Text(
                        t.t('register.sign_up'),
                        style: const TextStyle(fontSize: 16),
                      ),
                
              ),
            ),
            SizedBox(height: 13.h),
             Row(
              children: [
                Expanded(
                  child: Divider(color: cs.outlineVariant, thickness: 1.0),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                  child: Text(
                    t.t('login.or'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: Divider(color: Colors.grey[400], thickness: 1.0),
                ),
              ],
            ),
            SizedBox(height: 13.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cs.outlineVariant),
                  backgroundColor: cs.surface,
                  foregroundColor: cs.surface,
                ),
                onPressed: () {},
                label: Text(
                  t.t('login.continue_with_linkedin'),
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                icon: Image.asset(
                  'assets/images/linkeldin_logo.png',
                  height: 24.h,
                  width: 24.w,
                ),
              ),
            ),
            SizedBox(height: 13.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t.t('register.have_account'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(width: 3.w),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Text(
                    t.t('register.sign_in'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
