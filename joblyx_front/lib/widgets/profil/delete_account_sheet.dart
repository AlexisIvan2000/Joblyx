import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:joblyx_front/providers/user_provider.dart';
import 'package:joblyx_front/services/app_localizations.dart';

void showDeleteAccountSheet(BuildContext context) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  showModalBottomSheet(
    backgroundColor: cs.surface,
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.r),
      ),
    ),
    builder: (context) => const DeleteAccountSheet(),
  );
}

class DeleteAccountSheet extends ConsumerStatefulWidget {
  const DeleteAccountSheet({super.key});

  @override
  ConsumerState<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<DeleteAccountSheet> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final t = AppLocalizations.of(context);
    // final userAsync = ref.watch(userProvider);
    // final userEmail = userAsync.valueOrNull?.email ?? '';

    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.w,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Icon(
              Icons.warning_amber_rounded,
              size: 48.sp,
              color: cs.error,
            ),
            SizedBox(height: 16.h),
            Text(
              t.t('profil.delete_account_title'),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              t.t('profil.delete_account_message'),
              style: textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: t.t('profil.delete_account_email_hint'),
                // hintText: userEmail,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.t('login.no_email');
                }
                // if (value != userEmail) {
                //   return t.t('profil.delete_account_email_mismatch');
                // }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.t('settings.cancel')),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.error,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Implement delete account logic
                        Navigator.pop(context);
                      }
                    },
                    child: Text(t.t('profil.delete_account_confirm')),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
