import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';

void showOAuthInfoSheet(BuildContext context, String field) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  showModalBottomSheet(
    backgroundColor: cs.surface,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.r),
      ),
    ),
    builder: (context) => OAuthInfoSheet(field: field),
  );
}

class OAuthInfoSheet extends StatelessWidget {
  final String field;

  const OAuthInfoSheet({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final t = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.all(24.w),
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
          SizedBox(height: 24.h),
          Icon(
            Icons.info_outline_rounded,
            size: 48.sp,
            color: cs.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            t.t('profil.oauth_info_title'),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            field == 'email'
                ? t.t('profil.oauth_email_message')
                : t.t('profil.oauth_password_message'),
            style: textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.t('profil.got_it')),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
