import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joblyx_front/services/app_localizations.dart';

void showAboutSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => const AboutWidget(),
  );
}

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
        left: 16.w,
        right: 16.w,
        top: 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Joblyx',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.secondary,
                fontSize: 20.sp,
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Center(
            child: Text('Version 1.0.0', style: theme.textTheme.bodyMedium),
          ),
          Divider(color: cs.onSurfaceVariant, thickness: 1.0),
          Text(
            t.t('settings.description'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            t.t('settings.about_description'),
            style: theme.textTheme.bodyMedium,
          ),
          Divider(color: cs.onSurfaceVariant, thickness: 1.0),
          Text(
            t.t('settings.social_networks'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Open Twitter link
                },
                child: Text(
                  'LinkedIn',
                  style: theme.textTheme.bodyMedium?.copyWith(
                   
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              GestureDetector(
                onTap: () {
                  // Open Twitter link
                },
                child: Text(
                  'GitHub',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: cs.onSurfaceVariant, thickness: 1.0),
          Center(
            child: Text(
              t.t('settings.copyright'),
              style: theme.textTheme.bodySmall,
            ),
          ),
          SizedBox(height: 15.h),
        ],
      ),
    );
  }
}
